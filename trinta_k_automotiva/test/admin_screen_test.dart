import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/admin_screen.dart';
import 'package:trinta_k_automotiva/product_inventory_screen.dart';
import 'package:trinta_k_automotiva/product_store.dart';

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
  final store = ProductStore.instance;
  late List<StoreProduct> backup;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    navigationObserver.lastPushedRoute = null;
    await tester.pumpWidget(MaterialApp(
      home: const AdminScreen(),
      navigatorObservers: [navigationObserver],
    ));
    await tester.pumpAndSettle();
  }

  setUp(() => backup = List<StoreProduct>.from(store.products));

  tearDown(() {
    for (final product in List<StoreProduct>.from(store.products)) {
      store.remove(product.id);
    }
    for (final product in backup) {
      store.add(product);
    }
  });

  testWidgets('QA-108 painel administrativo mostra indicadores', (tester) async {
    await open(tester);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Gerencie sua loja'), findsOneWidget);
    expect(find.text('BAIXO ESTOQUE'), findsOneWidget);
    expect(find.text('ESGOTADOS'), findsOneWidget);
  });

  testWidgets('QA-109 lista produtos existentes', (tester) async {
    await open(tester);
    expect(find.text('PRODUTOS DO CATÁLOGO'), findsOneWidget);
    expect(find.text('${store.products.length} cadastrados'), findsOneWidget);
    expect(find.text(store.products.first.name), findsOneWidget);
  });

  testWidgets('QA-110 abre formulario de produto', (tester) async {
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pump();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Novo produto'), findsWidgets);
    expect(find.text('Nome do produto'), findsOneWidget);
  });

  testWidgets('QA-111 formulario vazio exige campos obrigatorios', (tester) async {
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Salvar produto'),
      180,
      scrollable: find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.tap(find.text('Salvar produto'));
    await tester.pump();
    expect(find.text('Campo obrigatório'), findsWidgets);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('QA-112 cancelar cadastro nao altera catalogo', (tester) async {
    final initial = store.products.length;
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Cancelar'),
      180,
      scrollable: find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pump();
    expect(find.byType(Dialog), findsNothing);
    expect(store.products.length, initial);
  });

  testWidgets('QA-113 abre controle de estoque pelo painel', (tester) async {
    await open(tester);
    final label = find.text('Abrir controle de estoque');
    await tester.ensureVisible(label);
    final action = find.ancestor(
      of: label,
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(navigationObserver.lastPushedRoute, isNotNull,
        reason: 'O botão de estoque não abriu uma nova rota');
    expect(find.byType(InventoryScreen), findsOneWidget);
    expect(find.text('Controle de estoque'), findsOneWidget);
  });

  testWidgets('QA-114 exibe estado de catalogo sem produtos', (tester) async {
    for (final product in List<StoreProduct>.from(store.products)) {
      store.remove(product.id);
    }
    await open(tester);
    expect(find.text('Seu catálogo está vazio'), findsOneWidget);
    expect(find.text('Cadastrar produto'), findsOneWidget);
  });
}
