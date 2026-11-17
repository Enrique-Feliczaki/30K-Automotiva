import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/main.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(isAdmin: false, onLogout: () {})),
    );
    await tester.pumpAndSettle();
  }

  final search = find.byKey(const ValueKey('product-search'));

  for (final size in [const Size(390, 640), const Size(1100, 1800)]) {
    testWidgets('explorar produtos abre catalogo e limpa categoria em $size', (tester) async {
      await open(tester);
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ceras'));
      await tester.tap(find.text('Ceras'));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ).first,
      );
      scrollable.position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Explorar produtos'));
      await tester.tap(find.text('Explorar produtos'));
      await tester.pumpAndSettle();
      if (scrollable.position.maxScrollExtent > 0) {
        expect(scrollable.position.pixels, greaterThan(0));
      }
      expect(find.text('PRODUTOS').hitTestable(), findsOneWidget);
      expect(find.text(ProductStore.instance.products.first.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pesquisa por parte do nome ignora maiúsculas e acentos', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(search, '  CERA LIQUIDA  ');
    await tester.pumpAndSettle();
    final products = ProductStore.instance.products;
    expect(find.text(products.firstWhere((p) => p.id == 'cera-liquida').name),
        findsOneWidget);
    expect(find.text(products.firstWhere((p) => p.id == 'shampoo-neutro').name),
        findsNothing);
  });

  testWidgets('avisa quando não encontra produtos e permite limpar a busca', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(search, 'produto-inexistente-xyz');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum produto encontrado para esta pesquisa.'),
        findsOneWidget);
    await tester.tap(find.byTooltip('Limpar pesquisa'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(find.text('Nenhum produto encontrado para esta pesquisa.'),
        findsNothing);
    expect(find.text(ProductStore.instance.products.first.name), findsOneWidget);
  });
}
