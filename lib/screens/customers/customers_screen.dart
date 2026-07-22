import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/firestore_service.dart';
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<List<Customer>>(
      stream: widget.firestoreService.watchCustomers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('לא ניתן לטעון את רשימת הלקוחות'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = _filtered(snapshot.data!);
        return Stack(
          children: [
            Column(
              children: [
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
                  child: customers.isEmpty
                      ? _EmptyCustomers(hasQuery: _query.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return CustomerCard(
                              customer: customer,
                              onEdit: () => _openForm(customer),
                              onDelete: () => _delete(customer),
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
  }

  List<Customer> _filtered(List<Customer> customers) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.phone.contains(query) ||
          customer.hp.contains(query) ||
          customer.address.toLowerCase().contains(query);
    }).toList();
  }
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'לא נמצאו לקוחות התואמים לחיפוש'
                  : 'אין עדיין לקוחות רשומים.\nלחץ על "לקוח חדש" כדי להתחיל.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
