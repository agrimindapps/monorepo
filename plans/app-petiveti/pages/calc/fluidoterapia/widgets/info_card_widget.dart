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
                'Calculadora de Fluidoterapia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Esta calculadora ajuda a determinar a quantidade de fluidos necessários para um animal com base no peso e no percentual de hidratação. '
                'O resultado fornece o volume total e a taxa de gotejamento recomendada.\n\n'
                'ATENÇÃO: Esta é apenas uma ferramenta de referência. Sempre consulte um médico veterinário para determinar as necessidades específicas do animal.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
