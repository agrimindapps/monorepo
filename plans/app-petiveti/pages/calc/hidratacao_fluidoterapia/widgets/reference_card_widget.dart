// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/hidratacao_fluidoterapia_model.dart';

class ReferenceCardWidget extends StatelessWidget {
  const ReferenceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Referência: Sinais Clínicos de Desidratação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.blue.shade200),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.blue),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '% Desidratação',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Sinais Clínicos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  ...HidratacaoFluidoterapiaModel.sinaisDesidratacao
                      .map((sinal) => TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${sinal['percentual']}%',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: sinal['percentual'] >= 10
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  sinal['sinais'],
                                  style: TextStyle(
                                    color: sinal['percentual'] >= 10
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
