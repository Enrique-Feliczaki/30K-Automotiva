import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'customer_profile.dart';

const _background = Color(0xFF0A0A0A);
const _surface = Color(0xFF171717);
const _surfaceRaised = Color(0xFF202020);
const _accent = Color(0xFFE11D2E);
const _silver = Color(0xFFC9CDD2);
const _muted = Color(0xFF92979D);

enum _PaymentMethod { pix, card }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.items});

  final List<CartItem> items;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _method = _PaymentMethod.pix;
  final _formKey = GlobalKey<FormState>();
  final _postalCodeController = TextEditingController(text: CustomerProfile.instance.postalCode);
  final _stateController = TextEditingController(text: CustomerProfile.instance.state);
  final _cityController = TextEditingController(text: CustomerProfile.instance.city);
  final _neighborhoodController = TextEditingController(text: CustomerProfile.instance.neighborhood);
  final _streetController = TextEditingController(text: CustomerProfile.instance.street);
  final _houseNumberController = TextEditingController(text: CustomerProfile.instance.houseNumber);

  double get _subtotal => widget.items.fold(0, (sum, item) => sum + item.total);
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
    return Scaffold(
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
              detail: 'Aprovação imediata',
              icon: Icons.qr_code_2,
              badge: '5% OFF',
            ),
            const SizedBox(height: 9),
            _paymentChoice(
              method: _PaymentMethod.card,
              title: 'Cartão de crédito',
              detail: 'Parcele em até 3x sem juros',
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
            const Row(
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

  Widget _checkoutProgress() => Row(
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
      Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
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
          'Informe seu CEP para calcular a entrega',
          style: TextStyle(fontSize: 11, color: _muted),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _inputField(
                controller: _postalCodeController,
                label: 'CEP',
                hint: '00000-000',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.replaceAll(RegExp(r'\D'), '').length != 8
                    ? 'Informe um CEP válido'
                    : null,
              ),
            ),
            const SizedBox(width: 9),
            SizedBox(
              height: 45,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: _silver,
                  side: const BorderSide(color: Color(0xFF484848)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                child: const Text('Calcular', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _inputField(controller: _stateController, label: 'Estado', hint: 'SP', validator: _required)),
          const SizedBox(width: 9),
          Expanded(flex: 2, child: _inputField(controller: _cityController, label: 'Cidade', hint: 'Sua cidade', validator: _required)),
        ]),
        const SizedBox(height: 10),
        _inputField(controller: _neighborhoodController, label: 'Bairro', hint: 'Seu bairro', validator: _required),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(flex: 3, child: _inputField(controller: _streetController, label: 'Rua', hint: 'Nome da rua', validator: _required)),
          const SizedBox(width: 9),
          Expanded(child: _inputField(controller: _houseNumberController, label: 'Número', hint: 'Nº', keyboardType: TextInputType.number, validator: _required)),
        ]),
      ],
    ),
  );

  Widget _paymentChoice({
    required _PaymentMethod method,
    required String title,
    required String detail,
    required IconData icon,
    String? badge,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 7),
                        Text(
                          badge,
                          style: const TextStyle(
                            color: Color(0xFFFF737B),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 10, color: _muted),
                  ),
                ],
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
          validator: _required,
        ),
        const SizedBox(height: 10),
        _inputField(
          label: 'Número do cartão',
          hint: '0000 0000 0000 0000',
          keyboardType: TextInputType.number,
          validator: (value) =>
              value == null || value.replaceAll(' ', '').length < 13
              ? 'Confira o número do cartão'
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _inputField(
                label: 'Validade',
                hint: 'MM/AA',
                validator: _required,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _inputField(
                label: 'CVV',
                hint: '123',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.length < 3 ? 'Confira o CVV' : null,
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
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(fontSize: 12),
    decoration: InputDecoration(
      labelText: label,
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
        const _SummaryRow(label: 'Entrega', value: 'Calcular pelo CEP'),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFF343434)),
        const SizedBox(height: 12),
        _SummaryRow(
          label: 'Total parcial',
          value: formatBrl(_subtotal),
          total: true,
        ),
        const SizedBox(height: 5),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'O valor da entrega será informado após o CEP.',
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
        onPressed: _submitOrder,
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

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;
    final profile = CustomerProfile.instance;
    profile
      ..postalCode = _postalCodeController.text.trim()
      ..state = _stateController.text.trim()
      ..city = _cityController.text.trim()
      ..neighborhood = _neighborhoodController.text.trim()
      ..street = _streetController.text.trim()
      ..houseNumber = _houseNumberController.text.trim();
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
            onPressed: () => Navigator.of(context).pop(),
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
  Widget build(BuildContext context) => Row(
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
