// Flutter imports:
import 'package:flutter/material.dart';

class DietaCaseiraInfoCard extends StatelessWidget {
  final VoidCallback onToggleInfo;

  const DietaCaseiraInfoCard({
    super.key,
    required this.onToggleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onToggleInfo,
                  tooltip: 'Fechar',
                ),
              ],
            ),
            const Divider(),
            const Text(
              'Esta calculadora permite estimar as necessidades nutricionais para dietas caseiras '
              'em cães e gatos. É importante ressaltar que:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(
              'As dietas caseiras devem ser formuladas adequadamente para garantir que '
              'todas as necessidades nutricionais do animal sejam atendidas.',
            ),
            _buildBulletPoint(
              'Esta calculadora oferece apenas estimativas gerais. A formulação real '
              'de uma dieta caseira deve ser feita por um médico veterinário '
              'nutricionista.',
            ),
            _buildBulletPoint(
              'Diferentes estágios de vida e condições de saúde requerem '
              'diferentes perfis nutricionais.',
            ),
            _buildBulletPoint(
              'Sempre inclua suplementações vitamínicas e minerais conforme '
              'orientação veterinária.',
            ),
            const SizedBox(height: 8),
            const Text(
              'Como usar:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNumberedPoint(
              1,
              'Selecione a espécie do seu animal (cão ou gato).',
            ),
            _buildNumberedPoint(
              2,
              'Indique o estado fisiológico (filhote, adulto, idoso, etc.).',
            ),
            _buildNumberedPoint(
              3,
              'Escolha o nível de atividade do animal.',
            ),
            _buildNumberedPoint(
              4,
              'Selecione o tipo de dieta desejada conforme necessidades específicas.',
            ),
            _buildNumberedPoint(
              5,
              'Informe o peso do animal e a idade (em anos e meses).',
            ),
            const SizedBox(height: 8),
            const Text(
              'Nota: Os resultados são aproximações e podem precisar de ajustes '
              'baseados na resposta individual do animal. Monitore o peso '
              'e a condição corporal regularmente.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
