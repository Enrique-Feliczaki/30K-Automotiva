import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_store.dart';

void main() {
  final cart = CartStore.instance;
  late List<CartItem> savedItems;

  setUp(() {
    savedItems = cart.items;
    cart.restore([]);
  });

  tearDown(() => cart.restore(savedItems));

  test('adiciona, altera e remove produtos recalculando o subtotal', () {
    const product = CartItem(
      name: 'Shampoo de teste',
      category: 'Shampoos',
      price: 25,
      quantity: 1,
      icon: Icons.local_drink,
    );

    expect(cart.add(product), isTrue);
    expect(cart.add(product.copyWith(quantity: 2)), isTrue);
    expect(cart.items, hasLength(1));
    expect(cart.unitCount, 3);
    expect(cart.subtotal, 75);

    cart.changeQuantity(0, -1);
    expect(cart.items.single.quantity, 2);
    expect(cart.subtotal, 50);

    cart.remove(0);
    expect(cart.items, isEmpty);
    expect(cart.subtotal, 0);
  });
}
