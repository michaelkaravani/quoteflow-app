import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/profile.dart';
import '../../services/firestore_service.dart';
import 'logo_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.firestoreService});

  final FirestoreService firestoreService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vatController = TextEditingController(text: '17');
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  bool _vatExempt = false;
  String _logoPath = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _businessController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vatController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await widget.firestoreService.loadProfile();
      if (profile != null && mounted) {
        _businessController.text = profile.businessName;
        _phoneController.text = profile.phone;
        _emailController.text = profile.email;
        _vatController.text = profile.vatRate.toStringAsFixed(0);
        _vatExempt = profile.vatExempt;
        _notesController.text = profile.defaultPdfNotes;
        _termsController.text = profile.paymentTerms;
        _logoPath = profile.logoPath;
      } else if (mounted) {
        _emailController.text = authService.currentUser?.email ?? '';
      }
    } catch (_) {
      if (mounted) _showMessage('לא ניתן לטעון את הפרופיל');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await widget.firestoreService.saveProfile(Profile(
        businessName: _businessController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        logoPath: _logoPath,
        vatRate: double.tryParse(_vatController.text.trim()) ?? 17,
        vatExempt: _vatExempt,
        defaultPdfNotes: _notesController.text.trim(),
        paymentTerms: _termsController.text.trim(),
      ));

      if (mounted) _showMessage('הפרטים עודכנו ונשמרו בהצלחה!');
    } catch (_) {
      if (mounted) _showMessage('שגיאה בשמירה. נא לנסות שוב.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickLogo() async {
    final path = await pickAndSaveLogo();
    if (path != null) setState(() => _logoPath = path);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('פרופיל משתמש')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('פרופיל משתמש')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  _businessController.text.isNotEmpty
                      ? _businessController.text[0]
                      : '?',
                  style: TextStyle(fontSize: 36, color: cs.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _businessController.text.isNotEmpty
                    ? _businessController.text
                    : 'שם העסק שלך',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _businessController,
              decoration: const InputDecoration(
                labelText: 'שם העסק / פרופיל',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'כתובת אימייל',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'מספר טלפון',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'אחוז מע"מ',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('פטור ממע"מ', style: TextStyle(fontSize: 13)),
                    value: _vatExempt,
                    onChanged: (v) => setState(() => _vatExempt = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (_vatExempt)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'אינו גובה מע"מ ואינו מנכה מע"מ',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.image_outlined),
              label: Text(_logoPath.isNotEmpty ? 'החלף לוגו' : 'הוסף לוגו עסק'),
            ),
            if (_logoPath.isNotEmpty)
              Text(
                'לוגו נבחר',
                style: TextStyle(color: cs.outline, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            const Text('הגדרות PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'הערות ברירת מחדל לתחתית ה-PDF',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'תנאי תשלום ל-PDF',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('שמירת שינויים'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ביטול'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
