import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/hive_database.dart';
import '../../scan/providers/scan_provider.dart';
import '../domain/folder_entity.dart';
import '../domain/document_entity.dart';
import '../../../shared/theme/app_theme.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String? _selectedFolderId;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(documentRepositoryProvider);
    final folders = HiveDatabase.folders.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: _selectedFolderId == null
            ? const Text('Vault')
            : Text(HiveDatabase.folders.get(_selectedFolderId!)?.name ?? 'Folder'),
        leading: _selectedFolderId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFolderId = null),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/vault/search'),
          ),
          if (_selectedFolderId == null)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddFolderDialog(context),
            ),
        ],
      ),
      body: _selectedFolderId == null
          ? _FolderGrid(folders: folders, onFolderTap: (id) => setState(() => _selectedFolderId = id))
          : _DocumentList(
              folderId: _selectedFolderId!,
              documents: repo.getByFolder(_selectedFolderId!),
            ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '📁';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Folder Name'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await HiveDatabase.folders.put(
                  nameCtrl.text.toLowerCase().replaceAll(' ', '_'),
                  FolderEntity(
                    id: nameCtrl.text.toLowerCase().replaceAll(' ', '_'),
                    name: nameCtrl.text.trim(),
                    iconEmoji: selectedEmoji,
                    colorHex: '#64748B',
                    documentCount: 0,
                    createdAt: DateTime.now(),
                  ),
                );
                if (mounted) setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _FolderGrid extends StatelessWidget {
  final List<FolderEntity> folders;
  final ValueChanged<String> onFolderTap;

  const _FolderGrid({required this.folders, required this.onFolderTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: folders.length,
      itemBuilder: (ctx, i) => _FolderCard(folder: folders[i], onTap: onFolderTap),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final FolderEntity folder;
  final ValueChanged<String> onTap;

  const _FolderCard({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(folder.colorHex);

    return InkWell(
      onTap: () => onTap(folder.id),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(folder.iconEmoji, style: const TextStyle(fontSize: 22)),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
              const Spacer(),
              Text(folder.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                '${folder.documentCount} doc${folder.documentCount == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}

class _DocumentList extends StatelessWidget {
  final String folderId;
  final List<DocumentEntity> documents;

  const _DocumentList({required this.folderId, required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No documents in this folder'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/scan'),
              icon: const Icon(Icons.document_scanner),
              label: const Text('Scan Document'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _DocumentItem(document: documents[i]),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final DocumentEntity document;

  const _DocumentItem({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(document.type.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(document.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.type.displayName,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (document.isExpiringSoon || document.isExpired)
              Row(
                children: [
                  Icon(
                    document.isExpired ? Icons.error : Icons.warning_amber,
                    color: document.isExpired ? AppTheme.dangerColor : AppTheme.warningColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    document.isExpired
                        ? 'Expired'
                        : 'Expires in ${document.daysUntilExpiry} days',
                    style: TextStyle(
                      color: document.isExpired ? AppTheme.dangerColor : AppTheme.warningColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chevron_right, color: Colors.grey),
            if (document.hasReminder)
              const Icon(Icons.notifications_active, color: AppTheme.primaryColor, size: 14),
          ],
        ),
        onTap: () => context.push('/vault/document/${document.id}'),
      ),
    );
  }
}
