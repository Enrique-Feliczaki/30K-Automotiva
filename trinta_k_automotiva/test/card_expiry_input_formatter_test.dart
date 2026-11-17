import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/card_expiry_input_formatter.dart';

void main() {
  final formatter = CardExpiryInputFormatter();
  TextEditingValue value(String text, [int? cursor]) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: cursor ?? text.length),
  );

  test('digitar quatro numeros insere a barra automaticamente', () {
    var current = TextEditingValue.empty;
    for (final entry in [
      ('0', '0'),
      ('01', '01/'),
      ('01/2', '01/2'),
      ('01/26', '01/26'),
    ]) {
      current = formatter.formatEditUpdate(current, value(entry.$1));
      expect(current.text, entry.$2);
      expect(current.selection.baseOffset, current.text.length);
    }
  });

  test('colar validade filtra simbolos e limita a quatro digitos', () {
    for (final text in ['0126', '01/26', '01/26a789']) {
      expect(
        formatter.formatEditUpdate(TextEditingValue.empty, value(text)).text,
        '01/26',
      );
    }
  });

  test('apagar a barra permite corrigir o mes sem prender o cursor', () {
    final result = formatter.formatEditUpdate(value('01/', 3), value('01', 2));
    expect(result.text, '0');
    expect(result.selection.baseOffset, 1);
    expect(formatter.formatEditUpdate(value('0'), value('')).text, isEmpty);
  });

  test('editar no meio preserva a posicao do cursor', () {
    final result = formatter.formatEditUpdate(
      value('01/26', 1),
      value('11/26', 1),
    );
    expect(result.text, '11/26');
    expect(result.selection.baseOffset, 1);
  });
}
