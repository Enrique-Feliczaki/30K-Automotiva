import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_store.dart';

void main() {
  final carrinho = CartStore.instance;
  late List<CartItem> originais;

  setUp(() {
    originais = List<CartItem>.from(carrinho.items);
    for (var i = carrinho.items.length - 1; i >= 0; i--) {
      carrinho.remove(i);
    }
  });

  tearDown(() {
    for (var i = carrinho.items.length - 1; i >= 0; i--) {
      carrinho.remove(i);
    }
    for (final item in originais) {
      carrinho.add(item);
    }
  });

  CartItem produto(String nome, double preco, int quantidade) => CartItem(
        name: nome,
        category: 'Teste',
        price: preco,
        quantity: quantidade,
        icon: Icons.shopping_cart,
      );

  test('QA-05 carrinho vazio tem quantidade e subtotal zero', () {
    expect(carrinho.items, isEmpty);
    expect(carrinho.unitCount, 0);
    expect(carrinho.subtotal, 0);
  });

  test('QA-06 adiciona produto ao carrinho', () {
    carrinho.add(produto('Shampoo QA', 20, 2));
    expect(carrinho.items.length, 1);
    expect(carrinho.unitCount, 2);
    expect(carrinho.subtotal, 40);
  });

  test('QA-07 soma quantidades de produtos com o mesmo nome', () {
    carrinho.add(produto('Shampoo QA', 20, 1));
    carrinho.add(produto('Shampoo QA', 20, 3));
    expect(carrinho.items.length, 1);
    expect(carrinho.items.first.quantity, 4);
    expect(carrinho.subtotal, 80);
  });

  test('QA-08 calcula subtotal de vários produtos', () {
    carrinho.add(produto('Shampoo QA', 15.50, 2));
    carrinho.add(produto('Cera QA', 30, 1));
    expect(carrinho.unitCount, 3);
    expect(carrinho.subtotal, closeTo(61, 0.001));
  });

  test('QA-09 aumenta a quantidade de um produto', () {
    carrinho.add(produto('Shampoo QA', 12, 1));
    carrinho.changeQuantity(0, 2);
    expect(carrinho.items.first.quantity, 3);
    expect(carrinho.subtotal, 36);
  });

  test('QA-10 diminui a quantidade de um produto', () {
    carrinho.add(produto('Shampoo QA', 12, 3));
    carrinho.changeQuantity(0, -1);
    expect(carrinho.items.first.quantity, 2);
  });

  test('QA-11 remove item quando a quantidade chega a zero', () {
    carrinho.add(produto('Shampoo QA', 12, 1));
    carrinho.changeQuantity(0, -1);
    expect(carrinho.items, isEmpty);
  });

  test('QA-12 remove o item pelo índice', () {
    carrinho.add(produto('Shampoo QA', 12, 1));
    carrinho.remove(0);
    expect(carrinho.items, isEmpty);
  });

  test('QA-13 ignora índice inválido sem lançar erro', () {
    expect(() => carrinho.remove(-1), returnsNormally);
    expect(() => carrinho.changeQuantity(99, 1), returnsNormally);
    expect(carrinho.items, isEmpty);
  });

  test('QA-14 avisa os ouvintes quando um produto é adicionado', () {
    var avisos = 0;
    void ouvinte() => avisos++;
    carrinho.addListener(ouvinte);
    try {
      carrinho.add(produto('Shampoo QA', 12, 1));
      expect(avisos, 1);
    } finally {
      carrinho.removeListener(ouvinte);
    }
  });
}
