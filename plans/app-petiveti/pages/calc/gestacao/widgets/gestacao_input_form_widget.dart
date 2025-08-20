// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/gestacao_controller.dart';
import '../model/gestacao_model.dart';

class GestacaoInputFormWidget extends StatelessWidget {
  final GestacaoController controller;

  const GestacaoInputFormWidget({
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
              TextFormField(
                controller: controller.model.especieController,
                decoration: InputDecoration(
                  labelText: 'Espécie',
                  border: const OutlineInputBorder(),
                  hintText: 'Ex: Cadela, Gata, Vaca...',
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (String value) {
                      controller.model.especieController.text = value;
                    },
                    itemBuilder: (BuildContext context) {
                      return GestacaoModel.periodosGestacao.keys
                          .map((String value) {
                        return PopupMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList();
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a espécie';
                  }
                  if (!GestacaoModel.periodosGestacao.containsKey(value)) {
                    return 'Espécie não reconhecida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => controller.selecionarData(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: controller.model.dataInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Data do início (cio/acasalamento)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma data';
                      }
                      return null;
                    },
                  ),
                ),
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
                    onPressed: () => controller.calcular(context),
                    style: ElevatedButton.styleFrom(
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
    );
  }
}
