// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import '../models/necessidade_hidrica_model.dart';

class NecessidadeHidricaResultCard extends StatelessWidget {
  final NecessidadeHidricaModel model;
  final bool isVisible;
  final VoidCallback onShare;

  const NecessidadeHidricaResultCard({
    super.key,
    required this.model,
    this.isVisible = false,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: isVisible,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ShadcnStyle.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultHeader(),
              const Divider(thickness: 1, height: 1),
              _buildResultValues(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return ListTile(
      leading: Icon(
        Icons.analytics,
        color: Colors.cyan.shade600,
      ),
      title: Text(
        'Resultado',
        style: TextStyle(
          color: ShadcnStyle.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.share,
          color: Colors.cyan.shade600,
        ),
        onPressed: onShare,
        tooltip: 'Compartilhar resultado',
      ),
    );
  }

  Widget _buildResultValues() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.cyan.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ingestão básica recomendada: ${model.resultado.toStringAsFixed(2)} litros/dia',
                  style: TextStyle(
                    fontSize: 16,
                    color: ShadcnStyle.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Icon(
                Icons.local_drink,
                color: Colors.cyan.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ingestão ajustada recomendada: ${model.resultadoAjustado.toStringAsFixed(2)} litros/dia',
                  style: TextStyle(
                    fontSize: 16,
                    color: ShadcnStyle.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildDicas(),
      ],
    );
  }

  Widget _buildDicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ],
          ),
        ),
        _buildDicaItem(
          Icons.schedule,
          '• Distribua a ingestão de água ao longo do dia.',
        ),
        _buildDicaItem(
          Icons.fitness_center,
          '• Aumente a ingestão durante exercícios físicos intensos.',
        ),
        _buildDicaItem(
          Icons.warning,
          '• Bebidas com cafeína e álcool podem causar desidratação.',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.medical_information,
                color: Colors.orange.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '• Esta é uma estimativa. Consulte um profissional de saúde para recomendações personalizadas.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: ShadcnStyle.mutedTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDicaItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.cyan.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
