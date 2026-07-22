import 'dart:typed_data';
import 'package:printing/printing.dart';

import '../models/quote.dart';
import '../models/profile.dart';
import 'pdf_templates/premium_dark_template.dart';

class PdfService {
  static const templates = {
    'premium_dark': 'יוקרתי כהה',
  };

  static Future<Uint8List> generateQuotePdf(Quote quote, Profile profile, {String template = 'premium_dark'}) async {
    switch (template) {
      default:
        return PremiumDarkTemplate.build(quote, profile);
    }
  }

  static Future<void> shareQuote(Quote quote, Profile profile, {String template = 'premium_dark'}) async {
    final pdf = await generateQuotePdf(quote, profile, template: template);
    await Printing.sharePdf(
      bytes: pdf,
      filename: 'quote_${quote.quoteNumber}.pdf',
    );
  }

  static Future<void> previewQuote(Quote quote, Profile profile, {String template = 'premium_dark'}) async {
    final pdf = await generateQuotePdf(quote, profile, template: template);
    await Printing.sharePdf(
      bytes: pdf,
      filename: 'quote_${quote.quoteNumber}.pdf',
    );
  }
}
