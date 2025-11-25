// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import '../services/exercicio_data_service.dart';
import '../services/exercicio_event_service.dart';
import '../services/exercicio_logger_service.dart';
import '../services/exercicio_validation_service.dart';

part 'exercicio_form_controller.g.dart';

/// State class for Exercicio Form
class ExercicioFormState {
  final bool isLoading;
  final String selectedCategoria;
  final Map<String, dynamic>? exercicioSelecionado;
  final List<Map<String, dynamic>> exerciciosFiltrados;
  final DateTime dataRegistro;
  final bool isFormValid;
  final ExercicioModel? exercicioEditando;

  ExercicioFormState({
    this.isLoading = false,
    this.selectedCategoria = 'Aeróbico',
    this.exercicioSelecionado,
    List<Map<String, dynamic>>? exerciciosFiltrados,
    DateTime? dataRegistro,
    this.isFormValid = false,
    this.exercicioEditando,
  })  : exerciciosFiltrados = exerciciosFiltrados ?? const [],
        dataRegistro = dataRegistro ?? DateTime.now();

  ExercicioFormState copyWith({
    bool? isLoading,
    String? selectedCategoria,
    Map<String, dynamic>? exercicioSelecionado,
    List<Map<String, dynamic>>? exerciciosFiltrados,
    DateTime? dataRegistro,
    bool? isFormValid,
    ExercicioModel? exercicioEditando,
  }) {
    return ExercicioFormState(
      isLoading: isLoading ?? this.isLoading,
      selectedCategoria: selectedCategoria ?? this.selectedCategoria,
      exercicioSelecionado: exercicioSelecionado ?? this.exercicioSelecionado,
      exerciciosFiltrados: exerciciosFiltrados ?? this.exerciciosFiltrados,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      isFormValid: isFormValid ?? this.isFormValid,
      exercicioEditando: exercicioEditando ?? this.exercicioEditando,
    );
  }
}

// Helper class for default DateTime value
class _DefaultDateTime {
  const _DefaultDateTime._();
}

/// Provider for ExercicioDataService
@riverpod
ExercicioDataService exercicioDataService(Ref ref) {
  return ExercicioDataService();
}

/// Provider for form repository
@riverpod
ExercicioRepository exercicioFormRepository(Ref ref) {
  return ExercicioRepository();
}

/// Provider for event service
@riverpod
ExercicioEventService exercicioFormEventService(
    Ref ref) {
  return ExercicioEventService();
}

/// Form Notifier
@riverpod
class ExercicioFormNotifier extends _$ExercicioFormNotifier {
  late TextEditingController nomeController;
  late TextEditingController categoriaController;
  late TextEditingController duracaoController;
  late TextEditingController caloriasController;
  late TextEditingController observacoesController;

  final formKey = GlobalKey<FormState>();

  @override
  ExercicioFormState build() {
    // Initialize text controllers
    nomeController = TextEditingController();
    categoriaController = TextEditingController(text: 'Aeróbico');
    duracaoController = TextEditingController(
        text: ExercicioConstants.duracaoPadraoMinutos.toString());
    caloriasController = TextEditingController(text: '0');
    observacoesController = TextEditingController();

    // Setup listeners
    duracaoController.addListener(_calcularCalorias);
    nomeController.addListener(_validateForm);
    duracaoController.addListener(_validateForm);

    // Cleanup on dispose
    ref.onDispose(() {
      duracaoController.removeListener(_calcularCalorias);
      nomeController.removeListener(_validateForm);
      duracaoController.removeListener(_validateForm);

      nomeController.dispose();
      categoriaController.dispose();
      duracaoController.dispose();
      caloriasController.dispose();
      observacoesController.dispose();
    });

    // Initialize with default categoria
    final dataService = ref.read(exercicioDataServiceProvider);
    final exerciciosFiltrados =
        dataService.obterExerciciosPorCategoria('Aeróbico');

    return ExercicioFormState(
      selectedCategoria: 'Aeróbico',
      exerciciosFiltrados: exerciciosFiltrados,
      dataRegistro: DateTime.now(),
    );
  }

