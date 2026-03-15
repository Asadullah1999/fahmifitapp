import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/biometric_auth_service.dart';
import '../../../core/database/hive_database.dart';
import '../../../shared/theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _biometric = BiometricAuthService();
  final _pinController = TextEditingController();
  String _pin = '';
  String? _error;
  bool _showPinInput = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final settings = HiveDatabase.settings.get('settings');
    if (settings?.hasCompletedOnboarding == false) {
      if (mounted) context.go('/onboarding');
      return;
    }
    await _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final biometricEnabled = await _biometric.isBiometricEnabled();
    final hasPin = await _biometric.hasPin();

    if (!hasPin) {
      // First time - go to onboarding/setup
      if (mounted) context.go('/onboarding');
      return;
    }

    if (biometricEnabled) {
      final authenticated = await _biometric.authenticateWithBiometric();
      if (authenticated && mounted) {
        context.go('/home');
        return;
      }
    }

    // Fall back to PIN
    if (mounted) setState(() => _showPinInput = true);
  }

  Future<void> _verifyPin() async {
    final correct = await _biometric.verifyPin(_pin);
    if (correct) {
      if (mounted) context.go('/home');
    } else {
      setState(() {
        _pin = '';
        _error = 'Incorrect PIN';
      });
    }
  }

  void _onKeyTap(String key) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += key;
      _error = null;
    });
    if (_pin.length == 6) _verifyPin();
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: !_showPinInput
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: AppTheme.primaryColor, size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'DocVault',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 48),
                    const CircularProgressIndicator(color: AppTheme.primaryColor),
                  ],
                )
              : _PinPad(
                  pin: _pin,
                  error: _error,
                  onKeyTap: _onKeyTap,
                  onDelete: _onDelete,
                  onBiometric: _tryBiometric,
                ),
        ),
      ),
    );
  }
}

class _PinPad extends StatelessWidget {
  final String pin;
  final String? error;
  final ValueChanged<String> onKeyTap;
  final VoidCallback onDelete;
  final VoidCallback onBiometric;

  const _PinPad({
    required this.pin,
    required this.error,
    required this.onKeyTap,
    required this.onDelete,
    required this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, color: AppTheme.primaryColor, size: 48),
        const SizedBox(height: 16),
        const Text('Enter PIN',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
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
                border: Border.all(
                  color: filled ? AppTheme.primaryColor : Colors.grey[600]!,
                  width: 1.5,
                ),
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
              _Key(
                child: const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                onTap: onBiometric,
              ),
              _Key(label: '0', onTap: () => onKeyTap('0')),
              _Key(
                child: const Icon(Icons.backspace_outlined, color: Colors.white, size: 24),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ],
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
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: label != null
                ? Text(label!,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300))
                : child,
          ),
        ),
      ),
    );
  }
}
