// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class AlcoolSangueInfoDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AlcoolSangueInfoDialogContent(),
    );
  }
}

class _AlcoolSangueInfoDialogContent extends StatelessWidget {
  const _AlcoolSangueInfoDialogContent();

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
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
                  const Expanded(
                    child: Text(
                      'Sobre o Cálculo de Álcool no Sangue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Como funciona o cálculo:',
                'A Taxa de Álcool no Sangue (TAS) depende de diversos fatores, incluindo:',
                isDark,
                Icons.science_outlined,
                Colors.purple,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• O percentual de álcool na bebida',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• O volume consumido',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• O tempo desde o consumo',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• O peso corporal',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Fórmula aplicada:',
                'TAS = [(% álcool × volume em oz × 0,075) ÷ (peso em lb)] - (horas × 0,015)',
                isDark,
                Icons.functions_outlined,
                Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• O volume é convertido de ml para oz (1 oz = 29,5735 ml)',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• O peso é convertido de kg para lb (1 kg = 2,2 lb)',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• A cada hora, o corpo metaboliza cerca de 0,015% de álcool',
                      style: TextStyle(color: ShadcnStyle.textColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Observação:',
                'Este cálculo é apenas uma estimativa. Fatores individuais como metabolismo, alimentação e tolerância podem afetar o resultado real. Nunca dirija após consumir álcool.',
                isDark,
                Icons.warning_amber_outlined,
                Colors.red,
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

  Widget _buildSection(
      String title, String content, bool isDark, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? color.withValues(alpha: 0.8) : color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
