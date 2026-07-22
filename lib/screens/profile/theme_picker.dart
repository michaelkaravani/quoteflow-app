import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/theme_notifier.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.notifier});

  final ThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'ערכת נושא',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Text('סגנון צבע', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppTheme.all.map((t) {
                final selected = notifier.theme.name == t.name;
                return ChoiceChip(
                  label: Text(t.displayName),
                  selected: selected,
                  onSelected: (_) {
                    notifier.setTheme(t.name);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('מצב תצוגה', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('ברירת מחדל של המערכת'),
                  selected: notifier.mode == ThemeMode.system,
                  onSelected: (_) {
                    notifier.setMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('מצב בהיר'),
                  selected: notifier.mode == ThemeMode.light,
                  onSelected: (_) {
                    notifier.setMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('מצב כהה'),
                  selected: notifier.mode == ThemeMode.dark,
                  onSelected: (_) {
                    notifier.setMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
