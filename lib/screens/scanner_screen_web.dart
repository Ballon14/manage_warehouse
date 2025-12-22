import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Barcode scanner screen for web platform
/// Provides two modes: Camera scanning and Manual input
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

enum ScanMode { camera, manual }

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualInputController = TextEditingController();
  bool _hasResult = false;
  ScanMode _currentMode = ScanMode.camera;

  @override
  void dispose() {
    _controller.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasResult || capture.barcodes.isEmpty) return;

    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) {
      return;
    }

    setState(() => _hasResult = true);
    Navigator.of(context).pop(value);
  }

  void _submitManualInput() {
    final value = _manualInputController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a barcode')),
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan or Enter Barcode'),
        actions: [
          // Mode toggle button
          SegmentedButton<ScanMode>(
            segments: const [
              ButtonSegment(
                value: ScanMode.camera,
                icon: Icon(Icons.camera_alt, size: 18),
                label: Text('Camera'),
              ),
              ButtonSegment(
                value: ScanMode.manual,
                icon: Icon(Icons.keyboard, size: 18),
                label: Text('Manual'),
              ),
            ],
            selected: {_currentMode},
            onSelectionChanged: (Set<ScanMode> newSelection) {
              setState(() {
                _currentMode = newSelection.first;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _currentMode == ScanMode.camera
          ? _buildCameraMode()
          : _buildManualMode(),
    );
  }

  Widget _buildCameraMode() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Align barcode within the square',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                label: const Text('Cancel'),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildManualMode() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.qr_code_2,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 32),
          Text(
            'Enter Barcode Manually',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Type the barcode number below',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _manualInputController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Barcode',
              hintText: 'Enter barcode number',
              prefixIcon: Icon(Icons.qr_code_scanner),
              border: OutlineInputBorder(),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            onSubmitted: (_) => _submitManualInput(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitManualInput,
            icon: const Icon(Icons.check),
            label: const Text('Submit'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
