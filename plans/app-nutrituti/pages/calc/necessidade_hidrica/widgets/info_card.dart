// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';

class NecessidadeHidricaInfoCard extends StatelessWidget {
  const NecessidadeHidricaInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ShadcnStyle.borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calculadora de Necessidade Hídrica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta calculadora estima a quantidade de água que você deve consumir diariamente, baseando-se no seu peso corporal e ajustando para seu nível de atividade física e o clima da sua região.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'A água é essencial para praticamente todas as funções do corpo, incluindo regulação da temperatura corporal, transporte de nutrientes, remoção de resíduos e lubrificação das articulações.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Cálculo básico: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '35 ml × peso corporal (kg)',
                  ),
                ],
              ),
            ),
            _buildFatoresAjuste(),
            _buildObservacao(),
          ],
        ),
      ),
    );
  }

  Widget _buildFatoresAjuste() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Este valor básico é então ajustado com base em:',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          '• Nível de atividade física: o exercício aumenta a perda de água através do suor e da respiração',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          '• Clima: temperaturas mais altas aumentam a necessidade de água, enquanto climas frios podem diminuí-la',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'Fatores de ajuste por nível de atividade:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text('• Sedentário: +0%', style: TextStyle(fontSize: 14)),
        Text('• Levemente ativo: +20%', style: TextStyle(fontSize: 14)),
        Text('• Moderadamente ativo: +40%', style: TextStyle(fontSize: 14)),
        Text('• Muito ativo: +60%', style: TextStyle(fontSize: 14)),
        Text('• Extra ativo: +80%', style: TextStyle(fontSize: 14)),
        SizedBox(height: 8),
        Text(
          'Fatores de ajuste por clima:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text('• Muito frio: -20%', style: TextStyle(fontSize: 14)),
        Text('• Temperado/Ameno: +0%', style: TextStyle(fontSize: 14)),
        Text('• Quente: +20%', style: TextStyle(fontSize: 14)),
        Text('• Muito quente e seco: +40%', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildObservacao() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        'Observação: Esta é uma estimativa geral. Necessidades individuais podem variar com base em fatores como idade, condições de saúde e medicamentos. Consulte um profissional de saúde para recomendações personalizadas.',
        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    );
  }
}
