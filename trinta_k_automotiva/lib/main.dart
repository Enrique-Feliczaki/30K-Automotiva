import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'cart_screen.dart';
import 'cart_store.dart';
import 'admin_screen.dart';
import 'product_store.dart';

void main() => runApp(const TrintaKApp());

const _bg = Color(0xFF0A0A0A);
const _panel = Color(0xFF171717);
const _panel2 = Color(0xFF202020);
const _red = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);

class TrintaKApp extends StatelessWidget {
  const TrintaKApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '30K Automotiva',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        primary: _red,
        surface: _panel,
        onSurface: Color(0xFFF2F2F2),
      ),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  int _category = 0;
  final _categories = const [
    'Todos',
    'Shampoos',
    'Polimento',
    'Ceras',
    'Acessórios',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _search()),
          SliverToBoxAdapter(child: _hero()),
          SliverToBoxAdapter(child: _categoriesSection()),
          SliverToBoxAdapter(child: _offersSection()),
          SliverToBoxAdapter(child: _benefitStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      height: 64,
      selectedIndex: _tab,
      backgroundColor: const Color(0xFF111111),
      indicatorColor: const Color(0xFF351518),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        if (index == 1) {
          Navigator.of(context)
              .push(
                MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
              )
              .then((_) {
                if (mounted) setState(() => _tab = 0);
              });
          return;
        }
        setState(() => _tab = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Conta',
        ),
      ],
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            'assets/images/logo30k.png',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '30K AUTOMOTIVA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'O cuidado que seu carro merece',
                style: TextStyle(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        _roundAction(Icons.favorite_border),
        const SizedBox(width: 8),
        _cartButton(),
      ],
    ),
  );

  Widget _roundAction(IconData icon, {VoidCallback? onTap}) => Material(
    color: _panel2,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: _silver, size: 19),
      ),
    ),
  );

  Widget _cartButton() => ListenableBuilder(
    listenable: CartStore.instance,
    builder: (context, _) => Stack(
      clipBehavior: Clip.none,
      children: [
        _roundAction(
          Icons.shopping_bag_outlined,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
        ),
        if (CartStore.instance.unitCount > 0)
          Positioned(
            right: -2,
            top: -3,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(
                color: _red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${CartStore.instance.unitCount}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _search() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const TextField(
        style: TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'O que você está procurando?',
          hintStyle: TextStyle(color: _muted, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: _silver, size: 20),
          suffixIcon: Icon(Icons.tune, color: _muted, size: 19),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    ),
  );

  Widget _hero() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF292A2B), Color(0xFF121212), Color(0xFF080808)],
        ),
        border: Border.all(color: const Color(0xFF343434)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -38,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withValues(alpha: .10),
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: 13,
            child: Icon(
              Icons.directions_car_filled,
              size: 190,
              color: Colors.white.withValues(alpha: .10),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 51,
            child: Icon(
              Icons.directions_car_filled,
              size: 145,
              color: const Color(0xFF777B80).withValues(alpha: .28),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 21, 20, 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'PERFORMANCE & CUIDADO',
                    style: TextStyle(
                      color: Color(0xFFFF777F),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Seu carro\nno melhor estado.',
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Produtos profissionais para um brilho\nque chama atenção.',
                  style: TextStyle(
                    color: Color(0xFFB5B7BA),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => setState(() => _tab = 1),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explorar produtos',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _categoriesSection() => Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('COMPRE POR CATEGORIA', 'Ver todas'),
        const SizedBox(height: 13),
        SizedBox(
          height: 91,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final active = index == _category;
              const icons = [
                Icons.grid_view_rounded,
                Icons.water_drop_outlined,
                Icons.auto_fix_high,
                Icons.wb_sunny_outlined,
                Icons.handyman_outlined,
              ];
              return GestureDetector(
                onTap: () => setState(() => _category = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: index == 0 ? 70 : 91,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF351518) : _panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? _red : const Color(0xFF292929),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 23,
                        color: active ? const Color(0xFFFF6A72) : _silver,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _categories[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: active
                              ? Colors.white
                              : const Color(0xFFB6B8BB),
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, String action) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.15,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AdminScreen())),
          child: const Row(
            children: [
              Text('Gerenciar', style: TextStyle(fontSize: 10, color: _silver)),
              SizedBox(width: 3),
              Icon(Icons.chevron_right, size: 15, color: _silver),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _offersSection() => ListenableBuilder(
    listenable: ProductStore.instance,
    builder: (context, _) {
      final products = ProductStore.instance.products;
      return Padding(
        padding: const EdgeInsets.only(top: 27),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: _red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'OFERTAS DA SEMANA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF351518),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'CUIDADO PROFISSIONAL',
                      style: TextStyle(
                        color: Color(0xFFFF777F),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Novos produtos em breve.',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              )
            else
              SizedBox(
                height: 224,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 11),
                  itemBuilder: (context, index) =>
                      _catalogProductCard(products[index]),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _legacyOffersSection() => Padding(
    padding: const EdgeInsets.only(top: 27),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: _red, size: 18),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'OFERTAS DA SEMANA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF351518),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'ATÉ 25% OFF',
                  style: TextStyle(
                    color: Color(0xFFFF777F),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 224,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) => _legacyProductCard(index),
          ),
        ),
      ],
    ),
  );

  Widget _legacyProductCard(int index) {
    const names = [
      'Shampoo Neutro\nConcentrado 1,5L',
      'Cera Líquida\nUltra brilho 500ml',
      'Revitalizador\nde pneus 500ml',
    ];
    const prices = ['R\$ 59,90', 'R\$ 79,90', 'R\$ 42,90'];
    const old = ['R\$ 74,90', 'R\$ 99,90', 'R\$ 54,90'];
    const numericPrices = [59.90, 79.90, 42.90];
    const categories = [
      'Shampoo automotivo',
      'Cera para pintura',
      'Cuidados com pneus',
    ];
    const icons = [
      Icons.local_drink_outlined,
      Icons.auto_awesome,
      Icons.tire_repair,
    ];
    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF292929)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 112,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF393B3E), Color(0xFF141414)],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xFF62666B)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icons[index], color: _silver, size: 30),
                        const SizedBox(height: 4),
                        Text(
                          '30K',
                          style: TextStyle(
                            color: index == 1
                                ? const Color(0xFFFF5B63)
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(left: 8, top: 8, child: _OfferTag()),
              Positioned(
                right: 7,
                top: 7,
                child: Icon(
                  Icons.favorite_border,
                  size: 17,
                  color: Colors.white.withValues(alpha: .75),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[index],
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            old[index],
                            style: const TextStyle(
                              fontSize: 9,
                              color: _muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            prices[index],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Adicionar à sacola',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF351518),
                        foregroundColor: const Color(0xFFFF737B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _addProduct(
                        name: names[index].replaceAll('\n', ' '),
                        category: categories[index],
                        price: numericPrices[index],
                        icon: icons[index],
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _catalogProductCard(StoreProduct product) => Container(
    width: 156,
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF292929)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 112,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFF111111),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: product.imageBytes == null
                  ? Center(
                      child: Icon(
                        product.icon,
                        size: 51,
                        color: const Color(0xFF777B80),
                      ),
                    )
                  : Image.memory(
                      product.imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
            if (product.compareAtPrice != null)
              const Positioned(left: 8, top: 8, child: _OfferTag()),
            if (product.stock == 0)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: .62),
                  alignment: Alignment.center,
                  child: const Text(
                    'ESGOTADO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 9, 8, 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (product.compareAtPrice != null)
                Text(
                  formatCurrency(product.compareAtPrice!),
                  style: const TextStyle(
                    fontSize: 9,
                    color: _muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatCurrency(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton.filledTonal(
                      tooltip: product.stock == 0
                          ? 'Produto esgotado'
                          : 'Adicionar à sacola',
                      onPressed: product.stock == 0
                          ? null
                          : () => _addCatalogProduct(product),
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF351518),
                        foregroundColor: const Color(0xFFFF737B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _addCatalogProduct(StoreProduct product) {
    CartStore.instance.add(
      CartItem(
        name: product.name,
        category: product.category,
        price: product.price,
        quantity: 1,
        icon: product.icon,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} adicionado à sacola'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _addProduct({
    required String name,
    required String category,
    required double price,
    required IconData icon,
  }) {
    CartStore.instance.add(
      CartItem(
        name: name,
        category: category,
        price: price,
        quantity: 1,
        icon: icon,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$name adicionado à sacola'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _benefitStrip() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF292929)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Benefit(icon: Icons.local_shipping_outlined, title: 'Envio rápido'),
          _Benefit(icon: Icons.verified_outlined, title: 'Linha original'),
          _Benefit(icon: Icons.support_agent, title: 'Atendimento'),
        ],
      ),
    ),
  );
}

class _OfferTag extends StatelessWidget {
  const _OfferTag();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: _red,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'OFERTA',
      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 19, color: _silver),
      const SizedBox(height: 5),
      Text(title, style: const TextStyle(fontSize: 8, color: _muted)),
    ],
  );
}