  /// Initialize form with data (for editing)
  void initializeForm(ExercicioModel? exercicio) {
    if (exercicio != null) {
      // Editing mode
      nomeController.text = exercicio.nome;
      categoriaController.text = exercicio.categoria;
      duracaoController.text = exercicio.duracao.toString();
      caloriasController.text = exercicio.caloriasQueimadas.toString();
      observacoesController.text = exercicio.observacoes ?? '';

      final dataService = ref.read(exercicioDataServiceProvider);
      final exercicioEncontrado =
          dataService.buscarExercicioPorNome(exercicio.nome);

      state = state.copyWith(
        selectedCategoria: exercicio.categoria,
        dataRegistro: DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro),
        exercicioEditando: exercicio,
        exercicioSelecionado: exercicioEncontrado ?? {
          'id': -1,
          'value': 0,
          'text': exercicio.nome,
          'categoria': exercicio.categoria,
        },
        exerciciosFiltrados:
            dataService.obterExerciciosPorCategoria(exercicio.categoria),
      );
    } else {
      // New mode - reset form
      _resetForm();
    }
  }

  /// Reset form to initial state
  void _resetForm() {
    nomeController.clear();
    categoriaController.text = 'Aeróbico';
    duracaoController.text =
        ExercicioConstants.duracaoPadraoMinutos.toString();
    caloriasController.text = '0';
    observacoesController.clear();

    final dataService = ref.read(exercicioDataServiceProvider);

    state = ExercicioFormState(
      selectedCategoria: 'Aeróbico',
      dataRegistro: DateTime.now(),
      exerciciosFiltrados:
          dataService.obterExerciciosPorCategoria('Aeróbico'),
    );
  }

  /// Handle categoria change
  void onCategoriaChanged(String? categoria) {
    if (categoria != null) {
      categoriaController.text = categoria;
      nomeController.clear();

      final dataService = ref.read(exercicioDataServiceProvider);
      final exerciciosFiltrados =
          dataService.obterExerciciosPorCategoria(categoria);

      state = state.copyWith(
        selectedCategoria: categoria,
        exercicioSelecionado: null,
        exerciciosFiltrados: exerciciosFiltrados,
      );
    }
  }

  /// Handle exercicio selection
  void onExercicioSelected(Map<String, dynamic>? exercicio) {
    if (exercicio != null) {
      nomeController.text = (exercicio['text'] as String?) ?? '';

      state = state.copyWith(
        exercicioSelecionado: exercicio,
      );

      _calcularCalorias();
    }
  }

  /// Calculate calories based on duration and exercise
  void _calcularCalorias() {
    final exercicioSelecionado = state.exercicioSelecionado;

    if (exercicioSelecionado != null && duracaoController.text.isNotEmpty) {
      try {
        int duracao = int.parse(duracaoController.text);
        double valorPorMinuto =
            (exercicioSelecionado['value'] as num?)?.toDouble() ?? 0.0;
        int calorias = (duracao * valorPorMinuto).round();
        caloriasController.text = calorias.toString();
      } catch (e) {
        ExercicioLoggerService.e('Erro ao calcular calorias',
            component: 'FormNotifier',
            error: e,
            context: {
              'duracao': duracaoController.text,
              'exercicio': exercicioSelecionado['text']
            });
      }
    }
  }

  /// Validate form
  void _validateForm() {
    final isValid = nomeController.text.isNotEmpty &&
        duracaoController.text.isNotEmpty &&
        int.tryParse(duracaoController.text) != null &&
        int.tryParse(duracaoController.text)! > 0;

    state = state.copyWith(isFormValid: isValid);
  }

  /// Handle date selection
  void onDataSelected(DateTime data) {
    state = state.copyWith(dataRegistro: data);
  }

  /// Save form (create or update)
  Future<bool> salvarFormulario() async {
    if (!formKey.currentState!.validate() || !state.isFormValid) {
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(exercicioFormRepositoryProvider);

      final exercicio = ExercicioModel(
        id: state.exercicioEditando?.id,
        nome: nomeController.text.trim(),
        categoria: state.selectedCategoria,
        duracao: int.parse(duracaoController.text),
        caloriasQueimadas: int.tryParse(caloriasController.text) ?? 0,
        dataRegistro: state.dataRegistro.millisecondsSinceEpoch,
        observacoes: observacoesController.text.trim().isEmpty
            ? null
            : observacoesController.text.trim(),
      );

      final savedExercicio = await repository.saveExercicio(exercicio);
      final isUpdate = state.exercicioEditando != null;

      // Emit event
      _notifyViaEvents(savedExercicio, isUpdate: isUpdate);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      ExercicioLoggerService.e('Erro ao salvar exercício',
          component: 'FormNotifier', error: e);
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Notify via events
  void _notifyViaEvents(ExercicioModel exercicio, {required bool isUpdate}) {
    try {
      final eventService = ref.read(exercicioFormEventServiceProvider);

      if (isUpdate) {
        eventService.emitExercicioUpdated(exercicio);
        ExercicioLoggerService.i('Evento de atualização emitido',
            component: 'FormNotifier',
            context: {'exerciseName': exercicio.nome});
      } else {
        eventService.emitExercicioCreated(exercicio);
        ExercicioLoggerService.i('Evento de criação emitido',
            component: 'FormNotifier',
            context: {'exerciseName': exercicio.nome});
      }
    } catch (e) {
      ExercicioLoggerService.e('Erro ao emitir evento',
          component: 'FormNotifier',
          error: e,
          context: {'isUpdate': isUpdate, 'exerciseName': exercicio.nome});
    }
  }

  // Validation methods
  String? validateNome(String? value) {
    return ExercicioValidationService.validateNomeInput(value);
  }

  String? validateDuracao(String? value) {
    return ExercicioValidationService.validateDuracaoInput(value);
  }

  String? validateCalorias(String? value) {
    return ExercicioValidationService.validateCaloriasInput(value);
  }

  String? validateObservacoes(String? value) {
    return ExercicioValidationService.validateObservacoesInput(value);
  }

  // Getters
  bool get isEditing => state.exercicioEditando != null;
  String get formTitle => isEditing ? 'Editar Exercício' : 'Novo Exercício';
  List<String> get categorias =>
      ref.read(exercicioDataServiceProvider).categorias;
}
