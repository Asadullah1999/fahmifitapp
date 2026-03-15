import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

import '../providers/scan_provider.dart';
import '../../../shared/theme/app_theme.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 10,
        isGalleryImportAllowed: true,
      );

      if (!mounted) return;

      if (pictures == null || pictures.isEmpty) {
        context.pop();
        return;
      }

      // Add all captured images to state
      final notifier = ref.read(scanProvider.notifier);
      notifier.clearCaptures();
      for (final path in pictures) {
        notifier.addCapture(path);
      }

      // Go to edge adjustment (or skip to processing if only 1 page)
      context.pushReplacement('/scan/processing', extra: {'imagePaths': pictures});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e'), backgroundColor: AppTheme.dangerColor),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            Text(
              _isScanning ? 'Opening Camera...' : 'Preparing...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
