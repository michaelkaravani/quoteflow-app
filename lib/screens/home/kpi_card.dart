import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.icon, required this.value, required this.label, this.active = false});

  final IconData icon;
  final String value;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: active ? cs.secondary.withAlpha(20) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: active ? Border.all(color: cs.secondary, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: cs.secondary),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(153))),
        ],
      ),
    );
  }
}
