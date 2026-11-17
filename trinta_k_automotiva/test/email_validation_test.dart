import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/email_validation.dart';

void main() {
  group('validação de e-mail para cadastro', () {
    test('aceita endereços com formato válido sem limitar o domínio', () {
      expect(validateRegistrationEmail('cliente@exemplo.com'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.co'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.dev'), isNull);
      expect(validateRegistrationEmail('cliente@e.com'), isNull);
    });

    test('rejeita enderecos incompletos ou malformados', () {
      for (final email in [
        '',
        'cliente',
        'cliente@exemplo',
        'cliente@@exemplo.com',
        '.cliente@exemplo.com',
        'cliente..vendas@exemplo.com',
        'cliente@-exemplo.com',
        'cliente@exemplo.123',
      ]) {
        expect(validateRegistrationEmail(email), invalidEmailError);
      }
    });
  });
}
