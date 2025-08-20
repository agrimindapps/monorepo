// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class AdipososidadeInfoDialog {
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
                          'Sobre o Índice de Adiposidade Corporal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'O que é IAC:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O Índice de Adiposidade Corporal (IAC) é uma medida alternativa ao IMC para avaliar a quantidade de gordura corporal. Foi desenvolvido em 2011 e tem como vantagem não necessitar da medição do peso corporal.',
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
                      'IAC = (Circunferência do quadril em cm / Altura em m^1.5) - 18',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Classificação para homens:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Adiposidade essencial: < 8%\n• Adiposidade saudável: 8% - 20,9%\n• Sobrepeso: 21% - 25,9%\n• Obesidade: ≥ 26%',
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Classificação para mulheres:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Adiposidade essencial: < 21%\n• Adiposidade saudável: 21% - 32,9%\n• Sobrepeso: 33% - 38,9%\n• Obesidade: ≥ 39%',
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vantagens do IAC:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Não necessita de medição do peso corporal\n• Fácil de calcular e aplicar em campo\n• Considera diferenças anatômicas entre gêneros\n• Boa correlação com métodos padrão-ouro de medição de gordura corporal',
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Observação:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Embora o IAC seja uma ferramenta útil, deve ser interpretado considerando outros fatores como idade, composição corporal e nível de atividade física. Para uma avaliação completa, consulte um profissional de saúde.',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
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
      },
    );
  }
}
