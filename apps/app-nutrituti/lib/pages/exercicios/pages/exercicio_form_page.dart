// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../controllers/exercicio_form_controller.dart';
import '../models/exercicio_model.dart';

/// Exercise form page optimized for performance

class ExercicioFormPage extends ConsumerWidget {
  final ExercicioModel? registro;

  const ExercicioFormPage({
    super.key,
    this.registro,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize form with existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exercicioFormProvider.notifier).initializeForm(registro);
    });

    final formNotifier = ref.read(exercicioFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ExercicioConstants.cardInternalPadding),
        child: Form(
          key: formNotifier.formKey,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title with state
              _FormTitle(),

              SizedBox(height: 16),

              // Categoria dropdown
              _CategoriaDropdown(),

              SizedBox(height: 8),

              // Exercicio dropdown
              _ExercicioDropdown(),

              SizedBox(height: 8),

              // Nome text field
              _NomeTextField(),

              SizedBox(height: 8),

              // Duracao and calorias row
              _DuracaoCaloriasRow(),

              SizedBox(height: 8),

              // Observacoes text field
              _ObservacoesTextField(),

              SizedBox(height: 8),

              // Date selector
              _DataSelector(),

              SizedBox(height: 16),

              // Action buttons
              _ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// OPTIMIZED WIDGET COMPONENTS
// ============================================================================

/// Form title widget
class _FormTitle extends ConsumerWidget {
  const _FormTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formTitle = ref.read(exercicioFormProvider.notifier).formTitle;

    return Text(
      formTitle,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Categoria dropdown widget
class _CategoriaDropdown extends ConsumerWidget {
  const _CategoriaDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercicioFormProvider);
    final notifier = ref.read(exercicioFormProvider.notifier);

    return DropdownButtonFormField<String>(
      initialValue: state.selectedCategoria,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
      items: notifier.categorias
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: notifier.onCategoriaChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione uma categoria';
        }
        return null;
      },
    );
  }
}

/// Exercicio dropdown widget
class _ExercicioDropdown extends ConsumerWidget {
  const _ExercicioDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercicioFormProvider);
    final notifier = ref.read(exercicioFormProvider.notifier);

    return DropdownButtonFormField<Map<String, dynamic>>(
      initialValue: state.exercicioSelecionado,
      decoration: const InputDecoration(
        labelText: 'Tipo de Exercício',
        border: OutlineInputBorder(),
      ),
      items: state.exerciciosFiltrados
          .map((e) => DropdownMenuItem<Map<String, dynamic>>(
                value: e,
                child: Text(e['text'] as String),
              ))
          .toList(),
      onChanged: notifier.onExercicioSelected,
      validator: (value) {
        if (notifier.nomeController.text.isEmpty) {
          return 'Por favor, selecione um exercício';
        }
        return null;
      },
    );
  }
}

/// Nome text field widget
class _NomeTextField extends ConsumerWidget {
  const _NomeTextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(exercicioFormProvider.notifier);

    return TextFormField(
      controller: notifier.nomeController,
      decoration: const InputDecoration(
        labelText: 'Nome do Exercício (ou informe manualmente)',
        border: OutlineInputBorder(),
      ),
      validator: notifier.validateNome,
    );
  }
}

/// Duracao and calorias row widget
class _DuracaoCaloriasRow extends ConsumerWidget {
  const _DuracaoCaloriasRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(exercicioFormProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: notifier.duracaoController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Duração (minutos)',
              border: OutlineInputBorder(),
            ),
            validator: notifier.validateDuracao,
          ),
        ),
        const SizedBox(width: ExercicioConstants.defaultPadding),
        Expanded(
          child: TextFormField(
            controller: notifier.caloriasController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Calorias Queimadas',
              border: OutlineInputBorder(),
            ),
            validator: notifier.validateCalorias,
          ),
        ),
      ],
    );
  }
}

/// Observacoes text field widget
class _ObservacoesTextField extends ConsumerWidget {
  const _ObservacoesTextField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(exercicioFormProvider.notifier);

    return TextFormField(
      controller: notifier.observacoesController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Observações (opcional)',
        border: OutlineInputBorder(),
      ),
      validator: notifier.validateObservacoes,
    );
  }
}

/// Data selector widget
class _DataSelector extends ConsumerWidget {
  const _DataSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercicioFormProvider);

    return Row(
      children: [
        const Text('Data: '),
        TextButton(
          onPressed: () => _selecionarData(context, ref),
          child: Text(
            _formatarData(state.dataRegistro),
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  Future<void> _selecionarData(BuildContext context, WidgetRef ref) async {
    final state = ref.read(exercicioFormProvider);
    final notifier = ref.read(exercicioFormProvider.notifier);

    final date = await showDatePicker(
      context: context,
      initialDate: state.dataRegistro,
      firstDate: DateTime(ExercicioConstants.calendarioAnoInicio),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null) {
      notifier.onDataSelected(date);
    }
  }
}

/// Action buttons widget
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercicioFormProvider);

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
        ElevatedButton(
          onPressed:
              state.isLoading ? null : () => _salvarExercicio(context, ref),
          child: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _salvarExercicio(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(exercicioFormProvider.notifier);

    if (notifier.formKey.currentState?.validate() == true) {
      final success = await notifier.salvarFormulario();
      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
