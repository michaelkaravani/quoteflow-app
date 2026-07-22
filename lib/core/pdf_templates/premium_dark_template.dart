import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/profile.dart';
import '../../models/quote.dart';
import '../../models/quote_item.dart';

class PremiumDarkTemplate {
  static Future<Uint8List> build(Quote quote, Profile profile) async {
    final pdf = pw.Document();
    final font = pw.Font.helvetica();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _header(context, quote, profile, font),
          _customerInfo(quote, font),
          _itemsTable(quote.items, font),
          _summary(quote, font),
          if (quote.notes.isNotEmpty) _notes(quote.notes, font),
          if (profile.paymentTerms.isNotEmpty) _terms(profile.paymentTerms, font),
        ],
      ),
    );
    return pdf.save();
  }

static pw.Widget _header(pw.Context ctx, Quote quote, Profile profile, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profile.businessName.isNotEmpty ? profile.businessName : 'QuoteFlow',
                  style: pw.TextStyle(font: font, fontSize: 22, fontWeight: pw.FontWeight.bold)),
              if (profile.phone.isNotEmpty) pw.Text(profile.phone, style: pw.TextStyle(font: font, fontSize: 10)),
              if (profile.email.isNotEmpty) pw.Text(profile.email, style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('הצעת מחיר מס\' ${quote.quoteNumber}',
                  style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(quote.date.toString(), style: pw.TextStyle(font: font, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _customerInfo(Quote quote, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('לקוח:', style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(quote.customerName, style: pw.TextStyle(font: font, fontSize: 12)),
          if (quote.customerHp.isNotEmpty) pw.Text('ח.פ: ${quote.customerHp}', style: pw.TextStyle(font: font, fontSize: 10)),
          if (quote.customerAddress.isNotEmpty) pw.Text(quote.customerAddress, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _itemsTable(List<QuoteItem> items, pw.Font font) {
    final headers = ['תיאור', 'כמות', 'מחיר ליחידה', 'סה"כ'];
    final headerStyle = pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    final cellStyle = pw.TextStyle(font: font, fontSize: 10);

    return pw.TableHelper.fromTextArray(
      headerStyle: headerStyle,
      cellStyle: cellStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      headerPadding: const pw.EdgeInsets.all(6),
      cellPadding: const pw.EdgeInsets.all(6),
      headers: headers,
      data: items.map((item) => [
            item.name,
            item.quantity.toString(),
            '₪${item.price.toStringAsFixed(0)}',
            '₪${item.total.toStringAsFixed(0)}',
          ]).toList(),
    );
  }

  static pw.Widget _summary(Quote quote, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('סכום ביניים: ₪${quote.subtotal.toStringAsFixed(0)}', style: pw.TextStyle(font: font, fontSize: 11)),
          if (quote.discount > 0)
            pw.Text('הנחה: ₪${quote.discount.toStringAsFixed(0)}', style: pw.TextStyle(font: font, fontSize: 11)),
          pw.Divider(),
          pw.Text('סה"כ לתשלום: ₪${quote.finalTotal.toStringAsFixed(0)}',
              style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _notes(String notes, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Divider(),
          pw.Text('הערות:', style: pw.TextStyle(font: font, fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(notes, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _terms(String terms, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Text('תנאי תשלום: $terms', style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey)),
    );
  }
}
