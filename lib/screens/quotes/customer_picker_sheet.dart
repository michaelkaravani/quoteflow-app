import 'package:flutter/material.dart';

import '../../models/customer.dart';

Future<Customer?> showCustomerPicker(BuildContext context, List<Customer> customers) {
  return showModalBottomSheet<Customer>(
    context: context,
    builder: (context) => _CustomerPickerSheet(customers: customers),
  );
}

class _CustomerPickerSheet extends StatelessWidget {
  const _CustomerPickerSheet({required this.customers});

  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'בחר לקוח מהרשימה',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (customers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('אין לקוחות רשומים. יש להוסיף לקוח תחילה.'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final c = customers[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
                    title: Text(c.name),
                    subtitle: Text(c.hp.isNotEmpty ? 'ח.פ: ${c.hp}' : c.phone),
                    onTap: () => Navigator.pop(context, c),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
