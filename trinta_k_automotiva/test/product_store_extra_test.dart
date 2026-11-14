import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final store = ProductStore.instance;
  late List<StoreProduct> backup;

  const sample = StoreProduct(
    id: 'extra-qa',
    name: 'Produto QA',
    category: 'Outros',
    sku: 'EX-001',
    price: 37.5,
    stock: 5,
    minimumStock: 2,
    icon: Icons.inventory_2_outlined,
    compareAtPrice: 50,
  );

  setUp(() => backup = List<StoreProduct>.from(store.products));
  tearDown(() {
    for (final product in List<StoreProduct>.from(store.products)) {
      store.remove(product.id);
    }
    for (final product in backup) {
      store.add(product);
    }
  });

  test('QA-55 identifica estoque abaixo do minimo', () {
    expect(sample.copyWith(stock: 1).isLow, isTrue);
    expect(sample.copyWith(stock: 3).isLow, isFalse);
  });

  test('QA-56 identifica estoque no limite do minimo', () {
    expect(sample.copyWith(stock: 2).isLow, isTrue);
    expect(sample.copyWith(stock: 0).isEmpty, isTrue);
  });

  test('QA-57 copia produto mantendo campos nao alterados', () {
    final updated = sample.copyWith(price: 42, stock: 8);
    expect(updated.price, 42);
    expect(updated.stock, 8);
    expect(updated.id, sample.id);
    expect(updated.sku, sample.sku);
    expect(updated.compareAtPrice, 50);
    expect(sample.price, 37.5);
  });

  test('QA-58 limpa foto mantendo demais propriedades', () {
    final image = Uint8List.fromList([1, 2, 3]);
    final withImage = sample.copyWith(imageBytes: image);
    expect(withImage.imageBytes, image);
    final withoutImage = withImage.copyWith(clearImage: true);
    expect(withoutImage.imageBytes, isNull);
    expect(withoutImage.name, sample.name);
  });

  test('QA-59 catalogo retorna lista nao modificavel', () {
    expect(() => store.products.add(sample), throwsUnsupportedError);
  });

  test('QA-60 gera identificador para produto sem id', () {
    store.add(sample.copyWith(id: ''));
    final saved = store.products.last;
    expect(saved.id, isNotEmpty);
    expect(saved.name, sample.name);
  });

  test('QA-61 atualizar id inexistente nao altera catalogo', () {
    final before = List<StoreProduct>.from(store.products);
    store.update(sample.copyWith(id: 'id-inexistente-qa'));
    expect(store.products.length, before.length);
    expect(store.products.map((p) => p.id), orderedEquals(before.map((p) => p.id)));
  });

  test('QA-62 calcular contador de baixo estoque apos ajuste', () {
    store.add(sample.copyWith(stock: 3));
    final before = store.lowStockCount;
    store.setStock(sample.id, 2);
    expect(store.lowStockCount, before + 1);
  });

  test('QA-63 notifica ouvintes ao editar o estoque', () {
    store.add(sample);
    var calls = 0;
    void listener() => calls++;
    store.addListener(listener);
    store.setStock(sample.id, 4);
    store.removeListener(listener);
    expect(calls, 1);
    expect(store.products.last.stock, 4);
  });

  test('QA-64 nao altera estoque de identificador inexistente', () {
    final before = store.totalUnits;
    store.setStock('id-ausente-qa', 999);
    expect(store.totalUnits, before);
  });

  test('QA-65 inclui Outros nas categorias selecionaveis', () {
    expect(ProductStore.selectableCategories, contains('Outros'));
    expect(ProductStore.homeCategories, isNot(contains('Outros')));
  });
}
