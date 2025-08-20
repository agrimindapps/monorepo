// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/hidratacao_fluidoterapia_model.dart';

class ResultCardWidget extends StatelessWidget {
  final HidratacaoFluidoterapiaModel? modelo;

  const ResultCardWidget({
    super.key,
    required this.modelo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resultados da Fluidoterapia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (modelo?.volumeTotalDia != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.lightBlue.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResultRow(
                            'Volume para corrigir desidratação:',
                            '${modelo!.volumeDesidratacao!.toStringAsFixed(0)} ml',
                          ),
                          _buildResultRow(
                            'Volume de manutenção diária:',
                            '${modelo!.manutencaoDiaria!.toStringAsFixed(0)} ml',
                          ),
                          if (modelo!.perdaCorrente != null &&
                              modelo!.perdaCorrente! > 0)
                            _buildResultRow(
                              'Volume para perdas correntes:',
                              '${modelo!.perdaCorrente!.toStringAsFixed(0)} ml',
                            ),
                          const Divider(),
                          _buildResultRow(
                            'Volume total em 24h:',
                            '${modelo!.volumeTotalDia!.toStringAsFixed(0)} ml',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                    if (modelo!.recomendacoes != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12.0),
                        color: Colors.orange.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: modelo!.recomendacoes!.entries
                              .map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                )
              else
                const Text(
                  'Preencha os campos acima para calcular as necessidades de fluidoterapia.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              fontSize: emphasize ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              fontSize: emphasize ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
