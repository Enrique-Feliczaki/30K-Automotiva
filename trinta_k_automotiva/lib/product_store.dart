import 'dart:typed_data';

import 'package:flutter/material.dart';

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.price,
    required this.stock,
    required this.minimumStock,
    required this.icon,
    this.compareAtPrice,
    this.imageBytes,
  });

  final String id;
  final String name;
  final String category;
  final String sku;
  final double price;
  final int stock;
  final int minimumStock;
  final IconData icon;
  final double? compareAtPrice;
  final Uint8List? imageBytes;

  bool get isEmpty => stock <= 0;
  bool get isLow => stock > 0 && stock <= minimumStock;

  StoreProduct copyWith({
    String? id,
    String? name,
    String? category,
    String? sku,
    double? price,
    int? stock,
    int? minimumStock,
    IconData? icon,
    double? compareAtPrice,
    Uint8List? imageBytes,
    bool clearImage = false,
  }) => StoreProduct(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    sku: sku ?? this.sku,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    minimumStock: minimumStock ?? this.minimumStock,
    icon: icon ?? this.icon,
    compareAtPrice: compareAtPrice ?? this.compareAtPrice,
    imageBytes: clearImage ? null : imageBytes ?? this.imageBytes,
  );
}

class ProductStore extends ChangeNotifier {
  ProductStore._();

  static final ProductStore instance = ProductStore._();

  final List<StoreProduct> _products = [
    const StoreProduct(
      id: 'shampoo-neutro',
      name: 'Shampoo Neutro Concentrado 1,5L',
      category: 'Shampoos',
      sku: '30K-SH-015',
      price: 59.90,
      compareAtPrice: 74.90,
      stock: 24,
      minimumStock: 5,
      icon: Icons.local_drink_outlined,
    ),
    const StoreProduct(
      id: 'cera-liquida',
      name: 'Cera Líquida Ultra Brilho 500ml',
      category: 'Ceras',
      sku: '30K-CR-050',
      price: 79.90,
      compareAtPrice: 99.90,
      stock: 4,
      minimumStock: 5,
      icon: Icons.auto_awesome,
    ),
    const StoreProduct(
      id: 'revitalizador-pneus',
      name: 'Revitalizador de Pneus 500ml',
      category: 'Acabamento',
      sku: '30K-PN-050',
      price: 42.90,
      compareAtPrice: 54.90,
      stock: 12,
      minimumStock: 5,
      icon: Icons.tire_repair,
    ),
    const StoreProduct(
      id: 'graphene-armor',
      name: 'Graphene Liquid Armor',
      category: 'Proteção cerâmica',
      sku: '30K-GR-100',
      price: 289.90,
      stock: 8,
      minimumStock: 3,
      icon: Icons.shield_outlined,
    ),
    const StoreProduct(
      id: 'ultra-plush',
      name: 'Ultra Plush 800GSM',
      category: 'Microfibras',
      sku: '30K-MF-800',
      price: 89.90,
      stock: 0,
      minimumStock: 5,
      icon: Icons.layers_outlined,
    ),
  ];

  List<StoreProduct> get products => List.unmodifiable(_products);
  int get totalUnits =>
      _products.fold(0, (sum, product) => sum + product.stock);
  int get lowStockCount => _products.where((product) => product.isLow).length;
  int get outOfStockCount =>
      _products.where((product) => product.isEmpty).length;

  void add(StoreProduct product) {
    final id = product.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : product.id;
    _products.add(product.copyWith(id: id));
    notifyListeners();
  }

  void update(StoreProduct product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) return;
    _products[index] = product;
    notifyListeners();
  }

  void remove(String id) {
    _products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  void setStock(String id, int stock) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index < 0) return;
    _products[index] = _products[index].copyWith(stock: stock < 0 ? 0 : stock);
    notifyListeners();
  }
}

String formatCurrency(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
