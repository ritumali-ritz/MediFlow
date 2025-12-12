
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanned = false; // Prevent double scan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Patient Token')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return; 
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              setState(() => _isScanned = true);
              // In real app: Validate token with backend
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scanned: $code')));
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}
