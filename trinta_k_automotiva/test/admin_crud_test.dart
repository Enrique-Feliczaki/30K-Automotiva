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

  Finder editorList() => find
      .descendant(of: find.byType(Dialog), matching: find.byType(Scrollable))
      .first;

  Future<void> type(WidgetTester tester, String label, String value) async {
    await tester.scrollUntilVisible(
      field(label),
      160,
      scrollable: editorList(),
    );
    await tester.enterText(field(label), value);
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Salvar produto'),
      160,
      scrollable: editorList(),
    );
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
    await type(
      tester,
      'Descrição',
      'Produto criado para validar a descrição no painel.',
    );
    await type(tester, 'Código / SKU', '30k-qa-136');
    await type(tester, 'Preço no varejo (R\$)', '48,50');
    await type(tester, 'Preço no atacado (R\$)', '45,00');
    await save(tester);
    expect(store.products.length, before + 1);
    final product = store.products.firstWhere((p) => p.name == 'Produto UI QA');
    expect(product.sku, '30K-QA-136');
    expect(
      product.description,
      'Produto criado para validar a descrição no painel.',
    );
    expect(product.price, 48.5);
  });

  testWidgets('descricao opcional pode ser cadastrada editada e removida', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Nome do produto', 'Produto com descrição');
    await type(tester, 'Código / SKU', '30K-QA-999');
    await type(tester, 'Preço no varejo (R\$)', '48,50');
    await type(tester, 'Preço no atacado (R\$)', '45,00');
    await type(
      tester,
      'Descrição',
      '  Aplicar na superfície limpa.\nUsar uma microfibra.  ',
    );
    await save(tester);
    final created = store.products.last;
    expect(
      created.description,
      'Aplicar na superfície limpa.\nUsar uma microfibra.',
    );

    // Keep the created product visible while editing it again.
    store.restore([created]);
    await tester.pumpAndSettle();
    for (final description in ['Descrição atualizada', '']) {
      await openMenu(tester);
      await tester.tap(find.text('Editar').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        field('Descrição'),
        160,
        scrollable: editorList(),
      );
      expect(
        tester.widget<TextField>(field('Descrição')).controller!.text,
        store.products.single.description,
      );
      await type(tester, 'Descrição', description);
      await save(tester);
      expect(store.products.single.description, description);
    }
  });

  testWidgets('SKU aceita o padrão alfanumérico usado pelos produtos', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Código / SKU', '30k-cr-050extra');
    expect(
      tester.widget<TextField>(field('Código / SKU')).controller!.text,
      '30K-CR-050',
    );
  });

  testWidgets('cadastro com SKU repetido mantém o formulário aberto', (
    tester,
  ) async {
    final before = store.products.length;
    await open(tester);
    await tester.tap(find.text('Novo produto').last);
    await tester.pumpAndSettle();
    await type(tester, 'Nome do produto', 'Produto duplicado');
    await type(tester, 'Código / SKU', '30k-sh-015');
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

  testWidgets('edicao permite alterar SKU no formato dos produtos', (
    tester,
  ) async {
    final first = store.products.first;
    await open(tester);
    await openMenu(tester);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    await type(tester, 'Código / SKU', '30k-xy-999');
    await save(tester);

    final updated = store.products.firstWhere((p) => p.id == first.id);
    expect(updated.sku, '30K-XY-999');
  });

  testWidgets('edicao permite alterar a descricao do produto', (tester) async {
    final first = store.products.first;
    await open(tester);
    await openMenu(tester);
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();

    await type(tester, 'Descrição', 'Nova descrição detalhada do produto.');
    await save(tester);

    final updated = store.products.firstWhere((p) => p.id == first.id);
    expect(updated.description, 'Nova descrição detalhada do produto.');
  });
}
