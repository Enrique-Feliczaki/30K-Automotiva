import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final store = ProductStore.instance;
  late List<StoreProduct> savedProducts;

  const product = StoreProduct(
    id: 'produto-unitario',
    name: 'Produto unitário',
    category: 'Ceras',
    sku: 'UNIT-001',
    price: 40,
    stock: 5,
    minimumStock: 2,
    icon: Icons.auto_awesome,
  );

  setUp(() {
    savedProducts = store.products;
    store.restore([product]);
  });

  tearDown(() => store.restore(savedProducts));

  test('impede SKU repetido e estoque negativo', () {
    expect(
      () => store.add(product.copyWith(id: 'outro-produto')),
      throwsStateError,
    );
    expect(store.products, hasLength(1));

    store.setStock(product.id, -3);
    expect(store.products.single.stock, 0);
    expect(store.products.single.isEmpty, isTrue);
  });
}
