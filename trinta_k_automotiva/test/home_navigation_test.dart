import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/admin_screen.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/main.dart';

class _NavigationObserver extends NavigatorObserver {
  Route<dynamic>? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      lastPushedRoute = route;
    }
    super.didPush(route, previousRoute);
  }
}

void main() {
  final navigationObserver = _NavigationObserver();
  final profile = CustomerProfile.instance;
  late Map<String, String> saved;
  late bool savedIsCompany;

  Future<void> open(
    WidgetTester tester, {
    bool admin = false,
    VoidCallback? logout,
    Size size = const Size(1100, 1800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    navigationObserver.lastPushedRoute = null;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(isAdmin: admin, onLogout: logout ?? () {}),
        navigatorObservers: [navigationObserver],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    savedIsCompany = profile.isCompany;
    saved = {
      'name': profile.name,
      'document': profile.document,
      'email': profile.email,
      'postalCode': profile.postalCode,
      'state': profile.state,
      'city': profile.city,
      'neighborhood': profile.neighborhood,
      'street': profile.street,
      'houseNumber': profile.houseNumber,
    };
    profile
      ..isCompany = false
      ..name = ''
      ..document = ''
      ..email = ''
      ..postalCode = ''
      ..state = ''
      ..city = ''
      ..neighborhood = ''
      ..street = ''
      ..houseNumber = '';
  });

  tearDown(() {
    profile
      ..isCompany = savedIsCompany
      ..name = saved['name']!
      ..document = saved['document']!
      ..email = saved['email']!
      ..postalCode = saved['postalCode']!
      ..state = saved['state']!
      ..city = saved['city']!
      ..neighborhood = saved['neighborhood']!
      ..street = saved['street']!
      ..houseNumber = saved['houseNumber']!;
  });

  testWidgets('QA-127 cliente ve navegacao sem admin', (tester) async {
    await open(tester);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Favoritos'), findsNothing);
    expect(find.text('Conta'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('QA-128 administrador ve acesso a gestao', (tester) async {
    await open(tester, admin: true);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('pessoa juridica navega sem acesso a administracao', (
    tester,
  ) async {
    profile.isCompany = true;
    await open(tester);
    await tester.ensureVisible(find.text('COMPRE POR CATEGORIA'));
    await tester.pumpAndSettle();
    expect(find.text('Gerenciar'), findsNothing);
    expect(find.text('Admin'), findsNothing);
    expect(find.byType(AdminScreen), findsNothing);
    await tester.tap(find.text('Conta'));
    await tester.pumpAndSettle();
    expect(find.text('Minha conta'), findsOneWidget);
    expect(find.text('Gerenciar'), findsNothing);
    expect(find.text('Admin'), findsNothing);
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('Gerenciar'), findsNothing);
    expect(find.byType(AdminScreen), findsNothing);
    expect(navigationObserver.lastPushedRoute, isNull);
  });

  testWidgets('somente administrador acessa painel pelo botao Gerenciar', (
    tester,
  ) async {
    await open(tester, admin: true);
    await tester.ensureVisible(find.text('Gerenciar'));
    await tester.tap(find.text('Gerenciar'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminScreen), findsOneWidget);
  });

  testWidgets('QA-129 cliente acessa sacola pelo cabecalho', (tester) async {
    await open(tester);
    final icon = find.byIcon(Icons.shopping_bag_outlined).first;
    final action = find
        .ancestor(of: icon, matching: find.byType(InkWell))
        .first;
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(
      navigationObserver.lastPushedRoute,
      isNotNull,
      reason: 'O ícone da sacola não abriu uma nova rota',
    );
    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('QA-130 cliente acessa area da conta', (tester) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    expect(find.text('Minha conta'), findsOneWidget);
    expect(find.text('Informações pessoais'), findsOneWidget);
  });

  testWidgets('QA-131 conta vazia solicita endereco', (tester) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    expect(
      find.text('Informe seu endereço ao finalizar um pedido.'),
      findsOneWidget,
    );
    expect(find.text('Cadastrar endereço'), findsOneWidget);
  });

  testWidgets('QA-132 sair da conta chama logout', (tester) async {
    var loggedOut = false;
    await open(tester, logout: () => loggedOut = true);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Sair da conta'));
    await tester.pump();
    expect(loggedOut, isTrue);
  });

  testWidgets('QA-133 administrador abre painel pelo menu', (tester) async {
    await open(tester, admin: true);
    final destination = find.byWidgetPredicate(
      (widget) => widget is NavigationDestination && widget.label == 'Admin',
    );
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(
      navigationObserver.lastPushedRoute,
      isNotNull,
      reason: 'O item Admin não abriu uma nova rota',
    );
    expect(find.byType(AdminScreen), findsOneWidget);
  });

  testWidgets('QA-134 formulario de endereco impede CEP invalido', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pump();
    await tester.tap(find.text('Salvar endereço'));
    await tester.pump();
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('QA-135 cancela cadastro de endereco sem alterar perfil', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '12345678');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Minha conta'), findsOneWidget);
    expect(profile.address, isEmpty);

    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .initialValue,
      isEmpty,
    );
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('simbolos no endereco impedem salvar sem alterar perfil', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    final values = ['12345@678', '@@', 'Cidade@', 'Bairro#', 'Rua!', '10@'];
    for (var index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }
    await tester.tap(find.text('Salvar endereço'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Informe um CEP válido'), findsOneWidget);
    expect(find.text('Informe a sigla do estado com 2 letras'), findsOneWidget);
    expect(find.text('Use apenas letras, números e espaços'), findsNWidgets(3));
    expect(profile.address, isEmpty);
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Minha conta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('salva endereco e retorna ao perfil sem erros', (tester) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    final values = ['12345678', 'sp', 'São Paulo', 'Centro', 'Rua Teste', '10'];
    for (var index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }
    await tester.tap(find.text('Salvar endereço'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Minha conta'), findsOneWidget);
    expect(profile.postalCode, '12345678');
    expect(profile.state, 'SP');
    expect(profile.city, 'São Paulo');
    expect(profile.neighborhood, 'Centro');
    expect(profile.street, 'Rua Teste');
    expect(profile.houseNumber, '10');
  });

  testWidgets('campos de endereco usam o mesmo estilo e limitam o numero', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pumpAndSettle();

    InputDecoration decoration(String label) => tester
        .widget<TextField>(
          find.descendant(
            of: find.widgetWithText(TextFormField, label),
            matching: find.byType(TextField),
          ),
        )
        .decoration!;

    final cityDecoration = decoration('Cidade');
    final neighborhoodDecoration = decoration('Bairro');
    expect(cityDecoration.fillColor, neighborhoodDecoration.fillColor);
    expect(cityDecoration.enabledBorder, neighborhoodDecoration.enabledBorder);
    expect(cityDecoration.errorBorder, neighborhoodDecoration.errorBorder);

    final numberFinder = find.widgetWithText(TextFormField, 'Número');
    await tester.enterText(numberFinder, '123456789012345');
    final numberInput = tester.widget<EditableText>(
      find.descendant(of: numberFinder, matching: find.byType(EditableText)),
    );
    expect(numberInput.controller.text, '123456');
  });

  testWidgets('cancelar alteracao de endereco repetidamente nao gera erro', (
    tester,
  ) async {
    profile
      ..postalCode = '85010-000'
      ..state = 'PR'
      ..city = 'Guarapuava'
      ..neighborhood = 'Centro'
      ..street = 'Rua Teste'
      ..houseNumber = '100';
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();

    for (var attempt = 0; attempt < 5; attempt++) {
      await tester.tap(find.text('Alterar endereço'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Cidade'));
      await tester.pump();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'tentativa $attempt');
      expect(find.byType(AlertDialog), findsNothing);
    }
  });

  testWidgets('botao explorar produtos rola ate os produtos disponiveis', (
    tester,
  ) async {
    await open(tester, size: const Size(390, 700));

    await tester.tap(find.text('Explorar produtos'));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, greaterThan(0));
    expect(find.text('PRODUTOS'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('PRODUTOS')).dy,
      greaterThanOrEqualTo(0),
    );
    expect(
      tester.getBottomRight(find.text('PRODUTOS')).dy,
      lessThanOrEqualTo(700),
    );
  });
}
