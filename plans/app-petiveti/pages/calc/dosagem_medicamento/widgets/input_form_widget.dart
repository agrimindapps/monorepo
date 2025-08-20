// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/dosagem_medicamentos_controller.dart';
import '../utils/dosagem_medicamentos_utils.dart';

class InputFormWidget extends StatelessWidget {
  final DosagemMedicamentosController controller;

  const InputFormWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
                TextFormField(
                  controller: controller.model.pesoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso do animal (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: DosagemMedicamentosUtils.validateNumber,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: controller.model.medicamentoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Medicamento (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.model.medicamentos.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.atualizarDosagemRecomendada(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.model.dosagemController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dosagem recomendada (mg/kg)',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 10 ou 10 - 20',
                  ),
                  validator: DosagemMedicamentosUtils.validateDosagem,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.model.concentracaoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Concentração do medicamento (mg/ml)',
                    border: OutlineInputBorder(),
                  ),
                  validator: DosagemMedicamentosUtils.validateNumber,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
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
}
