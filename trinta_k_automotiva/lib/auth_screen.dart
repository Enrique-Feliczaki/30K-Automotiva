import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive_layout.dart';

import 'customer_profile.dart';
import 'document_input_formatter.dart';
import 'local_accounts.dart';
import 'local_persistence.dart';

const _red = Color(0xFFE11D2E);
const _panel = Color(0xFF171717);
const _muted = Color(0xFF92979D);
final _numericCharacters = RegExp(r'\p{N}', unicode: true);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final ValueChanged<bool> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _isAdminLogin = false;
  bool _isCompany = false;
  bool _obscurePassword = true;
  bool _submitting = false;
  static const _adminCnpj = '00011100111100';
  static const _adminPassword = '30kautomotiva';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_isAdminLogin) {
      final cnpj = _documentController.text.replaceAll(RegExp(r'\D'), '');
      if (cnpj != _adminCnpj || _passwordController.text != _adminPassword) {
        _showMessage('CNPJ ou senha de administrador incorretos.');
        return;
      }
      CustomerProfile.instance.restore({});
      LocalPersistence.active?.switchCustomer(null);
      widget.onAuthenticated(true);
      return;
    }
    if (_isRegister) {
      final email = _emailController.text.trim().toLowerCase();
      final document = _documentController.text.replaceAll(RegExp(r'\D'), '');
      final duplicate = _duplicateRegistrationMessage(email, document);
      if (duplicate != null) {
        _showMessage(duplicate);
        return;
      }
      setState(() => _submitting = true);
      try {
        final account = await LocalAccounts.instance.register(
          profile: {
            'name': _nameController.text.trim(),
            'email': email,
            'document': _documentController.text.trim(),
            'isCompany': _isCompany,
          },
          password: _passwordController.text,
        );
        try {
          await LocalPersistence.active?.flush();
        } catch (_) {
          LocalAccounts.instance.remove(account.email);
          rethrow;
        }
        if (!mounted) return;
        CustomerProfile.instance.restore(account.profile);
        setState(() => _isRegister = false);
        _showMessage('Cadastro criado. Faça login para continuar.');
      } catch (_) {
        if (mounted)
          _showMessage('Não foi possível salvar o cadastro. Tente novamente.');
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    setState(() => _submitting = true);
    try {
      final account = await LocalAccounts.instance.authenticate(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      if (account == null) {
        _showMessage('e-mail ou senha incorretos.');
        return;
      }
      CustomerProfile.instance.restore(account.profile);
      LocalPersistence.active?.switchCustomer(account.email);
      widget.onAuthenticated(false);
    } catch (_) {
      if (mounted) _showMessage('Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _duplicateRegistrationMessage(String email, String document) {
    return LocalAccounts.instance.duplicateMessage(email, document);
  }

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
    body: AbsorbPointer(
      absorbing: _submitting,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/logo30k.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '30K AUTOMOTIVA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Entre na sua conta ou crie seu cadastro',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  if (!_isAdminLogin)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _modeButton(
                            'Entrar',
                            !_isRegister && !_isAdminLogin,
                            () => setState(() {
                              _isRegister = false;
                              _isAdminLogin = false;
                            }),
                          ),
                          _modeButton(
                            'Cadastrar',
                            _isRegister,
                            () => setState(() {
                              _isRegister = true;
                              _isAdminLogin = false;
                              _isCompany = false;
                            }),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'Entrar admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 22),
                  if (_isRegister) ...[
                    const Text(
                      'TIPO DE CADASTRO',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                            'Pessoa física',
                            !_isCompany,
                            () => setState(() {
                              _isCompany = false;
                              _documentController.clear();
                              _nameController.clear();
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeButton(
                            'Pessoa jurídica',
                            _isCompany,
                            () => setState(() {
                              _isCompany = true;
                              _documentController.clear();
                              _nameController.clear();
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isRegister) ...[
                          _field(
                            controller: _nameController,
                            label: _isCompany
                                ? 'Razão social'
                                : 'Nome completo',
                            icon: _isCompany
                                ? Icons.business_outlined
                                : Icons.person_outline,
                            inputFormatters: _isCompany
                                ? [
                                    FilteringTextInputFormatter.deny(
                                      _numericCharacters,
                                    ),
                                  ]
                                : null,
                            validator: (value) {
                              final name = value?.trim() ?? '';
                              if (name.isEmpty) {
                                return 'Informe ${_isCompany ? 'a razão social' : 'seu nome'}';
                              }
                              if (_isCompany &&
                                  _numericCharacters.hasMatch(name)) {
                                return 'A razão social não pode conter números';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_isAdminLogin)
                          _field(
                            controller: _documentController,
                            label: 'CNPJ',
                            hintText: '00.000.000/0000-00',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DocumentInputFormatter(isCompany: true),
                            ],
                            validator: (value) {
                              final cnpj = (value ?? '').replaceAll(
                                RegExp(r'\D'),
                                '',
                              );
                              if (cnpj.isEmpty) return 'Informe seu CNPJ';
                              return cnpj.length == 14
                                  ? null
                                  : 'Informe um CNPJ com 14 dígitos';
                            },
                          )
                        else
                          _field(
                            controller: _emailController,
                            label: 'E-mail',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (!_isRegister)
                                return email.isEmpty
                                    ? 'Informe seu e-mail'
                                    : null;
                              return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(email)
                                  ? null
                                  : 'Informe um e-mail válido';
                            },
                          ),
                        if (_isRegister) ...[
                          const SizedBox(height: 14),
                          _field(
                            controller: _documentController,
                            label: _isCompany ? 'CNPJ' : 'CPF',
                            hintText: _isCompany
                                ? '00.000.000/0000-00'
                                : '000.000.000-00',
                            inputFormatters: [
                              DocumentInputFormatter(isCompany: _isCompany),
                            ],
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _validDocument(value ?? '', _isCompany)
                                ? null
                                : 'Informe um ${_isCompany ? 'CNPJ' : 'CPF'} válido',
                          ),
                        ],
                        const SizedBox(height: 14),
                        _field(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _muted,
                              size: 20,
                            ),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            if (!_isRegister)
                              return password.isEmpty
                                  ? 'Informe sua senha'
                                  : null;
                            return password.length >= 6
                                ? null
                                : 'A senha deve ter pelo menos 6 caracteres';
                          },
                        ),
                      ],
                    ),
                  ),
                  if (!_isRegister)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showMessage(
                          'Entre em contato com o suporte para redefinir sua senha.',
                        ),
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 50),
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: Text(
                        _submitting
                            ? 'Aguarde...'
                            : (_isRegister ? 'Criar cadastro' : 'Entrar'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isRegister
                        ? 'Ao criar seu cadastro, você poderá acompanhar suas compras.'
                        : _isAdminLogin
                        ? 'Acesso restrito à administração de produtos.'
                        : 'Ainda não tem cadastro? Selecione “Cadastrar” para começar.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  if (!_isRegister && !_isAdminLogin) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() {
                        _isAdminLogin = true;
                        _formKey.currentState?.reset();
                        _documentController.clear();
                        _passwordController.clear();
                        _isCompany = true;
                      }),
                      child: const Text(
                        'Entrar como administrador',
                        style: TextStyle(
                          color: Color(0xFFFF737B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ] else if (_isAdminLogin) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => setState(() {
                        _isAdminLogin = false;
                        _formKey.currentState?.reset();
                        _documentController.clear();
                        _passwordController.clear();
                        _isCompany = false;
                      }),
                      child: const Text(
                        'Voltar ao login de cliente',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _modeButton(String label, bool selected, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF303030) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _muted,
              ),
            ),
          ),
        ),
      );

  Widget _typeButton(String label, bool selected, VoidCallback onTap) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : _muted,
          backgroundColor: selected ? const Color(0xFF351518) : _panel,
          side: BorderSide(color: selected ? _red : const Color(0xFF303030)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffix,
  }) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      errorMaxLines: 3,
      prefixIcon: Icon(icon, size: 19, color: _muted),
      suffixIcon: suffix,
      filled: true,
      fillColor: _panel,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF303030)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF303030)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _red, width: 1.3),
      ),
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

bool _validDocument(String input, bool cnpj) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length != (cnpj ? 14 : 11) ||
      RegExp(r'^(\d)\1+$').hasMatch(digits))
    return false;
  if (cnpj) {
    int checkDigit(String value, List<int> weights) {
      final sum = List.generate(
        value.length,
        (i) => int.parse(value[i]) * weights[i],
      ).reduce((a, b) => a + b);
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }

    final first = checkDigit(digits.substring(0, 12), [
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    final second = checkDigit(digits.substring(0, 12) + '$first', [
      6,
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    return digits.endsWith('$first$second');
  }
  int checkDigit(String value, int startWeight) {
    var sum = 0;
    for (var i = 0; i < value.length; i++) {
      sum += int.parse(value[i]) * (startWeight - i);
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  final first = checkDigit(digits.substring(0, 9), 10);
  final second = checkDigit(digits.substring(0, 9) + '$first', 11);
  return digits.endsWith('$first$second');
}
