import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/auth/biometric_auth_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/scan/presentation/camera_screen.dart';
import 'features/scan/presentation/edge_adjust_screen.dart';
import 'features/scan/presentation/processing_screen.dart';
import 'features/scan/presentation/save_document_screen.dart';
import 'features/vault/presentation/vault_screen.dart';
import 'features/vault/presentation/document_detail_screen.dart';
import 'features/vault/presentation/search_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/paywall/presentation/paywall_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/lock_screen.dart';
import 'shared/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/lock',
  routes: [
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/vault',
          builder: (context, state) => const VaultScreen(),
          routes: [
            GoRoute(
              path: 'document/:id',
              builder: (context, state) => DocumentDetailScreen(
                documentId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Scan flow (full-screen, no shell)
    GoRoute(
      path: '/scan',
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/scan/adjust',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return EdgeAdjustScreen(imagePaths: extra['imagePaths'] as List<String>);
      },
    ),
    GoRoute(
      path: '/scan/processing',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ProcessingScreen(imagePaths: extra['imagePaths'] as List<String>);
      },
    ),
    GoRoute(
      path: '/scan/save',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SaveDocumentScreen(scanResult: extra['scanResult']);
      },
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
  ],
);

class DocVaultApp extends ConsumerWidget {
  const DocVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'DocVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _tabs = ['/home', '/vault', '/settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.push('/scan'),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.document_scanner, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              index: 0,
              currentIndex: _currentIndex,
              onTap: () => _navigate(0),
            ),
            const SizedBox(width: 56), // FAB space
            _NavItem(
              icon: Icons.folder_outlined,
              selectedIcon: Icons.folder,
              label: 'Vault',
              index: 1,
              currentIndex: _currentIndex,
              onTap: () => _navigate(1),
            ),
            _NavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              label: 'Settings',
              index: 2,
              currentIndex: _currentIndex,
              onTap: () => _navigate(2),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(int index) {
    setState(() => _currentIndex = index);
    context.go(_tabs[index]);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final color = isSelected ? AppTheme.primaryColor : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
