// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../controller/gestacao_parto_controller.dart';

class ResultCardWidget extends StatelessWidget {
  final GestacaoPartoController controller;

  const ResultCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = controller.model;

    // Calcular dias restantes para o parto
    int? diasRestantes;
    if (model.dataParto != null) {
      final hoje = DateTime.now();
      if (hoje.isBefore(model.dataParto!)) {
        diasRestantes = model.dataParto!.difference(hoje).inDays;
      }
    }

    // Calcular variação possível
    String? variacaoParto;
    if (model.dataParto != null && model.especieSelecionada != null) {
      final variacao = model.variacaoGestacao[model.especieSelecionada]!;
      final dataMin = model.dataAcasalamento!.add(Duration(days: variacao[0]));
      final dataMax = model.dataAcasalamento!.add(Duration(days: variacao[1]));

      variacaoParto =
          'O parto pode ocorrer entre ${DateFormat('dd/MM/yyyy').format(dataMin)} e ${DateFormat('dd/MM/yyyy').format(dataMax)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (model.dataParto != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Data prevista do parto: ${DateFormat('dd/MM/yyyy').format(model.dataParto!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (variacaoParto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          variacaoParto,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (diasRestantes != null && diasRestantes > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Tempo restante até o parto: aproximadamente $diasRestantes dias',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (diasRestantes != null && diasRestantes <= 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'ATENÇÃO: O parto deve ocorrer a qualquer momento ou já ocorreu!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (model.fasePrenhezAtual != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.blue.shade50,
                        child: Text(
                          'Fase atual: ${model.fasePrenhezAtual}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (model.fasesPrenhez != null) ...[
                      const Text(
                        'Cronograma da gestação:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...model.fasesPrenhez!.map((fase) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(fase),
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.yellow.shade50,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observações importantes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• As datas são estimativas e podem variar.\n'
                            '• Consulte um veterinário regularmente durante a gestação.\n'
                            '• Em caso de sinais de parto ou complicações, procure atendimento veterinário imediatamente.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Preencha os campos acima para calcular a data prevista do parto.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
