import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../scan/providers/scan_provider.dart';
import '../domain/document_entity.dart';
import '../../../shared/theme/app_theme.dart';

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  File? _decryptedPdfFile;
  bool _isLoading = true;
  String? _error;
  DocumentEntity? _document;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final repo = ref.read(documentRepositoryProvider);
    final doc = repo.getById(widget.documentId);
    if (doc == null) {
      setState(() {
        _error = 'Document not found';
        _isLoading = false;
      });
      return;
    }

    setState(() => _document = doc);

    try {
      final bytes = await repo.getDecryptedPdfBytes(widget.documentId);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/view_${widget.documentId}.pdf');
      await tempFile.writeAsBytes(bytes);
      setState(() {
        _decryptedPdfFile = tempFile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to decrypt document';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up decrypted temp file
    _decryptedPdfFile?.delete().ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    final doc = _document!;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActions(context, doc),
          ),
        ],
      ),
      body: Column(
        children: [
          // Document info header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(doc.type.emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          Text(
                            doc.type.displayName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          Text(
                            'Saved ${DateFormat('dd MMM yyyy').format(doc.createdAt)}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Expiry date
                if (doc.expiryDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: doc.isExpired
                          ? AppTheme.dangerColor.withOpacity(0.1)
                          : doc.isExpiringSoon
                              ? AppTheme.warningColor.withOpacity(0.1)
                              : AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: doc.isExpired
                              ? AppTheme.dangerColor
                              : doc.isExpiringSoon
                                  ? AppTheme.warningColor
                                  : AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          doc.isExpired
                              ? 'Expired ${DateFormat('dd MMM yyyy').format(doc.expiryDate!)}'
                              : 'Expires ${DateFormat('dd MMM yyyy').format(doc.expiryDate!)} (${doc.daysUntilExpiry} days)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: doc.isExpired
                                ? AppTheme.dangerColor
                                : doc.isExpiringSoon
                                    ? AppTheme.warningColor
                                    : AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Extracted fields
                if (doc.extractedFields.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  ...doc.extractedFields.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Text(
                          _formatKey(e.key),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          e.value,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),

          // PDF Viewer
          Expanded(
            child: _decryptedPdfFile != null
                ? SfPdfViewer.file(_decryptedPdfFile!)
                : const Center(child: Text('Unable to display document')),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, DocumentEntity doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, doc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.grey),
              title: const Text('Share (Premium)'),
              subtitle: const Text('Upgrade to share documents'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/paywall');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.dangerColor),
              title: const Text('Delete', style: TextStyle(color: AppTheme.dangerColor)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, doc);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, DocumentEntity doc) {
    final ctrl = TextEditingController(text: doc.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              doc.title = ctrl.text.trim();
              await doc.save();
              if (mounted) setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DocumentEntity doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: Text('This will permanently delete "${doc.title}". This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final repo = ref.read(documentRepositoryProvider);
      await repo.deleteDocument(widget.documentId);
      if (mounted) context.pop();
    }
  }

  String _formatKey(String key) {
    return key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}
