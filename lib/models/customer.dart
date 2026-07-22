class Customer {
  final String id;
  final String name;
  final String hp;
  final String address;
  final String phone;

  const Customer({
    required this.id,
    required this.name,
    required this.hp,
    required this.address,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'hp': hp,
        'address': address,
        'phone': phone,
      };

  factory Customer.fromMap(String id, Map<String, dynamic> map) => Customer(
        id: id,
        name: map['name'] as String? ?? '',
        hp: map['hp'] as String? ?? '',
        address: map['address'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
      );

  Customer copyWith({
    String? name,
    String? hp,
    String? address,
    String? phone,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        hp: hp ?? this.hp,
        address: address ?? this.address,
        phone: phone ?? this.phone,
      );
}
