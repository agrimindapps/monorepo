import 'package:flutter/material.dart';

/// Data Inspector Page for ReceitaAgro - Simplified Version
/// TODO: Integrate with unified data inspector when available in core package
class DataInspectorPage extends StatelessWidget {
  const DataInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector - ReceitaAgro'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storage,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'Database Inspector',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Unified data inspector temporarily unavailable.\nWill be integrated when core package presentation layer is restored.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Planned features:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Culturas data inspection\n'
                '• Diagnósticos data inspection\n'
                '• Fitossanitários data inspection\n'
                '• Fitossanitários Info data inspection\n'
                '• Plantas Info data inspection\n'
                '• Pragas data inspection\n'
                '• Pragas Info data inspection',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}