import 'package:flutter/material.dart';

import '../../core/pdf_service.dart';
import '../../models/customer.dart';
import '../../models/profile.dart';
import '../../models/quote.dart';
import '../../models/quote_status.dart';
import '../../services/firestore_service.dart';
import '../../utils/csv_export_service.dart';
import '../../utils/month_picker_dialog.dart';
import 'kpi_card.dart';
import 'quote_card.dart';
import 'quick_action_tile.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    this.firestoreService,
    this.onNavigate,
    this.onEditQuote,
    this.onDeleteQuote,
    this.onUpdateQuoteStatus,
  });

  final FirestoreService? firestoreService;
  final ValueChanged<int>? onNavigate;
  final ValueChanged<Quote>? onEditQuote;
  final ValueChanged<Quote>? onDeleteQuote;
  final ValueChanged<Quote>? onUpdateQuoteStatus;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _searchController = TextEditingController();
  String _query = '';
  QuoteStatus? _filterStatus;
  bool _filterOpenOnly = false;
  String? _filterCustomerId;
  late final Stream<Profile?> _profileStream;
  late final Stream<List<Quote>> _quotesStream;

  @override
  void initState() {
    super.initState();
    _profileStream = widget.firestoreService!.watchProfile();
    _quotesStream = widget.firestoreService!.watchQuotes();
    widget.firestoreService!.migrateEmptyCustomerIds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Quote> _filtered(List<Quote> quotes) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return quotes;
    return quotes.where((quote) =>
      quote.title.toLowerCase().contains(q) ||
      quote.customerName.toLowerCase().contains(q) ||
      quote.quoteNumber.toString().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.firestoreService == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<Profile?>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        final businessName = profile?.businessName ?? '';
        final showQuoteNumber = profile?.showQuoteNumber ?? true;

        return StreamBuilder<List<Quote>>(
          stream: _quotesStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('שגיאה בטעינת הצעות מחיר:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allQuotes = snapshot.data ?? [];
            final filteredQuotes = allQuotes.where((q) {
              if (_filterOpenOnly && q.status != QuoteStatus.draft && q.status != QuoteStatus.sent) {
                return false;
              }
              if (_filterStatus != null && q.status != _filterStatus) {
                return false;
              }
              if (_filterCustomerId != null) {
                final match = q.customerId == _filterCustomerId;
                debugPrint('QUOTE_FILTER: q.customerId="${q.customerId}" == _filterCustomerId="$_filterCustomerId" => $match');
                if (!match) return false;
              }
              return true;
            }).toList();
            final quotes = _filtered(filteredQuotes);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  businessName.isNotEmpty ? 'שלום $businessName,' : 'שלום,',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('ניהול הצעות מחיר בזמן אמת', style: TextStyle(color: cs.onSurface.withAlpha(153))),
                const SizedBox(height: 24),
                Text('פעולות מהירות',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: QuickActionTile(
                      icon: Icons.calculate_rounded,
                      label: 'הצעת מחיר חדשה',
                      color: cs.secondary,
                      onTap: widget.onNavigate != null ? () => widget.onNavigate!(1) : null,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: QuickActionTile(
                      icon: Icons.people_alt_rounded,
                      label: 'ניהול לקוחות',
                      color: cs.primary,
                      onTap: widget.onNavigate != null ? () => widget.onNavigate!(2) : null,
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: KpiCard(
                      icon: Icons.description_outlined,
                      value: allQuotes.length.toString(),
                      label: 'הצעות',
                      active: _filterStatus == null && !_filterOpenOnly,
                      onTap: () => setState(() { _filterStatus = null; _filterOpenOnly = false; }),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: KpiCard(
                      icon: Icons.people_outline,
                      value: _uniqueCustomers(allQuotes).toString(),
                      label: 'לקוחות',
                      active: _filterCustomerId != null,
                      onTap: () => _showCustomerPicker(context),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: KpiCard(
                      icon: Icons.trending_up,
                      value: '₪${_totalOpen(allQuotes).toStringAsFixed(0)}',
                      label: 'סה"כ פתוח',
                      active: _filterOpenOnly,
                      onTap: () => setState(() => _filterOpenOnly = !_filterOpenOnly),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                if (_filterStatus != null || _filterOpenOnly || _filterCustomerId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        if (_filterOpenOnly)
                          Chip(
                            label: const Text('סטטוס: פתוח',
                                style: TextStyle(fontSize: 13, color: Colors.blue)),
                            backgroundColor: Colors.blue.withAlpha(38),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(() => _filterOpenOnly = false),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (_filterStatus != null)
                          Chip(
                            label: Text('סטטוס: ${_filterStatus!.displayName}',
                                style: TextStyle(fontSize: 13, color: _statusColor(_filterStatus!))),
                            backgroundColor: _statusColor(_filterStatus!).withAlpha(38),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(() => _filterStatus = null),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (_filterCustomerId != null)
                          Chip(
                            label: Text('לקוח מסונן',
                                style: const TextStyle(fontSize: 13)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(() => _filterCustomerId = null),
                            visualDensity: VisualDensity.compact,
                          ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _filterStatus = null;
                            _filterOpenOnly = false;
                            _filterCustomerId = null;
                          }),
                          child: const Text('נקה סינון', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: _filterStatus != null || _filterOpenOnly || _filterCustomerId != null ? 16 : 24),
                Row(
                  children: [
                    Expanded(
                      child: Text('הצעות מחיר אחרונות',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (allQuotes.isNotEmpty)
                      IconButton(
                        tooltip: 'ייצוא דוח חודשי',
                        icon: Icon(Icons.file_download, color: cs.primary, size: 24),
                        onPressed: () => _exportCsv(context, allQuotes, profileSnapshot.data),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (allQuotes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'חיפוש הצעות מחיר...',
                        hintStyle: TextStyle(color: cs.onSurface.withAlpha(102)),
                        prefixIcon: Icon(Icons.search, size: 20, color: cs.onSurface.withAlpha(153)),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18, color: cs.onSurface.withAlpha(153)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: cs.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: cs.secondary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                if (quotes.isEmpty)
                  Card(
                    surfaceTintColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _query.isNotEmpty
                            ? 'לא נמצאו הצעות מחיר העונות לסינון זה'
                            : 'אין עדיין הצעות מחיר שמורות.\nלחץ על הצעת מחיר חדשה כדי להתחיל.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurface.withAlpha(153)),
                      ),
                    ),
                  )
                else
                  ...quotes.take(20).map((quote) => QuoteCard(
                    quote: quote,
                    showQuoteNumber: showQuoteNumber,
                    onEdit: widget.onEditQuote,
                    onDelete: widget.onDeleteQuote,
                    onShare: () => _shareQuote(context, quote),
                    onStatusChanged: (newStatus) => _showStatusPicker(context, quote, newStatus),
                  )),
              ],
            );
          },
        );
      },
    );
  }

  int _uniqueCustomers(List<Quote> quotes) {
    return quotes.map((q) => q.customerId).toSet().length;
  }

  double _totalOpen(List<Quote> quotes) {
    return quotes
        .where((q) => q.status == QuoteStatus.draft || q.status == QuoteStatus.sent)
        .fold(0.0, (sum, q) => sum + q.finalTotal);
  }

  Color _statusColor(QuoteStatus status) {
    switch (status) {
      case QuoteStatus.draft:       return Colors.grey;
      case QuoteStatus.sent:        return Colors.blue;
      case QuoteStatus.approved:    return Colors.orange;
      case QuoteStatus.inProduction: return Colors.purple;
      case QuoteStatus.paid:        return Colors.green;
    }
  }

  void _showStatusPicker(BuildContext context, Quote quote, QuoteStatus current) {
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
                leading: Icon(Icons.circle, color: _statusColor(status), size: 20),
                title: Text(status.displayName),
                trailing: quote.status == status ? Icon(Icons.check, color: cs.primary) : null,
                onTap: () {
                  if (quote.status != status) {
                    widget.onUpdateQuoteStatus?.call(quote.copyWith(status: status));
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

  void _showCustomerPicker(BuildContext context) {
    final customersFuture = widget.firestoreService!.loadCustomers();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: FutureBuilder<List<Customer>>(
            future: customersFuture,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('שגיאה בטעינת לקוחות: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                );
              }
              final customers = snapshot.data ?? [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('בחר לקוח לסינון',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.primary)),
                  ),
                  if (customers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('אין לקוחות רשומים'),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: customers.length,
                        itemBuilder: (ctx, i) {
                          final c = customers[i];
                          return ListTile(
                            title: Text(c.name),
                            trailing: _filterCustomerId == c.id
                                ? Icon(Icons.check, color: cs.primary)
                                : null,
                            onTap: () {
                              setState(() => _filterCustomerId = c.id);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _exportCsv(BuildContext context, List<Quote> allQuotes, Profile? profile) async {
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('יש להשלים פרופיל תחילה')),
      );
      return;
    }
    final result = await showDialog<DateTime>(
      context: context,
      builder: (_) => const MonthPickerDialog(),
    );
    if (result == null || !context.mounted) return;
    try {
      await CsvExportService.shareCsv(allQuotes, profile, result.year, result.month);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בייצוא הדוח')),
        );
      }
    }
  }

  Future<void> _shareQuote(BuildContext context, Quote quote) async {
    if (widget.firestoreService == null) return;
    try {
      final profile = await widget.firestoreService!.loadProfile();
      if (profile != null) {
        await PdfService.shareQuote(quote, profile);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה בשמירת PDF')),
        );
      }
    }
  }
}
