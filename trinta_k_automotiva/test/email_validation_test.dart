import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/email_validation.dart';

void main() {
  group('validação de e-mail para cadastro', () {
    test('aceita endereços com formato e sufixo reconhecidos', () {
      expect(validateRegistrationEmail('cliente@exemplo.com'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.co'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.dev'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.com.br'), isNull);
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
        'cliente@e.com',
        'cliente@loja.e.com',
        'cliente@exemplo.come',
        'cliente@exemplo.comx',
        'cliente@exemplo.com.brr',
      ]) {
        expect(validateRegistrationEmail(email), invalidEmailError);
      }
    });
  });
}
