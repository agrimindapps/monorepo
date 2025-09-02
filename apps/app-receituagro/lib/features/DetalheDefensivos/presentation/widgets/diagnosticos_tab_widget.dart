import 'package:flutter/material.dart';

/// Widget para tab de diagnósticos com filtros e listagem
/// TEMPORARIAMENTE SIMPLIFICADO para resolver build blockers
/// TODO: Reimplementar após resolver incompatibilidades de provider
class DiagnosticosTabWidget extends StatelessWidget {
  final String defensivoName;

  const DiagnosticosTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Diagnósticos para $defensivoName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(
              child: Text(
                'Funcionalidade em desenvolvimento\nSerá implementada na próxima fase',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}