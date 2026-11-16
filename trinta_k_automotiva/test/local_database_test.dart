import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/local_accounts.dart';
import 'package:trinta_k_automotiva/local_database.dart';
import 'package:trinta_k_automotiva/local_persistence.dart';
import 'package:trinta_k_automotiva/product_store.dart';

class _FailingDatabase extends LocalDatabase {
  _FailingDatabase() : super(NativeDatabase.memory());
  bool failWrites = false;

  @override
  Future<void> save(LocalSnapshot snapshot) async {
    if (failWrites) throw StateError('Simulated disk failure');
    await super.save(snapshot);
  }
}

void main() {
  late Directory directory;
  late List<StoreProduct> originalProducts;
  late List<CartItem> originalCart;
  late List<LocalAccount> originalAccounts;
  late Map<String, dynamic> originalProfile;
  LocalPersistence? persistence;
  LocalDatabase? database;

  LocalAccount fixture(String email, String document) => LocalAccount(
    email: email,
    document: document,
    passwordHash: 'test-hash',
    salt: 'test-salt',
    iterations: 600000,
    profile: {
      'name': 'Cliente Local',
      'email': email,
      'document': document,
      'isCompany': false,
    },
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('30k-local-db-test-');
    originalProducts = ProductStore.instance.products;
    originalCart = CartStore.instance.items;
    originalAccounts = LocalAccounts.instance.accounts;
    originalProfile = CustomerProfile.instance.toRecord();
  });

  tearDown(() async {
    if (persistence != null) {
      await persistence!.close();
      persistence = null;
      database = null;
    } else {
      await database?.close();
      database = null;
    }
    ProductStore.instance.restore(originalProducts);
    CartStore.instance.restore(originalCart);
    LocalAccounts.instance.restore(originalAccounts);
    CustomerProfile.instance.restore(originalProfile);
    await directory.delete(recursive: true);
  });

  Future<CartItem> preparePurchase({LocalDatabase? target}) async {
    database =
        target ??
        LocalDatabase(
          NativeDatabase(File('${directory.path}/purchase.sqlite')),
        );
    final product = originalProducts.first.copyWith(stock: 7);
    final account = fixture('compra@example.com', '52998224725');
    await database!.save(
      LocalSnapshot(products: [product], accounts: [account], carts: {}),
    );
    persistence = LocalPersistence(database!);
    await persistence!.initialize();
    persistence!.switchCustomer(account.email);
    final item = CartItem(
      productId: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      quantity: 5,
      icon: product.icon,
    );
    CartStore.instance.add(item);
    await persistence!.flush();
    return item;
  }

  test(
    'compra de cinco unidades deixa duas no banco e limpa o carrinho',
    () async {
      final item = await preparePurchase();
      await persistence!.completePurchase([item]);
      expect(ProductStore.instance.products.single.stock, 2);
      expect(CartStore.instance.items, isEmpty);
      await persistence!.close();
      persistence = null;
      database = LocalDatabase(
        NativeDatabase(File('${directory.path}/purchase.sqlite')),
      );
      final snapshot = (await database!.load())!;
      expect(snapshot.products.single.stock, 2);
      expect(snapshot.carts['compra@example.com'], isEmpty);
    },
  );

  test('estoque insuficiente rejeita a compra sem desconto parcial', () async {
    final item = await preparePurchase();
    await expectLater(
      persistence!.completePurchase([item, item]),
      throwsStateError,
    );
    expect(ProductStore.instance.products.single.stock, 7);
    expect(CartStore.instance.unitCount, 5);
    expect((await database!.load())!.products.single.stock, 7);
  });

  test(
    'falha no banco preserva estoque e carrinho e permite tentar novamente',
    () async {
      final failing = _FailingDatabase();
      final item = await preparePurchase(target: failing);
      failing.failWrites = true;
      await expectLater(
        persistence!.completePurchase([item]),
        throwsStateError,
      );
      expect(ProductStore.instance.products.single.stock, 7);
      expect(CartStore.instance.unitCount, 5);
      final snapshot = (await database!.load())!;
      expect(snapshot.products.single.stock, 7);
      expect(snapshot.carts['compra@example.com']!.single.quantity, 5);
      failing.failWrites = false;
      await persistence!.completePurchase([item]);
      expect((await database!.load())!.products.single.stock, 2);
      expect(CartStore.instance.items, isEmpty);
    },
  );

  test(
    'arquivo SQLite preserva cadastro, foto, endereco e carrinho ao reabrir',
    () async {
      final path = File('${directory.path}/local.sqlite');
      database = LocalDatabase(NativeDatabase(path));
      expect(await database!.load(), isNull);
      final account = fixture('cliente@example.com', '52998224725');
      final product = originalProducts.first.copyWith(
        description: 'Descrição persistida do produto.',
        imageBytes: Uint8List.fromList([1, 2, 3, 255]),
      );
      final entry = CartItem(
        productId: product.id,
        name: product.name,
        category: product.category,
        price: product.price,
        quantity: 2,
        icon: product.icon,
      );
      await database!.save(
        LocalSnapshot(
          products: [product],
          accounts: [
            account.withProfile({
              ...account.profile,
              'street': 'Rua São José',
              'houseNumber': '10',
            }),
          ],
          carts: {
            account.email: [entry],
          },
        ),
      );
      await database!.close();
      database = LocalDatabase(NativeDatabase(path));
      final loaded = (await database!.load())!;
      expect(loaded.products.single.imageBytes, [1, 2, 3, 255]);
      expect(loaded.products.single.icon, product.icon);
      expect(loaded.products.single.stock, product.stock);
      expect(
        loaded.products.single.description,
        'Descrição persistida do produto.',
      );
      expect(loaded.accounts.single.profile['street'], 'Rua São José');
      expect(loaded.accounts.single.passwordHash, 'test-hash');
      expect(loaded.carts[account.email]!.single.quantity, 2);
    },
  );

  test(
    'falha de unicidade desfaz toda a transacao sem perder dados anteriores',
    () async {
      database = LocalDatabase(NativeDatabase.memory());
      final first = fixture('um@example.com', '52998224725');
      await database!.save(
        LocalSnapshot(products: originalProducts, accounts: [first], carts: {}),
      );
      await expectLater(
        database!.save(
          LocalSnapshot(
            products: [],
            accounts: [first, fixture('dois@example.com', first.document)],
            carts: {},
          ),
        ),
        throwsA(isA<Exception>()),
      );
      final loaded = (await database!.load())!;
      expect(loaded.accounts, hasLength(1));
      expect(loaded.products, hasLength(originalProducts.length));
    },
  );

  test(
    'gravacao automatica preserva estoque, endereco e carrinhos separados',
    () async {
      final path = File('${directory.path}/local.sqlite');
      database = LocalDatabase(NativeDatabase(path));
      final first = fixture('um@example.com', '52998224725');
      final second = fixture('dois@example.com', '11144477735');
      await database!.save(
        LocalSnapshot(
          products: originalProducts,
          accounts: [first, second],
          carts: {},
        ),
      );
      persistence = LocalPersistence(database!);
      await persistence!.initialize();
      persistence!.switchCustomer(first.email);
      final product = ProductStore.instance.products.first;
      CartStore.instance.add(
        CartItem(
          productId: product.id,
          name: product.name,
          category: product.category,
          price: product.price,
          quantity: 3,
          icon: product.icon,
        ),
      );
      CustomerProfile.instance.restore({
        ...first.profile,
        'postalCode': '01001-000',
        'street': 'Rua Local',
      });
      CustomerProfile.instance.save();
      persistence!.switchCustomer(second.email);
      expect(CartStore.instance.items, isEmpty);
      CartStore.instance.add(
        CartItem(
          productId: product.id,
          name: product.name,
          category: product.category,
          price: product.price,
          quantity: 1,
          icon: product.icon,
        ),
      );
      ProductStore.instance.setStock(product.id, 2);
      await persistence!.flush();
      await persistence!.close();
      persistence = null;
      database = LocalDatabase(NativeDatabase(path));
      persistence = LocalPersistence(database!);
      await persistence!.initialize();
      expect(ProductStore.instance.products.first.stock, 2);
      persistence!.switchCustomer(first.email);
      expect(CartStore.instance.unitCount, 2);
      expect(
        LocalAccounts.instance.accounts.first.profile['street'],
        'Rua Local',
      );
      persistence!.switchCustomer(second.email);
      expect(CartStore.instance.unitCount, 1);
      persistence!.switchCustomer(null);
      expect(CartStore.instance.items, isEmpty);
    },
  );

  test(
    'catalogo vazio salvo nao recebe novamente os produtos de demonstracao',
    () async {
      database = LocalDatabase(NativeDatabase.memory());
      await database!.save(
        LocalSnapshot(products: [], accounts: [], carts: {}),
      );
      persistence = LocalPersistence(database!);
      await persistence!.initialize();
      expect(ProductStore.instance.products, isEmpty);
      expect(CartStore.instance.items, isEmpty);
    },
  );

  test('falha de armazenamento fica visivel e pode ser recuperada', () async {
    final failing = _FailingDatabase();
    database = failing;
    persistence = LocalPersistence(failing);
    await persistence!.initialize();
    failing.failWrites = true;
    ProductStore.instance.setStock(originalProducts.first.id, 7);
    await expectLater(persistence!.flush(), throwsStateError);
    expect(persistence!.lastError, isNotNull);
    failing.failWrites = false;
    await persistence!.retry();
    expect(persistence!.lastError, isNull);
    expect((await database!.load())!.products.first.stock, 7);
  });

  test(
    'hash de senha permite entrar novamente depois de reabrir o banco',
    () async {
      final accounts = LocalAccounts();
      final first = await accounts.register(
        profile: {
          'name': 'Cliente',
          'email': 'cliente@example.com',
          'document': '52998224725',
          'isCompany': false,
        },
        password: 'senha-local-teste',
      );
      expect(first.passwordHash, isNot('senha-local-teste'));
      final path = File('${directory.path}/accounts.sqlite');
      database = LocalDatabase(NativeDatabase(path));
      await database!.save(
        LocalSnapshot(products: [], accounts: accounts.accounts, carts: {}),
      );
      final rows = await database!
          .customSelect('SELECT * FROM customers')
          .get();
      expect(
        rows.single.data.values.join(' '),
        isNot(contains('senha-local-teste')),
      );
      await database!.close();
      database = LocalDatabase(NativeDatabase(path));
      final restored = LocalAccounts()
        ..restore((await database!.load())!.accounts);
      expect(
        await restored.authenticate('CLIENTE@example.com', 'senha-local-teste'),
        isNotNull,
      );
      expect(
        await restored.authenticate('cliente@example.com', 'senha-errada'),
        isNull,
      );
      expect(
        restored.duplicateMessage('cliente@example.com', '11144477735'),
        contains('e-mail'),
      );
      expect(
        restored.duplicateMessage('outro@example.com', '52998224725'),
        contains('CPF'),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
