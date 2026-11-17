import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/local_accounts.dart';

void main() {
  test('bloqueia formatos incorretos no salvamento sem criar conta', () async {
    final accounts = LocalAccounts();
    for (final email in [
      'cliente@gmail.com123',
      'cliente@gmail.com.',
      'cliente@gmail.123',
    ]) {
      await expectLater(
        accounts.register(
          profile: {'email': email, 'document': '52998224725'},
          password: 'senha-teste',
        ),
        throwsArgumentError,
      );
      expect(accounts.accounts, isEmpty);
    }
  });

  test('aceita TLDs e subdominios sintaticamente validos', () {
    for (final email in [
      'cliente@example.com',
      ' CLIENTE@EMPRESA.COM.BR ',
      'cliente@example.org',
      'cliente@example.co.uk',
      'cliente@e.com',
      'cliente@example.co',
    ]) {
      expect(LocalAccounts.registrationEmailError(email), isNull);
    }
  });
}
