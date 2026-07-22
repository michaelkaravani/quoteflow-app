import 'package:flutter/material.dart';

import '../../models/customer.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(customer.name.trim().isEmpty ? '?' : customer.name.trim()[0]),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (customer.address.isNotEmpty) _DetailRow(Icons.location_on_outlined, customer.address),
          if (customer.phone.isNotEmpty) _DetailRow(Icons.phone_outlined, customer.phone),
          if (customer.hp.isNotEmpty) _DetailRow(Icons.badge_outlined, 'ח.פ / ת.ז: ${customer.hp}'),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('עריכה'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('מחיקה'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final parts = <String>[];
    if (customer.hp.isNotEmpty) parts.add('ח.פ: ${customer.hp}');
    if (customer.phone.isNotEmpty) parts.add(customer.phone);
    return parts.isEmpty ? 'אין פרטים נוספים' : parts.join(' | ');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
