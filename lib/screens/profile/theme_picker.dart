import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/theme_notifier.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, required this.notifier});

  final ThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('ערכת נושא',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.primary)),
            ),
            const SizedBox(height: 20),
            Text('סגנון צבע',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface.withAlpha(153))),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children: AppTheme.all.map((t) {
                final selected = notifier.theme.name == t.name;
                return GestureDetector(
                  onTap: () {
                    notifier.setTheme(t.name);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary.withAlpha(25) : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? cs.primary : cs.onSurface.withAlpha(38),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(t.icon, size: 28,
                            color: selected ? cs.primary : cs.onSurface.withAlpha(153)),
                        const SizedBox(height: 6),
                        Text(t.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: selected ? cs.primary : cs.onSurface.withAlpha(204),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('מצב תצוגה',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface.withAlpha(153))),
            const SizedBox(height: 8),
            _modeOption(context, Icons.brightness_auto, 'ברירת מחדל של המערכת', ThemeMode.system),
            _modeOption(context, Icons.light_mode, 'מצב בהיר', ThemeMode.light),
            _modeOption(context, Icons.dark_mode, 'מצב כהה', ThemeMode.dark),
          ],
        ),
      ),
    );
  }

  Widget _modeOption(BuildContext context, IconData icon, String label, ThemeMode mode) {
    final cs = Theme.of(context).colorScheme;
    final selected = notifier.mode == mode;
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
      onTap: () {
        notifier.setMode(mode);
        Navigator.pop(context);
      },
    );
  }
}
