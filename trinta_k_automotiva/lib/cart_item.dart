import 'package:flutter/material.dart';

class CartItem {
  const CartItem({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.icon,
    this.productId,
  });

  final String name;
  final String category;
  final double price;
  final int quantity;
  final IconData icon;
  final String? productId;

  double get total => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    name: name,
    category: category,
    price: price,
    quantity: quantity ?? this.quantity,
    icon: icon,
    productId: productId,
  );
}

String formatBrl(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
