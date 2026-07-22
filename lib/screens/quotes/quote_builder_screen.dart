import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/pdf_service.dart';
import '../../models/customer.dart';
import '../../models/quote.dart';
import '../../models/quote_item.dart';
import '../../models/quote_status.dart';
import '../../services/firestore_service.dart';
import 'add_item_dialog.dart';
import 'customer_picker_sheet.dart';
import 'quote_summary_card.dart';

class QuoteBuilderScreen extends StatefulWidget {
  const QuoteBuilderScreen({super.key, required this.firestoreService, this.existingQuote});

  final FirestoreService firestoreService;
  final Quote? existingQuote;

  @override
  State<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends State<QuoteBuilderScreen> {
  final _titleController = TextEditingController();
  Customer? _customer;
  List<QuoteItem> _items = [];
  double _discount = 0;
  String _notes = '';
  bool _isSaving = false;

  bool get _isEditing => widget.existingQuote != null;

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuote;
    if (q != null) {
      _titleController.text = q.title;
      _customer = q.customer;
      _items = List.from(q.items);
      _discount = q.discount;
      _notes = q.notes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    if (_customer == null) { _showMessage('נא לבחור לקוח'); return; }
    if (_items.isEmpty) { _showMessage('נא להוסיף לפחות פריט אחד'); return; }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final quote = Quote(
        id: _isEditing ? widget.existingQuote!.id : FirestoreService.generateId(),
        quoteNumber: _isEditing
            ? widget.existingQuote!.quoteNumber
            : await widget.firestoreService.generateQuoteNumber(),
        title: _titleController.text.trim(),
        customerId: _customer!.id, customerName: _customer!.name,
        customerHp: _customer!.hp, customerAddress: _customer!.address, customerPhone: _customer!.phone,
        items: _items, discount: _discount, total: _total,
        notes: _notes, status: widget.existingQuote?.status ?? QuoteStatus.draft,
        date: widget.existingQuote?.date ?? now,
        createdAt: widget.existingQuote?.createdAt ?? now,
      );

      if (_isEditing) {
        await widget.firestoreService.updateQuote(quote);
      } else {
        await widget.firestoreService.addQuote(quote);
      }

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      _showMessage(_isEditing ? 'הצעת המחיר עודכנה בהצלחה!' : 'הצעת המחיר נשמרה בהיסטוריה בהצלחה!');
      if (_isEditing) {
        Navigator.pop(context);
      } else {
        _titleController.clear();
        setState(() { _customer = null; _items = []; _discount = 0; _notes = ''; });
      }
    } catch (e) {
      if (mounted) _showMessage('שגיאה בשמירה: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _share() async {
    if (_customer == null) { _showMessage('נא לבחור לקוח'); return; }
    if (_items.isEmpty) { _showMessage('נא להוסיף לפחות פריט אחד'); return; }
    try {
      final profile = await widget.firestoreService.loadProfile();
      if (profile == null) { _showMessage('יש להשלים פרופיל תחילה'); return; }
      final quote = Quote(
        id: '',
        quoteNumber: 0,
        title: _titleController.text.trim(),
        customerId: _customer!.id, customerName: _customer!.name,
        customerHp: _customer!.hp, customerAddress: _customer!.address, customerPhone: _customer!.phone,
        items: _items, discount: _discount, total: _total,
        notes: _notes, status: QuoteStatus.draft,
        date: DateTime.now(), createdAt: DateTime.now(),
      );
      await PdfService.shareQuote(quote, profile);
    } catch (_) {
      _showMessage('שגיאה בייצור PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<List<Customer>>(
      stream: widget.firestoreService.watchCustomers(),
      builder: (context, customerSnapshot) {
        final customers = customerSnapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 4),
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'נושא/כותרת ההצעה',
                hintText: 'לדוגמה: חיתוך שלטים, כרטיסי אלומיניום',
                hintStyle: TextStyle(color: cs.onSurface.withAlpha(102)),
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.secondary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('לקוח', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _pickCustomer(customers),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: customers.isEmpty
                    ? Row(
                        children: [
                          Icon(Icons.info_outline, color: cs.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text('יש להוסיף תחילה לקוחות במסך "לקוחות".',
                              style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(153))),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              _customer?.name ?? 'בחר לקוח מהרשימה',
                              style: TextStyle(
                                fontWeight: _customer != null ? FontWeight.bold : FontWeight.normal,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: cs.onSurface),
                        ],
                      ),
              ),
            ),
            if (_customer != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Text('ח.פ: ${_customer!.hp} | כתובת: ${_customer!.address}',
                    style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(153))),
              ),
            const SizedBox(height: 20),
            Text('פריטים בהצעה',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('(${_items.length})',
                style: TextStyle(color: cs.onSurface.withAlpha(153))),
            const SizedBox(height: 6),
            InkWell(
              onTap: _addItem,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.secondary.withAlpha(153), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20, color: cs.secondary),
                    const SizedBox(width: 6),
                    Text('הוסף שירות / פריט',
                        style: TextStyle(color: cs.secondary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            QuoteSummaryCard(
              items: _items,
              discount: _discount,
              notes: _notes,
              discountChanged: (v) => setState(() => _discount = v),
              notesChanged: (v) => setState(() => _notes = v),
              itemDeleted: _deleteItem,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  disabledBackgroundColor: Colors.black12,
                  disabledForegroundColor: Colors.black26,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('שמירת הצעה', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_items.isNotEmpty) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share, size: 18),
                label: const Text('שתף כ-PDF'),
                style: TextButton.styleFrom(
                  foregroundColor: cs.primary,
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
