import 'package:flutter/material.dart';

import '../main.dart';
import '../services/firestore_service.dart';
import 'customers/customers_screen.dart';
import 'home/bottom_nav_bar.dart';
import 'home/dashboard_view.dart';
import 'profile/profile_screen.dart';
import 'quotes/quote_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  FirestoreService? get _fs {
    final user = authService.currentUser;
    return user == null ? null : FirestoreService(uid: user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fs = _fs;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _selectedIndex = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuoteFlow'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          actions: [
            if (fs != null)
              IconButton(
                tooltip: 'פרופיל',
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(firestoreService: fs)),
                ),
              ),
            IconButton(
              tooltip: 'התנתקות',
              icon: const Icon(Icons.logout),
              onPressed: () => authService.signOut(),
            ),
          ],
        ),
        body: ColoredBox(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DashboardView(
                      firestoreService: fs,
                      onNavigate: (index) => setState(() => _selectedIndex = index),
                      onUpdateQuoteStatus: (quote) async {
                        if (fs == null) return;
                        await fs.updateQuote(quote);
                      },
                      onEditQuote: (quote) {
                        if (fs == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: Text('עריכת הצעת מחיר #${quote.quoteNumber}'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              body: QuoteBuilderScreen(
                                firestoreService: fs,
                                existingQuote: quote,
                              ),
                            ),
                          ),
                        );
                      },
                      onDeleteQuote: (quote) async {
                        if (fs == null) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('מחיקת הצעת מחיר'),
                            content: Text('האם למחוק את ${quote.title.isNotEmpty ? '${quote.title} #${quote.quoteNumber}' : 'הצעה #${quote.quoteNumber}'}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ביטול')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('מחיקה')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await fs.deleteQuote(quote.id);
                        }
                      },
                    ),
                    if (fs != null) QuoteBuilderScreen(firestoreService: fs)
                    else const Center(child: Text('הצעה חדשה')),
                    if (fs != null) CustomersScreen(firestoreService: fs)
                    else const Center(child: Text('לא נמצא משתמש מחובר')),
                  ],
                ),
              ),
              BottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
