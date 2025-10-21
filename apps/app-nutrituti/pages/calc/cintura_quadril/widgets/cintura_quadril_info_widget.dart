// Flutter imports:
import 'package:flutter/material.dart';

class CinturaQuadrilInfoWidget extends StatelessWidget {
  const CinturaQuadrilInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Relação Cintura-Quadril (RCQ)'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'O que é RCQ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'A Relação Cintura-Quadril (RCQ) é um método que avalia a distribuição de gordura corporal. É calculada dividindo a medida da circunferência da cintura pela medida da circunferência do quadril.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Como interpretar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Homens:'),
            _buildClassificacaoItem(context, 'Baixo', '< 0,83'),
            _buildClassificacaoItem(context, 'Moderado', '0,83 - 0,88'),
            _buildClassificacaoItem(context, 'Alto', '0,89 - 0,94'),
            _buildClassificacaoItem(context, 'Muito Alto', '> 0,94'),
            const SizedBox(height: 8),
            const Text('Mulheres:'),
            _buildClassificacaoItem(context, 'Baixo', '< 0,71'),
            _buildClassificacaoItem(context, 'Moderado', '0,71 - 0,77'),
            _buildClassificacaoItem(context, 'Alto', '0,78 - 0,82'),
            _buildClassificacaoItem(context, 'Muito Alto', '> 0,82'),
            const SizedBox(height: 16),
            const Text(
              'Orientações para medida:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Cintura: Meça ao redor da parte mais estreita da cintura, geralmente na altura do umbigo.\n'
              '• Quadril: Meça ao redor da parte mais larga dos quadris/glúteos.\n'
              '• Mantenha a fita métrica horizontalmente durante as medições.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildClassificacaoItem(
      BuildContext context, String nivel, String valor) {
    Color cor;
    switch (nivel) {
      case 'Baixo':
        cor = Colors.green;
        break;
      case 'Moderado':
        cor = Colors.amber;
        break;
      case 'Alto':
        cor = Colors.orange;
        break;
      case 'Muito Alto':
        cor = Colors.red;
        break;
      default:
        cor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('$nivel: '),
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CinturaQuadrilInfoWidget(),
    );
  }
}
