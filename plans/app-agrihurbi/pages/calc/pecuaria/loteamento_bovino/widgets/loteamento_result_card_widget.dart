// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../controller/loteamento_bovino_controller.dart';

class LoteamentoResultCardWidget extends StatelessWidget {
  const LoteamentoResultCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return GetBuilder<LoteamentoBovinoController>(
      builder: (controller) {
        if (!controller.calculado.value || controller.model == null) {
          return const SizedBox.shrink();
        }

        return AnimatedOpacity(
          opacity: controller.calculado.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Card(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: controller.compartilhar,
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Compartilhar'),
                        style: ShadcnStyle.primaryButtonStyle,
                      ),
                    ],
                  ),
                  const Divider(thickness: 1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildResultValue(context, controller, isDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoSection(context, controller, isDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultValue(BuildContext context,
      LoteamentoBovinoController controller, bool isDark) {
    final cor = controller.getCorResultado(isDark);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: cor.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(controller.getIconeResultado(), color: cor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacidade de Suporte:',
                        style: TextStyle(
                          fontSize: 14,
                          color: ShadcnStyle.mutedTextColor,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            controller.numberFormat.format(controller.model!.resultado),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                          Text(
                            ' UA/ha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              controller.model!.getAvaliacao(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.model!.getDescricaoAvaliacao(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: ShadcnStyle.mutedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context,
      LoteamentoBovinoController controller, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(top: isLargeScreen ? 16 : 0),
      decoration: BoxDecoration(
        color: isDark
            ? ShadcnStyle.borderColor.withValues(alpha: 0.3)
            : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ShadcnStyle.borderColor : Colors.green.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cálculo baseado nos valores:',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Animais: ${controller.numberFormatSimple.format(controller.model!.quantidadeAnimais)}',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Peso médio: ${controller.numberFormatSimple.format(controller.model!.pesoMedio)} kg',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Área total: ${controller.numberFormatSimple.format(controller.model!.areaHectares)} ha',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unidade Animal (UA):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            '1 UA = 450 kg de peso vivo',
            style: TextStyle(fontSize: 13, color: ShadcnStyle.textColor),
          ),
          Text(
            'UA Total: ${controller.numberFormatSimple.format((controller.model!.quantidadeAnimais * controller.model!.pesoMedio) / 450)}',
            style: TextStyle(fontSize: 13, color: ShadcnStyle.textColor),
          ),
        ],
      ),
    );
  }
}