import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive_layout.dart';

import 'auth_screen.dart';
import 'cart_item.dart';
import 'cart_screen.dart';
import 'cart_store.dart';
import 'admin_screen.dart';
import 'address_validation.dart';
import 'product_store.dart';
import 'customer_profile.dart';
import 'local_database.dart';
import 'local_persistence.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _LocalAppStartup());
}

class _LocalAppStartup extends StatefulWidget {
  const _LocalAppStartup();

  @override
  State<_LocalAppStartup> createState() => _LocalAppStartupState();
}

class _LocalAppStartupState extends State<_LocalAppStartup> {
  late Future<LocalPersistence> _initialization = _open();

  Future<LocalPersistence> _open() async {
    final persistence = LocalPersistence(LocalDatabase.onDevice());
    try {
      await persistence.initialize();
      return persistence;
    } catch (_) {
      await persistence.close();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LocalPersistence>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.hasData) return const TrintaKApp();
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: snapshot.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Não foi possível abrir os dados locais. Verifique o espaço e as permissões de armazenamento do aparelho.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              setState(() => _initialization = _open()),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}

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
    builder: (context, child) {
      final persistence = LocalPersistence.active;
      if (persistence == null) return child!;
      return ListenableBuilder(
        listenable: persistence,
        builder: (context, _) => Column(
          children: [
            if (persistence.lastError != null)
              Material(
                color: const Color(0xFF713138),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'As últimas alterações ainda não foram salvas no aparelho.',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await persistence.retry();
                            } catch (_) {
                              /* Keep the visible error until a successful save. */
                            }
                          },
                          child: const Text('Tentar salvar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child!),
          ],
        ),
      );
    },
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
        ? HomeScreen(
            isAdmin: _isAdmin,
            onLogout: () => setState(() {
              LocalPersistence.active?.switchCustomer(null);
              CustomerProfile.instance.restore({});
              _hasEntered = false;
              _isAdmin = false;
            }),
          )
        : AuthScreen(
            onAuthenticated: (isAdmin) => setState(() {
              _hasEntered = true;
              _isAdmin = isAdmin;
            }),
          ),
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
  final _searchController = TextEditingController();
  final _catalogScrollController = ScrollController();
  final _productsSectionKey = GlobalKey();
  final _homeCategories = ProductStore.homeCategories;
  List<String> get _categories => ['Todos', ..._homeCategories];

  String _normalizeSearch(String text) => text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c');

  @override
  void dispose() {
    _searchController.dispose();
    _catalogScrollController.dispose();
    super.dispose();
  }

