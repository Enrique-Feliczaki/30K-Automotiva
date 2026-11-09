import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';

void main() {
  const item = CartItem(
    name: 'Shampoo',
    category: 'Shampoos',
    price: 25.50,
    quantity: 3,
    icon: Icons.local_drink,
  );

  test('QA-01 calcula o total do item', () {
    expect(item.total, closeTo(76.50, 0.001));
  });

  test('QA-02 copia o item alterando a quantidade', () {
    final novo = item.copyWith(quantity: 5);
    expect(novo.quantity, 5);
    expect(novo.total, closeTo(127.50, 0.001));
    expect(item.quantity, 3);
    expect(novo.name, item.name);
  });

  test('QA-03 mantém a quantidade ao copiar sem alteração', () {
    expect(item.copyWith().quantity, 3);
  });

  test('QA-04 formata valores em reais', () {
    expect(formatBrl(29.90), 'R\$ 29,90');
    expect(formatBrl(0), 'R\$ 0,00');
  });
}
