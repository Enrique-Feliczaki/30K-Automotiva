import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/payment_screen.dart';

void main() {
  final profile = CustomerProfile.instance;
  late Map<String, String> address;

  const item = CartItem(
    name: 'Cera QA',
    category: 'Ceras',
    price: 59.90,
    quantity: 2,
    icon: Icons.auto_awesome,
  );

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: PaymentScreen(items: [item])));
  }

  setUp(() {
    address = {
      'postalCode': profile.postalCode,
      'state': profile.state,
      'city': profile.city,
      'neighborhood': profile.neighborhood,
      'street': profile.street,
      'houseNumber': profile.houseNumber,
    };
    profile
      ..postalCode = ''
      ..state = ''
      ..city = ''
      ..neighborhood = ''
      ..street = ''
      ..houseNumber = '';
  });

  tearDown(() {
    profile
      ..postalCode = address['postalCode']!
      ..state = address['state']!
      ..city = address['city']!
      ..neighborhood = address['neighborhood']!
      ..street = address['street']!
      ..houseNumber = address['houseNumber']!;
  });

  testWidgets('QA-100 checkout apresenta resumo e pagamento pix', (tester) async {
    await open(tester);
    expect(find.text('Finalizar pedido'), findsOneWidget);
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Continuar para o Pix'), findsOneWidget);
    expect(find.text('Produtos (2 itens)'), findsOneWidget);
    expect(find.text('R\$ 119,80'), findsWidgets);
  });

  testWidgets('QA-101 checkout apresenta campos de endereco', (tester) async {
    await open(tester);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Receber em casa'), findsOneWidget);
  });

  testWidgets('QA-102 alterna de pix para cartao', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cartão de crédito'));
    await tester.pump();
    expect(find.text('Confirmar pagamento'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(10));
  });

  testWidgets('QA-103 volta do cartao para pix', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cartão de crédito'));
    await tester.pump();
    await tester.tap(find.text('Pix'));
    await tester.pump();
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Continuar para o Pix'), findsOneWidget);
  });

  testWidgets('QA-104 checkout vazio acusa CEP invalido', (tester) async {
    await open(tester);
    await tester.tap(find.text('Continuar para o Pix'));
    await tester.pump();
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(find.text('Campo obrigatório'), findsNWidgets(5));
  });

  testWidgets('QA-105 checkout com CEP incorreto impede confirmacao', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField).at(0), '123');
    await tester.tap(find.text('Continuar para o Pix'));
    await tester.pump();
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(find.text('Tudo certo!'), findsNothing);
  });

  testWidgets('QA-106 cartao vazio exige numero e CVV', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cartão de crédito'));
    await tester.pump();
    await tester.tap(find.text('Confirmar pagamento'));
    await tester.pump();
    expect(find.text('Confira o número do cartão'), findsOneWidget);
    expect(find.text('Confira o CVV'), findsOneWidget);
  });

  testWidgets('QA-107 endereco valido permite confirmar fluxo simulado', (tester) async {
    await open(tester);
    const values = ['85010-000', 'PR', 'Guarapuava', 'Centro', 'Rua Teste', '100'];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.tap(find.text('Continuar para o Pix'));
    await tester.pump();
    expect(find.text('Tudo certo!'), findsOneWidget);
    expect(profile.postalCode, '85010-000');
    expect(profile.city, 'Guarapuava');
  });
}
