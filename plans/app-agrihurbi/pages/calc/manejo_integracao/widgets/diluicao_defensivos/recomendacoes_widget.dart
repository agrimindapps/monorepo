// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class RecomendacoesWidget extends StatelessWidget {
  const RecomendacoesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      elevation: 0,
      color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.blue.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recomendações de aplicação',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RecomendacaoItem(
              text: 'Use EPI durante o preparo e aplicação',
              icon: Icons.accessibility_new,
              color: isDark ? Colors.blue.shade300 : Colors.blue,
            ),
            _RecomendacaoItem(
              text: 'Verifique as condições climáticas antes da aplicação',
              icon: Icons.wb_sunny_outlined,
              color: isDark ? Colors.amber.shade300 : Colors.amber,
            ),
            _RecomendacaoItem(
              text: 'Calibre corretamente o pulverizador',
              icon: Icons.tune,
              color: isDark ? Colors.green.shade300 : Colors.green,
            ),
            _RecomendacaoItem(
              text: 'Evite aplicar durante horários quentes',
              icon: Icons.schedule,
              color: isDark ? Colors.red.shade300 : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecomendacaoItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _RecomendacaoItem({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: ShadcnStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
