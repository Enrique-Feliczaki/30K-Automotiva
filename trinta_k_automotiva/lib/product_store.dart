import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'cart_item.dart';

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
    this.description = '',
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
  final String description;
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
    String? description,
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
    description: description ?? this.description,
    compareAtPrice: compareAtPrice ?? this.compareAtPrice,
    imageBytes: clearImage ? null : imageBytes ?? this.imageBytes,
  );
}

class ProductStore extends ChangeNotifier {
  ProductStore._();

  static final ProductStore instance = ProductStore._();

  /// Categories shown on the home page. "Outros" is intentionally excluded
  /// because it is a catch-all category and should not have a home filter.
  static const List<String> homeCategories = [
    'Shampoos',
    'Ceras',
    'Microfibras',
    'Polimento',
    'Pretinhos',
    'Aromatizantes',
  ];

  static const List<String> selectableCategories = [
    ...homeCategories,
    'Outros',
  ];

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
      description: 'Shampoo automotivo concentrado para uma limpeza eficiente e segura, preservando o brilho da pintura.',
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
      description: 'Cera líquida de aplicação prática que realça o brilho e ajuda a proteger a pintura do veículo.',
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
      description: 'Revitalizador desenvolvido para renovar a aparência dos pneus e proporcionar acabamento uniforme.',
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
      description: 'Proteção avançada com grafeno para aumentar a resistência, o brilho e a durabilidade da superfície.',
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
      description: 'Toalha de microfibra macia e de alta gramatura, ideal para acabamento e remoção de produtos.',
    ),
  ];

  List<StoreProduct> get products => List.unmodifiable(_products);

  bool hasSku(String sku, {String? excludingProductId}) => _products.any(
    (product) =>
        product.id != excludingProductId &&
        product.sku.trim().toUpperCase() == sku.trim().toUpperCase(),
  );

  List<StoreProduct> stockAfterPurchase(Iterable<CartItem> items) {
    final quantities = <String, int>{};
    for (final item in items) {
      final matches = _products.where(
        (product) => item.productId != null
            ? product.id == item.productId
            : product.name == item.name,
      );
      if (matches.length != 1 || item.quantity <= 0) {
        throw StateError('Produto indisponível. Revise seu carrinho.');
      }
      final product = matches.single;
      quantities.update(
        product.id,
        (value) => value + item.quantity,
        ifAbsent: () => item.quantity,
      );
    }
    if (quantities.isEmpty) {
      throw StateError('Adicione produtos ao carrinho antes de finalizar.');
    }
    return _products.map((product) {
      final quantity = quantities[product.id] ?? 0;
      if (quantity > product.stock) {
        throw StateError(
          'Estoque insuficiente para ${product.name}. Revise seu carrinho.',
        );
      }
      return quantity == 0
          ? product
          : product.copyWith(stock: product.stock - quantity);
    }).toList();
  }

  void restore(Iterable<StoreProduct> products) {
    _products
      ..clear()
      ..addAll(products);
    notifyListeners();
  }

  int get totalUnits =>
      _products.fold(0, (sum, product) => sum + product.stock);
  int get lowStockCount => _products.where((product) => product.isLow).length;
  int get outOfStockCount =>
      _products.where((product) => product.isEmpty).length;

  void add(StoreProduct product) {
    if (hasSku(product.sku)) {
      throw StateError('Já existe um produto com este SKU.');
    }
    final id = product.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : product.id;
    _products.add(product.copyWith(id: id));
    notifyListeners();
  }

  void update(StoreProduct product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) return;
    if (hasSku(product.sku, excludingProductId: product.id)) {
      throw StateError('Já existe um produto com este SKU.');
    }
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
