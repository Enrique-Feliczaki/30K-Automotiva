import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/main.dart';
import 'package:trinta_k_automotiva/auth_screen.dart';

void main() {
  testWidgets('Aplica as máscaras de CPF e CNPJ no cadastro', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    Finder document(String label) => find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    );
    await tester.ensureVisible(document('CPF'));
    await tester.pumpAndSettle();
    await tester.enterText(document('CPF'), '52998224725');
    expect(find.text('529.982.247-25'), findsOneWidget);
    await tester.ensureVisible(find.text('Pessoa jurídica'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pessoa jurídica'));
    await tester.pumpAndSettle();
    expect(find.text('529.982.247-25'), findsNothing);
    await tester.ensureVisible(document('CNPJ'));
    await tester.pumpAndSettle();
    await tester.enterText(document('CNPJ'), '11222333000181');
    expect(find.text('11.222.333/0001-81'), findsOneWidget);
  });

  testWidgets('QA-26 abre a tela de autenticação', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('30K AUTOMOTIVA'), findsOneWidget);
  });

  testWidgets('QA-27 apresenta opções de entrar e cadastrar', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('QA-28 valida o formulário de login vazio', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });

  testWidgets('QA-29 permite abrir o cadastro', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();
    expect(find.text('TIPO DE CADASTRO'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Criar cadastro'), findsOneWidget);
  });

  testWidgets('QA-30 permite acessar a tela de administrador', (tester) async {
    await tester.pumpWidget(const TrintaKApp());
    await tester.ensureVisible(find.text('Entrar como administrador'));
    await tester.tap(find.text('Entrar como administrador'));
    await tester.pump();
    expect(find.text('Entrar admin'), findsOneWidget);
    expect(find.text('Cadastrar empresa'), findsNothing);
    expect(find.text('CNPJ'), findsOneWidget);
  });
}
