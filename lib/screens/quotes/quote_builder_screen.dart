import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/customer.dart';
import '../../models/quote.dart';
import '../../models/quote_item.dart';
import '../../models/quote_status.dart';
import '../../services/firestore_service.dart';
import 'add_item_dialog.dart';
import 'customer_picker_sheet.dart';
import 'quote_summary_card.dart';

class QuoteBuilderScreen extends StatefulWidget {
  const QuoteBuilderScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends State<QuoteBuilderScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  Customer? _customer;
  List<QuoteItem> _items = [];
  double _discount = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.total);
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  Future<void> _pickCustomer(List<Customer> customers) async {
    final customer = await showCustomerPicker(context, customers);
    if (customer != null) setState(() => _customer = customer);
  }

  Future<void> _addItem() async {
    final item = await showAddItemDialog(context);
    if (item != null) setState(() => _items = [..._items, item]);
  }

  void _deleteItem(int index) {
    setState(() => _items = [..._items]..removeAt(index));
  }

  Future<void> _save() async {
    if (_customer == null) {
      _showMessage('נא לבחור לקוח');
      return;
    }
    if (_items.isEmpty) {
      _showMessage('נא להוסיף לפחות פריט אחד');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final quoteNumber = await widget.firestoreService.generateQuoteNumber();
      final quoteId = FirestoreService.generateId();
      final now = DateTime.now();

      final quote = Quote(
        id: quoteId,
        quoteNumber: quoteNumber,
        title: _titleController.text.trim(),
        customerId: _customer!.id,
        customerName: _customer!.name,
        customerHp: _customer!.hp,
        customerAddress: _customer!.address,
        customerPhone: _customer!.phone,
        items: _items,
        discount: _discount,
        total: _total,
        notes: _notesController.text.trim(),
        status: QuoteStatus.draft,
        date: now,
        createdAt: now,
      );

      await widget.firestoreService.addQuote(quote);
      if (!mounted) return;

      HapticFeedback.mediumImpact();
      _showMessage('הצעת המחיר נשמרה בהיסטוריה בהצלחה!');
      _reset();
    } catch (e) {
      if (!mounted) return;
      _showMessage('שגיאה בשמירה: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _reset() {
    _titleController.clear();
    _notesController.clear();
    setState(() {
      _customer = null;
      _items = [];
      _discount = 0;
    });
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
        final customers = customerSnapshot.data ?? [];

        return StreamBuilder(
          stream: widget.firestoreService.watchCatalog(),
          builder: (context, catalogSnapshot) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'נושא/כותרת ההצעה',
                    hintText: 'לדוגמה: חיתוך שלטים, כרטיסי אלומיניום',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickCustomer(customers),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'לקוח',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    child: _customer != null
                        ? Text(_customer!.name)
                        : Text(customers.isEmpty ? 'אין לקוחות - יש להוסיף תחילה' : 'בחירת לקוח...'),
                  ),
                ),
                if (_customer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'ח.פ: ${_customer!.hp} | כתובת: ${_customer!.address}',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'פריטים בהצעה (${_items.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('הוסף שירות / פריט'),
                    ),
                  ],
                ),
                if (_items.isEmpty)
                  Card(
                    child: InkWell(
                      onTap: _addItem,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          'לחץ להוספת פריט ראשון',
                          style: TextStyle(color: cs.outline),
                        ),
                      ),
                    ),
                  ),
                QuoteSummaryCard(
                  items: _items,
                  discount: _discount,
                  notes: _notesController.text,
                  discountChanged: (v) => setState(() => _discount = v),
                  notesChanged: (v) => _notesController.text = v,
                  itemDeleted: _deleteItem,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'שומר...' : 'שמירת הצעה'),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        );
      },
    );
  }
}
