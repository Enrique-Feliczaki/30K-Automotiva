import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'cart_store.dart';
import 'payment_screen.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _raised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> get _items => CartStore.instance.items;
  double get _subtotal => CartStore.instance.subtotal;
  int get _units => CartStore.instance.unitCount;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CartStore.instance,
    builder: (context, _) => Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _silver),
        ),
        title: const Text(
          'Minha sacola',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(
                '$_units ${_units == 1 ? 'item' : 'itens'}',
                style: const TextStyle(fontSize: 11, color: _muted),
              ),
            ),
          ),
        ],
      ),
      body: _items.isEmpty ? _emptyCart() : _cartBody(),
      bottomNavigationBar: _items.isEmpty ? null : _bottomSummary(),
    ),
  );

  Widget _cartBody() => ListView(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
    children: [
      _progress(),
      const SizedBox(height: 19),
      Row(
        children: [
          const Expanded(
            child: Text(
              'SEUS PRODUTOS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _silver,
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Continuar comprando',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...List.generate(_items.length, _itemCard),
      const SizedBox(height: 17),
      _shippingNotice(),
      const SizedBox(height: 17),
      _discountField(),
      const SizedBox(height: 18),
      _summaryCard(),
      const SizedBox(height: 14),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 14, color: _muted),
          SizedBox(width: 6),
          Text('Compra segura', style: TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _progress() => Row(
    children: [
      _step('1', 'Sacola', active: true),
      Expanded(child: Container(height: 1, color: const Color(0xFF343434))),
      _step('2', 'Pagamento'),
      Expanded(child: Container(height: 1, color: const Color(0xFF343434))),
      _step('3', 'Confirmação'),
    ],
  );

  Widget _step(String number, String title, {bool active = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _accent : _raised,
          border: Border.all(color: active ? _accent : const Color(0xFF414141)),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        title,
        style: TextStyle(
          fontSize: 9,
          color: active ? Colors.white : _muted,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _itemCard(int index) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _decoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 82,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF292929)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF222222), Color(0xFF101010)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(item.icon, size: 42, color: const Color(0xFF777B80)),
                Positioned(
                  bottom: 11,
                  child: Text(
                    '30K',
                    style: TextStyle(
                      color: index == 0
                          ? const Color(0xFFFF5B63)
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category.toUpperCase(),
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 8,
                              letterSpacing: .8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 29,
                        height: 29,
                      ),
                      padding: EdgeInsets.zero,
                      tooltip: 'Remover produto',
                      onPressed: () => _removeItem(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: _muted,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  formatBrl(item.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _quantityButton(
                      Icons.remove,
                      () => _changeQuantity(index, -1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    _quantityButton(Icons.add, () => _changeQuantity(index, 1)),
                    const Spacer(),
                    Text(
                      formatBrl(item.total),
                      style: const TextStyle(
                        color: _silver,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) => SizedBox(
    width: 27,
    height: 27,
    child: IconButton.filledTonal(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: _raised,
        foregroundColor: _silver,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      icon: Icon(icon, size: 15),
    ),
  );

  Widget _shippingNotice() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: const Color(0xFF303030)),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_shipping_outlined, color: _silver, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frete calculado no checkout',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                'Subtotal atual: ${formatBrl(_subtotal)}',
                style: const TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: _muted, size: 18),
      ],
    ),
  );

  Widget _discountField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'CUPOM DE DESCONTO',
        style: TextStyle(
          fontSize: 9,
          color: _silver,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Digite seu cupom',
                hintStyle: const TextStyle(color: _muted, fontSize: 11),
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: Color(0xFF303030)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: _accent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cupom indisponível para validação no momento.'),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _silver,
              side: const BorderSide(color: Color(0xFF484848)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Text('Aplicar', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    ],
  );

  Widget _summaryCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: _decoration(),
    child: Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'RESUMO DO PEDIDO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 13),
        _summaryLine('Subtotal', formatBrl(_subtotal)),
        const SizedBox(height: 8),
        _summaryLine(
          'Entrega',
          'Calculada no checkout',
          valueColor: const Color(0xFFFF737B),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFF343434)),
        ),
        _summaryLine('Total', formatBrl(_subtotal), total: true),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'O frete será adicionado na próxima etapa.',
            style: TextStyle(fontSize: 9, color: _muted),
          ),
        ),
      ],
    ),
  );

  Widget _summaryLine(
    String label,
    String value, {
    bool total = false,
    Color? valueColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: total ? Colors.white : _muted,
          fontSize: total ? 13 : 11,
          fontWeight: total ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor ?? (total ? Colors.white : _silver),
          fontSize: total ? 16 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _bottomSummary() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF292929))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 8,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  formatBrl(_subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _continueToPayment,
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(176, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text(
              'Finalizar pedido',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyCart() => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 54,
            color: Color(0xFF565A5F),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sua sacola está vazia',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          const Text(
            'Explore os produtos e encontre o cuidado ideal para seu carro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(backgroundColor: _accent),
            child: const Text('Voltar para a loja'),
          ),
        ],
      ),
    ),
  );

  void _changeQuantity(int index, int delta) {
    CartStore.instance.changeQuantity(index, delta);
  }

  void _removeItem(int index) => CartStore.instance.remove(index);

  void _continueToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(items: CartStore.instance.items),
      ),
    );
  }

  BoxDecoration _decoration() => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF303030)),
  );
}
