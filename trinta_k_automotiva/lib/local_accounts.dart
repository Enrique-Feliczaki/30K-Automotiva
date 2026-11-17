import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'email_validation.dart';

class LocalAccount {
  const LocalAccount({
    required this.email,
    required this.document,
    required this.passwordHash,
    required this.salt,
    required this.iterations,
    required this.profile,
  });

  final String email;
  final String document;
  final String passwordHash;
  final String salt;
  final int iterations;
  final Map<String, dynamic> profile;

  LocalAccount withProfile(Map<String, dynamic> value) => LocalAccount(
    email: email,
    document: document,
    passwordHash: passwordHash,
    salt: salt,
    iterations: iterations,
    profile: Map.of(value),
  );
}

class LocalAccounts extends ChangeNotifier {
  LocalAccounts();

  static final instance = LocalAccounts();
  final List<LocalAccount> _accounts = [];
  List<LocalAccount> get accounts => List.unmodifiable(_accounts);

  static String? registrationEmailError(String? value) =>
      validateRegistrationEmail(value);

  String? duplicateMessage(String email, String document) {
    if (_accounts.any((a) => a.email == email.trim().toLowerCase())) {
      return 'Já existe um usuário cadastrado com esse e-mail.';
    }
    if (document == '00011100111100' ||
        _accounts.any((a) => a.document == document)) {
      return document.length == 14
          ? 'Já existe um usuário cadastrado com esse CNPJ.'
          : 'Já existe um usuário cadastrado com esse CPF.';
    }
    return null;
  }

  void restore(Iterable<LocalAccount> accounts) {
    _accounts
      ..clear()
      ..addAll(accounts);
  }

  Future<LocalAccount> register({
    required Map<String, dynamic> profile,
    required String password,
  }) async {
    final email = (profile['email'] as String).trim().toLowerCase();
    final emailError = registrationEmailError(email);
    if (emailError != null) throw ArgumentError(emailError);
    final document = (profile['document'] as String).replaceAll(
      RegExp(r'\D'),
      '',
    );
    final duplicate = duplicateMessage(email, document);
    if (duplicate != null) throw StateError(duplicate);
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    const iterations = 600000;
    final key = await Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    final hash = await key.extractBytes();
    final repeated = duplicateMessage(email, document);
    if (repeated != null) throw StateError(repeated);
    final account = LocalAccount(
      email: email,
      document: document,
      passwordHash: base64Encode(hash),
      salt: base64Encode(salt),
      iterations: iterations,
      profile: {...profile, 'email': email},
    );
    _accounts.add(account);
    notifyListeners();
    return account;
  }

  Future<LocalAccount?> authenticate(String email, String password) async {
    final matches = _accounts.where(
      (a) => a.email == email.trim().toLowerCase(),
    );
    if (matches.isEmpty) return null;
    final account = matches.single;
    final key =
        await Pbkdf2.hmacSha256(
          iterations: account.iterations,
          bits: 256,
        ).deriveKeyFromPassword(
          password: password,
          nonce: base64Decode(account.salt),
        );
    final actual = await key.extractBytes();
    final expected = base64Decode(account.passwordHash);
    var difference = actual.length ^ expected.length;
    for (var i = 0; i < actual.length && i < expected.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    return difference == 0 ? account : null;
  }

  void updateProfile(Map<String, dynamic> profile) {
    final index = _accounts.indexWhere((a) => a.email == profile['email']);
    if (index < 0) return;
    _accounts[index] = _accounts[index].withProfile(profile);
    notifyListeners();
  }

  void remove(String email) {
    _accounts.removeWhere((a) => a.email == email);
    notifyListeners();
  }
}
