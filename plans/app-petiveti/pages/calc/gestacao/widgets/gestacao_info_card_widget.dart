// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/gestacao_controller.dart';

class GestacaoInfoCardWidget extends StatelessWidget {
  final GestacaoController controller;

  const GestacaoInfoCardWidget({
    super.key,
    required this.controller,
  });

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
                'Calculadora de Gestação',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Esta calculadora estima a data provável do parto com base na espécie e na data do primeiro dia do cio, acasalamento ou inseminação artificial. '
                'A gestação varia conforme a espécie e os resultados são apenas estimativas. '
                'Para resultados mais precisos, consulte um médico veterinário.',
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
