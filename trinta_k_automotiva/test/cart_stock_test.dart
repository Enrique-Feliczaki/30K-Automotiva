import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/main.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final cart = CartStore.instance;
  final catalog = ProductStore.instance;
  late List<CartItem> savedItems;
  late StoreProduct product;
  late bool wasCompany;

  void clearCart() {
    while (cart.items.isNotEmpty) {
      cart.remove(0);
    }
  }

  CartItem item(int quantity, {String? name}) => CartItem(
    productId: product.id,
    name: name ?? product.name,
    category: product.category,
    price: product.price,
    quantity: quantity,
    icon: product.icon,
  );

  setUp(() {
    savedItems = cart.items;
    clearCart();
    product = catalog.products.firstWhere((p) => p.id == 'cera-liquida');
    catalog.setStock(product.id, 3);
    wasCompany = CustomerProfile.instance.isCompany;
    CustomerProfile.instance.isCompany = false;
  });

  tearDown(() {
    clearCart();
    catalog.update(product);
    for (final entry in savedItems) {
      cart.add(entry);
    }
    CustomerProfile.instance.isCompany = wasCompany;
  });

  test('rejeita adicao acima do estoque sem alterar o carrinho', () {
    expect(cart.add(item(4)), isFalse);
    expect(cart.items, isEmpty);
    expect(cart.add(item(2)), isTrue);
    expect(cart.add(item(2)), isFalse);
    expect(cart.unitCount, 2);
    expect(cart.add(item(1)), isTrue);
    expect(cart.unitCount, 3);
  });

  test('bloqueia aumentos acima do estoque e permite diminuir', () {
    cart.add(item(3));
    cart.changeQuantity(0, 1);
    expect(cart.unitCount, 3);
    expect(cart.canIncrease(cart.items.single), isFalse);
    cart.changeQuantity(0, -1);
    expect(cart.canIncrease(cart.items.single), isTrue);
    cart.changeQuantity(0, 2);
    expect(cart.unitCount, 2);
  });

  test('produto renomeado continua com o mesmo limite por identificador', () {
    cart.add(item(2));
    catalog.update(product.copyWith(name: 'Novo nome', stock: 3));
    expect(cart.add(item(2, name: 'Novo nome')), isFalse);
    expect(cart.add(item(1, name: 'Novo nome')), isTrue);
    expect(cart.items, hasLength(1));
    expect(cart.unitCount, 3);
  });

  test('reduzir estoque ajusta a quantidade e esgotar remove o item', () {
    cart.add(item(3));
    catalog.setStock(product.id, 1);
    expect(cart.unitCount, 1);
    catalog.setStock(product.id, 0);
    expect(cart.items, isEmpty);
    expect(cart.add(item(1)), isFalse);
  });

  test('produto removido do catalogo nao pode continuar na sacola', () {
    cart.add(item(2));
    catalog.remove(product.id);
    expect(cart.items, isEmpty);
    expect(cart.add(item(1)), isFalse);
    catalog.add(product);
  });

  Future<void> openDetails(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ProductDetailsScreen(product: product, isAdmin: false),
                ),
              ),
              child: const Text('Abrir produto'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir produto'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'seleciona varias unidades e permanece no produto apos adicionar',
    (tester) async {
      await openDetails(tester);
      final increase = find.byKey(const ValueKey('product-quantity-increase'));
      await tester.ensureVisible(increase);
      await tester.tap(increase);
      await tester.pump();
      await tester.tap(increase);
      await tester.pump();
      expect(tester.widget<IconButton>(increase).onPressed, isNull);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('product-quantity')))
            .data,
        '3',
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Adicionar ao carrinho'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.byType(CartScreen), findsNothing);
      expect(find.text('Produto adicionado ao carrinho'), findsOneWidget);
      expect(cart.unitCount, 3);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Adicionar ao carrinho'),
            )
            .onPressed,
        isNull,
      );
      cart.changeQuantity(0, -1);
      await tester.pump();
      expect(cart.unitCount, 2);
      // Wait for the confirmation snackbar to stop covering the button.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Adicionar ao carrinho'),
      );
      await tester.pumpAndSettle();
      expect(cart.unitCount, 3);
      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.byType(CartScreen), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.text('Abrir produto'), findsOneWidget);
    },
  );

  testWidgets('descricao aparece ao abrir os detalhes do produto', (
    tester,
  ) async {
    expect(product.description, isNotEmpty);
    await openDetails(tester);
    expect(find.text('Descrição'), findsOneWidget);
    expect(find.text(product.description), findsOneWidget);
  });

  testWidgets(
    'selecao desconta unidades ja adicionadas e acompanha o estoque',
    (tester) async {
      cart.add(item(2));
      await openDetails(tester);
      final increase = find.byKey(const ValueKey('product-quantity-increase'));
      expect(tester.widget<IconButton>(increase).onPressed, isNull);
      catalog.setStock(product.id, 5);
      await tester.pump();
      expect(tester.widget<IconButton>(increase).onPressed, isNotNull);
      catalog.setStock(product.id, 2);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Adicionar ao carrinho'),
            )
            .onPressed,
        isNull,
      );
    },
  );
}
