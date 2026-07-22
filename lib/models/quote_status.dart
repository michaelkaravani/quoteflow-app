enum QuoteStatus {
  draft,
  sent,
  approved,
  inProduction,
  paid;

  String get displayName {
    switch (this) {
      case QuoteStatus.draft:
        return 'טיוטה';
      case QuoteStatus.sent:
        return 'נשלח';
      case QuoteStatus.approved:
        return 'אושר';
      case QuoteStatus.inProduction:
        return 'בייצור';
      case QuoteStatus.paid:
        return 'שולם';
    }
  }
}
