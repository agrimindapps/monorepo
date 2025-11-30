// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controller/taxa_metabolica_basal_controller.dart';
import '../../utils/constants.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key});

  void _compartilhar(BuildContext context) {
    final controller = context.read<TaxaMetabolicaBasalController>();
    final model = controller.model;

    StringBuffer t = StringBuffer();
    t.writeln('Taxa Metabólica Basal');
    t.writeln();
    t.writeln('Valores');
    t.writeln(
        'Gênero: ${model.generoSelecionado == 1 ? 'Masculino' : 'Feminino'}');
    t.writeln('Altura: ${model.altura} cm');
    t.writeln('Peso: ${model.peso} kg');
    t.writeln('Idade: ${model.idade} anos');
    t.writeln(
      'Nível de Atividade: ${TMBConstants.niveisAtividade.firstWhere(
        (nivel) => nivel['id'] == model.nivelAtividadeSelecionado,
        orElse: () => TMBConstants.niveisAtividade[0],
      )['text']}',
    );
    t.writeln();
    t.writeln('Resultados');
    t.writeln('TMB: ${model.resultadoTMB.toStringAsFixed(0)} calorias/dia');
    t.writeln(
      'Gasto Energético Total: ${model.resultadoTEE.toStringAsFixed(0)} calorias/dia',
    );

    SharePlus.instance.share(ShareParams(text: t.toString()));
  }

  Widget _buildResultCard(String title, String value, IconData icon,
      Color color, String description) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      elevation: 0,
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: ShadcnStyle.mutedTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: ShadcnStyle.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaxaMetabolicaBasalController>(
      builder: (context, controller, _) {
        final isDark = ThemeManager().isDark.value;
        final model = controller.model;

        return AnimatedOpacity(
          opacity: controller.isCalculated ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultados do cálculo:',
                        style: TextStyle(
                          color: ShadcnStyle.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultCard(
                        'Taxa Metabólica Basal (TMB)',
                        '${model.resultadoTMB.toStringAsFixed(0)} kcal/dia',
                        Icons.local_fire_department_outlined,
                        isDark ? Colors.amber.shade300 : Colors.amber,
                        'Energia mínima necessária em repouso',
                      ),
                      const SizedBox(height: 10),
                      _buildResultCard(
                        'Gasto Energético Total',
                        '${model.resultadoTEE.toStringAsFixed(0)} kcal/dia',
                        Icons.directions_run,
                        isDark ? Colors.green.shade300 : Colors.green,
                        'TMB ajustada pelo seu nível de atividade física',
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _compartilhar(context),
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                          style: ShadcnStyle.primaryButtonStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
