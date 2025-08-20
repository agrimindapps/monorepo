// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class FertilizanteInfoDialog extends StatelessWidget {
  const FertilizanteInfoDialog({super.key});

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
                  Expanded(
                    child: Text(
                      'Sobre o Cálculo de Fertilizantes',
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
                'Como funciona o cálculo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. DAP (Fosfato Diamônico): Calculado com base na quantidade de fósforo (P) necessária. O DAP contém 46% de P₂O₅.',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              const SizedBox(height: 4),
              Text(
                '2. Ureia (U): Calculada para complementar o nitrogênio, considerando que o DAP já fornece 18% de N.',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              const SizedBox(height: 4),
              Text(
                '3. MOP (Cloreto de Potássio): Calculado com base na quantidade de potássio (K) necessária. O MOP contém 60% de K₂O.',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Fórmulas aplicadas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  'DAP = (Quantidade × P) ÷ 46\nN do DAP = (18 × DAP) ÷ Quantidade\nUreia = (Quantidade × (N - N do DAP)) ÷ 46\nMOP = (Quantidade × K) ÷ 60',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: ShadcnStyle.textColor,
                  ),
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
