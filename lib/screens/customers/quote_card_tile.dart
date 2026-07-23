import 'package:flutter/material.dart';

import '../../models/quote.dart';
import '../../models/quote_status.dart';
import '../home/action_icon.dart';

class QuoteCardTile extends StatelessWidget {
  const QuoteCardTile({
    super.key,
    required this.quote,
    this.showQuoteNumber = true,
    this.onEdit,
    this.onShare,
    this.onDelete,
    this.onStatusChanged,
    this.onCall,
  });

  final Quote quote;
  final bool showQuoteNumber;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final ValueChanged<QuoteStatus>? onStatusChanged;
  final VoidCallback? onCall;

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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: cs.secondary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quote.title.isNotEmpty
                      ? (showQuoteNumber ? '${quote.title} #${quote.quoteNumber}' : quote.title)
                      : 'הצעה #${quote.quoteNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Text('₪${quote.finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: cs.secondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${quote.date.day.toString().padLeft(2, '0')}/${quote.date.month.toString().padLeft(2, '0')}/${quote.date.year}',
            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(153)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onStatusChanged != null ? () => _showStatusPicker(context) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quote.isOverdue ? Colors.red.shade50 : _statusColor.withAlpha(38),
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
              const SizedBox(width: 8),
              Text('${quote.items.length} פריטים',
                  style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(128))),
              const Spacer(),
              if (quote.isOverdue && onCall != null)
                ActionIcon(icon: Icons.phone, color: Colors.green, size: 18, onTap: onCall!),
              ActionIcon(icon: Icons.edit, color: cs.onSurface.withAlpha(153), size: 18, onTap: onEdit ?? () {}),
              ActionIcon(icon: Icons.share, color: Colors.teal, size: 18, onTap: onShare ?? () {}),
              ActionIcon(icon: Icons.delete_outline, color: cs.onSurface.withAlpha(102), size: 20, onTap: onDelete ?? () {}),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('בחר סטטוס',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.primary)),
              ),
              ...QuoteStatus.values.map((status) => ListTile(
                leading: Icon(Icons.circle, color: _statusColorFor(status), size: 20),
                title: Text(status.displayName),
                trailing: quote.status == status ? Icon(Icons.check, color: cs.primary) : null,
                onTap: () {
                  if (quote.status != status) {
                    onStatusChanged?.call(status);
                  }
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _statusColorFor(QuoteStatus status) {
    switch (status) {
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
}
