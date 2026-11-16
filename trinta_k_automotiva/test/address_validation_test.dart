import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/address_validation.dart';

void main() {
  group('validação de endereço', () {
    test('aceita os formatos válidos de CEP', () {
      expect(validatePostalCode('85010-000'), isNull);
      expect(validatePostalCode('85010000'), isNull);
    });

    test('rejeita CEP com símbolos', () {
      expect(validatePostalCode('85@010#000'), invalidPostalCodeError);
      expect(validatePostalCode('85010_000'), invalidPostalCodeError);
    });

    test('estado deve conter exatamente duas letras', () {
      expect(validateState('PR'), isNull);
      expect(validateState('P@'), invalidStateError);
      expect(validateState('Paraná'), invalidStateError);
    });

    test('cidade, bairro e rua aceitam acentos e números', () {
      expect(validateAddressText('São José dos Pinhais'), isNull);
      expect(validateAddressText('Rua 25 de Março'), isNull);
      expect(validateAddressText('Jardim América 2'), isNull);
    });

    test('cidade, bairro e rua rejeitam símbolos', () {
      for (final value in [
        'Centro@',
        'Rua das Flores!',
        'Bairro #2',
        '\u0301',
      ]) {
        expect(validateAddressText(value), invalidAddressTextError);
      }
    });

    test('número do imóvel aceita somente dígitos', () {
      expect(validateHouseNumber('100'), isNull);
      expect(validateHouseNumber('123456'), isNull);
      expect(validateHouseNumber('10@'), invalidHouseNumberError);
      expect(validateHouseNumber('S/N'), invalidHouseNumberError);
      expect(validateHouseNumber('1234567'), invalidHouseNumberLengthError);
    });

    test('campos vazios continuam obrigatórios', () {
      expect(validateState('  '), requiredAddressFieldError);
      expect(validateAddressText(null), requiredAddressFieldError);
      expect(validateHouseNumber(''), requiredAddressFieldError);
    });
  });
}
