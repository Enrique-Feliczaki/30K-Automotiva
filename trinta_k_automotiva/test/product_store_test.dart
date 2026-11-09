import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final loja = ProductStore.instance;
  late List<StoreProduct> originais;

  setUp(() {
    originais = List<StoreProduct>.from(loja.products);
  });

  tearDown(() {
    for (final produto in List<StoreProduct>.from(loja.products)) {
      loja.remove(produto.id);
    }
    for (final produto in originais) {
      loja.add(produto);
    }
  });

  const base = StoreProduct(
    id: 'produto-qa',
    name: 'Produto de teste',
    category: 'Shampoos',
    sku: 'QA-001',
    price: 30,
    stock: 10,
    minimumStock: 3,
    icon: Icons.local_drink,
  );

  test('QA-15 identifica estoque esgotado', () {
    expect(base.copyWith(stock: 0).isEmpty, isTrue);
    expect(base.isEmpty, isFalse);
  });

  test('QA-16 identifica estoque baixo', () {
    expect(base.copyWith(stock: 3).isLow, isTrue);
    expect(base.copyWith(stock: 2).isLow, isTrue);
    expect(base.copyWith(stock: 0).isLow, isFalse);
    expect(base.isLow, isFalse);
  });

  test('QA-17 adiciona produto ao catálogo', () {
    loja.add(base);
    expect(loja.products.any((produto) => produto.id == base.id), isTrue);
  });

  test('QA-18 atualiza um produto existente', () {
    loja.add(base);
    loja.update(base.copyWith(price: 45));
    expect(loja.products.firstWhere((p) => p.id == base.id).price, 45);
  });

  test('QA-19 remove produto do catálogo', () {
    loja.add(base);
    loja.remove(base.id);
    expect(loja.products.any((p) => p.id == base.id), isFalse);
  });

  test('QA-20 altera o estoque do produto', () {
    loja.add(base);
    loja.setStock(base.id, 5);
    expect(loja.products.firstWhere((p) => p.id == base.id).stock, 5);
  });

  test('QA-21 não permite estoque negativo no ajuste', () {
    loja.add(base);
    loja.setStock(base.id, -10);
    expect(loja.products.firstWhere((p) => p.id == base.id).stock, 0);
  });

  test('QA-22 calcula total de unidades do catálogo', () {
    final anterior = loja.totalUnits;
    loja.add(base);
    expect(loja.totalUnits, anterior + 10);
  });

  test('QA-23 identifica produto esgotado no contador', () {
    final anterior = loja.outOfStockCount;
    loja.add(base.copyWith(stock: 0));
    expect(loja.outOfStockCount, anterior + 1);
  });

  test('QA-24 não inclui Outros nas categorias da tela inicial', () {
    expect(ProductStore.homeCategories.contains('Outros'), isFalse);
    expect(ProductStore.selectableCategories.contains('Outros'), isTrue);
  });

  test('QA-25 formata preço em reais', () {
    expect(formatCurrency(49.90), 'R\$ 49,90');
  });
}
