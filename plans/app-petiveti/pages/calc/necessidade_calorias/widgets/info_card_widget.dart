// Flutter imports:
import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Calculadora de Necessidades Calóricas Diárias',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Esta calculadora estima as necessidades calóricas diárias do seu animal com base no peso, '
                'espécie, estado fisiológico e nível de atividade.\n\n'
                'Fórmula: Calorias diárias = RER × Fator Estado × Fator Atividade\n'
                'RER (Necessidade Energética em Repouso) = 70 × Peso^0.75',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'ATENÇÃO: Este cálculo é uma estimativa. A necessidade real pode variar. Monitore o peso e a condição corporal do animal e ajuste conforme necessário.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
