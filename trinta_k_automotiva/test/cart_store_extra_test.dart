import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_store.dart';

void main() {
  final store = CartStore.instance;
  late List<CartItem> backup;

  CartItem item(String name, double price, int quantity) => CartItem(
    name: name,
    category: 'QA',
    price: price,
    quantity: quantity,
    icon: Icons.shopping_bag_outlined,
  );

  void clear() {
    while (store.items.isNotEmpty) {
      store.remove(store.items.length - 1);
    }
  }

  setUp(() {
    backup = List<CartItem>.from(store.items);
    clear();
  });

  tearDown(() {
    clear();
    for (final entry in backup) {
      store.add(entry);
    }
  });

  test('QA-66 ignora alteracao de indice negativo', () {
    store.add(item('A', 10, 2));
    store.changeQuantity(-1, 1);
    expect(store.unitCount, 2);
  });

  test('QA-67 ignora alteracao alem do ultimo indice', () {
    store.add(item('A', 10, 2));
    store.changeQuantity(9, 1);
    expect(store.unitCount, 2);
  });

  test('QA-68 ignora remocao de indice invalido', () {
    store.add(item('A', 10, 2));
    store.remove(-1);
    store.remove(999);
    expect(store.items.length, 1);
  });

  test('QA-69 lista de itens nao pode ser modificada externamente', () {
    store.add(item('A', 10, 1));
    expect(() => store.items.clear(), throwsUnsupportedError);
  });

  test('QA-70 atualiza subtotal ao remover um de dois produtos', () {
    store.add(item('A', 19.90, 2));
    store.add(item('B', 10.10, 1));
    store.remove(0);
    expect(store.subtotal, closeTo(10.10, 0.001));
    expect(store.unitCount, 1);
  });

  test('QA-71 soma e reduz itens sem deixar quantidade negativa', () {
    store.add(item('A', 7.50, 3));
    store.changeQuantity(0, 2);
    expect(store.unitCount, 5);
    store.changeQuantity(0, -10);
    expect(store.items, isEmpty);
    expect(store.subtotal, 0);
  });

  test('QA-72 permite produtos distintos no mesmo carrinho', () {
    store.add(item('A', 10, 1));
    store.add(item('B', 15, 2));
    expect(store.items.map((e) => e.name).toList(), ['A', 'B']);
    expect(store.subtotal, 40);
  });
}
