import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isMonthlySelected = true;
  bool _isLoading = false;

  static const _monthlyPrice = '\$4.99/mo';
  static const _lifetimePrice = '\$39.99 once';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'DocVault Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your documents. Unlimited. Secure.',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Features list
              ..._features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppTheme.secondaryColor, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Text(f, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  ],
                ),
              )),

              const Spacer(),

              // Plan selector
              Row(
                children: [
                  Expanded(
                    child: _PlanCard(
                      title: 'Monthly',
                      price: _monthlyPrice,
                      isSelected: _isMonthlySelected,
                      onTap: () => setState(() => _isMonthlySelected = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlanCard(
                      title: 'Lifetime',
                      price: _lifetimePrice,
                      badge: 'Best Value',
                      isSelected: !_isMonthlySelected,
                      onTap: () => setState(() => _isMonthlySelected = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // CTA button
              ElevatedButton(
                onPressed: _isLoading ? null : _purchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isMonthlySelected
                            ? 'Start Premium — $_monthlyPrice'
                            : 'Get Lifetime Access — $_lifetimePrice',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),

              const SizedBox(height: 12),

              // Restore & terms
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Restore Purchase',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const Text('·', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Terms',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  const Text('·', style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Privacy',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    'Unlimited document storage',
    'Smart expiry reminders',
    'Advanced OCR & field extraction',
    'Encrypted cloud backup',
    'Secure time-limited share links',
    'Auto document categorization',
  ];

  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    // TODO: Integrate RevenueCat purchases_flutter SDK
    // final offerings = await Purchases.getOfferings();
    // await Purchases.purchasePackage(package);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase flow will connect to RevenueCat'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(price,
                style: const TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
