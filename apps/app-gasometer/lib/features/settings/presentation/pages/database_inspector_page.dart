import 'package:flutter/material.dart';

/// Database Inspector Page for GasOMeter - Simplified Version
//
class DatabaseInspectorPage extends StatelessWidget {
  const DatabaseInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector - GasOMeter'),
        backgroundColor: Colors.blue,
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
                color: Colors.blue,
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
                '• Veículos data inspection\n'
                '• Abastecimentos data inspection\n'
                '• Manutenções data inspection\n'
                '• Odômetro data inspection\n'
                '• Despesas data inspection\n'
                '• Sync queue data inspection\n'
                '• Categorias data inspection',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
