import 'package:flutter/material.dart';

class CartItem {
  const CartItem({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.icon,
  });

  final String name;
  final String category;
  final double price;
  final int quantity;
  final IconData icon;

  double get total => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    name: name,
    category: category,
    price: price,
    quantity: quantity ?? this.quantity,
    icon: icon,
  );
}

String formatBrl(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
