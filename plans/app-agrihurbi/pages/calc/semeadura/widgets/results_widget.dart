// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../controller/semeadura_controller.dart';

class ResultsWidget extends StatelessWidget {
  final SemeaduraController controller;
  final VoidCallback onCompartilhar;

  const ResultsWidget({
    super.key,
    required this.controller,
    required this.onCompartilhar,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.calculado,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildValues(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildInfoSection(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          onPressed: onCompartilhar,
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Compartilhar'),
          style: ShadcnStyle.primaryButtonStyle,
        ),
      ],
    );
  }

  Widget _buildValues() {
    final isDark = ThemeManager().isDark.value;
    final result = controller.result;
    if (result == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultItem(
            'Sementes por m²',
            result.sementesM2,
            Icons.grid_4x4,
            isDark ? Colors.amber.shade300 : Colors.amber,
            '',
          ),
          _buildResultItem(
            'Sementes por hectare',
            result.sementesHa,
            Icons.landscape,
            isDark ? Colors.green.shade300 : Colors.green,
            '',
          ),
          _buildResultItem(
            'Sementes total',
            result.sementesTotal,
            Icons.inventory_2,
            isDark ? Colors.blue.shade300 : Colors.blue,
            '',
          ),
          _buildResultItem(
            'Kg de sementes por hectare',
            result.kgSementesHa,
            Icons.scale,
            isDark ? Colors.orange.shade300 : Colors.orange,
            'kg',
          ),
          _buildResultItem(
            'Kg de sementes total',
            result.kgSementesTotal,
            Icons.shopping_bag,
            isDark ? Colors.teal.shade300 : Colors.teal,
            'kg',
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
      String label, num value, IconData icon, Color color, String unit) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.mutedTextColor,
                    ),
                  ),
                  Text(
                    '${controller.numberFormat.format(value)}${unit.isNotEmpty ? ' $unit' : ''}',
                    style: TextStyle(
                      fontSize: 18,
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
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final input = controller.input;

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
            'Área plantada: ${controller.numberFormatSimple.format(input.areaPlantada)} ha',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Espaç. entre linhas: ${controller.numberFormatSimple.format(input.espacamentoLinha)} m',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Espaç. entre plantas: ${controller.numberFormatSimple.format(input.espacamentoPlanta)} m',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Poder de germinação: ${controller.numberFormatSimple.format(input.poderGerminacao)} %',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
          Text(
            'Peso de mil sementes: ${controller.numberFormatSimple.format(input.pesoMilSementes)} g',
            style: TextStyle(
              fontSize: 13,
              color: ShadcnStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
