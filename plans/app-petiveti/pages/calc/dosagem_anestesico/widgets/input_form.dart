// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../controller/dosagem_anestesicos_controller.dart';

class InputForm extends StatelessWidget {
  final DosagemAnestesicosController controller;

  const InputForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: controller.especieSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Espécie',
                  border: OutlineInputBorder(),
                ),
                items: controller.model.especies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: controller.setEspecie,
                validator: (value) =>
                    value == null ? 'Selecione uma espécie' : null,
              ),
              const SizedBox(height: 16),
              if (controller.especieSelecionada != null)
                DropdownButtonFormField<String>(
                  value: controller.anestesicoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Anestésico',
                    border: OutlineInputBorder(),
                  ),
                  items: controller
                      .model.anestesicos[controller.especieSelecionada]!.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: controller.setAnestesico,
                  validator: (value) =>
                      value == null ? 'Selecione um anestésico' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.pesoController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Peso do animal (kg)',
                  border: OutlineInputBorder(),
                ),
                validator: controller.validateNumber,
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
    );
  }
}
