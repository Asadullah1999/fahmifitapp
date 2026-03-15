import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../scan/providers/scan_provider.dart';
import '../domain/document_entity.dart';
import '../../../shared/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  List<DocumentEntity> _results = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final repo = ref.read(documentRepositoryProvider);
    setState(() {
      _results = repo.search(query);
      _hasSearched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search documents...',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                _search('');
              },
            ),
        ],
      ),
      body: !_hasSearched
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.manage_search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Search across all documents\nincluding OCR text',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No results for "${_ctrl.text}"',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _SearchResultCard(
                    document: _results[i],
                    query: _ctrl.text,
                  ),
                ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final DocumentEntity document;
  final String query;

  const _SearchResultCard({required this.document, required this.query});

  @override
  Widget build(BuildContext context) {
    // Show matching OCR snippet if available
    String? snippet;
    if (document.ocrText != null) {
      final lower = document.ocrText!.toLowerCase();
      final idx = lower.indexOf(query.toLowerCase());
      if (idx != -1) {
        final start = (idx - 40).clamp(0, document.ocrText!.length);
        final end = (idx + query.length + 40).clamp(0, document.ocrText!.length);
        snippet = '...${document.ocrText!.substring(start, end)}...';
      }
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document.type.displayName,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            if (snippet != null)
              Text(
                snippet,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.push('/vault/document/${document.id}'),
      ),
    );
  }
}
