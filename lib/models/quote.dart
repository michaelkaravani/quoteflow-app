import 'customer.dart';
import 'quote_item.dart';
import 'quote_status.dart';

class Quote {
  final String id;
  final int quoteNumber;
  final String customerId;
  final String customerName;
  final String customerHp;
  final String customerAddress;
  final String customerPhone;
  final List<QuoteItem> items;
  final double discount;
  final double total;
  final String title;
  final String notes;
  final QuoteStatus status;
  final DateTime date;
  final DateTime createdAt;

  const Quote({
    required this.id,
    required this.quoteNumber,
    required this.customerId,
    required this.customerName,
    this.customerHp = '',
    this.customerAddress = '',
    this.customerPhone = '',
    required this.items,
    this.discount = 0,
    required this.total,
    required this.title,
    this.notes = '',
    required this.status,
    required this.date,
    required this.createdAt,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get finalTotal => (subtotal - discount).clamp(0, double.infinity);

  Customer get customer => Customer(
        id: customerId,
        name: customerName,
        hp: customerHp,
        address: customerAddress,
        phone: customerPhone,
      );

  bool get isOverdue => status == QuoteStatus.sent &&
      DateTime.now().difference(date).inDays > 7;

  Map<String, dynamic> toMap() => {
        'quoteNumber': quoteNumber,
        'title': title,
        'customerId': customerId,
        'customerName': customerName,
        'customerHp': customerHp,
        'customerAddress': customerAddress,
        'customerPhone': customerPhone,
        'items': items.map((e) => e.toMap()).toList(),
        'discount': discount,
        'total': finalTotal,
        'notes': notes,
        'status': status.name,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Quote.fromMap(String id, Map<String, dynamic> map) {
    final itemsRaw = map['items'] as List<dynamic>? ?? [];
    final items = itemsRaw
        .map((e) => QuoteItem.fromMap(e as Map<String, dynamic>))
        .toList();

    return Quote(
      id: id,
      quoteNumber: (map['quoteNumber'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerHp: map['customerHp'] as String? ?? '',
      customerAddress: map['customerAddress'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      items: items,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? '',
      status: _parseStatus(map['status'] as String?),
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static QuoteStatus _parseStatus(String? value) {
    for (final s in QuoteStatus.values) {
      if (s.name == value) return s;
    }
    return QuoteStatus.draft;
  }

  Quote copyWith({
    String? id,
    int? quoteNumber,
    String? customerId,
    String? customerName,
    String? customerHp,
    String? customerAddress,
    String? customerPhone,
    List<QuoteItem>? items,
    double? discount,
    double? total,
    String? title,
    String? notes,
    QuoteStatus? status,
    DateTime? date,
    DateTime? createdAt,
  }) =>
      Quote(
        id: id ?? this.id,
        quoteNumber: quoteNumber ?? this.quoteNumber,
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        customerHp: customerHp ?? this.customerHp,
        customerAddress: customerAddress ?? this.customerAddress,
        customerPhone: customerPhone ?? this.customerPhone,
        items: items ?? this.items,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
}
