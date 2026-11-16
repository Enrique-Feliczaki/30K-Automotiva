import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/admin_screen.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final store = ProductStore.instance;
  late List<StoreProduct> backup;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: AdminScreen()));
  }

  Finder field(String label) => find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == label,
      );

  Finder editorList() => find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(Scrollable),
      ).first;

  Future<void> type(WidgetTester tester, String label, String value) async {
    await tester.scrollUntilVisible(field(label), 160, scrollable: editorList());
    await tester.enterText(field(label), value);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('Salvar produto'), 160, scrollable: editorList());
    await tester.tap(find.text('Salvar produto'));
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Ações do produto').first);
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

  testWidgets('QA-136 cadastra produto pelo painel', (tester) async {
    final before = store.products.length;
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Nome do produto', 'Produto UI QA');
    await type(tester, 'Código / SKU', '0136');
    await type(tester, 'Preço no varejo (R\$)', '48,50');
    await type(tester, 'Preço no atacado (R\$)', '45,00');
    await save(tester);
    expect(store.products.length, before + 1);
    final product = store.products.firstWhere((p) => p.name == 'Produto UI QA');
    expect(product.sku, '0136');
    expect(product.price, 48.5);
  });

  testWidgets('SKU aceita somente números e no máximo 4 dígitos', (tester) async {
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Código / SKU', 'ab012345');
    expect(tester.widget<TextField>(field('Código / SKU')).controller!.text, '0123');
  });

  testWidgets('cadastro com SKU repetido mantém o formulário aberto', (tester) async {
    store.update(store.products.first.copyWith(sku: '0123'));
    final before = store.products.length;
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Nome do produto', 'Produto duplicado');
    await type(tester, 'Código / SKU', '0123');
    await type(tester, 'Preço no varejo (R\$)', '48,50');
    await type(tester, 'Preço no atacado (R\$)', '45,00');
    await save(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Já existe um produto com este SKU'), findsOneWidget);
    expect(store.products.length, before);
  });

  testWidgets('QA-137 cancelar exclusao preserva produto', (tester) async {
    final first = store.products.first;
    await open(tester);
    await openMenu(tester);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(find.text('Excluir produto?'), findsOneWidget);
    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();
    expect(store.products.any((p) => p.id == first.id), isTrue);
  });

  testWidgets('QA-138 confirma exclusao de produto', (tester) async {
    final first = store.products.first;
    await open(tester);
    await openMenu(tester);
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();
    expect(store.products.any((p) => p.id == first.id), isFalse);
  });

  testWidgets('QA-139 altera preco de produto pelo painel', (tester) async {
    final first = store.products.first;
    await open(tester);
    await openMenu(tester);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();
    await type(tester, 'Preço no varejo (R\$)', '77,90');
    await save(tester);
    final updated = store.products.firstWhere((p) => p.id == first.id);
    expect(updated.price, 77.9);
  });
}
