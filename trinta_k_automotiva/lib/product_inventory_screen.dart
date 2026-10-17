import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'product_store.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _raised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);
const _green = Color(0xFF6FCF97);
const _amber = Color(0xFFF2B35E);

enum _Filter { all, available, low, empty }

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;
  String _query = '';

  List<StoreProduct> _filtered(ProductStore store) =>
      store.products.where((product) {
        final text = _query.toLowerCase();
        final matchesText =
            text.isEmpty ||
            product.name.toLowerCase().contains(text) ||
            product.sku.toLowerCase().contains(text);
        final matchesFilter = switch (_filter) {
          _Filter.all => true,
          _Filter.available => product.stock > product.minimumStock,
          _Filter.low => product.isLow,
          _Filter.empty => product.isEmpty,
        };
        return matchesText && matchesFilter;
      }).toList();

  @override
  void dispose() {
    _search.dispose();
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
        'Controle de estoque',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
    body: AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
        final store = ProductStore.instance;
        final products = _filtered(store);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _summary(store)),
            SliverToBoxAdapter(child: _searchBox()),
            SliverToBoxAdapter(child: _filters()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
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
                      '${products.length} encontrados',
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
            if (products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Nenhum produto encontrado',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),
                sliver: SliverList.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) => _productRow(products[index]),
                ),
              ),
          ],
        );
      },
    ),
  );

  Widget _summary(ProductStore store) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 5, 18, 0),
    child: Row(
      children: [
        Expanded(
          child: _metric(
            'UNIDADES',
            '${store.totalUnits}',
            Icons.inventory_2_outlined,
            _silver,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metric(
            'ESTOQUE BAIXO',
            '${store.lowStockCount}',
            Icons.warning_amber_rounded,
            _amber,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metric(
            'ESGOTADOS',
            '${store.outOfStockCount}',
            Icons.remove_shopping_cart_outlined,
            const Color(0xFFFF737B),
          ),
        ),
      ],
    ),
  );

  Widget _metric(String label, String value, IconData icon, Color color) =>
      Container(
        height: 79,
        padding: const EdgeInsets.all(9),
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
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      );

  Widget _searchBox() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
    child: TextField(
      controller: _search,
      onChanged: (value) => setState(() => _query = value.trim()),
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: 'Buscar produto ou SKU',
        hintStyle: const TextStyle(color: _muted, fontSize: 12),
        prefixIcon: const Icon(Icons.search, color: _silver, size: 19),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close, color: _muted, size: 18),
              ),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF303030)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    ),
  );

  Widget _filters() {
    const options = [
      (_Filter.all, 'Todos'),
      (_Filter.available, 'Disponíveis'),
      (_Filter.low, 'Baixo estoque'),
      (_Filter.empty, 'Esgotados'),
    ];
    return SizedBox(
      height: 37,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final (filter, label) = options[index];
          final selected = filter == _filter;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _filter = filter),
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
          );
        },
      ),
    );
  }

  Widget _productRow(StoreProduct product) {
    final statusColor = product.isEmpty
        ? const Color(0xFFFF737B)
        : product.isLow
        ? _amber
        : _green;
    final status = product.isEmpty
        ? 'ESGOTADO'
        : product.isLow
        ? 'ESTOQUE BAIXO'
        : 'DISPONÍVEL';
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF303030)),
      ),
      child: Row(
        children: [
          _StockPhoto(bytes: product.imageBytes, icon: product.icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 7,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
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
                      status,
                      style: TextStyle(
                        fontSize: 7,
                        color: statusColor,
                        fontWeight: FontWeight.w800,
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
              const Text('UNID.', style: TextStyle(color: _muted, fontSize: 7)),
              const SizedBox(height: 3),
              Text(
                '${product.stock}',
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
                  _stepButton(
                    Icons.remove,
                    () => ProductStore.instance.setStock(
                      product.id,
                      product.stock - 1,
                    ),
                    enabled: product.stock > 0,
                  ),
                  const SizedBox(width: 4),
                  _stepButton(
                    Icons.add,
                    () => ProductStore.instance.setStock(
                      product.id,
                      product.stock + 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepButton(
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
}

class _StockPhoto extends StatelessWidget {
  const _StockPhoto({required this.bytes, required this.icon});
  final Uint8List? bytes;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 51,
    height: 57,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF101010),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF353535)),
    ),
    child: bytes == null
        ? Icon(icon, color: _silver, size: 24)
        : Image.memory(bytes!, fit: BoxFit.cover),
  );
}
