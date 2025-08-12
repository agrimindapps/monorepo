// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/fluidoterapia_controller.dart';

class InputCardWidget extends StatelessWidget {
  final FluidoterapiaController controller;
  final VoidCallback onCalcular;

  const InputCardWidget({
    super.key,
    required this.controller,
    required this.onCalcular,
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
                  controller: controller.pesoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso do animal (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: controller.validateNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.percentualController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Percentual de hidratação (%)',
                    border: OutlineInputBorder(),
                    hintText:
                        'Ex: Para manutenção use 5-6% para cães e 4-5% para gatos',
                  ),
                  validator: controller.validateNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.horasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Período de administração (horas)',
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
                      onPressed: onCalcular,
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
