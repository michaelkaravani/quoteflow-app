import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../main.dart';
import '../../models/profile.dart';
import '../../services/firestore_service.dart';
import '../about_screen.dart';
import 'theme_picker.dart';

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
  bool _showQuoteNumber = true;
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
        _showQuoteNumber = profile.showQuoteNumber;
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
        showQuoteNumber: _showQuoteNumber,
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    if (file.lengthSync() > 5 * 1024 * 1024) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await file.copy('${dir.path}/business_logo${result.files.single.extension ?? '.png'}');
    if (mounted) setState(() => _logoPath = saved.path);
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
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: cs.primary,
                child: Icon(Icons.business_rounded, size: 40, color: cs.onPrimary),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _businessController.text.isNotEmpty ? _businessController.text : 'שם העסק שלך',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ),
            Center(
              child: Text('מנהל מערכת',
                  style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(153))),
            ),
            const SizedBox(height: 32),
            Card(
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildField(_businessController, 'שם העסק / פרופיל', Icons.business),
                    const SizedBox(height: 16),
                    _buildField(_phoneController, 'מספר טלפון', Icons.phone_outlined),
                    const SizedBox(height: 16),
                    _buildField(_emailController, 'כתובת אימייל', Icons.email_outlined, readOnly: true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vatController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'אחוז מע"מ',
                              suffixText: '%',
                              filled: true, fillColor: cs.surfaceContainerLow,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.percent, size: 20),
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
                        child: Text('אינו גובה מע"מ ואינו מנכה מע"מ',
                            style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(128))),
                      ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _pickLogo,
                      icon: const Icon(Icons.image, size: 18),
                      label: Text(_logoPath.isNotEmpty ? 'החלף לוגו' : 'בחר לוגו'),
                    ),
                    if (_logoPath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('לוגו נבחר', style: TextStyle(color: cs.outline, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'הערות ברירת מחדל לתחתית ה-PDF',
                        filled: true, fillColor: cs.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _termsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'תנאי תשלום ל-PDF',
                        filled: true, fillColor: cs.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('שמירת שינויים'),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              surfaceTintColor: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.tag, color: cs.primary),
                    title: const Text('הצג מספר הצעה', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('הצגת #N ליד שם ההצעה (מוצג תמיד אם אין כותרת)',
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(153))),
                    value: _showQuoteNumber,
                    onChanged: (v) async {
                      setState(() => _showQuoteNumber = v);
                      try {
                        await widget.firestoreService.saveProfile(Profile(
                          businessName: _businessController.text.trim(),
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim(),
                          logoPath: _logoPath,
                          vatRate: double.tryParse(_vatController.text.trim()) ?? 17,
                          vatExempt: _vatExempt,
                          showQuoteNumber: v,
                          defaultPdfNotes: _notesController.text.trim(),
                          paymentTerms: _termsController.text.trim(),
                        ));
                      } catch (_) {}
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.palette_outlined, color: cs.primary),
                    title: const Text('ערכת נושא', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(themeNotifier.theme.displayName,
                        style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(153))),
                    trailing: Icon(Icons.arrow_back_ios_new, size: 16, color: cs.onSurface.withAlpha(153)),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (_) => ThemePicker(notifier: themeNotifier),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: cs.primary),
                    title: const Text('אודות האפליקציה', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Icon(Icons.arrow_back_ios_new, size: 16, color: cs.onSurface.withAlpha(153)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => authService.sendPasswordReset(authService.currentUser?.email ?? ''),
              icon: const Icon(Icons.lock_reset, size: 20),
              label: const Text('שליחת קישור לאיפוס סיסמה',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: cs.primary),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => authService.signOut(),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('התנתקות מהמערכת',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
