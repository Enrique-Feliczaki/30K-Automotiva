import 'package:flutter/material.dart';

/// Three equal columns keep the benefits together even on narrow phones.
class BenefitStrip extends StatelessWidget {
  const BenefitStrip({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF171717),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF292929)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Benefit(
            icon: Icons.local_shipping_outlined,
            title: 'Envio rápido',
          ),
        ),
        Expanded(
          child: _Benefit(
            icon: Icons.verified_outlined,
            title: 'Linha original',
          ),
        ),
        Expanded(
          child: _Benefit(icon: Icons.support_agent, title: 'Atendimento'),
        ),
      ],
    ),
  );
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: const Color(0xFFC9CDD2)),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF92979D),
            height: 1.3,
          ),
        ),
      ],
    ),
  );
}
