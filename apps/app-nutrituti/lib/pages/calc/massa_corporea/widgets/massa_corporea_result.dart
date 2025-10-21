// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../../../../core/themes/manager.dart';
import '../controller/massa_corporea_controller.dart';

class MassaCorporeaResult extends StatelessWidget {
  final bool isMobile;

  const MassaCorporeaResult({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MassaCorporeaController>();

    return AnimatedOpacity(
      opacity: controller.calculado ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: controller.calculado,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? _buildMobileLayout(context, controller)
                : _buildDesktopLayout(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, MassaCorporeaController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoSection(controller),
        const SizedBox(height: 16),
        _buildResultValues(context, controller),
      ],
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, MassaCorporeaController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildInfoSection(controller),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 7,
          child: _buildResultValues(context, controller),
        ),
      ],
    );
  }

  Widget _buildResultValues(
      BuildContext context, MassaCorporeaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildResultHeader(controller),
          const SizedBox(height: 16),
          _buildResultItem(
            'IMC',
            controller.resultado,
            Icons.calculate_outlined,
            controller.getColorForIMC(isDark),
            suffix: '',
          ),
          _buildResultCategory(
            'Categoria',
            controller.textIMC,
            Icons.category_outlined,
            controller.getColorForIMC(isDark),
          ),
          _buildSuggestionSection(controller),
        ],
      ),
    );
  }

  Widget _buildResultHeader(MassaCorporeaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Resultado do IMC',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: controller.getColorForIMC(isDark),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: controller.compartilhar,
          tooltip: 'Compartilhar resultados',
        ),
      ],
    );
  }

  Widget _buildSuggestionSection(MassaCorporeaController controller) {
    final isDark = ThemeManager().isDark.value;
    final String suggestion = controller.getSuggestionText();

    if (suggestion.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: isDark
          ? Colors.green.shade900.withValues(alpha: 0.2)
          : Colors.green.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.green.shade700 : Colors.green.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.green.shade300 : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  color: isDark ? Colors.green.shade100 : Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, num value, IconData icon, Color color,
      {String suffix = 'Kgs'}) {
    final isDark = ThemeManager().isDark.value;
    final numberFormat = NumberFormat('#,##0.00', 'pt_BR');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              '${numberFormat.format(value)}${suffix.isNotEmpty ? ' $suffix' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCategory(
      String label, String category, IconData icon, Color color) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(MassaCorporeaController controller) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados Informados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            'Gênero',
            controller.generoSelecionado == 1 ? 'Masculino' : 'Feminino',
            Icons.person_outline,
            isDark,
          ),
          _buildInfoItem(
            'Altura',
            '${controller.altura} cm',
            Icons.height_outlined,
            isDark,
          ),
          _buildInfoItem(
            'Peso',
            '${controller.peso.toStringAsFixed(2)} kg',
            Icons.monitor_weight_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
