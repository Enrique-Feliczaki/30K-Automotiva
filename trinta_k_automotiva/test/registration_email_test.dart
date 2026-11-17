import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/local_accounts.dart';

void main() {
  test(
    'bloqueia terminacoes incorretas no salvamento sem criar conta',
    () async {
      final accounts = LocalAccounts();
      for (final email in [
        ' CLIENTE@GMAIL.CO ',
        'cliente@gmail.come',
        'cliente@gmail.comx',
        'cliente@empresa.com.brr',
        'cliente@gmail.com123',
        'cliente@gmail.com.',
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
    },
  );

  test('mantem outras terminacoes e subdominios aceitos', () {
    for (final email in [
      'cliente@example.com',
      ' CLIENTE@EMPRESA.COM.BR ',
      'cliente@example.org',
      'cliente@example.co.uk',
    ]) {
      expect(LocalAccounts.registrationEmailError(email), isNull);
    }
  });
}
