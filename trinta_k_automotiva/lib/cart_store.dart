import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'product_store.dart';

class CartStore extends ChangeNotifier {
  CartStore._() {
    ProductStore.instance.addListener(_syncStock);
    _syncStock();
  }

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [
    const CartItem(
      productId: 'graphene-armor',
      name: 'Graphene Liquid Armor',
      category: 'Revestimento cerâmico',
      price: 289.90,
      quantity: 1,
      icon: Icons.shield_outlined,
    ),
    const CartItem(
      productId: 'ultra-plush',
      name: 'Ultra Plush 800GSM',
      category: 'Microfibra premium',
      price: 89.90,
      quantity: 2,
      icon: Icons.layers_outlined,
    ),
  ];

  List<CartItem> get items => List.unmodifiable(_items);
  void restore(Iterable<CartItem> items) {
    _items
      ..clear()
      ..addAll(items);
    _syncStock();
  }

  int get unitCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  bool _sameProduct(CartItem a, CartItem b) =>
      a.productId != null && b.productId != null
      ? a.productId == b.productId
      : a.name == b.name;

  int quantityFor(CartItem product) => _items
      .where((item) => _sameProduct(item, product))
      .fold(0, (sum, item) => sum + item.quantity);

  int? stockFor(CartItem item) {
    for (final product in ProductStore.instance.products) {
      if (item.productId != null
          ? product.id == item.productId
          : product.name == item.name) {
        return product.stock;
      }
    }
    return item.productId == null ? null : 0;
  }

  bool canIncrease(CartItem item) {
    final stock = stockFor(item);
    return stock == null || quantityFor(item) < stock;
  }

  void _syncStock() {
    for (var index = _items.length - 1; index >= 0; index--) {
      final stock = stockFor(_items[index]);
      if (stock == null) continue;
      if (stock <= 0) {
        _items.removeAt(index);
      } else if (_items[index].quantity > stock) {
        _items[index] = _items[index].copyWith(quantity: stock);
      }
    }
    notifyListeners();
  }

  bool add(CartItem product) {
    if (product.quantity <= 0) return false;
    final stock = stockFor(product);
    if (stock != null && quantityFor(product) + product.quantity > stock) {
      return false;
    }
    final index = _items.indexWhere((item) => _sameProduct(item, product));
    if (index < 0) {
      _items.add(product);
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + product.quantity,
      );
    }
    notifyListeners();
    return true;
  }

  void changeQuantity(int index, int delta) {
    if (index < 0 || index >= _items.length) return;
    final nextQuantity = _items[index].quantity + delta;
    if (nextQuantity <= 0) {
      remove(index);
      return;
    }
    final stock = stockFor(_items[index]);
    if (stock != null && nextQuantity > stock) return;
    _items[index] = _items[index].copyWith(quantity: nextQuantity);
    notifyListeners();
  }

  void remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }
}
