import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/biometric_auth_service.dart';
import '../../../core/database/hive_database.dart';
import '../../../shared/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  // PIN setup state
  bool _showPinSetup = false;
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _pinError;
  final _biometric = BiometricAuthService();

  static const _pages = [
    _OnboardingPage(
      icon: Icons.shield,
      iconColor: AppTheme.primaryColor,
      title: 'Your Documents,\nYour Control',
      body:
          'DocVault stores everything encrypted on your device. No cloud. No tracking. No selling your data.',
    ),
    _OnboardingPage(
      icon: Icons.document_scanner,
      iconColor: AppTheme.secondaryColor,
      title: 'Scan in Seconds',
      body:
          'Point your camera at any document. DocVault detects edges, extracts text, and identifies the document type automatically.',
    ),
    _OnboardingPage(
      icon: Icons.notifications_active,
      iconColor: AppTheme.warningColor,
      title: 'Never Miss\nan Expiry',
      body:
          'Passport, license, insurance — DocVault reads expiry dates and reminds you months in advance.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showPinSetup) {
      return _PinSetupView(
        pin: _isConfirming ? _confirmPin : _pin,
        isConfirming: _isConfirming,
        error: _pinError,
        onKeyTap: _onPinKey,
        onDelete: _onPinDelete,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goToPinSetup,
                child: const Text('Skip', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() {
                  _currentPage = i;
                  _isLastPage = i == _pages.length - 1;
                }),
                itemBuilder: (ctx, i) => _OnboardingPageView(page: _pages[i]),
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage ? AppTheme.primaryColor : Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _isLastPage
                    ? _goToPinSetup
                    : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isLastPage ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPinSetup() => setState(() => _showPinSetup = true);

  void _onPinKey(String key) {
    setState(() {
      _pinError = null;
      if (_isConfirming) {
        if (_confirmPin.length < 6) _confirmPin += key;
        if (_confirmPin.length == 6) _finishPinSetup();
      } else {
        if (_pin.length < 6) _pin += key;
        if (_pin.length == 6) _moveToConfirm();
      }
    });
  }

  void _moveToConfirm() => setState(() => _isConfirming = true);

  void _onPinDelete() {
    setState(() {
      _pinError = null;
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _finishPinSetup() async {
    if (_pin != _confirmPin) {
      setState(() {
        _pinError = 'PINs do not match. Try again.';
        _confirmPin = '';
        _pin = '';
        _isConfirming = false;
      });
      return;
    }

    await _biometric.savePin(_pin);

    // Enable biometric if available
    final biometricAvailable = await _biometric.isBiometricAvailable();
    if (biometricAvailable) {
      await _biometric.setBiometricEnabled(true);
    }

    // Mark onboarding done
    final settings = HiveDatabase.settings.get('settings');
    if (settings != null) {
      settings.hasCompletedOnboarding = true;
      settings.isBiometricEnabled = biometricAvailable;
      await settings.save();
    }

    if (mounted) context.go('/home');
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, color: page.iconColor, size: 64),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PinSetupView extends StatelessWidget {
  final String pin;
  final bool isConfirming;
  final String? error;
  final ValueChanged<String> onKeyTap;
  final VoidCallback onDelete;

  const _PinSetupView({
    required this.pin,
    required this.isConfirming,
    required this.error,
    required this.onKeyTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 48),
              const SizedBox(height: 16),
              Text(
                isConfirming ? 'Confirm PIN' : 'Create a 6-digit PIN',
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                isConfirming ? 'Re-enter your PIN to confirm' : 'This PIN protects your vault',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppTheme.primaryColor : Colors.grey[700],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              if (error != null)
                Text(error!, style: const TextStyle(color: AppTheme.dangerColor, fontSize: 14)),

              const SizedBox(height: 32),

              // Number pad
              ...[
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
              ].map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((k) => _Key(label: k, onTap: () => onKeyTap(k))).toList(),
                ),
              )),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 96),
                    _Key(label: '0', onTap: () => onKeyTap('0')),
                    _Key(
                      child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback onTap;

  const _Key({this.label, this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: label != null
                ? Text(label!,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300))
                : child,
          ),
        ),
      ),
    );
  }
}
