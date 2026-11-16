import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/email_validation.dart';

void main() {
  group('validação de e-mail para cadastro', () {
    test('aceita domínios completos comuns', () {
      expect(validateRegistrationEmail('cliente@exemplo.com'), isNull);
      expect(validateRegistrationEmail('cliente@exemplo.com.br'), isNull);
      expect(validateRegistrationEmail('cliente@loja.exemplo.com'), isNull);
    });

    test('rejeita dominio terminado somente em .co', () {
      expect(
        validateRegistrationEmail('cliente@exemplo.co'),
        invalidEmailError,
      );
    });

    test('rejeita letras ou sufixos extras depois de .com', () {
      for (final email in [
        'cliente@exemplo.come',
        'cliente@exemplo.comx',
        'cliente@exemplo.com.brx',
      ]) {
        expect(validateRegistrationEmail(email), invalidEmailError);
      }
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
      ]) {
        expect(validateRegistrationEmail(email), invalidEmailError);
      }
    });
  });
}
