import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/product_inventory_screen.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final store = ProductStore.instance;
  late List<StoreProduct> backup;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));
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

  testWidgets('QA-115 exibe controle de estoque', (tester) async {
    await open(tester);
    expect(find.text('Controle de estoque'), findsOneWidget);
    expect(find.text('UNIDADES'), findsOneWidget);
    expect(find.text('${store.products.length} encontrados'), findsOneWidget);
  });

  testWidgets('QA-116 filtro de esgotados conta produtos sem estoque', (tester) async {
    await open(tester);
    await tester.tap(find.text('Esgotados').last);
    await tester.pump();
    expect(find.text('${store.outOfStockCount} encontrados'), findsOneWidget);
  });

  testWidgets('QA-117 filtro de estoque baixo conta itens criticos', (tester) async {
    await open(tester);
    await tester.tap(find.text('Baixo estoque').last);
    await tester.pump();
    expect(find.text('${store.lowStockCount} encontrados'), findsOneWidget);
  });

  testWidgets('QA-118 filtro disponiveis exclui estoque baixo', (tester) async {
    await open(tester);
    await tester.tap(find.text('Disponíveis'));
    await tester.pump();
    final total = store.products.where((p) => p.stock > p.minimumStock).length;
    expect(find.text('$total encontrados'), findsOneWidget);
  });

  testWidgets('QA-119 busca SKU sem diferenciar letras', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, '30k-sh-015');
    await tester.pump();
    expect(find.text('1 encontrados'), findsOneWidget);
  });

  testWidgets('QA-120 termo inexistente mostra lista vazia', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'produto-que-nao-existe');
    await tester.pump();
    expect(find.text('0 encontrados'), findsOneWidget);
    expect(find.text('Nenhum produto encontrado'), findsOneWidget);
  });

  testWidgets('QA-121 limpar busca restaura o catalogo', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'nada-encontrado');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(find.text('${store.products.length} encontrados'), findsOneWidget);
  });

  testWidgets('QA-140 aumenta uma unidade pelo controle', (tester) async {
    final first = store.products.first;
    await open(tester);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();
    expect(store.products.firstWhere((p) => p.id == first.id).stock, first.stock + 1);
  });

  testWidgets('QA-141 diminui uma unidade pelo controle', (tester) async {
    final first = store.products.first;
    await open(tester);
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pump();
    expect(store.products.firstWhere((p) => p.id == first.id).stock, first.stock - 1);
  });

  testWidgets('QA-142 produto esgotado nao fica com quantidade negativa', (tester) async {
    final empty = store.products.firstWhere((p) => p.stock == 0);
    await open(tester);
    await tester.tap(find.text('Esgotados').last);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove).last);
    await tester.pump();
    expect(store.products.firstWhere((p) => p.id == empty.id).stock, 0);
  });
}
