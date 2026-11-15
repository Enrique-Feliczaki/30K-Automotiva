import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/admin_screen.dart';
import 'package:trinta_k_automotiva/auth_screen.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/main.dart';
import 'package:trinta_k_automotiva/payment_screen.dart';
import 'package:trinta_k_automotiva/product_inventory_screen.dart';
import 'package:trinta_k_automotiva/inventory_screen.dart' as legacy;
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  void clearCart() {
    while (CartStore.instance.items.isNotEmpty) {
      CartStore.instance.remove(0);
    }
  }

  for (final size in [
    const Size(320, 568),
    const Size(667, 375),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Layouts $size, text scale $scale', (tester) async {
        final reportError = FlutterError.onError!;
        FlutterError.onError = (details) {
          debugPrint(details.toString());
          reportError(details);
        };
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        clearCart();
        CartStore.instance.add(
          CartItem(
            name: 'Produto com nome longo para verificar o layout',
            category: 'Shampoos',
            price: 1234.56,
            quantity: 2,
            icon: Icons.local_drink,
          ),
        );
        addTearDown(clearCart);

        Future<void> show(
          Widget screen, {
          Future<void> Function()? interact,
        }) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData.dark(useMaterial3: true),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: screen,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} initial',
          );
          if (interact != null) {
            await interact();
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${screen.runtimeType} interaction',
            );
          }
          final scrollables = find
              .byType(Scrollable)
              .evaluate()
              .where(
                (e) =>
                    (e.widget as Scrollable).axisDirection ==
                    AxisDirection.down,
              );
          if (scrollables.isNotEmpty) {
            final state = tester.state<ScrollableState>(
              find.byWidget(scrollables.last.widget),
            );
            for (var i = 0; i < 10; i++) {
              state.position.jumpTo(
                (state.position.pixels + 250).clamp(
                  0,
                  state.position.maxScrollExtent,
                ),
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: '${screen.runtimeType} scroll $i',
              );
            }
          }
          await tester.pumpWidget(const SizedBox());
        }

        await show(AuthScreen(onAuthenticated: (_) {}));
        await show(HomeScreen(onLogout: () {}, isAdmin: false));
        await show(const CartScreen());
        await show(PaymentScreen(items: CartStore.instance.items));
        await show(const AdminScreen());
        await show(const InventoryScreen());
        await show(const legacy.InventoryScreen());
        await show(
          ProductDetailsScreen(
            product: ProductStore.instance.products.first,
            isAdmin: false,
          ),
        );
        await show(
          AuthScreen(onAuthenticated: (_) {}),
          interact: () async {
            await tester.ensureVisible(find.text('Cadastrar'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Cadastrar'));
            await tester.pumpAndSettle();
            expect(find.text('TIPO DE CADASTRO'), findsOneWidget);
          },
        );
        await show(
          const AdminScreen(),
          interact: () async {
            await tester.tap(find.byTooltip('Adicionar produto'));
          },
        );
        await show(
          PaymentScreen(items: CartStore.instance.items),
          interact: () async {
            await tester.scrollUntilVisible(
              find.text('Cartão de crédito'),
              200,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Cartão de crédito'));
          },
        );
        await show(
          HomeScreen(onLogout: () {}, isAdmin: false),
          interact: () async {
            await tester.tap(find.text('Conta'));
            await tester.pumpAndSettle();
            await tester.scrollUntilVisible(
              find.text('Cadastrar endereço'),
              150,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Cadastrar endereço'));
            await tester.pumpAndSettle();
            expect(find.byType(AlertDialog), findsOneWidget);
          },
        );
        clearCart();
        await show(const CartScreen());
        tester.view.viewInsets = FakeViewPadding(
          bottom: size.height > 500 ? 250 : 120,
        );
        addTearDown(tester.view.resetViewInsets);
        await show(
          AuthScreen(onAuthenticated: (_) {}),
          interact: () async {
            await tester.scrollUntilVisible(
              find.text('Entrar como administrador'),
              120,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Entrar como administrador'));
            await tester.pumpAndSettle();
            expect(find.text('CNPJ'), findsOneWidget);
            expect(find.text('Cadastrar empresa'), findsNothing);
          },
        );
      });
    }
  }
}
