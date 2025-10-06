import 'package:flutter/material.dart';

/// Database Inspector Page for Plantis - Simplified Version
class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector - Plantis'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storage, size: 64, color: Colors.teal),
              SizedBox(height: 16),
              Text(
                'Database Inspector',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Unified data inspector temporarily unavailable.\nWill be integrated when core package presentation layer is restored.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'Planned features:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Plants data inspection\n'
                '• Tasks data inspection\n'
                '• Spaces data inspection\n'
                '• Settings data inspection',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alias for backward compatibility
class DataInspectorPage extends DatabaseInspectorPage {
  const DataInspectorPage({super.key});
}
