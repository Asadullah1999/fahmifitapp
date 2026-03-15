import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/ocr/ocr_service.dart';
import '../../../core/database/hive_database.dart';
import '../providers/scan_provider.dart';
import '../../vault/domain/document_entity.dart';
import '../../../shared/theme/app_theme.dart';

class SaveDocumentScreen extends ConsumerStatefulWidget {
  final OcrResult? scanResult;

  const SaveDocumentScreen({super.key, this.scanResult});

  @override
  ConsumerState<SaveDocumentScreen> createState() => _SaveDocumentScreenState();
}

class _SaveDocumentScreenState extends ConsumerState<SaveDocumentScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late DocumentType _selectedType;
  late String _selectedFolderId;
  DateTime? _expiryDate;
  bool _setReminder = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.scanResult?.detectedType ?? DocumentType.other;
    _selectedFolderId = _selectedType.suggestedFolderId;
    _expiryDate = widget.scanResult?.extractedExpiryDate;
    _titleController.text = _selectedType.displayName;
    if (_expiryDate != null) _setReminder = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final folders = HiveDatabase.folders.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Document'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Detected type chip
            if (widget.scanResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(_selectedType.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document detected',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          _selectedType.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: AppTheme.secondaryColor),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Document Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
            ),

            const SizedBox(height: 16),

            // Document Type
            DropdownButtonFormField<DocumentType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: DocumentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.emoji),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() {
                    _selectedType = type;
                    _selectedFolderId = type.suggestedFolderId;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Folder
            DropdownButtonFormField<String>(
              value: _selectedFolderId,
              decoration: const InputDecoration(
                labelText: 'Folder',
                prefixIcon: Icon(Icons.folder),
              ),
              items: folders.map((f) {
                return DropdownMenuItem(
                  value: f.id,
                  child: Row(
                    children: [
                      Text(f.iconEmoji),
                      const SizedBox(width: 8),
                      Text(f.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) setState(() => _selectedFolderId = id);
              },
            ),

            const SizedBox(height: 16),

            // Expiry Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expiry Date'),
              subtitle: Text(
                _expiryDate != null
                    ? DateFormat('dd MMM yyyy').format(_expiryDate!)
                    : 'Not set',
                style: TextStyle(
                  color: _expiryDate != null
                      ? (_expiryDate!.isBefore(DateTime.now())
                          ? AppTheme.dangerColor
                          : AppTheme.secondaryColor)
                      : Colors.grey,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiryDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => setState(() {
                        _expiryDate = null;
                        _setReminder = false;
                      }),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickExpiryDate,
                  ),
                ],
              ),
            ),

            // Reminder toggle
            if (_expiryDate != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set Reminder'),
                subtitle: const Text('Get notified 6 months before expiry'),
                value: _setReminder,
                onChanged: (v) => setState(() => _setReminder = v),
              ),

            const SizedBox(height: 24),

            // Extracted fields preview
            if (widget.scanResult?.extractedFields.isNotEmpty == true) ...[
              Text(
                'Extracted Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.scanResult!.extractedFields.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      _formatFieldKey(e.key),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      e.value,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Save button
            ElevatedButton(
              onPressed: state.isProcessing ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: state.isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Document'),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Cancel'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (date != null) {
      setState(() {
        _expiryDate = date;
        _setReminder = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final doc = await ref.read(scanProvider.notifier).saveDocument(
      title: _titleController.text.trim(),
      folderId: _selectedFolderId,
      type: _selectedType,
      expiryDate: _expiryDate,
    );

    if (!mounted) return;

    final scanState = ref.read(scanProvider);
    if (scanState.error == 'FREE_LIMIT_REACHED') {
      context.push('/paywall');
      return;
    }

    if (doc != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Document saved securely!'),
          backgroundColor: AppTheme.secondaryColor,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => context.go('/vault/document/${doc.id}'),
          ),
        ),
      );
      context.go('/vault');
    }
  }

  String _formatFieldKey(String key) {
    return key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}
