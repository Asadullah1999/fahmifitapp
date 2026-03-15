import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/hive_database.dart';
import '../../../core/auth/biometric_auth_service.dart';
import '../../scan/providers/scan_provider.dart';
import '../../../shared/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _biometric = BiometricAuthService();
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await _biometric.isBiometricEnabled();
    final available = await _biometric.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = HiveDatabase.settings.get('settings');
    final repo = ref.read(documentRepositoryProvider);
    final docCount = repo.totalCount;
    final isPremium = settings?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Subscription status
          _SectionHeader('Subscription'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPremium ? AppTheme.secondaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPremium ? 'Premium' : 'Free',
                          style: TextStyle(
                            color: isPremium ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!isPremium)
                        TextButton(
                          onPressed: () => context.push('/paywall'),
                          child: const Text('Upgrade'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!isPremium)
                    LinearProgressIndicator(
                      value: docCount / 20,
                      backgroundColor: Colors.grey[200],
                      color: docCount >= 18 ? AppTheme.dangerColor : AppTheme.primaryColor,
                    ),
                  if (!isPremium)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$docCount / 20 documents used',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Security
          _SectionHeader('Security'),
          if (_biometricAvailable)
            _SettingsTile(
              icon: Icons.fingerprint,
              title: 'Biometric Unlock',
              subtitle: 'Use Face ID / Fingerprint to unlock',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (v) async {
                  await _biometric.setBiometricEnabled(v);
                  setState(() => _biometricEnabled = v);
                },
              ),
            ),
          _SettingsTile(
            icon: Icons.pin,
            title: 'Change PIN',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 8),

          // Backup
          _SectionHeader('Backup & Restore'),
          _SettingsTile(
            icon: Icons.cloud_upload,
            title: 'Encrypted Cloud Backup',
            subtitle: isPremium ? 'Tap to configure' : 'Premium feature',
            trailing: isPremium
                ? const Icon(Icons.chevron_right)
                : const Icon(Icons.lock, color: Colors.grey, size: 18),
            onTap: () {
              if (!isPremium) context.push('/paywall');
            },
          ),

          const SizedBox(height: 8),

          // Reminders
          _SectionHeader('Reminders'),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Expiry Reminders',
            subtitle: isPremium ? 'Set before expiry date' : 'Premium feature',
            trailing: isPremium
                ? const Icon(Icons.chevron_right)
                : const Icon(Icons.lock, color: Colors.grey, size: 18),
            onTap: () {
              if (!isPremium) context.push('/paywall');
            },
          ),

          const SizedBox(height: 8),

          // About
          _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
