import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/profile.dart';
import '../models/quote.dart';

class CsvExportService {
  static String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _vatSuffix(Profile profile) =>
      profile.vatExempt ? 'פטור' : '${profile.vatRate.toStringAsFixed(0)}%';

  static String generateCsv(List<Quote> quotes, Profile profile, int year, int month) {
    final buf = StringBuffer();

    // Header row
    buf.writeln('מס\' הצעה,תאריך,לקוח,ח"פ,תיאור,סטטוס,סכום נטו,מע"מ (${_vatSuffix(profile)}),סה"כ');

    final filtered = quotes.where((q) =>
        q.date.year == year && q.date.month == month);

    for (final quote in filtered) {
      final netTotal = profile.vatExempt
          ? quote.finalTotal
          : (quote.finalTotal / (1 + profile.vatRate / 100));
      final vat = profile.vatExempt ? 0.0 : quote.finalTotal - netTotal;
      final total = profile.vatExempt ? netTotal : quote.finalTotal;

      buf.writeln([
        quote.quoteNumber.toString(),
        _formatDate(quote.date),
        _escape(quote.customerName),
        _escape(quote.customerHp),
        _escape(quote.title),
        _escape(quote.status.displayName),
        netTotal.toStringAsFixed(2),
        vat.toStringAsFixed(2),
        total.toStringAsFixed(2),
      ].join(','));
    }

    return buf.toString();
  }

  static Future<void> shareCsv(List<Quote> quotes, Profile profile, int year, int month) async {
    final csv = '\uFEFF${generateCsv(quotes, profile, year, month)}';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/quoteflow_report_${year}_${month.toString().padLeft(2, '0')}.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'דוח חודשי $month/$year - QuoteFlow',
    );
  }
}
