// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';

class ReservaEmergenciaInfoDialog {
  static void show(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildContent(isDark),
                  const SizedBox(height: 24),
                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Row(
      children: [
        Icon(
          Icons.savings_outlined,
          size: 24,
          color: isDark ? Colors.green.shade300 : Colors.green,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Reserva de Emergência',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'O que é?',
          'A reserva de emergência é um montante guardado para cobrir despesas inesperadas ou períodos sem renda. É o primeiro passo para uma vida financeira segura.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Por que é importante?',
          'Uma reserva adequada evita o endividamento em momentos de crise, como problemas de saúde, manutenções urgentes ou desemprego.',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildCategoriesSection(isDark),
        const SizedBox(height: 16),
        _buildTipsSection(isDark),
      ],
    );
  }

  static Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  static Widget _buildCategoriesSection(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categorias de Reserva',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Mínima (1-2 meses): Proteção básica para emergências de curto prazo.\n'
              '• Básica (3-5 meses): Cobre emergências comuns e períodos moderados sem renda.\n'
              '• Confortável (6-11 meses): Tranquilidade em casos de emergências maiores ou desemprego.\n'
              '• Robusta (12+ meses): Proteção abrangente para crises prolongadas.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTipsSection(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.green.withValues(alpha: 0.3) : Colors.green.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dicas para sua Reserva',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade300 : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Guarde em investimentos de alta liquidez como Tesouro Selic ou CDBs com liquidez diária.\n'
              '• Comece pequeno: mesmo 1-2 meses de despesas já fazem diferença.\n'
              '• Separe uma pequena quantia todo mês até atingir sua meta.\n'
              '• Utilize apenas em verdadeiras emergências, não para compras planejadas.\n'
              '• Recomponha sua reserva sempre que precisar usá-la.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ShadcnStyle.primaryButtonStyle,
        child: const Text('Fechar'),
      ),
    );
  }
}
