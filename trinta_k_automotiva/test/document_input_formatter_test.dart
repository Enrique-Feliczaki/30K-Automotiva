import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/document_input_formatter.dart';

TextEditingValue value(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

void main() {
  final cpf = DocumentInputFormatter(isCompany: false);
  final cnpj = DocumentInputFormatter(isCompany: true);

  test('Formats CPF and CNPJ pasted with or without punctuation', () {
    expect(
      cpf.formatEditUpdate(value(''), value('52998224725')).text,
      '529.982.247-25',
    );
    expect(
      cpf.formatEditUpdate(value(''), value('529.982.247-25')).text,
      '529.982.247-25',
    );
    expect(
      cnpj.formatEditUpdate(value(''), value('11222333000181')).text,
      '11.222.333/0001-81',
    );
    expect(
      cnpj.formatEditUpdate(value(''), value('11.222.333/0001-81')).text,
      '11.222.333/0001-81',
    );
  });
  test('Formats progressively and limits the number of digits', () {
    var current = value('');
    for (final digit in '52998224725'.split('')) {
      current = cpf.formatEditUpdate(current, value('${current.text}$digit'));
      expect(current.selection.baseOffset, current.text.length);
    }
    expect(current.text, '529.982.247-25');
    expect(
      cpf.formatEditUpdate(current, value('${current.text}9')).text,
      current.text,
    );
    expect(
      cnpj.formatEditUpdate(value(''), value('1122233300018199')).text,
      '11.222.333/0001-81',
    );
    expect(
      cpf.formatEditUpdate(value(''), value('abc52998224725')).text,
      '529.982.247-25',
    );
  });
  test('Backspace across punctuation removes the previous digit', () {
    final result = cpf.formatEditUpdate(
      value('529.982', 4),
      value('529982', 3),
    );
    expect(result.text, '529.82');
    expect(result.selection.baseOffset, 2);
    expect(cpf.formatEditUpdate(value('529'), value('')).text, isEmpty);
  });
  test('Preserves selection when editing in the middle', () {
    final result = cpf.formatEditUpdate(value('529.982'), value('529.1982', 5));
    expect(result.text, '529.198.2');
    expect(result.selection.baseOffset, 5);
    final replaced = cpf.formatEditUpdate(
      const TextEditingValue(
        text: '529.982',
        selection: TextSelection(baseOffset: 0, extentOffset: 3),
      ),
      value('123.982', 3),
    );
    expect(replaced.text, '123.982');
    expect(replaced.selection.baseOffset, 3);
  });
}
