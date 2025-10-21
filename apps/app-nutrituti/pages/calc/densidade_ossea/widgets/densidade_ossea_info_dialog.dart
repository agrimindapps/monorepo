// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class DensidadeOsseaInfoDialog {
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
              child: SingleChildScrollView(
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
                            'Informações sobre Densidade Óssea',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'O que é Densidade Óssea?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A densidade óssea, também chamada de densidade mineral óssea (DMO), é uma medição da quantidade de minerais (principalmente cálcio e fósforo) contidos em um determinado volume de osso.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Por que é importante?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A densidade óssea é um indicador da saúde e força dos ossos. Baixa densidade óssea pode levar a ossos mais frágeis e aumentar o risco de fraturas. Condições como osteopenia (baixa massa óssea) e osteoporose (doença caracterizada por ossos frágeis) estão relacionadas à baixa densidade óssea.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Como é medida?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O padrão-ouro para medição da densidade óssea é o exame de absorciometria de raios-X de dupla energia (DEXA ou DXA). Este exame mede a densidade óssea em diferentes partes do corpo, como coluna lombar, quadril e antebraço.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Interpretação dos Resultados:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Os resultados do exame são geralmente apresentados como T-score e Z-score:',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• T-score: Compara sua densidade óssea com a de um adulto jovem saudável do mesmo sexo.\n'
                      '  - T-score entre -1 e +1: densidade óssea normal\n'
                      '  - T-score entre -1 e -2,5: osteopenia (baixa massa óssea)\n'
                      '  - T-score abaixo de -2,5: osteoporose',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Z-score: Compara sua densidade óssea com a de pessoas de mesma idade e sexo.\n'
                      '  - Z-score abaixo de -2: densidade óssea inferior ao esperado para idade',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fatores que afetam a densidade óssea:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Idade: a densidade óssea geralmente atinge seu pico entre 25-30 anos e diminui gradualmente após isso\n'
                      '• Sexo: mulheres têm maior risco de perda óssea, especialmente após a menopausa\n'
                      '• Genética e etnia\n'
                      '• Níveis hormonais\n'
                      '• Dieta (especialmente ingestão de cálcio e vitamina D)\n'
                      '• Exercício físico\n'
                      '• Tabagismo e consumo de álcool\n'
                      '• Medicamentos (como corticosteroides)',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Importante: Esta calculadora fornece apenas uma estimativa. Para uma avaliação precisa da densidade óssea, consulte um profissional médico especializado.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
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
      },
    );
  }
}
