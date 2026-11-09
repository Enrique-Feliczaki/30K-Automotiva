import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'cart_item.dart';
import 'cart_screen.dart';
import 'cart_store.dart';
import 'admin_screen.dart';
import 'product_store.dart';
import 'customer_profile.dart';

void main() => runApp(const TrintaKApp());

const _bg = Color(0xFF0A0A0A);
const _panel = Color(0xFF171717);
const _panel2 = Color(0xFF202020);
const _red = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);

class TrintaKApp extends StatefulWidget {
  const TrintaKApp({super.key});

  @override
  State<TrintaKApp> createState() => _TrintaKAppState();
}

class _TrintaKAppState extends State<TrintaKApp> {
  bool _hasEntered = false;
  bool _isAdmin = false;

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
    home: _hasEntered
        ? HomeScreen(isAdmin: _isAdmin, onLogout: () => setState(() { _hasEntered = false; _isAdmin = false; }))
        : AuthScreen(onAuthenticated: (isAdmin) => setState(() { _hasEntered = true; _isAdmin = isAdmin; })),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogout, required this.isAdmin});

  final VoidCallback onLogout;
  final bool isAdmin;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  int _category = 0;
  final _homeCategories = ProductStore.homeCategories;
  List<String> get _categories => ['Todos', ..._homeCategories];

  @override
  Widget build(BuildContext context) {
    final showAdmin = widget.isAdmin;
    final navigationIndex = showAdmin
        ? _tab
        : (_tab == 0 ? 0 : (_tab == 2 ? 1 : 2));
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Início',
      ),
      if (showAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favoritos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Conta',
      ),
    ];
    return Scaffold(
    body: SafeArea(
      bottom: false,
      child: _tab == 3
          ? _accountPage()
          : CustomScrollView(
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
      selectedIndex: navigationIndex,
      backgroundColor: const Color(0xFF111111),
      indicatorColor: const Color(0xFF351518),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        if (showAdmin && index == 1) {
          Navigator.of(context)
              .push(
                MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
              )
              .then((_) {
                if (mounted) setState(() => _tab = 0);
              });
          return;
        }
        final tab = showAdmin
            ? index
            : (index == 0 ? 0 : (index == 1 ? 2 : 3));
        setState(() => _tab = tab);
      },
      destinations: destinations,
    ),
  );
  }

  Widget _accountPage() {
    final profile = CustomerProfile.instance;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
      children: [
        const Text('Minha conta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Informações pessoais e endereço de entrega', style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 22),
        _profileSection(
          icon: Icons.person_outline,
          title: 'Informações pessoais',
          children: [
            _profileValue('Nome', profile.name),
            _profileValue('CPF / CNPJ', profile.document),
            _profileValue('E-mail', profile.email),
          ],
        ),
        const SizedBox(height: 14),
        _profileSection(
          icon: Icons.location_on_outlined,
          title: 'Endereço',
          children: [
            Text(profile.address.isEmpty ? 'Informe seu endereço ao finalizar um pedido.' : profile.address,
              style: const TextStyle(color: _silver, fontSize: 13, height: 1.6)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _editAddress,
                icon: Icon(profile.address.isEmpty ? Icons.add_location_alt_outlined : Icons.edit_location_alt_outlined, size: 17),
                label: Text(profile.address.isEmpty ? 'Cadastrar endereço' : 'Alterar endereço'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF737B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Sair da conta'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFF737B),
            side: const BorderSide(color: Color(0xFF713138)),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _profileSection({required IconData icon, required String title, required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF303030))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: const Color(0xFFFF646D), size: 18), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))]),
      const SizedBox(height: 14),
      ...children,
    ]),
  );

  Widget _profileValue(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
      const SizedBox(height: 3),
      Text(value.isEmpty ? 'Não informado' : value, style: const TextStyle(color: _silver, fontSize: 13)),
    ]),
  );

  Future<void> _editAddress() async {
    final profile = CustomerProfile.instance;
    final formKey = GlobalKey<FormState>();
    final postalCode = TextEditingController(text: profile.postalCode);
    final state = TextEditingController(text: profile.state);
    final city = TextEditingController(text: profile.city);
    final neighborhood = TextEditingController(text: profile.neighborhood);
    final street = TextEditingController(text: profile.street);
    final houseNumber = TextEditingController(text: profile.houseNumber);
    String? requiredValue(String? value) =>
        value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
    InputDecoration decoration(String label, String hint) => InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF111111),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
    );
    Widget field(TextEditingController controller, String label, String hint,
        {TextInputType? keyboardType, String? Function(String?)? validator}) =>
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ?? requiredValue,
          decoration: decoration(label, hint),
        );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel2,
        title: Text(profile.address.isEmpty ? 'Cadastrar endereço' : 'Alterar endereço'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                field(postalCode, 'CEP', '00000-000', keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.replaceAll(RegExp(r'\D'), '').length != 8 ? 'Informe um CEP válido' : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: field(state, 'Estado', 'SP')),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: field(city, 'Cidade', 'Sua cidade')),
                ]),
                const SizedBox(height: 10),
                field(neighborhood, 'Bairro', 'Seu bairro'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(flex: 3, child: field(street, 'Rua', 'Nome da rua')),
                  const SizedBox(width: 8),
                  Expanded(child: field(houseNumber, 'Número', 'Nº', keyboardType: TextInputType.number)),
                ]),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
            },
            child: const Text('Salvar endereço'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      profile
        ..postalCode = postalCode.text.trim()
        ..state = state.text.trim()
        ..city = city.text.trim()
        ..neighborhood = neighborhood.text.trim()
        ..street = street.text.trim()
        ..houseNumber = houseNumber.text.trim();
      setState(() {});
    }
    postalCode.dispose();
    state.dispose();
    city.dispose();
    neighborhood.dispose();
    street.dispose();
    houseNumber.dispose();
  }

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
        if (!widget.isAdmin) ...[
          const SizedBox(width: 8),
          _cartButton(),
        ],
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
                Icons.auto_awesome,
                Icons.layers_outlined,
                Icons.auto_fix_high,
                Icons.tire_repair,
                Icons.air,
                Icons.handyman_outlined,
              ];
              return GestureDetector(
                onTap: () => setState(() => _category = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 102,
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
        if (CustomerProfile.instance.isCompany)
          GestureDetector(
          onTap: _openAdmin,
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

  void _openAdmin() {
    if (!CustomerProfile.instance.isCompany) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
    );
  }

  Widget _offersSection() => ListenableBuilder(
    listenable: ProductStore.instance,
    builder: (context, _) {
      final allProducts = ProductStore.instance.products;
      final selectedCategory = _category == 0 ? null : _categories[_category];
      final products = selectedCategory == null
          ? allProducts
          : allProducts
                .where((product) => product.category == selectedCategory)
                .toList();
      return Padding(
        padding: const EdgeInsets.only(top: 27),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'PRODUTOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 13),
            if (products.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Text(
                  'Nenhum produto nesta categoria.',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 9,
                    childAspectRatio: 2.16,
                  ),
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
                height: 88,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF111111),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 62,
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
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
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

  Widget _catalogProductCard(StoreProduct product) => Material(
    color: Colors.transparent,
    child: InkWell(
    borderRadius: BorderRadius.circular(13),
    onTap: () => _openProductDetails(product),
    child: Container(
    width: double.infinity,
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
              height: 46,
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
                        size: 32,
                        color: const Color(0xFF777B80),
                      ),
                    )
                  : Image.memory(
                      product.imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
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
          padding: const EdgeInsets.fromLTRB(6, 4, 5, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                fontSize: 8,
                height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: _customerPrice(product) == null
                        ? const Text('Atacado indisponível', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 7, color: _muted))
                        : Text(
                            formatCurrency(_customerPrice(product)!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                  ),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: IconButton.filledTonal(
                      tooltip: product.stock == 0
                          ? 'Produto esgotado'
                          : 'Adicionar à sacola',
                      onPressed: product.stock == 0 || _customerPrice(product) == null
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
                      icon: const Icon(Icons.add_shopping_cart, size: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  )));

  Future<void> _openProductDetails(StoreProduct product) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProductDetailsScreen(product: product, isAdmin: widget.isAdmin),
      ),
    );
    if (added == true && mounted) {
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
  }

  void _addCatalogProduct(StoreProduct product) {
    final price = _customerPrice(product);
    if (price == null) return;
    CartStore.instance.add(
      CartItem(
        name: product.name,
        category: product.category,
        price: price,
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

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product, required this.isAdmin});

  final StoreProduct product;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final image = product.imageBytes == null
        ? Center(child: Icon(product.icon, size: 112, color: _silver))
        : Image.memory(product.imageBytes!, fit: BoxFit.contain);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do produto'),
        backgroundColor: _bg,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  Container(
                    height: 320,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: SizedBox.expand(child: image),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(product.category.toUpperCase(),
                    style: const TextStyle(color: Color(0xFFFF737B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 7),
                  Text(product.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 12),
                  if (_customerPrice(product) != null)
                    Text(formatCurrency(_customerPrice(product)!), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900))
                  else
                    const Text('Preço no atacado indisponível', style: TextStyle(color: _muted, fontSize: 14)),
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(product.stock > 0 ? 'Em estoque: ${product.stock} unidades' : 'Produto esgotado',
                        style: TextStyle(color: product.stock > 0 ? const Color(0xFF81D79A) : const Color(0xFFFF737B), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Código: ${product.sku}', style: const TextStyle(color: _muted, fontSize: 13)),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: isAdmin
                  ? OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    )
                  : Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: FilledButton.icon(
                  onPressed: product.stock == 0 || _customerPrice(product) == null ? null : () {
                    CartStore.instance.add(CartItem(
                      name: product.name,
                      category: product.category,
                      price: _customerPrice(product)!,
                      quantity: 1,
                      icon: product.icon,
                    ));
                    Navigator.of(context).pop(true);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Adicionar ao carrinho'),
                  style: FilledButton.styleFrom(backgroundColor: _red, minimumSize: const Size.fromHeight(50)),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
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

double? _customerPrice(StoreProduct product) => CustomerProfile.instance.isCompany
    ? product.compareAtPrice
    : product.price;

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
