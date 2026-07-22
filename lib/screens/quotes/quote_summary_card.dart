import 'package:flutter/material.dart';

import '../../models/quote_item.dart';

class QuoteSummaryCard extends StatelessWidget {
  const QuoteSummaryCard({
    super.key,
    required this.items,
    this.discount = 0,
    this.notes = '',
    this.discountChanged,
    this.notesChanged,
    this.itemDeleted,
  });

  final List<QuoteItem> items;
  final double discount;
  final String notes;
  final ValueChanged<double>? discountChanged;
  final ValueChanged<String>? notesChanged;
  final ValueChanged<int>? itemDeleted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final total = subtotal - discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (items.isNotEmpty) ...[
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: Text('₪${item.price.toStringAsFixed(0)} × ${item.quantity}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₪${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (itemDeleted != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                      onPressed: () => itemDeleted!(i),
                    ),
                ],
              ),
            );
          }),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('סכום ביניים'),
              Text('₪${subtotal.toStringAsFixed(0)}'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text('הנחה', style: TextStyle(color: cs.onSurfaceVariant))),
              SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: discount > 0 ? discount.toStringAsFixed(0) : '',
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '₪ 0',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final n = double.tryParse(v.trim());
                    discountChanged?.call(n != null && n > 0 ? n : 0);
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Divider(thickness: 2, color: cs.primary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('סה"כ לתשלום', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '₪${total.clamp(0, double.infinity).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            initialValue: notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'הערות ללקוח',
              border: OutlineInputBorder(),
            ),
            onChanged: notesChanged,
          ),
        ),
      ],
    );
  }
}
