// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/pages/calc/financeiro/valor_futuro/widgets/models/valor_futuro_model.dart';

class InfoSection extends StatelessWidget {
  final ValorFuturoModel modelo;

  const InfoSection({
    super.key,
    required this.modelo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Cálculo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Valor Inicial:',
                'R\$ ${modelo.valorInicial.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildInfoRow('Taxa de Juros:',
                '${modelo.taxa.toStringAsFixed(2)}% ${modelo.ehAnual ? 'ao ano' : 'ao mês'}'),
            const SizedBox(height: 8),
            _buildInfoRow('Período:', modelo.periodoFormatado),
            const SizedBox(height: 8),
            _buildInfoRow('Classificação:', modelo.classificacao),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    );
  }
}
