class Profile {
  final String businessName;
  final String phone;
  final String email;
  final String logoPath;
  final double vatRate;
  final bool vatExempt;
  final String defaultPdfNotes;
  final String paymentTerms;

  const Profile({
    required this.businessName,
    required this.phone,
    required this.email,
    this.logoPath = '',
    this.vatRate = 17.0,
    this.vatExempt = false,
    this.defaultPdfNotes = '',
    this.paymentTerms = '',
  });

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'phone': phone,
        'email': email,
        'logoPath': logoPath,
        'vatRate': vatRate,
        'vatExempt': vatExempt,
        'defaultPdfNotes': defaultPdfNotes,
        'paymentTerms': paymentTerms,
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        businessName: map['businessName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        logoPath: map['logoPath'] as String? ?? '',
        vatRate: (map['vatRate'] as num?)?.toDouble() ?? 17.0,
        vatExempt: map['vatExempt'] as bool? ?? false,
        defaultPdfNotes: map['defaultPdfNotes'] as String? ?? '',
        paymentTerms: map['paymentTerms'] as String? ?? '',
      );

  Profile copyWith({
    String? businessName,
    String? phone,
    String? email,
    String? logoPath,
    double? vatRate,
    bool? vatExempt,
    String? defaultPdfNotes,
    String? paymentTerms,
  }) =>
      Profile(
        businessName: businessName ?? this.businessName,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        logoPath: logoPath ?? this.logoPath,
        vatRate: vatRate ?? this.vatRate,
        vatExempt: vatExempt ?? this.vatExempt,
        defaultPdfNotes: defaultPdfNotes ?? this.defaultPdfNotes,
        paymentTerms: paymentTerms ?? this.paymentTerms,
      );
}
