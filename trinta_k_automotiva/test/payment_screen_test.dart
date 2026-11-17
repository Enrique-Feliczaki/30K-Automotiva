import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/payment_screen.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final profile = CustomerProfile.instance;
  late Map<String, String> address;
  late List<StoreProduct> savedProducts;
  late List<CartItem> savedCart;

  const item = CartItem(
    productId: 'cera-liquida',
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
    await tester.pumpWidget(
      MaterialApp(home: const PaymentScreen(items: [item])),
    );
  }

  setUp(() {
    savedProducts = ProductStore.instance.products;
    savedCart = CartStore.instance.items;
    ProductStore.instance.setStock(item.productId!, 7);
    CartStore.instance.restore([item]);
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
    ProductStore.instance.restore(savedProducts);
    CartStore.instance.restore(savedCart);
    profile
      ..postalCode = address['postalCode']!
      ..state = address['state']!
      ..city = address['city']!
      ..neighborhood = address['neighborhood']!
      ..street = address['street']!
      ..houseNumber = address['houseNumber']!;
  });

  testWidgets('QA-100 checkout apresenta resumo e pagamento pix', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Finalizar pedido'), findsOneWidget);
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Continuar para o Pix'), findsOneWidget);
    expect(find.text('Produtos (2 itens)'), findsOneWidget);
    expect(find.text('R\$ 119,80'), findsWidgets);
    expect(find.text('R\$ 50,00'), findsOneWidget);
    expect(find.text('R\$ 169,80'), findsOneWidget);
    expect(find.text('Total parcial'), findsNothing);
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

  testWidgets('validade insere barra ao digitar somente quatro numeros', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Cartão de crédito'));
    await tester.pump();
    final field = find.widgetWithText(TextFormField, 'Validade');
    await tester.enterText(field, '1230');
    final editable = tester.widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    );
    expect(editable.controller.text, '12/30');
    expect(editable.keyboardType, TextInputType.number);
    expect(tester.widget<TextFormField>(field).validator!('12/30'), isNull);
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

  testWidgets('QA-105 checkout com CEP incorreto impede confirmacao', (
    tester,
  ) async {
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

  testWidgets(
    'cartao exige comprimentos exatos e validade nos limites pedidos',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('Cartão de crédito'));
      await tester.pump();

      TextFormField field(String label) => tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, label),
      );

      final name = field('Nome impresso no cartão').validator!;
      for (final value in [
        '',
        '   ',
        'João 123',
        'Maria@Silva',
        '１２３',
        '\u0301',
      ]) {
        expect(name(value), isNotNull, reason: value);
      }
      expect(name('João da Conceição'), isNull);
      expect(name('Jose\u0301 Silva'), isNull);

      final number = field('Número do cartão').validator!;
      for (final value in [
        '',
        '123456789012345',
        '12345678901234567',
        '123456789012345a',
      ]) {
        expect(number(value), isNotNull, reason: value);
      }
      expect(number('1234567890123456'), isNull);

      final cvv = field('CVV').validator!;
      for (final value in ['', '12', '1234', '1a3', '   ']) {
        expect(cvv(value), isNotNull, reason: value);
      }
      expect(cvv('012'), isNull);

      final expiry = field('Validade').validator!;
      for (final value in ['01/26', '12/36', '06/30']) {
        expect(expiry(value), isNull, reason: value);
      }
      for (final value in [
        '',
        '00/26',
        '13/26',
        '01/25',
        '12/37',
        '1/26',
        '01/2026',
        '0126',
        'aa/bb',
      ]) {
        expect(expiry(value), isNotNull, reason: value);
      }

      for (final entry in {
        'Nome impresso no cartão': ['João 123 & Silva! １２３', 'João   Silva '],
        'Número do cartão': ['1234567890123456a7', '1234567890123456'],
        'CVV': ['0a123', '012'],
        'Validade': ['01/26a7', '01/26'],
      }.entries) {
        final finder = find.widgetWithText(TextFormField, entry.key);
        await tester.enterText(finder, entry.value.first);
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: finder,
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          entry.value.last,
        );
      }
    },
  );
}
