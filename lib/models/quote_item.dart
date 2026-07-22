class QuoteItem {
  final String name;
  final double price;
  final int quantity;

  const QuoteItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory QuoteItem.fromMap(Map<String, dynamic> map) => QuoteItem(
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );

  QuoteItem copyWith({
    String? name,
    double? price,
    int? quantity,
  }) =>
      QuoteItem(
        name: name ?? this.name,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
      );
}
