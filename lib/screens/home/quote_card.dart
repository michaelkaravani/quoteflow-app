import 'package:flutter/material.dart';

import '../../models/quote.dart';
import '../../models/quote_status.dart';
import 'action_icon.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.showQuoteNumber = true,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onStatusChanged,
  });

  final Quote quote;
  final bool showQuoteNumber;
  final ValueChanged<Quote>? onEdit;
  final ValueChanged<Quote>? onDelete;
  final VoidCallback? onShare;
  final ValueChanged<QuoteStatus>? onStatusChanged;

  Color get _statusColor {
    switch (quote.status) {
      case QuoteStatus.draft:
        return Colors.grey;
      case QuoteStatus.sent:
        return Colors.blue;
      case QuoteStatus.approved:
        return Colors.orange;
      case QuoteStatus.inProduction:
        return Colors.purple;
      case QuoteStatus.paid:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.secondary.withAlpha(38),
                  child: Icon(Icons.description_rounded, color: cs.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quote.title.isNotEmpty
                          ? (showQuoteNumber ? '${quote.title} #${quote.quoteNumber}' : quote.title)
                          : 'הצעה #${quote.quoteNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(quote.customerName,
                          style: TextStyle(color: cs.onSurface.withAlpha(153), fontSize: 13)),
                    ],
                  ),
                ),
                Text('₪${quote.finalTotal.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cs.secondary, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                InkWell(
                  onTap: onStatusChanged != null ? () => onStatusChanged!(quote.status) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quote.isOverdue
                        ? Colors.red.shade50
                        : _statusColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (quote.isOverdue)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade800),
                        ),
                      Text(
                        quote.isOverdue
                            ? 'ממתין ${DateTime.now().difference(quote.date).inDays} ימים'
                            : quote.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: quote.isOverdue ? Colors.red.shade800 : _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                const Spacer(),
                ActionIcon(icon: Icons.edit, color: cs.onSurface.withAlpha(153), size: 18, onTap: () => onEdit?.call(quote)),
                ActionIcon(icon: Icons.share, color: Colors.teal, size: 18, onTap: onShare ?? () {}),
                ActionIcon(icon: Icons.delete_outline, color: cs.onSurface.withAlpha(102), size: 20, onTap: () => onDelete?.call(quote)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
