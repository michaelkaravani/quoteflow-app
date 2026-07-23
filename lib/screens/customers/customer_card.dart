import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/quote.dart';
import 'quote_card_tile.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.quotes,
    this.showQuoteNumber = true,
    this.onEdit,
    this.onDelete,
    this.onQuoteEdit,
    this.onQuoteShare,
    this.onQuoteDelete,
    this.onQuoteStatusChanged,
    this.onQuoteCall,
  });

  final Customer customer;
  final List<Quote> quotes;
  final bool showQuoteNumber;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<Quote>? onQuoteEdit;
  final ValueChanged<Quote>? onQuoteShare;
  final ValueChanged<Quote>? onQuoteDelete;
  final ValueChanged<Quote>? onQuoteStatusChanged;
  final ValueChanged<Quote>? onQuoteCall;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        iconColor: cs.secondary,
        collapsedIconColor: cs.onSurface,
        leading: CircleAvatar(
          backgroundColor: cs.secondary,
          child: Text(
            customer.name.trim().isEmpty ? '?' : customer.name.trim()[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(_subtitle, style: TextStyle(color: cs.onSurface.withAlpha(153), fontSize: 13)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          if (customer.address.isNotEmpty)
            Text(customer.address, style: TextStyle(fontSize: 14, color: cs.onSurface)),
          if (quotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('הצעות מחיר',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: cs.onSurface)),
            const SizedBox(height: 8),
            ...quotes.map((quote) => QuoteCardTile(
              quote: quote,
              showQuoteNumber: showQuoteNumber,
              onEdit: () => onQuoteEdit?.call(quote),
              onShare: () => onQuoteShare?.call(quote),
              onDelete: () => onQuoteDelete?.call(quote),
              onStatusChanged: (status) => onQuoteStatusChanged?.call(quote.copyWith(status: status)),
              onCall: () => onQuoteCall?.call(quote),
            )),
          ],
          const Divider(height: 24),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('ערוך לקוח', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('מחק לקוח', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
    if (parts.isEmpty) return 'אין פרטים נוספים';
    return parts.join(' | ');
  }
}
