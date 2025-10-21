// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/stat_column_widget.dart';

class MetaCardWidget extends StatelessWidget {
  final String pesoInicial;
  final String pesoAtual;
  final String pesoMeta;
  final VoidCallback onSetMeta;

  const MetaCardWidget({
    super.key,
    required this.pesoInicial,
    required this.pesoAtual,
    required this.pesoMeta,
    required this.onSetMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Progresso',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatColumnWidget(
                    label: 'Peso Inicial', value: '$pesoInicial kg'),
                StatColumnWidget(label: 'Peso Atual', value: '$pesoAtual kg'),
                StatColumnWidget(label: 'Meta', value: '$pesoMeta kg'),
                ElevatedButton(
                  onPressed: onSetMeta,
                  child: const Text('Definir Meta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
