// Flutter imports:
import 'package:flutter/material.dart';

class CaloriasDiariasInfo extends StatelessWidget {
  const CaloriasDiariasInfo({super.key});

  static void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CaloriasDiariasInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sobre a Calculadora de Calorias Diárias'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Esta calculadora estima a quantidade de calorias que você deve consumir diariamente, baseando-se na equação de Harris-Benedict, que leva em consideração seu gênero, idade, altura, peso e nível de atividade física.',
            ),
            SizedBox(height: 10),
            Text(
              'As calorias são a unidade de medida para energia que o corpo obtém dos alimentos e bebidas. Entender suas necessidades calóricas é importante para manter, perder ou ganhar peso de forma saudável.',
            ),
            SizedBox(height: 10),
            Text('Fórmula para homens:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('TMB = 66 + (13,7 × peso) + (6,8 × altura) - (5 × idade)'),
            SizedBox(height: 10),
            Text('Fórmula para mulheres:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('TMB = 65,5 + (9,6 × peso) + (4,7 × altura) - (1,8 × idade)'),
            SizedBox(height: 10),
            Text(
                'Este valor básico (TMB - Taxa Metabólica Basal) é então multiplicado por um fator baseado em seu nível de atividade física:'),
            SizedBox(height: 5),
            Text('• Sedentário (pouca ou nenhuma atividade): × 1,25'),
            Text('• Levemente ativo (exercício leve 1-3 dias/semana): × 1,3'),
            Text(
                '• Moderadamente ativo (exercício moderado 3-5 dias/semana): × 1,5'),
            Text('• Muito ativo (exercício intenso 6-7 dias/semana): × 1,7'),
            Text(
                '• Extremamente ativo (exercício muito intenso, trabalho físico): × 2,0'),
            SizedBox(height: 10),
            Text(
              'Observação: Esta é uma estimativa geral. Necessidades individuais podem variar com base em fatores como metabolismo, composição corporal, condições de saúde e medicamentos. Consulte um profissional de saúde ou nutricionista para recomendações personalizadas.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
