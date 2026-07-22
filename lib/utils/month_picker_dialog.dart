import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({super.key});

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  void _pick() {
    Navigator.pop(context, DateTime(_selectedYear, _selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('בחר חודש לייצוא',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _selectedYear,
            decoration: const InputDecoration(labelText: 'שנה'),
            items: List.generate(5, (i) => now.year - 2 + i).map((y) {
              return DropdownMenuItem(value: y, child: Text(y.toString()));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedYear = v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _selectedMonth,
            decoration: const InputDecoration(labelText: 'חודש'),
            items: List.generate(12, (i) => i + 1).map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(DateTime(2000, m).toString().split(' ')[0]),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedMonth = v);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  final now = DateTime.now();
                  Navigator.pop(context, DateTime(now.year, now.month));
                },
                child: const Text('החודש'),
              ),
              TextButton(
                onPressed: () {
                  final prev = DateTime.now().subtract(const Duration(days: 30));
                  Navigator.pop(context, DateTime(prev.year, prev.month));
                },
                child: const Text('חודש שעבר'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        FilledButton(
          onPressed: _pick,
          child: const Text('ייצוא'),
        ),
      ],
    );
  }
}
