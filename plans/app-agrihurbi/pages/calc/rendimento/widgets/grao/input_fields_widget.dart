// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/grao_controller.dart';

class GraoInputFieldsWidget extends StatelessWidget {
  const GraoInputFieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dados para Cálculo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Espigas por Planta',
              (value) =>
                  Get.find<GraoController>().setEspigasPorPlanta(value),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              'Fileiras por Espiga',
              (value) =>
                  Get.find<GraoController>().setFileirasPorEspiga(value),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              'Grãos por Fileira',
              (value) =>
                  Get.find<GraoController>().setGraosPorFileira(value),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              'Peso de Mil Sementes (g)',
              (value) =>
                  Get.find<GraoController>().setPesoMilSementes(value),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              'Plantas por m²',
              (value) => Get.find<GraoController>().setPlantasM2(value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.find<GraoController>().limpar(),
              child: const Text('Limpar Campos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}
