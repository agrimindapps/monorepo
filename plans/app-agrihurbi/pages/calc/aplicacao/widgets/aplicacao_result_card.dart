// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controllers/aplicacao_controller.dart';

class AplicacaoResultCard extends StatelessWidget {
  final String tipo;
  final Color cardColor;
  final IconData resultIcon;

  const AplicacaoResultCard({
    super.key,
    required this.tipo,
    required this.cardColor,
    required this.resultIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AplicacaoController>(
      builder: (controller) {
        return AnimatedOpacity(
          opacity: controller.model.calculado ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: controller.model.calculado,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultHeader(controller),
                    const Divider(thickness: 1),
                    _buildResultValue(controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultHeader(AplicacaoController controller) {
    return Row(
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
          onPressed: () => controller.compartilhar(tipo),
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Compartilhar'),
          style: ShadcnStyle.primaryButtonStyle,
        ),
      ],
    );
  }

  Widget _buildResultValue(AplicacaoController controller) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: (isDark ? cardColor : cardColor)
            .withValues(alpha: isDark ? 0.3 : 1.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: (isDark ? cardColor : cardColor).withValues(alpha: 0.3),
              width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                resultIcon,
                color: isDark ? cardColor : cardColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 16,
                        color: ShadcnStyle.mutedTextColor,
                      ),
                    ),
                    Text(
                      '${controller.model.numberFormat.format(controller.model.resultado)} Lt/Ha',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
