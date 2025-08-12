// Flutter imports:
import 'package:flutter/material.dart';

class AlertaCard extends StatelessWidget {
  final VoidCallback onToggleAlerta;

  const AlertaCard({
    super.key,
    required this.onToggleAlerta,
  });

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
                'ALERTA DE SEGURANÇA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Esta calculadora destina-se apenas para referência educacional e deve ser usada SOMENTE por médicos veterinários qualificados. '
                'As dosagens sugeridas são apenas guias gerais e muitos fatores individuais podem alterar a dose apropriada. '
                'A administração de anestésicos requer monitoramento constante do paciente e preparação para lidar com complicações.',
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
