// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../controllers/exercicio_form_controller.dart';
import '../models/exercicio_model.dart';

/// Exercise form page optimized for performance

class ExercicioFormPage extends GetView<ExercicioFormController> {
  final ExercicioModel? registro;

  const ExercicioFormPage({
    super.key,
    this.registro,
  });

  @override
  Widget build(BuildContext context) {
    // Inicializa o controller
    final controller = Get.put(ExercicioFormController());

    // Se está editando, carrega os dados do registro
    controller.initializeForm(registro);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ExercicioConstants.cardInternalPadding),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optimize: Extract title to avoid unnecessary rebuilds
              _FormTitle(controller: controller),
              const SizedBox(height: 16),

              // Optimize: Separate dropdown widgets
              _CategoriaDropdown(controller: controller),

              const SizedBox(height: 8),

              _ExercicioDropdown(controller: controller),

              const SizedBox(height: 8),

              // Static field - no Obx needed
              const _NomeTextField(),

              const SizedBox(height: 8),

              // Static fields - no Obx needed
              const _DuracaoCaloriasRow(),

              const SizedBox(height: 8),

              // Static field - no Obx needed
              const _ObservacoesTextField(),

              const SizedBox(height: 8),

              // Optimize: Separate date picker
              _DataSelector(controller: controller),

              const SizedBox(height: 16),

              // Optimize: Separate action buttons
              _ActionButtons(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _selecionarData(
      BuildContext context, ExercicioFormController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.dataRegistro.value,
      firstDate: DateTime(ExercicioConstants.calendarioAnoInicio),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null) {
      controller.onDataSelected(date);
    }
  }

  Future<void> _salvarExercicio(
      BuildContext context, ExercicioFormController controller) async {
    if (controller.formKey.currentState?.validate() == true) {
      final success = await controller.salvarFormulario();
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

// ============================================================================
// OPTIMIZED WIDGET COMPONENTS
// ============================================================================

/// Optimized form title widget
class _FormTitle extends StatelessWidget {
  const _FormTitle({required this.controller});
  
  final ExercicioFormController controller;
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(
      controller.formTitle,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ));
  }
}

/// Optimized categoria dropdown widget
class _CategoriaDropdown extends StatelessWidget {
  const _CategoriaDropdown({required this.controller});
  
  final ExercicioFormController controller;
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedCategoria.value,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
      items: controller.categorias
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: controller.onCategoriaChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione uma categoria';
        }
        return null;
      },
    ));
  }
}

/// Optimized exercicio dropdown widget
class _ExercicioDropdown extends StatelessWidget {
  const _ExercicioDropdown({required this.controller});
  
  final ExercicioFormController controller;
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
      value: controller.exercicioSelecionado.value,
      decoration: const InputDecoration(
        labelText: 'Tipo de Exercício',
        border: OutlineInputBorder(),
      ),
      items: controller.exerciciosFiltrados
          .map((e) => DropdownMenuItem<Map<String, dynamic>>(
                value: e,
                child: Text(e['text']),
              ))
          .toList(),
      onChanged: controller.onExercicioSelected,
      validator: (value) {
        if (controller.nomeController.text.isEmpty) {
          return 'Por favor, selecione um exercício';
        }
        return null;
      },
    ));
  }
}

/// Static nome text field widget
class _NomeTextField extends GetView<ExercicioFormController> {
  const _NomeTextField();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome do Exercício (ou informe manualmente)',
        border: OutlineInputBorder(),
      ),
      validator: controller.validateNome,
    );
  }
}

/// Static duracao and calorias row widget
class _DuracaoCaloriasRow extends GetView<ExercicioFormController> {
  const _DuracaoCaloriasRow();
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller.duracaoController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Duração (minutos)',
              border: OutlineInputBorder(),
            ),
            validator: controller.validateDuracao,
          ),
        ),
        const SizedBox(width: ExercicioConstants.defaultPadding),
        Expanded(
          child: TextFormField(
            controller: controller.caloriasController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Calorias Queimadas',
              border: OutlineInputBorder(),
            ),
            validator: controller.validateCalorias,
          ),
        ),
      ],
    );
  }
}

/// Static observacoes text field widget
class _ObservacoesTextField extends GetView<ExercicioFormController> {
  const _ObservacoesTextField();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.observacoesController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        border: OutlineInputBorder(),
      ),
      validator: controller.validateObservacoes,
    );
  }
}

/// Optimized data selector widget
class _DataSelector extends StatelessWidget {
  const _DataSelector({required this.controller});
  
  final ExercicioFormController controller;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Data: '),
        Obx(() => TextButton(
          onPressed: () => _selecionarData(context, controller),
          child: Text(
            _formatarData(controller.dataRegistro.value),
          ),
        )),
      ],
    );
  }
  
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _selecionarData(
      BuildContext context, ExercicioFormController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.dataRegistro.value,
      firstDate: DateTime(ExercicioConstants.calendarioAnoInicio),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null) {
      controller.onDataSelected(date);
    }
  }
}

/// Optimized action buttons widget
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller});
  
  final ExercicioFormController controller;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: ExercicioConstants.defaultPadding),
        Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => _salvarExercicio(context, controller),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        )),
      ],
    );
  }
  
  Future<void> _salvarExercicio(
      BuildContext context, ExercicioFormController controller) async {
    if (controller.formKey.currentState?.validate() == true) {
      final success = await controller.salvarFormulario();
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
