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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isNotEmpty) ...[
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Card(
                surfaceTintColor: Colors.transparent,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.quantity} יח\' X ₪${item.price.toStringAsFixed(0)}',
                      style: TextStyle(color: cs.onSurface.withAlpha(153))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₪${item.total.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
                      if (itemDeleted != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => itemDeleted!(i),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('סכום ביניים', style: TextStyle(color: cs.onSurface.withAlpha(153))),
              Text('₪${subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text('הנחה', style: TextStyle(color: cs.onSurface.withAlpha(153))),
              const Spacer(),
              Container(
                width: 80,
                height: 35,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: discount > 0 ? cs.primary : cs.outlineVariant),
                ),
                child: Center(
                  child: TextFormField(
                    initialValue: discount > 0 ? discount.toStringAsFixed(0) : '',
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: discount > 0 ? cs.primary : cs.onSurface.withAlpha(153),
                      fontWeight: discount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '₪ 0',
                      hintStyle: TextStyle(color: cs.onSurface.withAlpha(153)),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final n = double.tryParse(v.trim());
                      discountChanged?.call(n != null && n > 0 ? n : 0);
                    },
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24, thickness: 2, color: cs.primary),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('סה"כ לתשלום', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('₪${(subtotal - discount).clamp(0, double.infinity).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: cs.secondary)),
            ],
          ),
          const SizedBox(height: 16),
          Text('הערות ללקוח', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: notes,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.secondary),
              ),
            ),
            onChanged: notesChanged,
          ),
        ],
      ),
    );
  }
}
