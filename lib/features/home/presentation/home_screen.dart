import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../scan/providers/scan_provider.dart';
import '../../vault/domain/document_entity.dart';
import '../../../shared/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(documentRepositoryProvider);
    final allDocs = repo.getAll();
    final recentDocs = allDocs.take(5).toList();
    final expiringSoon = repo.getExpiringSoon().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/vault/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: AppTheme.secondaryColor, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'All documents encrypted on-device',
                  style: TextStyle(color: AppTheme.secondaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatCard(
                value: allDocs.length.toString(),
                label: 'Documents',
                icon: Icons.description,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              _StatCard(
                value: expiringSoon.length.toString(),
                label: 'Expiring Soon',
                icon: Icons.warning_amber,
                color: AppTheme.warningColor,
              ),
            ],
          ),

          // Expiry alerts
          if (expiringSoon.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expiry Alerts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton(
                  onPressed: () => context.go('/vault'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...expiringSoon.map((doc) => _ExpiryAlertCard(document: doc)),
          ],

          const SizedBox(height: 24),

          // Recent documents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Documents', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(
                onPressed: () => context.go('/vault'),
                child: const Text('View All'),
              ),
            ],
          ),

          if (recentDocs.isEmpty)
            _EmptyState(onScan: () => context.push('/scan'))
          else ...[
            const SizedBox(height: 8),
            ...recentDocs.map((doc) => _DocumentListItem(document: doc)),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryAlertCard extends StatelessWidget {
  final DocumentEntity document;

  const _ExpiryAlertCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final daysLeft = document.daysUntilExpiry;
    final isExpired = document.isExpired;
    final color = isExpired ? AppTheme.dangerColor : AppTheme.warningColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(document.type.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(document.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          isExpired
              ? 'Expired ${DateFormat('dd MMM yyyy').format(document.expiryDate!)}'
              : 'Expires in $daysLeft days',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          isExpired ? Icons.error : Icons.warning_amber,
          color: color,
        ),
        onTap: () => context.push('/vault/document/${document.id}'),
      ),
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  final DocumentEntity document;

  const _DocumentListItem({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(document.type.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(document.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${document.type.displayName} • ${DateFormat('dd MMM yyyy').format(document.updatedAt)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.push('/vault/document/${document.id}'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.document_scanner, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No documents yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the scan button below to\nadd your first document',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner),
            label: const Text('Scan Document'),
          ),
        ],
      ),
    );
  }
}
