import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive_layout.dart';

import 'cart_item.dart';
import 'cart_store.dart';
import 'product_store.dart';
import 'customer_profile.dart';
import 'local_persistence.dart';
import 'shipping.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _surfaceRaised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);
final _invalidCardholderCharacters = RegExp(r'[^\p{L}\p{M} ]', unicode: true);

enum _PaymentMethod { pix, card }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.items});

  final List<CartItem> items;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _method = _PaymentMethod.pix;
  bool _submitting = false;
  bool _completed = false;
  final _formKey = GlobalKey<FormState>();
  final _postalCodeController = TextEditingController(
    text: CustomerProfile.instance.postalCode,
  );
  final _stateController = TextEditingController(
    text: CustomerProfile.instance.state,
  );
  final _cityController = TextEditingController(
    text: CustomerProfile.instance.city,
  );
  final _neighborhoodController = TextEditingController(
    text: CustomerProfile.instance.neighborhood,
  );
  final _streetController = TextEditingController(
    text: CustomerProfile.instance.street,
  );
  final _houseNumberController = TextEditingController(
    text: CustomerProfile.instance.houseNumber,
  );

  double get _subtotal => widget.items.fold(0, (sum, item) => sum + item.total);
  double get _total => _subtotal + fixedShippingFee;
  int get _units => widget.items.fold(0, (sum, item) => sum + item.quantity);

  @override
  void dispose() {
    _postalCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _silver),
        ),
        title: const Text(
          'Finalizar pedido',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 5, 18, 24),
          children: [
            _checkoutProgress(),
            const SizedBox(height: 22),
            _sectionHeading('ENTREGA', Icons.local_shipping_outlined),
            const SizedBox(height: 12),
            _deliveryCard(),
            const SizedBox(height: 23),
            _sectionHeading('FORMA DE PAGAMENTO', Icons.lock_outline),
            const SizedBox(height: 12),
            _paymentChoice(
              method: _PaymentMethod.pix,
              title: 'Pix',
              icon: Icons.qr_code_2,
            ),
            const SizedBox(height: 9),
            _paymentChoice(
              method: _PaymentMethod.card,
              title: 'Cartão de crédito',
              icon: Icons.credit_card_outlined,
            ),
            if (_method == _PaymentMethod.card) ...[
              const SizedBox(height: 12),
              _cardFields(),
            ],
            const SizedBox(height: 23),
            _sectionHeading('RESUMO DO PEDIDO', Icons.receipt_long_outlined),
            const SizedBox(height: 12),
            _orderSummary(),
            const SizedBox(height: 16),
            const ResponsiveRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 15, color: _muted),
                SizedBox(width: 6),
                Text(
                  'Pagamento protegido e dados criptografados',
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _checkoutButton(),
    );
  }

  Widget _checkoutProgress() => ResponsiveRow(
    children: [
      _step('1', 'Sacola', complete: true),
      Expanded(child: Container(height: 1, color: _accent)),
      _step('2', 'Pagamento', active: true),
      Expanded(child: Container(height: 1, color: const Color(0xFF343434))),
      _step('3', 'Confirmação'),
    ],
  );

  Widget _step(
    String number,
    String label, {
    bool active = false,
    bool complete = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active || complete ? _accent : _surfaceRaised,
          border: Border.all(
            color: active || complete ? _accent : const Color(0xFF414141),
          ),
        ),
        child: Center(
          child: complete
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  number,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: active ? Colors.white : _muted,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _sectionHeading(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 17, color: const Color(0xFFFF646D)),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    ],
  );

  Widget _deliveryCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Receber em casa',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.edit_outlined, color: _silver, size: 17),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Informe seu CEP para a entrega',
          style: TextStyle(fontSize: 11, color: _muted),
        ),
        const SizedBox(height: 12),
        _inputField(
          controller: _postalCodeController,
          label: 'CEP',
          hint: '00000-000',
          keyboardType: TextInputType.number,
          validator: (value) =>
              value == null || value.replaceAll(RegExp(r'\D'), '').length != 8
              ? 'Informe um CEP válido'
              : null,
        ),
        const SizedBox(height: 10),
        ResponsiveRow(
          children: [
            Expanded(
              child: _inputField(
                controller: _stateController,
                label: 'Estado',
                hint: 'SP',
                validator: _required,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 2,
              child: _inputField(
                controller: _cityController,
                label: 'Cidade',
                hint: 'Sua cidade',
                validator: _required,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _inputField(
          controller: _neighborhoodController,
          label: 'Bairro',
          hint: 'Seu bairro',
          validator: _required,
        ),
        const SizedBox(height: 10),
        ResponsiveRow(
          children: [
            Expanded(
              flex: 3,
              child: _inputField(
                controller: _streetController,
                label: 'Rua',
                hint: 'Nome da rua',
                validator: _required,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _inputField(
                controller: _houseNumberController,
                label: 'Número',
                hint: 'Nº',
                keyboardType: TextInputType.number,
                validator: _required,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _paymentChoice({
    required _PaymentMethod method,
    required String title,
    required IconData icon,
  }) {
    final selected = _method == method;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _method = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF211315) : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : const Color(0xFF303030),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFFF737B) : _silver,
              size: 22,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _accent : _muted,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFields() => Container(
    padding: const EdgeInsets.all(13),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        _inputField(
          label: 'Nome impresso no cartão',
          hint: 'Como aparece no cartão',
          inputFormatters: [
            FilteringTextInputFormatter.deny(_invalidCardholderCharacters),
          ],
          validator: (value) {
            final requiredError = _required(value);
            if (requiredError != null) return requiredError;
            return _invalidCardholderCharacters.hasMatch(value!) ||
                    !RegExp(r'\p{L}', unicode: true).hasMatch(value)
                ? 'Use apenas letras e espaços no nome'
                : null;
          },
        ),
        const SizedBox(height: 10),
        _inputField(
          label: 'Número do cartão',
          hint: '0000000000000000',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (value) => !RegExp(r'^[0-9]{16}$').hasMatch(value ?? '')
              ? 'Confira o número do cartão'
              : null,
        ),
        const SizedBox(height: 10),
        ResponsiveRow(
          children: [
            Expanded(
              child: _inputField(
                label: 'Validade',
                hint: 'MM/AA',
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (value) =>
                    !RegExp(r'^(0[1-9]|1[0-2])/(2[6-9]|3[0-6])$')
                        .hasMatch(value ?? '')
                    ? 'Use MM/AA: mês de 01 a 12 e ano de 26 a 36'
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _inputField(
                label: 'CVV',
                hint: '123',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) =>
                    !RegExp(r'^[0-9]{3}$').hasMatch(value ?? '')
                    ? 'Confira o CVV'
                    : null,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;

  Widget _inputField({
    TextEditingController? controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
    style: const TextStyle(fontSize: 12),
    decoration: InputDecoration(
      labelText: label,
      errorMaxLines: 3,
      hintText: hint,
      labelStyle: const TextStyle(color: _muted, fontSize: 11),
      hintStyle: const TextStyle(color: Color(0xFF6E7277), fontSize: 11),
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

  Widget _orderSummary() => Container(
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        _SummaryRow(
          label: 'Produtos ($_units itens)',
          value: formatBrl(_subtotal),
        ),
        const SizedBox(height: 9),
        _SummaryRow(label: 'Entrega', value: formatBrl(fixedShippingFee)),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFF343434)),
        const SizedBox(height: 12),
        _SummaryRow(label: 'Total', value: formatBrl(_total), total: true),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Frete fixo incluído no total.',
            style: TextStyle(fontSize: 9, color: _muted),
          ),
        ),
      ],
    ),
  );

  Widget _checkoutButton() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF292929))),
      ),
      child: FilledButton.icon(
        onPressed: _submitting || _completed ? null : _submitOrder,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(Icons.lock_outline, size: 17),
        label: Text(
          _method == _PaymentMethod.pix
              ? 'Continuar para o Pix'
              : 'Confirmar pagamento',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );

  Future<void> _submitOrder() async {
    if (_submitting || _completed) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final profile = CustomerProfile.instance;
    profile
      ..postalCode = _postalCodeController.text.trim()
      ..state = _stateController.text.trim()
      ..city = _cityController.text.trim()
      ..neighborhood = _neighborhoodController.text.trim()
      ..street = _streetController.text.trim()
      ..houseNumber = _houseNumberController.text.trim();
    profile.save();
    try {
      final persistence = LocalPersistence.active;
      if (persistence != null) {
        await persistence.flush();
        await persistence.completePurchase(widget.items);
      } else {
        final products = ProductStore.instance.stockAfterPurchase(widget.items);
        ProductStore.instance.restore(products);
        CartStore.instance.restore([]);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message.toString()
                : 'Não foi possível finalizar a compra. Tente novamente.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _completed = true;
    });
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceRaised,
        icon: const Icon(
          Icons.check_circle_outline,
          color: Color(0xFFFF737B),
          size: 34,
        ),
        title: const Text('Tudo certo!'),
        content: Text(
          _method == _PaymentMethod.pix
              ? 'Seu pedido está pronto. O código Pix será gerado na próxima etapa.'
              : 'Seus dados foram validados. O pagamento será processado na próxima etapa.',
          style: const TextStyle(color: _silver, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text(
              'Entendi',
              style: TextStyle(color: Color(0xFFFF737B)),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF303030)),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.total = false,
  });

  final String label;
  final String value;
  final bool total;

  @override
  Widget build(BuildContext context) => ResponsiveRow(
    breakpoint: 340,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: total ? Colors.white : _muted,
          fontSize: total ? 12 : 11,
          fontWeight: total ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: total ? Colors.white : _silver,
          fontSize: total ? 14 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
