import 'package:flutter/material.dart';

import '../../models/customer.dart';

class CustomerFormDialog extends StatefulWidget {
  const CustomerFormDialog({super.key, this.customer});

  final Customer? customer;

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _hpController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer?.name);
    _hpController = TextEditingController(text: customer?.hp);
    _addressController = TextEditingController(text: customer?.address);
    _phoneController = TextEditingController(text: customer?.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Customer(
        id: widget.customer?.id ?? '',
        name: _nameController.text.trim(),
        hp: _hpController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return AlertDialog(
      title: Text(isEditing ? 'עריכת לקוח' : 'הוספת לקוח חדש'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'שם הלקוח / חברה',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'נא להזין שם לקוח'
                    : null,
              ),
              TextFormField(
                controller: _hpController,
                decoration: const InputDecoration(
                  labelText: 'ח.פ / ת.ז',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'כתובת',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'טלפון',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return RegExp(r'^[0-9+\- ]+$').hasMatch(value)
                      ? null
                      : 'מספר הטלפון אינו תקין';
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        FilledButton(onPressed: _save, child: const Text('שמירה')),
      ],
    );
  }
}
