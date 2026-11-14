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

  Future<void> open(WidgetTester tester, {bool admin = false, VoidCallback? logout}) async {
    tester.view.physicalSize = const Size(1100, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    navigationObserver.lastPushedRoute = null;
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(isAdmin: admin, onLogout: logout ?? () {}),
      navigatorObservers: [navigationObserver],
    ));
    await tester.pumpAndSettle();
  }

  setUp(() {
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
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Conta'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('QA-128 administrador ve acesso a gestao', (tester) async {
    await open(tester, admin: true);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('QA-129 cliente acessa sacola pelo cabecalho', (tester) async {
    await open(tester);
    final icon = find.byIcon(Icons.shopping_bag_outlined).first;
    final action = find.ancestor(
      of: icon,
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(navigationObserver.lastPushedRoute, isNotNull,
        reason: 'O ícone da sacola não abriu uma nova rota');
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
    expect(find.text('Informe seu endereço ao finalizar um pedido.'), findsOneWidget);
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
    expect(navigationObserver.lastPushedRoute, isNotNull,
        reason: 'O item Admin não abriu uma nova rota');
    expect(find.byType(AdminScreen), findsOneWidget);
  });

  testWidgets('QA-134 formulario de endereco impede CEP invalido', (tester) async {
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

  testWidgets('QA-135 cancela cadastro de endereco sem alterar perfil', (tester) async {
    await open(tester);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    await tester.tap(find.text('Cadastrar endereço'));
    await tester.pump();
    await tester.tap(find.text('Cancelar'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    expect(profile.address, isEmpty);
  });
}
