// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class LoteamentoInfoDialogWidget extends StatelessWidget {
  const LoteamentoInfoDialogWidget({super.key});

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? Colors.green.shade300
                          : Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sobre o Loteamento Bovino',
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

                // Conteúdo do card informativo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.green.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que é o Loteamento Bovino?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Esta calculadora determina a capacidade de suporte da pastagem em unidades animais por hectare (UA/ha) com base no número e peso dos animais e na área disponível.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Fórmula utilizada:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• 1 UA (Unidade Animal) = 450 kg de peso vivo',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• UA Total = (Quantidade × Peso Médio) ÷ 450',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Capacidade de Suporte = UA Total ÷ Área (ha)',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Interpretação:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• < 1 UA/ha: Baixa capacidade (melhorar pastagens ou reduzir animais)',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 1-3 UA/ha: Capacidade moderada (sistema extensivo/semi-intensivo)',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• > 3 UA/ha: Alta capacidade (sistema intensivo)',
                  style: TextStyle(color: ShadcnStyle.textColor),
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
      ),
    );
  }
}
