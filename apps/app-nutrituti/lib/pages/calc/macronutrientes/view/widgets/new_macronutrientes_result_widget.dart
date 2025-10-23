// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../../core/themes/manager.dart';
import '../../controller/new_macronutrientes_controller.dart';

class NewMacronutrientesResultWidget extends StatelessWidget {
  const NewMacronutrientesResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MacronutrientesController>(context);
    final model = controller.model;

    return Consumer<MacronutrientesController>(
      builder: (context, controller, _) {
        return AnimatedOpacity(
          opacity: model.calculado ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Visibility(
            visible: model.calculado,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildResponsiveLayout(context, model, controller),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, model, controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultHeader(context, controller),
        const SizedBox(height: 20),
        _buildResultValues(context, model),
      ],
    );
  }

  Widget _buildResultHeader(BuildContext context, controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultados do Cálculo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: controller.compartilhar as VoidCallback?,
          tooltip: 'Compartilhar resultados',
        ),
      ],
    );
  }

  Widget _buildResultValues(BuildContext context, model) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMacronutrienteRow(
          context,
          'Carboidratos',
          (model.carboidratosPorcentagem as num).toInt(),
          (model.carboidratosGramas as num).toDouble(),
          (model.carboidratosCalorias as num).toDouble(),
          Colors.amber,
        ),
        const SizedBox(height: 10),
        _buildMacronutrienteRow(
          context,
          'Proteínas',
          (model.proteinasPorcentagem as num).toInt(),
          (model.proteinasGramas as num).toDouble(),
          (model.proteinasCalorias as num).toDouble(),
          Colors.red,
        ),
        const SizedBox(height: 10),
        _buildMacronutrienteRow(
          context,
          'Gorduras',
          (model.gordurasPorcentagem as num).toInt(),
          (model.gordurasGramas as num).toDouble(),
          (model.gordurasCalorias as num).toDouble(),
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMacronutrienteRow(BuildContext context, String nome,
      int porcentagem, double gramas, double calorias, Color cor) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      color: cor.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nome,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _buildValueChip('$porcentagem%', cor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${gramas.toStringAsFixed(1)}g',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${calorias.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueChip(String text, Color baseColor) {
    final isDark = ThemeManager().isDark.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              isDark ? baseColor.withValues(alpha: 0.9) : baseColor.withValues(alpha: 0.8),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
