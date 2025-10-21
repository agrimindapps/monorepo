// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../../controller/peso_ideal_controller.dart';

class PesoIdealResult extends StatelessWidget {
  const PesoIdealResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PesoIdealController>(
      builder: (context, controller, child) {
        return AnimatedOpacity(
          opacity: controller.isCalculated ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: controller.isCalculated,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildResultHeader(context, controller),
                    const SizedBox(height: 16),
                    _buildResultValues(context, controller),
                    _buildResponsiveLayout(context, controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultHeader(
      BuildContext context, PesoIdealController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado do Cálculo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Text(
                'Base de cálculo: ${controller.model.generoDef['text']}',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Resultado do Cálculo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Text(
                'Base de cálculo: ${controller.model.generoDef['text']}',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildResultValues(
      BuildContext context, PesoIdealController controller) {
    // Calcular IMC aproximado
    final alturaMetros = controller.model.altura / 100;
    final imcAproximado =
        controller.model.resultado / (alturaMetros * alturaMetros);

    Color statusColor;
    String statusText;

    if (imcAproximado < 18.5) {
      statusColor = Colors.blue;
      statusText = 'Abaixo do peso';
    } else if (imcAproximado >= 18.5 && imcAproximado < 25) {
      statusColor = Colors.green;
      statusText = 'Peso normal';
    } else if (imcAproximado >= 25 && imcAproximado < 30) {
      statusColor = Colors.amber;
      statusText = 'Sobrepeso';
    } else {
      statusColor = Colors.red;
      statusText = 'Obesidade';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peso Ideal:',
                style: TextStyle(
                  fontSize: 16,
                  color: ShadcnStyle.textColor,
                ),
              ),
              Text(
                '${controller.model.numberFormat.format(controller.model.resultado)} kg',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Classificação:',
                style: TextStyle(
                  fontSize: 16,
                  color: ShadcnStyle.textColor,
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context, PesoIdealController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildInfoSection(context, controller),
        if (!isSmallScreen)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: controller.compartilhar,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(
      BuildContext context, PesoIdealController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.shade900.withValues(alpha: 0.2)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ShadcnStyle.borderColor : Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações do Cálculo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Valores utilizados:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Altura: ${controller.model.numberFormat.format(controller.model.altura)} cm',
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
          Text(
            'Gênero: ${controller.model.generoDef['text']}',
            style: TextStyle(color: ShadcnStyle.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Fórmula utilizada:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ShadcnStyle.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.model.generoDef['id'] == 1
                ? 'Masculino: 35,15 + ((altura - 130) × 0,75)'
                : 'Feminino: 33,875 + ((altura - 130) × 0,675)',
            style: TextStyle(
              color: ShadcnStyle.textColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
