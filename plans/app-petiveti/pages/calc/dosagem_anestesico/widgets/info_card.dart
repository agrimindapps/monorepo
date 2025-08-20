// Flutter imports:
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final VoidCallback onToggleInfo;

  const InfoCard({
    super.key,
    required this.onToggleInfo,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Calculadora de Dosagem de Anestésicos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Esta calculadora estima o volume de anestésico a ser administrado com base no peso do animal, '
                'espécie e faixas de dosagem recomendadas para cada medicamento.\n\n'
                'Fórmula: Volume (ml) = [Peso (kg) × Dosagem (mg/kg)] ÷ Concentração (mg/ml)',
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
