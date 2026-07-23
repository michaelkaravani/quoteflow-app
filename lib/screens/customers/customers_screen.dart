import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/pdf_service.dart';
import '../../models/customer.dart';
import '../../models/quote.dart';
import '../../services/firestore_service.dart';
import '../quotes/quote_builder_screen.dart';
import 'customer_card.dart';
import 'customer_form_dialog.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm([Customer? customer]) async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (_) => CustomerFormDialog(customer: customer),
    );
    if (result == null) return;

    try {
      if (customer == null) {
        final newCustomer = result.copyWith();
        await widget.firestoreService.addCustomer(
          Customer(
            id: FirestoreService.generateId(),
            name: newCustomer.name,
            hp: newCustomer.hp,
            address: newCustomer.address,
            phone: newCustomer.phone,
          ),
        );
      } else {
        await widget.firestoreService.updateCustomer(result);
      }
    } catch (_) {
      _showMessage('לא ניתן לשמור את הלקוח. נא לנסות שוב.');
    }
  }

  Future<void> _delete(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('מחיקת לקוח'),
        content: Text('האם למחוק את ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('מחיקה'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.firestoreService.deleteCustomer(customer.id);
    } catch (_) {
      _showMessage('לא ניתן למחוק את הלקוח. נא לנסות שוב.');
    }
  }

  void _editQuote(Quote quote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text('עריכת הצעת מחיר #${quote.quoteNumber}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: QuoteBuilderScreen(
            firestoreService: widget.firestoreService,
            existingQuote: quote,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteQuote(Quote quote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('מחיקת הצעת מחיר'),
        content: Text('האם למחוק את ${quote.title.isNotEmpty ? '${quote.title} #${quote.quoteNumber}' : 'הצעה #${quote.quoteNumber}'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ביטול')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('מחיקה')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.firestoreService.deleteQuote(quote.id);
    }
  }

  Future<void> _shareQuote(Quote quote) async {
    try {
      final profile = await widget.firestoreService.loadProfile();
      if (profile != null) {
        await PdfService.shareQuote(quote, profile);
      }
    } catch (_) {
      _showMessage('שגיאה בשמירת PDF');
    }
  }

  void _callCustomer(Quote quote) {
    final phone = quote.customerPhone;
    if (phone.isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<List<Customer>>(
      stream: widget.firestoreService.watchCustomers(),
      builder: (context, customerSnapshot) {
        if (customerSnapshot.hasError) {
          return const Center(child: Text('לא ניתן לטעון את רשימת הלקוחות'));
        }
        final customers = customerSnapshot.data ?? [];

        return StreamBuilder<List<Quote>>(
          stream: widget.firestoreService.watchQuotes(),
          builder: (context, quoteSnapshot) {
            final allQuotes = quoteSnapshot.data ?? [];
            final filtered = _filtered(customers, allQuotes);

            return Stack(
              children: [
                Column(
                  children: [
                    if (customers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'חיפוש לקוח...',
                            hintStyle: TextStyle(color: cs.onSurface.withAlpha(102)),
                            prefixIcon: Icon(Icons.search, color: cs.onSurface.withAlpha(153)),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: Icon(Icons.clear, color: cs.onSurface.withAlpha(153)),
                                  )
                                : null,
                            filled: true,
                            fillColor: cs.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.secondary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_outline, size: 64, color: cs.outline),
                                    const SizedBox(height: 16),
                                    Text(
                                      _query.isNotEmpty
                                          ? 'לא נמצאו לקוחות התואמים לחיפוש'
                                          : 'אין עדיין לקוחות רשומים.\nלחץ על "לקוח חדש" כדי להתחיל.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final entry = filtered[index];
                                final customer = entry.key;
                                final quotes = entry.value;
                                return CustomerCard(
                                  customer: customer,
                                  quotes: quotes,
                                  onEdit: () => _openForm(customer),
                                  onDelete: () => _delete(customer),
                                  onQuoteEdit: _editQuote,
                                  onQuoteShare: _shareQuote,
                                  onQuoteDelete: _deleteQuote,
                                  onQuoteStatusChanged: (quote) async {
                                    await widget.firestoreService.updateQuote(quote);
                                  },
                                  onQuoteCall: _callCustomer,
                                );
                              },
                            ),
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    backgroundColor: cs.secondary,
                    elevation: 2,
                    onPressed: _openForm,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<MapEntry<Customer, List<Quote>>> _filtered(
      List<Customer> customers, List<Quote> allQuotes) {
    final query = _query.trim().toLowerCase();
    final result = <MapEntry<Customer, List<Quote>>>[];

    for (final customer in customers) {
      final customerQuotes = allQuotes
          .where((q) => q.customerId == customer.id)
          .toList();

      if (query.isEmpty) {
        result.add(MapEntry(customer, customerQuotes));
      } else {
        final matchesCustomer = customer.name.toLowerCase().contains(query) ||
            customer.phone.contains(query) ||
            customer.hp.contains(query) ||
            customer.address.toLowerCase().contains(query);
        final matchesQuote = customerQuotes.any((q) =>
            q.title.toLowerCase().contains(query) ||
            q.quoteNumber.toString().contains(query));

        if (matchesCustomer || matchesQuote) {
          result.add(MapEntry(customer, customerQuotes));
        }
      }
    }

    return result;
  }
}
