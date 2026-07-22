import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('אודות')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.request_quote, size: 72, color: cs.primary),
              const SizedBox(height: 16),
              Text('QuoteFlow', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'מערכת ניהול הצעות מחיר',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text('גרסה 1.0.0'),
              const SizedBox(height: 24),
              Text(
                'QuoteFlow נועדה לנהל ולהפיק הצעות מחיר מקצועיות.\nניתן להוסיף לקוחות, פריטים מועדפים,\nולשתף הצעות מחיר כקובצי PDF מותאמים אישית.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://wa.me/972500000000')),
                icon: const Icon(Icons.chat),
                label: const Text('ליצירת קשר ב-WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
