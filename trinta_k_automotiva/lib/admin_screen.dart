import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'product_inventory_screen.dart';
import 'product_store.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _raised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);
const _green = Color(0xFF6FCF97);
const _amber = Color(0xFFF2B35E);

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
        'Administrador',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          tooltip: 'Adicionar produto',
          onPressed: () => _editProduct(context),
          icon: const Icon(Icons.add, color: _silver),
        ),
        const SizedBox(width: 6),
      ],
    ),
    body: AnimatedBuilder(
      animation: ProductStore.instance,
      builder: (context, _) {
        final store = ProductStore.instance;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
          children: [
            _welcome(),
            const SizedBox(height: 16),
            _summary(store),
            const SizedBox(height: 17),
            _inventoryLink(context),
            const SizedBox(height: 21),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'PRODUTOS DO CATÁLOGO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${store.products.length} cadastrados',
                  style: const TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (store.products.isEmpty)
              _emptyProducts(context)
            else
              ...store.products.map(
                (product) => _productCard(context, product),
              ),
          ],
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      onPressed: () => _editProduct(context),
      icon: const Icon(Icons.add),
      label: const Text(
        'Novo produto',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );

  Widget _welcome() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PAINEL DE CONTROLE',
        style: TextStyle(
          color: Color(0xFFFF737B),
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
      ),
      SizedBox(height: 6),
      Text(
        'Gerencie sua loja',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -.4,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Atualize produtos, preços, fotos e quantidades.',
        style: TextStyle(color: _muted, fontSize: 11),
      ),
    ],
  );

  Widget _summary(ProductStore store) => Row(
    children: [
      Expanded(
        child: _metric(
          'PRODUTOS',
          '${store.products.length}',
          Icons.inventory_2_outlined,
          _silver,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _metric(
          'BAIXO ESTOQUE',
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
  );

  Widget _metric(String title, String value, IconData icon, Color color) =>
      Container(
        height: 78,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .35,
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

  Widget _inventoryLink(BuildContext context) => Material(
    color: const Color(0xFF211315),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const InventoryScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF612329)),
        ),
        child: const Row(
          children: [
            Icon(Icons.inventory_outlined, color: Color(0xFFFF737B), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Abrir controle de estoque',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Ajuste unidades e acompanhe alertas.',
                    style: TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: _silver),
          ],
        ),
      ),
    ),
  );

  Widget _productCard(BuildContext context, StoreProduct product) {
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
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF303030)),
      ),
      child: Row(
        children: [
          _ProductPhoto(
            bytes: product.imageBytes,
            icon: product.icon,
            size: 57,
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 3),
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
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
          PopupMenuButton<String>(
            tooltip: 'Ações do produto',
            color: _raised,
            icon: const Icon(Icons.more_vert, color: _silver, size: 20),
            onSelected: (action) {
              if (action == 'edit') _editProduct(context, product);
              if (action == 'delete') _confirmDelete(context, product);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 17),
                    SizedBox(width: 9),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 17,
                      color: Color(0xFFFF737B),
                    ),
                    SizedBox(width: 9),
                    Text('Excluir', style: TextStyle(color: Color(0xFFFF737B))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyProducts(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF303030)),
    ),
    child: Column(
      children: [
        const Icon(Icons.inventory_2_outlined, size: 35, color: _muted),
        const SizedBox(height: 9),
        const Text(
          'Seu catálogo está vazio',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Cadastre um produto para começar.',
          style: TextStyle(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _editProduct(context),
          child: const Text(
            'Cadastrar produto',
            style: TextStyle(color: Color(0xFFFF737B)),
          ),
        ),
      ],
    ),
  );

  Future<void> _editProduct(
    BuildContext context, [
    StoreProduct? product,
  ]) async {
    final result = await showDialog<StoreProduct>(
      context: context,
      builder: (_) => _ProductEditor(product: product),
    );
    if (result == null) return;
    if (product == null) {
      ProductStore.instance.add(result);
    } else {
      ProductStore.instance.update(result);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StoreProduct product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _raised,
        title: const Text('Excluir produto?'),
        content: Text(
          '“${product.name}” será removido do catálogo e do estoque.',
          style: const TextStyle(color: _silver, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: _silver)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Color(0xFFFF737B)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) ProductStore.instance.remove(product.id);
  }
}

class _ProductEditor extends StatefulWidget {
  const _ProductEditor({this.product});

  final StoreProduct? product;

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  String? _selectedCategory;
  late final TextEditingController _sku;
  late final TextEditingController _price;
  late final TextEditingController _comparePrice;
  late final TextEditingController _stock;
  late final TextEditingController _minimumStock;
  Uint8List? _imageBytes;
  bool _removeImage = false;
  bool _choosingImage = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    final currentCategory = product?.category;
    _selectedCategory = ProductStore.selectableCategories.contains(
      currentCategory,
    )
        ? currentCategory
        : (currentCategory == null || currentCategory.isEmpty
              ? ProductStore.selectableCategories.first
              : currentCategory);
    _sku = TextEditingController(text: product?.sku ?? '');
    _price = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    _comparePrice = TextEditingController(
      text: product?.compareAtPrice?.toStringAsFixed(2) ?? '',
    );
    _stock = TextEditingController(text: product?.stock.toString() ?? '0');
    _minimumStock = TextEditingController(
      text: product?.minimumStock.toString() ?? '5',
    );
    _imageBytes = product?.imageBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _price.dispose();
    _comparePrice.dispose();
    _stock.dispose();
    _minimumStock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: _surface,
    insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF343434)),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              widget.product == null ? 'Novo produto' : 'Editar produto',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 15),
            Center(
              child: _ProductPhoto(
                bytes: _imageBytes,
                icon: widget.product?.icon ?? Icons.inventory_2_outlined,
                size: 105,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _choosingImage ? null : _pickImage,
                  icon: _choosingImage
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library_outlined, size: 16),
                  label: Text(
                    _choosingImage ? 'Abrindo fotos...' : 'Escolher foto',
                  ),
                ),
                if (_imageBytes != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _imageBytes = null;
                      _removeImage = true;
                    }),
                    child: const Text(
                      'Remover',
                      style: TextStyle(color: Color(0xFFFF737B)),
                    ),
                  ),
              ],
            ),
            _field(_name, 'Nome do produto', required: true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _categoryDropdown()),
                const SizedBox(width: 9),
                Expanded(child: _field(_sku, 'Código / SKU', required: true)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _price,
                    'Preço no varejo (R\$)',
                    number: true,
                    positive: true,
                    required: true,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _field(
                    _comparePrice,
                    'Preço no atacado (R\$)',
                    number: true,
                    positive: true,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _stock,
                    'Unidades',
                    number: true,
                    whole: true,
                    required: true,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _field(
                    _minimumStock,
                    'Alerta de estoque baixo',
                    number: true,
                    whole: true,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _silver,
                      side: const BorderSide(color: Color(0xFF484848)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    child: const Text('Salvar produto'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    bool positive = false,
    bool whole = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    style: const TextStyle(fontSize: 12),
    validator: (value) {
      if (required && (value == null || value.trim().isEmpty))
        return 'Campo obrigatório';
      if (number && value != null && value.trim().isNotEmpty) {
        final parsed = _parseNumber(value);
        if (parsed == null || !parsed.isFinite)
          return 'Informe um valor válido';
        if (positive && parsed <= 0) return 'Informe um valor maior que zero';
        if (whole && parsed < 0)
          return 'Informe um valor igual ou maior que zero';
        if (whole && parsed % 1 != 0) return 'Informe uma quantidade inteira';
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF111111),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFF343434)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _accent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _accent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _accent),
      ),
    ),
  );

  double? _parseNumber(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  Widget _categoryDropdown() {
    final categories = [
      ...ProductStore.selectableCategories,
      if (_selectedCategory != null &&
          !ProductStore.selectableCategories.contains(_selectedCategory))
        _selectedCategory!,
    ];
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Categoria',
        labelStyle: const TextStyle(color: _muted, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF111111),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF343434)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (category) => setState(() => _selectedCategory = category),
      validator: (value) => value == null || value.isEmpty
          ? 'Selecione uma categoria'
          : null,
    );
  }

  Future<void> _pickImage() async {
    setState(() => _choosingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (mounted)
        setState(() {
          _imageBytes = bytes;
          _removeImage = false;
        });
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir as fotos.')),
        );
    } finally {
      if (mounted) setState(() => _choosingImage = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final original = widget.product;
    final price = _parseNumber(_price.text)!;
    final stock = _parseNumber(_stock.text)!.toInt();
    final minimumStock = _parseNumber(_minimumStock.text)!.toInt();
    Navigator.pop(
      context,
      StoreProduct(
        id: original?.id ?? '',
        name: _name.text.trim(),
        category: _selectedCategory!,
        sku: _sku.text.trim(),
        price: price,
        stock: stock < 0 ? 0 : stock,
        minimumStock: minimumStock < 0 ? 0 : minimumStock,
        icon: original?.icon ?? Icons.inventory_2_outlined,
        compareAtPrice: _comparePrice.text.trim().isEmpty
            ? null
            : _parseNumber(_comparePrice.text),
        imageBytes: _imageBytes,
      ).copyWith(clearImage: _removeImage),
    );
  }
}

class _ProductPhoto extends StatelessWidget {
  const _ProductPhoto({
    required this.bytes,
    required this.icon,
    required this.size,
  });

  final Uint8List? bytes;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: const Color(0xFF383838)),
      gradient: bytes == null
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF292A2B), Color(0xFF101010)],
            )
          : null,
    ),
    child: bytes == null
        ? Icon(icon, color: _silver, size: size * .42)
        : Image.memory(bytes!, fit: BoxFit.cover),
  );
}
