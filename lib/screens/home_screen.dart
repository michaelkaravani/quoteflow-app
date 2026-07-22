import 'package:flutter/material.dart';

import '../main.dart';
import '../services/firestore_service.dart';
import 'customers/customers_screen.dart';
import 'profile/profile_screen.dart';
import 'quotes/quote_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  FirestoreService? _firestoreService() {
    final user = authService.currentUser;
    return user == null ? null : FirestoreService(uid: user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fs = _firestoreService();

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
                  _DashboardView(onNavigate: (index) => setState(() => _selectedIndex = index)),
                  if (fs != null) QuoteBuilderScreen(firestoreService: fs)
                  else const Center(child: Text('הצעה חדשה')),
                  if (fs != null)
                    CustomersScreen(firestoreService: fs)
                  else
                    const Center(child: Text('לא נמצא משתמש מחובר')),
                ],
              ),
            ),
            _BottomNavBar(
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

// ── Bottom navigation ──

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: selectedIndex == 0 ? Icons.dashboard_rounded : Icons.dashboard_outlined,
                label: 'ראשי',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: selectedIndex == 1 ? Icons.description : Icons.description_outlined,
                label: 'הצעה חדשה',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: selectedIndex == 2 ? Icons.people : Icons.people_outlined,
                label: 'לקוחות',
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashboard ──

class _DashboardView extends StatelessWidget {
  const _DashboardView({this.onNavigate});

  final ValueChanged<int>? onNavigate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('שלום,', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'ניהול הצעות מחיר בזמן אמת',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Text(
          'פעולות מהירות',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.add_circle,
                label: 'הצעת מחיר חדשה',
                color: cs.primary,
                onTap: onNavigate != null ? () => onNavigate!(1) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.people,
                label: 'ניהול לקוחות',
                color: cs.tertiary,
                onTap: onNavigate != null ? () => onNavigate!(2) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'הצעות מחיר אחרונות',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'אין עדיין הצעות מחיר שמורות',
          style: TextStyle(color: cs.outline),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onColor = Theme.of(context).colorScheme.onPrimary;
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: onColor, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: onColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
