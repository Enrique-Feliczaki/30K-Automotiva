import 'package:flutter/material.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _raised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);
const _green = Color(0xFF6FCF97);
const _amber = Color(0xFFF2B35E);

enum _StockFilter { all, available, low, empty }

class _InventoryProduct {
  _InventoryProduct({
    required this.name,
    required this.category,
    required this.sku,
    required this.icon,
    required this.quantity,
    this.minimum = 5,
  });

  final String name;
  final String category;
  final String sku;
  final IconData icon;
  final int minimum;
  int quantity;

  bool get isEmpty => quantity == 0;
  bool get isLow => quantity > 0 && quantity <= minimum;
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  final List<_InventoryProduct> _products = [
    _InventoryProduct(
      name: 'Shampoo Neutro Concentrado 1,5L',
      category: 'Shampoos',
      sku: '30K-SH-015',
      icon: Icons.local_drink_outlined,
      quantity: 24,
    ),
    _InventoryProduct(
      name: 'Cera Líquida Ultra Brilho 500ml',
      category: 'Ceras',
      sku: '30K-CR-050',
      icon: Icons.auto_awesome,
      quantity: 4,
    ),
    _InventoryProduct(
      name: 'Graphene Liquid Armor',
      category: 'Proteção',
      sku: '30K-GR-100',
      icon: Icons.shield_outlined,
      quantity: 8,
    ),
    _InventoryProduct(
      name: 'Ultra Plush 800GSM',
      category: 'Microfibras',
      sku: '30K-MF-800',
      icon: Icons.layers_outlined,
      quantity: 0,
    ),
    _InventoryProduct(
      name: 'Revitalizador de Pneus 500ml',
      category: 'Acabamento',
      sku: '30K-PN-050',
      icon: Icons.tire_repair,
      quantity: 12,
    ),
  ];

  _StockFilter _filter = _StockFilter.all;
  String _query = '';

  List<_InventoryProduct> get _visibleProducts => _products.where((product) {
    final matchesQuery =
        _query.isEmpty ||
        product.name.toLowerCase().contains(_query.toLowerCase()) ||
        product.sku.toLowerCase().contains(_query.toLowerCase());
    final matchesFilter = switch (_filter) {
      _StockFilter.all => true,
      _StockFilter.available => product.quantity > product.minimum,
      _StockFilter.low => product.isLow,
      _StockFilter.empty => product.isEmpty,
    };
    return matchesQuery && matchesFilter;
  }).toList();

  int get _totalUnits =>
      _products.fold(0, (sum, product) => sum + product.quantity);
  int get _lowCount => _products.where((product) => product.isLow).length;
  int get _emptyCount => _products.where((product) => product.isEmpty).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    appBar: AppBar(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: _silver),
      ),
      title: const Text(
        'Estoque',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          tooltip: 'Atualizar estoque',
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh, color: _silver, size: 20),
        ),
        const SizedBox(width: 6),
      ],
    ),
    body: SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _intro()),
          SliverToBoxAdapter(child: _metrics()),
          SliverToBoxAdapter(child: _search()),
          SliverToBoxAdapter(child: _filters()),
          SliverToBoxAdapter(child: _listHeading()),
          if (_visibleProducts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyResults(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList.separated(
                itemCount: _visibleProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _productCard(_visibleProducts[index]),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _intro() => const Padding(
    padding: EdgeInsets.fromLTRB(18, 4, 18, 17),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTROLE DE PRODUTOS',
          style: TextStyle(
            color: Color(0xFFFF737B),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Visão geral do estoque',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Acompanhe os níveis e ajuste suas quantidades.',
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _metrics() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18),
    child: Row(
      children: [
        Expanded(
          child: _metricCard(
            'UNIDADES',
            '$_totalUnits',
            Icons.inventory_2_outlined,
            _silver,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _metricCard(
            'ESTOQUE BAIXO',
            '$_lowCount',
            Icons.warning_amber_rounded,
            _amber,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _metricCard(
            'ESGOTADOS',
            '$_emptyCount',
            Icons.remove_shopping_cart_outlined,
            const Color(0xFFFF737B),
          ),
        ),
      ],
    ),
  );

  Widget _metricCard(String label, String value, IconData icon, Color color) =>
      Container(
        height: 84,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFF303030)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );

  Widget _search() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
    child: TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.trim()),
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: 'Buscar produto ou código',
        hintStyle: const TextStyle(color: _muted, fontSize: 12),
        prefixIcon: const Icon(Icons.search, color: _silver, size: 19),
        suffixIcon: _query.isEmpty
            ? const Icon(Icons.tune, color: _muted, size: 18)
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close, color: _muted, size: 18),
              ),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFF303030)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    ),
  );

  Widget _filters() {
    const filters = [
      (_StockFilter.all, 'Todos'),
      (_StockFilter.available, 'Disponíveis'),
      (_StockFilter.low, 'Baixo estoque'),
      (_StockFilter.empty, 'Esgotados'),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final (filter, title) = filters[index];
          final selected = _filter == filter;
          return ChoiceChip(
            label: Text(title),
            selected: selected,
            onSelected: (_) => setState(() => _filter = filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 9,
              color: selected ? Colors.white : _silver,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: _surface,
            selectedColor: const Color(0xFF351518),
            side: BorderSide(
              color: selected ? _accent : const Color(0xFF303030),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 7),
          );
        },
      ),
    );
  }

  Widget _listHeading() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 19, 18, 10),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'PRODUTOS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Text(
          '${_visibleProducts.length} ${_visibleProducts.length == 1 ? 'produto' : 'produtos'}',
          style: const TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    ),
  );

  Widget _productCard(_InventoryProduct product) {
    final statusColor = product.isEmpty
        ? const Color(0xFFFF737B)
        : product.isLow
        ? _amber
        : _green;
    final statusLabel = product.isEmpty
        ? 'ESGOTADO'
        : product.isLow
        ? 'ESTOQUE BAIXO'
        : 'DISPONÍVEL';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF303030)),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 59,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF292A2B), Color(0xFF101010)],
              ),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF3B3B3B)),
            ),
            child: Icon(product.icon, color: _silver, size: 25),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 7,
                    letterSpacing: .9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'SKU ${product.sku}',
                      style: const TextStyle(fontSize: 8, color: _muted),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 7,
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Column(
            children: [
              const Text(
                'UNID.',
                style: TextStyle(color: _muted, fontSize: 7, letterSpacing: .5),
              ),
              const SizedBox(height: 3),
              Text(
                '${product.quantity}',
                style: TextStyle(
                  color: product.isEmpty ? statusColor : Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _quantityButton(
                    Icons.remove,
                    () => _adjust(product, -1),
                    enabled: product.quantity > 0,
                  ),
                  const SizedBox(width: 4),
                  _quantityButton(Icons.add, () => _adjust(product, 1)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
    IconData icon,
    VoidCallback onTap, {
    bool enabled = true,
  }) => Material(
    color: _raised,
    borderRadius: BorderRadius.circular(6),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          size: 14,
          color: enabled ? _silver : const Color(0xFF555555),
        ),
      ),
    ),
  );

  void _adjust(_InventoryProduct product, int delta) => setState(() {
    product.quantity = (product.quantity + delta).clamp(0, 9999).toInt();
  });
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFF565A5F), size: 42),
          SizedBox(height: 12),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Tente mudar a busca ou o filtro.',
            style: TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
