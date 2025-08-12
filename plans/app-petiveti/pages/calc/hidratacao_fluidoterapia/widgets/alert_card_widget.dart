// Flutter imports:
import 'package:flutter/material.dart';

class AlertCardWidget extends StatelessWidget {
  const AlertCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Card(
        color: Colors.red.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ALERTA MÉDICO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Esta calculadora é uma ferramenta de apoio e NÃO substitui a avaliação clínica profissional. '
                'A fluidoterapia deve ser sempre prescrita e monitorada por um médico veterinário. '
                'O tratamento inadequado da desidratação pode resultar em complicações graves ou morte.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
