import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinta_k_automotiva/cart_item.dart';
import 'package:trinta_k_automotiva/cart_screen.dart';
import 'package:trinta_k_automotiva/cart_store.dart';
import 'package:trinta_k_automotiva/customer_profile.dart';
import 'package:trinta_k_automotiva/product_store.dart';

void main() {
  final cart = CartStore.instance;
  final products = ProductStore.instance;
  final profile = CustomerProfile.instance;
  late List<CartItem> savedCart;
  late List<StoreProduct> savedProducts;
  late Map<String, dynamic> savedProfile;

  const product = StoreProduct(
    id: 'produto-integracao-carrinho',
    name: 'Cera de integração',
    category: 'Ceras',
    sku: 'INT-CART-001',
    price: 30,
    stock: 5,
    minimumStock: 1,
    icon: Icons.auto_awesome,
  );

  setUp(() {
    savedCart = cart.items;
    savedProducts = products.products;
    savedProfile = profile.toRecord();
    products.restore([product]);
    cart.restore([
      const CartItem(
        productId: 'produto-integracao-carrinho',
        name: 'Cera de integração',
        category: 'Ceras',
        price: 30,
        quantity: 1,
        icon: Icons.auto_awesome,
      ),
    ]);
    profile.restore({'isCompany': false});
  });

  tearDown(() {
    products.restore(savedProducts);
    cart.restore(savedCart);
    profile.restore(savedProfile);
  });

  testWidgets('botão do carrinho atualiza estado, quantidade e subtotal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();

    expect(cart.items.single.quantity, 2);
    expect(cart.subtotal, 60);
    expect(find.text('2 itens'), findsOneWidget);
    expect(find.text('Subtotal atual: R\$ 60,00'), findsOneWidget);
    expect(find.text('R\$ 110,00'), findsNWidgets(2));
  });
}
