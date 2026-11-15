import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'product_store.dart';

// Resolve persisted icons from constants so Flutter can still tree-shake fonts.
IconData _icon(int codePoint) =>
    const [
      Icons.local_drink_outlined,
      Icons.auto_awesome,
      Icons.tire_repair,
      Icons.shield_outlined,
      Icons.layers_outlined,
      Icons.inventory_2_outlined,
    ].firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.inventory_2_outlined,
    );

Map<String, dynamic> productRecord(StoreProduct product) => {
  'id': product.id,
  'name': product.name,
  'category': product.category,
  'sku': product.sku,
  'price': product.price,
  'stock': product.stock,
  'minimumStock': product.minimumStock,
  'icon': product.icon.codePoint,
  'compareAtPrice': product.compareAtPrice,
  'image': product.imageBytes == null
      ? null
      : base64Encode(product.imageBytes!),
};

StoreProduct productFromRecord(Map<String, dynamic> data) => StoreProduct(
  id: data['id'] as String,
  name: data['name'] as String,
  category: data['category'] as String,
  sku: data['sku'] as String,
  price: (data['price'] as num).toDouble(),
  stock: data['stock'] as int,
  minimumStock: data['minimumStock'] as int,
  icon: _icon(data['icon'] as int),
  compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
  imageBytes: data['image'] == null
      ? null
      : Uint8List.fromList(base64Decode(data['image'] as String)),
);

Map<String, dynamic> cartRecord(CartItem item) => {
  'productId': item.productId,
  'name': item.name,
  'category': item.category,
  'price': item.price,
  'quantity': item.quantity,
  'icon': item.icon.codePoint,
};

CartItem cartFromRecord(Map<String, dynamic> data) => CartItem(
  productId: data['productId'] as String?,
  name: data['name'] as String,
  category: data['category'] as String,
  price: (data['price'] as num).toDouble(),
  quantity: data['quantity'] as int,
  icon: _icon(data['icon'] as int),
);
