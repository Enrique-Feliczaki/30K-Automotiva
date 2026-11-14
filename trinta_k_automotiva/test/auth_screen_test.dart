import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/auth_screen.dart';

void main() {
  Future<void> open(WidgetTester tester, ValueChanged<bool> callback) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: AuthScreen(onAuthenticated: callback)));
  }

  Future<void> submit(WidgetTester tester, String title) async {
    final button = find.widgetWithText(FilledButton, title);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('QA-40 impede login sem email', (tester) async {
    await open(tester, (_) {});
    await submit(tester, 'Entrar');
    expect(find.text('Informe seu e-mail'), findsOneWidget);
  });

  testWidgets('QA-41 impede login sem senha', (tester) async {
    await open(tester, (_) {});
    await submit(tester, 'Entrar');
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('QA-73 renderiza login de cliente', (tester) async {
    await open(tester, (_) {});
    expect(find.text('30K AUTOMOTIVA'), findsOneWidget);
    expect(find.text('Esqueci minha senha'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('QA-74 login vazio apresenta os dois erros', (tester) async {
    await open(tester, (_) {});
    await submit(tester, 'Entrar');
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('QA-75 login com email e senha vazia exige senha', (tester) async {
    await open(tester, (_) {});
    await tester.enterText(find.byType(TextFormField).at(0), 'alguem@example.com');
    await submit(tester, 'Entrar');
    expect(find.text('Informe sua senha'), findsOneWidget);
    expect(find.text('Informe seu e-mail'), findsNothing);
  });

  testWidgets('QA-76 login com senha e email vazio exige email', (tester) async {
    await open(tester, (_) {});
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await submit(tester, 'Entrar');
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsNothing);
  });

  testWidgets('QA-77 login incorreto nao autentica', (tester) async {
    bool? authenticated;
    await open(tester, (isAdmin) => authenticated = isAdmin);
    await tester.enterText(find.byType(TextFormField).at(0), 'desconhecido.qa@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha-incorreta');
    await submit(tester, 'Entrar');
    expect(find.text('e-mail ou senha incorretos.'), findsOneWidget);
    expect(authenticated, isNull);
  });

  testWidgets('QA-78 alterna entre login e cadastro', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    expect(find.text('TIPO DE CADASTRO'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    await tester.tap(find.text('Entrar').first);
    await tester.pump();
    expect(find.text('Esqueci minha senha'), findsOneWidget);
  });

  testWidgets('QA-79 cadastro vazio exige nome email CPF e senha', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await submit(tester, 'Criar cadastro');
    expect(find.text('Informe seu nome'), findsOneWidget);
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(find.text('Informe um CPF válido'), findsOneWidget);
    expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
  });

  testWidgets('QA-80 cadastro rejeita email sem formato valido', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), 'email-invalido');
    await submit(tester, 'Criar cadastro');
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
  });

  testWidgets('QA-81 cadastro rejeita CPF invalido', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(2), '11111111111');
    await submit(tester, 'Criar cadastro');
    expect(find.text('Informe um CPF válido'), findsOneWidget);
  });

  testWidgets('QA-82 cadastro rejeita senha com menos de seis caracteres', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(3), '12345');
    await submit(tester, 'Criar cadastro');
    expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
  });

  testWidgets('QA-83 cadastro de empresa exige razao social e CNPJ', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    await tester.tap(find.text('Pessoa jurídica'));
    await tester.pump();
    await submit(tester, 'Criar cadastro');
    expect(find.text('Informe a razão social'), findsOneWidget);
    expect(find.text('Informe um CNPJ válido'), findsOneWidget);
  });

  testWidgets('QA-84 senha pode ser mostrada e ocultada', (tester) async {
    await open(tester, (_) {});
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
  });

  testWidgets('QA-85 recuperacao de senha mostra orientacao', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pump();
    expect(find.text('Entre em contato com o suporte para redefinir sua senha.'), findsOneWidget);
  });

  testWidgets('QA-86 admin invalido nao recebe acesso', (tester) async {
    bool? authenticated;
    await open(tester, (isAdmin) => authenticated = isAdmin);
    await tester.tap(find.text('Entrar como administrador'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), 'admin-inexistente.qa@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha-invalida');
    await submit(tester, 'Entrar');
    expect(find.text('E-mail ou senha de administrador incorretos.'), findsOneWidget);
    expect(authenticated, isNull);
  });

  testWidgets('QA-87 acessa cadastro administrativo e retorna', (tester) async {
    await open(tester, (_) {});
    await tester.tap(find.text('Entrar como administrador'));
    await tester.pump();
    expect(find.text('Entrar admin'), findsOneWidget);
    await tester.tap(find.text('Cadastrar empresa'));
    await tester.pump();
    expect(find.text('Criar cadastro'), findsOneWidget);
    await tester.tap(find.text('Voltar ao login de cliente'));
    await tester.pump();
    expect(find.text('Entrar como administrador'), findsOneWidget);
  });

  testWidgets('QA-88 cadastro e autenticacao de cliente funcionam', (tester) async {
    bool? authenticated;
    await open(tester, (isAdmin) => authenticated = isAdmin);
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Cliente Teste');
    await tester.enterText(fields.at(1), 'qa.cliente.88@example.com');
    await tester.enterText(fields.at(2), '52998224725');
    await tester.enterText(fields.at(3), 'senha123');
    await submit(tester, 'Criar cadastro');
    expect(find.text('Cadastro criado. Faça login para continuar.'), findsOneWidget);
    await submit(tester, 'Entrar');
    expect(authenticated, isFalse);
  });

  testWidgets('QA-89 cadastro administrativo autentica como administrador', (tester) async {
    bool? authenticated;
    await open(tester, (isAdmin) => authenticated = isAdmin);
    await tester.tap(find.text('Entrar como administrador'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar empresa'));
    await tester.pump();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Empresa Teste QA');
    await tester.enterText(fields.at(1), 'qa.admin.89@example.com');
    await tester.enterText(fields.at(2), '11222333000181');
    await tester.enterText(fields.at(3), 'senha456');
    await submit(tester, 'Criar cadastro');
    expect(find.text('Entrar admin'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'senha456');
    await submit(tester, 'Entrar');
    expect(authenticated, isTrue);
  });
}
