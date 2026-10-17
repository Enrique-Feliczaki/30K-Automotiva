import 'package:flutter/material.dart';

import 'cart_item.dart';

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [
    const CartItem(
      name: 'Graphene Liquid Armor',
      category: 'Revestimento cerâmico',
      price: 289.90,
      quantity: 1,
      icon: Icons.shield_outlined,
    ),
    const CartItem(
      name: 'Ultra Plush 800GSM',
      category: 'Microfibra premium',
      price: 89.90,
      quantity: 2,
      icon: Icons.layers_outlined,
    ),
  ];

  List<CartItem> get items => List.unmodifiable(_items);
  int get unitCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  void add(CartItem product) {
    final index = _items.indexWhere((item) => item.name == product.name);
    if (index < 0) {
      _items.add(product);
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + product.quantity,
      );
    }
    notifyListeners();
  }

  void changeQuantity(int index, int delta) {
    if (index < 0 || index >= _items.length) return;
    final nextQuantity = _items[index].quantity + delta;
    if (nextQuantity <= 0) {
      remove(index);
      return;
    }
    _items[index] = _items[index].copyWith(quantity: nextQuantity);
    notifyListeners();
  }

  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }
}
