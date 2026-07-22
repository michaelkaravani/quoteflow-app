import 'package:flutter/material.dart';

import '../../models/quote_item.dart';

Future<QuoteItem?> showAddItemDialog(BuildContext context) {
  return showDialog<QuoteItem>(
    context: context,
    builder: (context) => const _AddItemDialog(),
  );
}

class _AddItemDialog extends StatefulWidget {
  const _AddItemDialog();

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  bool _saveToFavorites = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      QuoteItem(
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('הוספת פריט להצעה',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'שם הפריט / השירות',
                labelStyle: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface.withAlpha(153)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.primary.withAlpha(51))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.secondary)),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'נא להזין שם פריט' : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'מחיר ליחידה',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'נא להזין מחיר';
                      final n = double.tryParse(v.trim());
                      if (n == null || n < 0) return 'מחיר לא תקין';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'כמות',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n < 1) return 'הכמות חייבת להיות לפחות 1';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Checkbox(
                  value: _saveToFavorites,
                  onChanged: (v) => setState(() => _saveToFavorites = v ?? false),
                  activeColor: cs.secondary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Text('שמור מוצר זה למועדפים קבועים',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ביטול', style: TextStyle(color: cs.onSurface.withAlpha(153))),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondary,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text('שמירה'),
        ),
      ],
    );
  }
}
