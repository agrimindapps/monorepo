// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../controller/gestacao_parto_controller.dart';

class InputFormWidget extends StatelessWidget {
  final GestacaoPartoController controller;

  const InputFormWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final racasPorEspecie = model.especieSelecionada != null
        ? model.ajusteRacasDias[model.especieSelecionada]!.keys.toList()
        : [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: model.especieSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
                  ),
                  items: model.especies
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: controller.atualizarEspecie,
                  validator: (value) =>
                      value == null ? 'Selecione uma espécie' : null,
                ),
                const SizedBox(height: 16),
                if (model.especieSelecionada != null)
                  DropdownButtonFormField<String>(
                    value: model.racaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Raça',
                      border: OutlineInputBorder(),
                    ),
                    items: racasPorEspecie
                        .map((e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        model.racaSelecionada = value;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Selecione uma raça' : null,
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: model.metodoCalculo,
                  decoration: const InputDecoration(
                    labelText: 'Método de cálculo',
                    border: OutlineInputBorder(),
                  ),
                  items: (model.especieSelecionada == 'Cão' ||
                          model.especieSelecionada == 'Gato')
                      ? model.opcoesTipoCalculo
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList()
                      : [model.opcoesTipoCalculo[0]]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                  onChanged: controller.atualizarMetodoCalculo,
                ),
                const SizedBox(height: 16),
                if (model.metodoCalculo == model.opcoesTipoCalculo[0])
                  // Cálculo baseado na data de acasalamento
                  _buildDataAcasalamentoField(context)
                else
                  // Cálculo baseado no ultrassom
                  Column(
                    children: [
                      _buildDataUltrassomField(context),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tamanho dos fetos (mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: controller.atualizarTamanhoFetos,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o tamanho dos fetos';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Informe um número válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: controller.limpar,
                      child: const Text('Limpar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.calcular,
                      child: const Text('Calcular'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataAcasalamentoField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.dataAcasalamento ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 100)),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.atualizarDataAcasalamento(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data do acasalamento',
          border: OutlineInputBorder(),
        ),
        child: Text(
          controller.dataAcasalamento != null
              ? DateFormat('dd/MM/yyyy').format(controller.dataAcasalamento!)
              : 'Selecione a data',
        ),
      ),
    );
  }

  Widget _buildDataUltrassomField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.dataUltrassom ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 100)),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.atualizarDataUltrassom(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data do ultrassom',
          border: OutlineInputBorder(),
        ),
        child: Text(
          controller.dataUltrassom != null
              ? DateFormat('dd/MM/yyyy').format(controller.dataUltrassom!)
              : 'Selecione a data',
        ),
      ),
    );
  }
}
