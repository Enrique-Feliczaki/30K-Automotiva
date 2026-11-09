import 'package:flutter/material.dart';

import 'customer_profile.dart';

const _red = Color(0xFFE11D2E);
const _panel = Color(0xFF171717);
const _muted = Color(0xFF92979D);

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
  bool _isAdminRegister = false;
  bool _isCompany = false;
  bool _obscurePassword = true;
  static String? _registeredEmail;
  static String? _registeredPassword;
  static final Set<String> _registeredEmails = {};
  static final Set<String> _registeredDocuments = {};
  static String? _adminEmail;
  static String? _adminPassword;
  static String? _adminCompanyName;
  static String? _adminCnpj;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_isAdminLogin) {
      if (_isAdminRegister) {
        final email = _emailController.text.trim().toLowerCase();
        final document = _documentController.text.replaceAll(RegExp(r'\D'), '');
        final duplicate = _duplicateRegistrationMessage(email, document);
        if (duplicate != null) {
          _showMessage(duplicate);
          return;
        }
        _adminCompanyName = _nameController.text.trim();
        _adminEmail = email;
        _adminCnpj = document;
        _adminPassword = _passwordController.text;
        _registeredEmails.add(email);
        _registeredDocuments.add(document);
        setState(() {
          _isAdminRegister = false;
          _passwordController.clear();
        });
        _showMessage('Empresa ${_adminCompanyName} (CNPJ ${_adminCnpj}) cadastrada. Entre com o e-mail e a senha cadastrados.');
        return;
      }
      if (_adminEmail == null ||
          _emailController.text.trim().toLowerCase() != _adminEmail ||
          _passwordController.text != _adminPassword) {
        _showMessage('E-mail ou senha de administrador incorretos.');
        return;
      }
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
      final profile = CustomerProfile.instance;
      profile
        ..name = _nameController.text.trim()
        ..email = _emailController.text.trim()
        ..document = _documentController.text.trim()
        ..isCompany = _isCompany;
      _registeredEmail = email;
      _registeredPassword = _passwordController.text;
      _registeredEmails.add(email);
      _registeredDocuments.add(document);
      setState(() => _isRegister = false);
      _showMessage('Cadastro criado. Faça login para continuar.');
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    if (email != _registeredEmail || _passwordController.text != _registeredPassword) {
      _showMessage('e-mail ou senha incorretos.');
      return;
    }

    widget.onAuthenticated(false);
  }

  String? _duplicateRegistrationMessage(String email, String document) {
    final profile = CustomerProfile.instance;
    final knownEmails = {..._registeredEmails, if (_registeredEmail != null) _registeredEmail!, if (_adminEmail != null) _adminEmail!};
    final knownDocuments = {
      ..._registeredDocuments,
      if (profile.document.isNotEmpty) profile.document.replaceAll(RegExp(r'\D'), ''),
      if (_adminCnpj != null) _adminCnpj!,
    };
    if (knownEmails.contains(email)) return 'Já existe um usuário cadastrado com esse e-mail.';
    if (knownDocuments.contains(document)) {
      return document.length == 14
          ? 'Já existe um usuário cadastrado com esse CNPJ.'
          : 'Já existe um usuário cadastrado com esse CPF.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Entre na sua conta ou crie seu cadastro',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 28),
                if (!_isAdminLogin) Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    _modeButton('Entrar', !_isRegister && !_isAdminLogin, () => setState(() { _isRegister = false; _isAdminLogin = false; })),
                    _modeButton('Cadastrar', _isRegister, () => setState(() { _isRegister = true; _isAdminLogin = false; _isCompany = false; })),
                  ]),
                ) else Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    _modeButton('Entrar admin', !_isAdminRegister, () => setState(() => _isAdminRegister = false)),
                    _modeButton('Cadastrar empresa', _isAdminRegister, () => setState(() => _isAdminRegister = true)),
                  ]),
                ),
                const SizedBox(height: 22),
                if (_isRegister) ...[
                  const Text('TIPO DE CADASTRO', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 9),
                  Row(children: [
                    Expanded(child: _typeButton('Pessoa física', !_isCompany, () => setState(() { _isCompany = false; _documentController.clear(); _nameController.clear(); }))),
                    const SizedBox(width: 10),
                    Expanded(child: _typeButton('Pessoa jurídica', _isCompany, () => setState(() { _isCompany = true; _documentController.clear(); _nameController.clear(); }))),
                  ]),
                  const SizedBox(height: 18),
                ],
                Form(
                  key: _formKey,
                  child: Column(children: [
                    if (_isRegister || _isAdminRegister) ...[
                      _field(
                        controller: _nameController,
                        label: _isCompany ? 'Razão social' : 'Nome completo',
                        icon: _isCompany ? Icons.business_outlined : Icons.person_outline,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe ${_isCompany ? 'a razão social' : 'seu nome'}' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    _field(
                      controller: _emailController,
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (!_isRegister && !_isAdminRegister) return email.isEmpty ? 'Informe seu e-mail' : null;
                        return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ? null : 'Informe um e-mail válido';
                      },
                    ),
                    if (_isRegister || _isAdminRegister) ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _documentController,
                        label: _isCompany ? 'CNPJ' : 'CPF',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) => _validDocument(value ?? '', _isCompany) ? null : 'Informe um ${_isCompany ? 'CNPJ' : 'CPF'} válido',
                      ),
                    ],
                    const SizedBox(height: 14),
                    _field(
                      controller: _passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _muted, size: 20),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (!_isRegister && !_isAdminRegister) return password.isEmpty ? 'Informe sua senha' : null;
                        return password.length >= 6 ? null : 'A senha deve ter pelo menos 6 caracteres';
                      },
                    ),
                  ]),
                ),
                if (!_isRegister && !_isAdminRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => _showMessage('Entre em contato com o suporte para redefinir sua senha.'), child: const Text('Esqueci minha senha', style: TextStyle(color: _muted, fontSize: 12))),
                  )
                else
                  const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(backgroundColor: _red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                    child: Text(_isRegister || _isAdminRegister ? 'Criar cadastro' : 'Entrar', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _isAdminRegister
                      ? 'Cadastre a empresa administradora para liberar o acesso de gestão.'
                      : _isRegister
                      ? 'Ao criar seu cadastro, você poderá acompanhar suas compras.'
                      : _isAdminLogin
                          ? 'Acesso restrito à administração de produtos.'
                          : 'Ainda não tem cadastro? Selecione “Cadastrar” para começar.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 11, height: 1.4),
                ),
                if (!_isRegister && !_isAdminLogin) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => setState(() { _isAdminLogin = true; _isAdminRegister = false; _isCompany = true; }),
                    child: const Text('Entrar como administrador', style: TextStyle(color: Color(0xFFFF737B), fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ] else if (_isAdminLogin) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => setState(() { _isAdminLogin = false; _isAdminRegister = false; _isCompany = false; }),
                    child: const Text('Voltar ao login de cliente', style: TextStyle(color: _muted, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _modeButton(String label, bool selected, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? const Color(0xFF303030) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : _muted)),
      ),
    ),
  );

  Widget _typeButton(String label, bool selected, VoidCallback onTap) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: selected ? Colors.white : _muted,
      backgroundColor: selected ? const Color(0xFF351518) : _panel,
      side: BorderSide(color: selected ? _red : const Color(0xFF303030)),
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardType,
    obscureText: obscureText,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 19, color: _muted),
      suffixIcon: suffix,
      filled: true,
      fillColor: _panel,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFF303030))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFF303030))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _red, width: 1.3)),
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

bool _validDocument(String input, bool cnpj) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length != (cnpj ? 14 : 11) || RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;
  if (cnpj) {
    int checkDigit(String value, List<int> weights) {
      final sum = List.generate(value.length, (i) => int.parse(value[i]) * weights[i]).reduce((a, b) => a + b);
      final remainder = sum % 11;
      return remainder < 2 ? 0 : 11 - remainder;
    }
    final first = checkDigit(digits.substring(0, 12), [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
    final second = checkDigit(digits.substring(0, 12) + '$first', [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]);
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
