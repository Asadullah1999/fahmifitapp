import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/scan_provider.dart';
import '../../../shared/theme/app_theme.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;

  const ProcessingScreen({super.key, required this.imagePaths});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'Analyzing document...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _runProcessing();
  }

  Future<void> _runProcessing() async {
    final notifier = ref.read(scanProvider.notifier);

    // Make sure images are in state
    notifier.clearCaptures();
    for (final path in widget.imagePaths) {
      notifier.addCapture(path);
    }

    setState(() => _statusText = 'Running OCR...');
    final result = await notifier.runOcr();

    if (!mounted) return;

    setState(() => _statusText = 'Detecting document type...');
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _statusText = 'Extracting key information...');
    await Future.delayed(const Duration(milliseconds: 500));

    context.pushReplacement('/scan/save', extra: {'scanResult': result});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scanner line
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePaths.first),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) => Positioned(
                      top: _controller.value * 190,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.primaryColor.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              _statusText,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'This happens on-device. Nothing leaves your phone.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
