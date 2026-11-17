import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/local_records.dart';
import 'package:trinta_k_automotiva/main.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final store = ProductStore.instance;
  late List<StoreProduct> backup;
  setUp(() => backup = store.products);
  tearDown(() => store.restore(backup));

  test(
    'descricao preservada ao atualizar estoque e carregar registros antigos',
    () {
      final product = store.products.first.copyWith(
        description: 'Modo de uso\nDiluir em água.',
      );
      store.restore([product]);
      store.setStock(product.id, 12);
      expect(store.products.single.description, product.description);
      expect(
        productFromRecord(productRecord(product)).description,
        product.description,
      );
      final oldRecord = productRecord(product)..remove('description');
      expect(productFromRecord(oldRecord).description, isEmpty);
    },
  );

  for (final description in ['Modo de uso\nDiluir em água.', '', '   ']) {
    testWidgets('descricao aparece somente nos detalhes: "$description"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1100, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final product = store.products.first.copyWith(description: description);
      store.restore([product]);
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(isAdmin: false, onLogout: () {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('Descrição'), findsNothing);
      if (description.trim().isNotEmpty) {
        expect(find.text(description), findsNothing);
      }
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: product, isAdmin: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Descrição'),
        description.trim().isEmpty ? findsNothing : findsOneWidget,
      );
      if (description.trim().isNotEmpty) {
        expect(find.text(description), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
