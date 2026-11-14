import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/payment_screen.dart';

class _NavigationObserver extends NavigatorObserver {
  Route<dynamic>? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      lastPushedRoute = route;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  final navigationObserver = _NavigationObserver();
  final cart = CartStore.instance;
  final profile = CustomerProfile.instance;
  late List<CartItem> backup;
  late bool company;

  void clear() {
    while (cart.items.isNotEmpty) {
      cart.remove(cart.items.length - 1);
    }
  }

  void add({int quantity = 1, double price = 40}) {
    cart.add(CartItem(
      name: 'Produto QA Carrinho',
      category: 'Shampoos',
      price: price,
      quantity: quantity,
      icon: Icons.local_drink_outlined,
    ));
  }

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    navigationObserver.lastPushedRoute = null;
    await tester.pumpWidget(MaterialApp(
      home: const CartScreen(),
      navigatorObservers: [navigationObserver],
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
    backup = List<CartItem>.from(cart.items);
    company = profile.isCompany;
    profile.isCompany = false;
    clear();
  });

  tearDown(() {
    clear();
    for (final entry in backup) {
      cart.add(entry);
    }
    profile.isCompany = company;
  });

  testWidgets('QA-90 mostra sacola vazia', (tester) async {
    await open(tester);
    expect(find.text('Sua sacola está vazia'), findsOneWidget);
    expect(find.text('Voltar para a loja'), findsOneWidget);
    expect(find.text('Finalizar pedido'), findsNothing);
  });

  testWidgets('QA-91 exibe produto e quantidade', (tester) async {
    add(quantity: 2);
    await open(tester);
    expect(find.text('Produto QA Carrinho'), findsOneWidget);
    expect(find.text('2 itens'), findsOneWidget);
    expect(find.text('Finalizar pedido'), findsOneWidget);
  });

  testWidgets('QA-92 mostra subtotal de dois itens', (tester) async {
    add(quantity: 2, price: 12.50);
    await open(tester);
    expect(cart.subtotal, 25);
    expect(find.text('R\$ 25,00'), findsWidgets);
  });

  testWidgets('QA-93 aumenta quantidade pelo botao', (tester) async {
    add();
    await open(tester);
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(cart.unitCount, 2);
    expect(cart.subtotal, 80);
  });

  testWidgets('QA-94 diminui quantidade pelo botao', (tester) async {
    add(quantity: 3);
    await open(tester);
    await tester.tap(find.byIcon(Icons.remove).last);
    await tester.pump();
    expect(cart.unitCount, 2);
    expect(cart.subtotal, 80);
  });

  testWidgets('QA-95 remove item usando lixeira', (tester) async {
    add();
    await open(tester);
    await tester.tap(find.byTooltip('Remover produto'));
    await tester.pump();
    expect(cart.items, isEmpty);
    expect(find.text('Sua sacola está vazia'), findsOneWidget);
  });

  testWidgets('QA-96 mostra aviso ao aplicar cupom', (tester) async {
    add();
    await open(tester);
    await tester.ensureVisible(find.text('Aplicar'));
    await tester.tap(find.text('Aplicar'));
    await tester.pump();
    expect(find.text('Cupom indisponível para validação no momento.'), findsOneWidget);
  });

  testWidgets('QA-97 pessoa fisica consegue abrir checkout', (tester) async {
    add();
    await open(tester);
    final label = find.text('Finalizar pedido');
    await tester.ensureVisible(label);
    final action = find.ancestor(
      of: label,
      matching: find.byWidgetPredicate((widget) => widget is FilledButton),
    ).first;
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(navigationObserver.lastPushedRoute, isNotNull,
        reason: 'Finalizar pedido não abriu a rota de pagamento');
    expect(find.byType(PaymentScreen), findsOneWidget);
  });

  testWidgets('QA-98 pessoa juridica abaixo do minimo nao avanca', (tester) async {
    profile.isCompany = true;
    add(quantity: 1, price: 100);
    await open(tester);
    await tester.tap(find.text('Finalizar pedido'));
    await tester.pump();
    expect(find.byType(PaymentScreen), findsNothing);
    expect(find.textContaining('Pedido mínimo para pessoa jurídica'), findsOneWidget);
  });

  testWidgets('QA-99 pessoa juridica no minimo consegue avancar', (tester) async {
    profile.isCompany = true;
    add(quantity: 1, price: 2500);
    await open(tester);
    final label = find.text('Finalizar pedido');
    await tester.ensureVisible(label);
    final action = find.ancestor(
      of: label,
      matching: find.byWidgetPredicate((widget) => widget is FilledButton),
    ).first;
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(navigationObserver.lastPushedRoute, isNotNull,
        reason: 'Finalizar pedido não abriu a rota de pagamento');
    expect(find.byType(PaymentScreen), findsOneWidget);
  });
}
