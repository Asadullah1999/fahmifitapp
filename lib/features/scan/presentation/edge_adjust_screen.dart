import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class EdgeAdjustScreen extends StatefulWidget {
  final List<String> imagePaths;

  const EdgeAdjustScreen({super.key, required this.imagePaths});

  @override
  State<EdgeAdjustScreen> createState() => _EdgeAdjustScreenState();
}

class _EdgeAdjustScreenState extends State<EdgeAdjustScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.imagePaths.length > 1
              ? 'Adjust Edges (${_currentPage + 1}/${widget.imagePaths.length})'
              : 'Adjust Edges',
        ),
        actions: [
          TextButton(
            onPressed: _proceed,
            child: const Text('Done', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: widget.imagePaths.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => _ImagePreview(path: widget.imagePaths[i]),
            ),
          ),
          if (widget.imagePaths.length > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imagePaths.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? AppTheme.primaryColor : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text('Continue to Process'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceed() {
    context.pushReplacement(
      '/scan/processing',
      extra: {'imagePaths': widget.imagePaths},
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String path;

  const _ImagePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.broken_image,
            color: Colors.white,
            size: 64,
          ),
        ),
      ),
    );
  }
}
