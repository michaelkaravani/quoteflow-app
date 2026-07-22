class CatalogItem {
  final String id;
  final String name;
  final double price;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };

  factory CatalogItem.fromMap(String id, Map<String, dynamic> map) => CatalogItem(
        id: id,
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
      );

  CatalogItem copyWith({
    String? name,
    double? price,
  }) =>
      CatalogItem(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
      );
}