  Future<void> _exploreProducts() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _category = 0;
      _searchController.clear();
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_catalogScrollController.hasClients) return;
    // On small screens the catalog sliver may not have been built yet.
    while (_productsSectionKey.currentContext == null) {
      final position = _catalogScrollController.position;
      if (position.pixels >= position.maxScrollExtent) return;
      _catalogScrollController.jumpTo(
        (position.pixels + position.viewportDimension).clamp(
          0.0,
          position.maxScrollExtent,
        ),
      );
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_catalogScrollController.hasClients) return;
    }
    await Scrollable.ensureVisible(
      _productsSectionKey.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAdmin = widget.isAdmin;
    final navigationIndex = _tab == 0 ? 0 : (showAdmin ? 2 : 1);
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
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Conta',
      ),
    ];
    return ResponsiveScaffold(
      body: SafeArea(
        bottom: false,
        child: _tab == 2
            ? _accountPage()
            : CustomScrollView(
                controller: _catalogScrollController,
                slivers: [
                  SliverToBoxAdapter(child: _header()),
                  SliverToBoxAdapter(child: _search()),
                  if (_searchController.text.trim().isEmpty)
                    SliverToBoxAdapter(child: _hero()),
                  SliverToBoxAdapter(child: _categoriesSection()),
                  SliverToBoxAdapter(
                    key: _productsSectionKey,
                    child: _offersSection(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 56 + MediaQuery.textScalerOf(context).scale(16),
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
          final tab = index == 0 ? 0 : 2;
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
        const Text(
          'Minha conta',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Informações pessoais e endereço de entrega',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
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
            Text(
              profile.address.isEmpty
                  ? 'Informe seu endereço ao finalizar um pedido.'
                  : profile.address,
              style: const TextStyle(color: _silver, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _editAddress,
                icon: Icon(
                  profile.address.isEmpty
                      ? Icons.add_location_alt_outlined
                      : Icons.edit_location_alt_outlined,
                  size: 17,
                ),
                label: Text(
                  profile.address.isEmpty
                      ? 'Cadastrar endereço'
                      : 'Alterar endereço',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF737B),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF303030)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveRow(
          children: [
            Icon(icon, color: const Color(0xFFFF646D), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );

  Widget _profileValue(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? 'Não informado' : value,
          style: const TextStyle(color: _silver, fontSize: 13),
        ),
      ],
    ),
  );

  Future<void> _editAddress() async {
    final profile = CustomerProfile.instance;
    final formKey = GlobalKey<FormState>();
    final address = <String, String>{
      'postalCode': profile.postalCode,
      'state': profile.state,
      'city': profile.city,
      'neighborhood': profile.neighborhood,
      'street': profile.street,
      'houseNumber': profile.houseNumber,
    };
    InputDecoration decoration(String label, String hint) => InputDecoration(
      labelText: label,
      errorMaxLines: 3,
      hintText: hint,
      labelStyle: const TextStyle(color: _muted),
      hintStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: const Color(0xFF111111),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFF343434)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _red),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFFF6470)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFFF6470)),
      ),
    );
    Widget field(
      String addressKey,
      String label,
      String hint, {
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator,
    }) => TextFormField(
      initialValue: address[addressKey],
      onSaved: (value) => address[addressKey] = value?.trim() ?? '',
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator ?? validateAddressText,
      decoration: decoration(label, hint),
    );

    final navigator = Navigator.of(context, rootNavigator: true);
    final dialogRoute = DialogRoute<bool>(
      context: context,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        backgroundColor: _panel2,
        title: Text(
          profile.address.isEmpty ? 'Cadastrar endereço' : 'Alterar endereço',
        ),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  field(
                    'postalCode',
                    'CEP',
                    '00000-000',
                    keyboardType: TextInputType.number,
                    validator: AddressValidation.postalCode,
                  ),
                  const SizedBox(height: 10),
                  field(
                    'state',
                    'Estado',
                    'SP',
                    validator: AddressValidation.state,
                  ),
                  const SizedBox(height: 10),
                  field(
                    'city',
                    'Cidade',
                    'Sua cidade',
                    validator: AddressValidation.city,
                  ),
                  const SizedBox(height: 10),
                  field(
                    'neighborhood',
                    'Bairro',
                    'Seu bairro',
                    validator: AddressValidation.neighborhood,
                  ),
                  const SizedBox(height: 10),
                  field(
                    'street',
                    'Rua',
                    'Nome da rua',
                    validator: AddressValidation.street,
                  ),
                  const SizedBox(height: 10),
                  field(
                    'houseNumber',
                    'Número',
                    'Nº',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        maximumHouseNumberLength,
                      ),
                    ],
                    validator: validateHouseNumber,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Salvar endereço'),
          ),
        ],
      ),
    );
    final saved = await navigator.push(dialogRoute);

    // Navigator.pop completes before the closing animation removes the dialog
    // from the tree. Keep its controllers alive until that removal finishes.
    await dialogRoute.completed;

    if (saved == true && mounted) {
      profile
        ..postalCode = address['postalCode']!
        ..state = address['state']!.toUpperCase()
        ..city = address['city']!
        ..neighborhood = address['neighborhood']!
        ..street = address['street']!
        ..houseNumber = address['houseNumber']!;
      profile.save();
      try {
        await LocalPersistence.active?.flush();
      } catch (_) {
        // The app-wide storage banner offers a retry without discarding edits.
      }
      if (mounted) setState(() {});
    }
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
        if (!widget.isAdmin) _cartButton(),
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
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: TextField(
        key: const ValueKey('product-search'),
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'O que você está procurando?',
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: _silver, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar pesquisa',
                  onPressed: () => setState(_searchController.clear),
                  icon: const Icon(Icons.close, color: _silver, size: 20),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    ),
  );

  Widget _hero() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Container(
      constraints: const BoxConstraints(minHeight: 250),
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
            right: -4,
            bottom: 13,
            child: Icon(
              Icons.directions_car_outlined,
              size: 190,
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
                const SizedBox(height: 18),
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
                  onPressed: _exploreProducts,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Explorar produtos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
        _sectionTitle('COMPRE POR CATEGORIA'),
        const SizedBox(height: 13),
        SizedBox(
          height: 70 + MediaQuery.textScalerOf(context).scale(21),
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

  Widget _sectionTitle(String title) => Padding(
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
        if (widget.isAdmin)
          GestureDetector(
            onTap: _openAdmin,
            child: const Row(
              children: [
                Text(
                  'Gerenciar',
                  style: TextStyle(fontSize: 10, color: _silver),
                ),
                SizedBox(width: 3),
                Icon(Icons.chevron_right, size: 15, color: _silver),
              ],
            ),
          ),
      ],
    ),
  );

  void _openAdmin() {
    if (!widget.isAdmin) return;
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const AdminScreen()));
  }

  Widget _offersSection() => ListenableBuilder(
    listenable: ProductStore.instance,
    builder: (context, _) {
      final allProducts = ProductStore.instance.products;
      final selectedCategory = _category == 0 ? null : _categories[_category];
      final query = _normalizeSearch(_searchController.text);
      final products = allProducts
          .where(
            (product) =>
                (selectedCategory == null ||
                    product.category == selectedCategory) &&
                _normalizeSearch(product.name).contains(query),
          )
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Text(
                  query.isEmpty
                      ? 'Nenhum produto nesta categoria.'
                      : 'Nenhum produto encontrado para esta pesquisa.',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scale =
                        MediaQuery.textScalerOf(context).scale(14) / 14;
                    final columns = (constraints.maxWidth / (180 * scale))
                        .floor()
                        .clamp(1, 5);
                    final width =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final product in products)
                          SizedBox(
                            width: width,
                            child: _catalogProductCard(product),
                          ),
                      ],
                    );
                  },
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
                        disabledBackgroundColor: widget.isAdmin
                            ? const Color(0xFF351518)
                            : null,
                        disabledForegroundColor: widget.isAdmin
                            ? const Color(0xFFFF737B)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: widget.isAdmin
                          ? null
                          : () => _addProduct(
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
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Color(0xFF111111),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
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
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height:
                        MediaQuery.textScalerOf(context).scale(14) * 1.2 * 2,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  ResponsiveRow(
                    breakpoint: 170,
                    children: [
                      Expanded(
                        child: _customerPrice(product) == null
                            ? const Text(
                                'Atacado indisponível',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: _muted),
                              )
                            : Text(
                                formatCurrency(_customerPrice(product)!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton.filledTonal(
                          tooltip: product.stock == 0
                              ? 'Produto esgotado'
                              : 'Adicionar à sacola',
                          onPressed:
                              widget.isAdmin ||
                                  product.stock == 0 ||
                                  _customerPrice(product) == null
                              ? null
                              : () => _addCatalogProduct(product),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF351518),
                            foregroundColor: const Color(0xFFFF737B),
                            disabledBackgroundColor: widget.isAdmin
                                ? const Color(0xFF351518)
                                : null,
                            disabledForegroundColor: widget.isAdmin
                                ? const Color(0xFFFF737B)
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _openProductDetails(StoreProduct product) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductDetailsScreen(product: product, isAdmin: widget.isAdmin),
      ),
    );
  }

  Future<void> _addCatalogProduct(StoreProduct product) async {
    if (widget.isAdmin) return;
    final price = _customerPrice(product);
    if (price == null) return;
    final added = CartStore.instance.add(
      CartItem(
        productId: product.id,
        name: product.name,
        category: product.category,
        price: price,
        quantity: 1,
        icon: product.icon,
      ),
    );
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade máxima em estoque atingida.')),
      );
      return;
    }
    try {
      await LocalPersistence.active?.flush();
    } catch (_) {
      return;
    }
    if (!mounted) return;
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
    if (widget.isAdmin) return;
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
}

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.isAdmin,
  });

  final StoreProduct product;
  final bool isAdmin;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _adding = false;
  bool get isAdmin => widget.isAdmin;

  StoreProduct get product => ProductStore.instance.products.firstWhere(
    (product) => product.id == widget.product.id,
    orElse: () => widget.product.copyWith(stock: 0),
  );

  CartItem _cartItem(int quantity) => CartItem(
    productId: product.id,
    name: product.name,
    category: product.category,
    price: _customerPrice(product) ?? product.price,
    quantity: quantity,
    icon: product.icon,
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([ProductStore.instance, CartStore.instance]),
    builder: (context, _) => _buildDetails(context),
  );

  Widget _buildDetails(BuildContext context) {
    final remaining =
        (product.stock - CartStore.instance.quantityFor(_cartItem(1))).clamp(
          0,
          product.stock < 0 ? 0 : product.stock,
        );
    final quantity = _quantity.clamp(1, remaining > 0 ? remaining : 1);
    final image = product.imageBytes == null
        ? Center(child: Icon(product.icon, size: 112, color: _silver))
        : Image.memory(product.imageBytes!, fit: BoxFit.contain);

    return ResponsiveScaffold(
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
                    child: SizedBox.expand(child: image),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFF737B),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  if (product.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: _silver,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_customerPrice(product) != null)
                    Text(
                      formatCurrency(_customerPrice(product)!),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  else
                    const Text(
                      'Preço no atacado indisponível',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.stock > 0
                              ? 'Em estoque: ${product.stock} unidades'
                              : 'Produto esgotado',
                          style: TextStyle(
                            color: product.stock > 0
                                ? const Color(0xFF81D79A)
                                : const Color(0xFFFF737B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Código: ${product.sku}',
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (!isAdmin) ...[
                    const SizedBox(height: 18),
                    const Text('Quantidade'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.outlined(
                          key: const ValueKey('product-quantity-decrease'),
                          tooltip: 'Diminuir quantidade',
                          onPressed: quantity > 1
                              ? () => setState(() => _quantity = quantity - 1)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            '$quantity',
                            key: const ValueKey('product-quantity'),
                          ),
                        ),
                        IconButton.outlined(
                          key: const ValueKey('product-quantity-increase'),
                          tooltip: 'Aumentar quantidade',
                          onPressed: quantity < remaining
                              ? () => setState(() => _quantity = quantity + 1)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    if (remaining == 0) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Quantidade máxima em estoque atingida.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ],
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
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    )
                  : ResponsiveRow(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Voltar'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed:
                                remaining == 0 ||
                                    _adding ||
                                    _customerPrice(product) == null
                                ? null
                                : () async {
                                    setState(() => _adding = true);
                                    final added = CartStore.instance.add(
                                      _cartItem(quantity),
                                    );
                                    if (!added) {
                                      setState(() => _adding = false);
                                      return;
                                    }
                                    try {
                                      await LocalPersistence.active?.flush();
                                    } catch (_) {
                                      if (mounted)
                                        setState(() => _adding = false);
                                      return;
                                    }
                                    if (!context.mounted) return;
                                    setState(() => _adding = false);
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Produto adicionado ao carrinho',
                                          ),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                  },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Adicionar ao carrinho'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _red,
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                      ],
                    ),
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

double? _customerPrice(StoreProduct product) =>
    CustomerProfile.instance.isCompany ? product.compareAtPrice : product.price;
