// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controllers/quebra_dormencia_controller.dart';
import '../../repositories/quebra_dormencia_repository.dart';

class InputFieldsWidget extends StatelessWidget {
  final QuebraDormenciaController controller;

  const InputFieldsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Horas de Frio
            VTextField(
              txEditController: controller.horasFrioController,
              focusNode: controller.focus1,
              labelText: 'Horas de frio acumuladas',
              hintText: 'Ex: 400',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              showClearButton: true,
            ),
            const SizedBox(height: 16),

            // Espécie e Variedade
            Row(
              children: [
                Expanded(
                  child: VTextField(
                    txEditController: controller.especieController,
                    focusNode: controller.focus2,
                    labelText: 'Espécie',
                    hintText: 'Selecione a espécie',
                    readOnly: true,
                    showClearButton: false,
                    onEditingComplete: () => _selecionarEspecie(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: VTextField(
                    txEditController: controller.variedadeController,
                    focusNode: controller.focus3,
                    labelText: 'Variedade',
                    hintText: 'Selecione a variedade',
                    readOnly: true,
                    showClearButton: false,
                    onEditingComplete: () => _selecionarVariedade(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Área e Número de Árvores
            Row(
              children: [
                Expanded(
                  child: VTextField(
                    txEditController: controller.areaPomarController,
                    focusNode: controller.focus4,
                    labelText: 'Área do pomar (ha)',
                    hintText: 'Ex: 1.5',
                    prefixIcon: const Icon(Icons.aspect_ratio),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    showClearButton: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: VTextField(
                    txEditController: controller.numeroArvoresController,
                    focusNode: controller.focus5,
                    labelText: 'Número de árvores',
                    hintText: 'Ex: 1000',
                    prefixIcon: const Icon(Icons.forest),
                    keyboardType: TextInputType.number,
                    showClearButton: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Idade do Pomar
            VTextField(
              txEditController: controller.idadePomarController,
              focusNode: controller.focus6,
              labelText: 'Idade do pomar (anos)',
              hintText: 'Ex: 5',
              prefixIcon: const Icon(Icons.calendar_today),
              keyboardType: TextInputType.number,
              showClearButton: true,
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: controller.limpar,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => controller.calcular(context),
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Calcular'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selecionarEspecie(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecione a Espécie',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: QuebraDormenciaRepository.getEspecies().length,
                    itemBuilder: (context, index) {
                      final especies = QuebraDormenciaRepository.getEspecies();
                      final especie = especies[index];
                      return ListTile(
                        leading: const Icon(Icons.grass),
                        title: Text(especie),
                        onTap: () {
                          controller.model.especie = especie;
                          controller.especieController.text = especie;
                          controller.atualizarVariedades();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selecionarVariedade(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecione a Variedade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: QuebraDormenciaRepository.getVariedades(
                            controller.model.especie)
                        .length,
                    itemBuilder: (context, index) {
                      final variedades =
                          QuebraDormenciaRepository.getVariedades(
                              controller.model.especie);
                      final variedade = variedades[index];
                      return ListTile(
                        leading: const Icon(Icons.eco),
                        title: Text(variedade),
                        onTap: () {
                          controller.model.variedade = variedade;
                          controller.variedadeController.text = variedade;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
