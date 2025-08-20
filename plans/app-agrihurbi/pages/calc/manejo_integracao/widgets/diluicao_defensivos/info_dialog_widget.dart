// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class InfoDialogWidget extends StatelessWidget {
  const InfoDialogWidget({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialogWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
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
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sobre a Diluição de Defensivos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Como funciona:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta calculadora determina a quantidade correta de defensivo agrícola a ser utilizada com base na dose recomendada por hectare e no volume do pulverizador disponível.',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Fórmula aplicada:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Defensivo = (Dose × Volume Pulverizador) ÷ Volume Calda',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Área tratada = Volume Pulverizador ÷ Volume Calda',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Observações importantes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Verifique sempre a bula do defensivo para a dose correta.\n'
                '• Use equipamentos de proteção individual (EPI).\n'
                '• Respeite o período de carência do produto.\n'
                '• Descarte embalagens vazias nos pontos de coleta.',
                style: TextStyle(
                  fontSize: 12,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ShadcnStyle.primaryButtonStyle,
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
