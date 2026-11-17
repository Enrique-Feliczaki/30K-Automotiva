import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/local_persistence.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final cart = CartStore.instance;
  final products = ProductStore.instance;
  final profile = CustomerProfile.instance;
  late List<CartItem> savedCart;
  late List<StoreProduct> savedProducts;
  late Map<String, dynamic> savedProfile;
  late LocalPersistence? savedPersistence;

  const product = StoreProduct(
    id: 'produto-integracao-checkout',
    name: 'Shampoo de integração',
    category: 'Shampoos',
    sku: 'INT-CHECKOUT-001',
    price: 50,
    stock: 5,
    minimumStock: 1,
    icon: Icons.local_drink,
  );

  setUp(() {
    savedCart = cart.items;
    savedProducts = products.products;
    savedProfile = profile.toRecord();
    savedPersistence = LocalPersistence.active;
    LocalPersistence.active = null;
    products.restore([product]);
    cart.restore([
      const CartItem(
        productId: 'produto-integracao-checkout',
        name: 'Shampoo de integração',
        category: 'Shampoos',
        price: 50,
        quantity: 2,
        icon: Icons.local_drink,
      ),
    ]);
    profile.restore({'isCompany': false});
  });

  tearDown(() {
    LocalPersistence.active = savedPersistence;
    products.restore(savedProducts);
    cart.restore(savedCart);
    profile.restore(savedProfile);
  });

  testWidgets(
    'checkout atualiza estoque, perfil e carrinho pelo fluxo visual',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: CartScreen()));
      await tester.tap(find.text('Finalizar pedido'));
      await tester.pumpAndSettle();

      const address = [
        '85010-000',
        'PR',
        'Guarapuava',
        'Centro',
        'Rua de Teste',
        '100',
      ];
      for (var index = 0; index < address.length; index++) {
        await tester.enterText(
          find.byType(TextFormField).at(index),
          address[index],
        );
      }

      await tester.tap(find.text('Continuar para o Pix'));
      await tester.pumpAndSettle();

      expect(find.text('Tudo certo!'), findsOneWidget);
      expect(products.products.single.stock, 3);
      expect(cart.items, isEmpty);
      expect(profile.city, 'Guarapuava');
      expect(profile.postalCode, '85010-000');
    },
  );
}
