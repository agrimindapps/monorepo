// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/exercicio_model.dart';
import '../services/exercicio_data_service.dart';
import '../services/exercicio_event_service.dart';
import '../services/exercicio_logger_service.dart';
import '../services/exercicio_validation_service.dart';
import 'exercicio_base_controller.dart';

/// Form controller for exercise creation and editing

class ExercicioFormController extends ExercicioBaseController {
  final nomeController = TextEditingController();
  final categoriaController = TextEditingController();
  final duracaoController = TextEditingController();
  final caloriasController = TextEditingController();
  final observacoesController = TextEditingController();

  final RxString selectedCategoria = 'Aeróbico'.obs;
  final Rx<Map<String, dynamic>?> exercicioSelecionado =
      Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> exerciciosFiltrados =
      <Map<String, dynamic>>[].obs;
  final Rx<DateTime> dataRegistro = DateTime.now().obs;
  final RxBool isFormValid = false.obs;

  Worker? _categoriaWorker;
  Worker? _duracaoWorker;
  Worker? _nomeWorker;

  final _dataService = ExercicioDataService();
  final _eventService = ExercicioEventService();
  final formKey = GlobalKey<FormState>();

  ExercicioModel? _exercicioEditando;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    _filtrarExercicios(selectedCategoria.value);
  }

  @override
  void onClose() {
    _categoriaWorker?.dispose();
    _duracaoWorker?.dispose();
    _nomeWorker?.dispose();

    duracaoController.removeListener(_calcularCalorias);
    nomeController.removeListener(_validateForm);
    duracaoController.removeListener(_validateForm);

    nomeController.dispose();
    categoriaController.dispose();
    duracaoController.dispose();
    caloriasController.dispose();
    observacoesController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    _categoriaWorker = ever(selectedCategoria, (categoria) {
      _filtrarExercicios(categoria);
    });

    duracaoController.addListener(_calcularCalorias);
    nomeController.addListener(_validateForm);
    duracaoController.addListener(_validateForm);
  }

  void initializeForm(ExercicioModel? exercicio) {
    _exercicioEditando = exercicio;

    if (exercicio != null) {
      nomeController.text = exercicio.nome;
      selectedCategoria.value = exercicio.categoria;
      categoriaController.text = exercicio.categoria;
      duracaoController.text = exercicio.duracao.toString();
      caloriasController.text = exercicio.caloriasQueimadas.toString();
      observacoesController.text = exercicio.observacoes ?? '';
      dataRegistro.value =
          DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);

      _findExercicioByName(exercicio.nome);
    } else {
      _resetForm();
    }
  }

  void _resetForm() {
    nomeController.clear();
    selectedCategoria.value = 'Aeróbico';
    categoriaController.text = 'Aeróbico';
    duracaoController.text = ExercicioConstants.duracaoPadraoMinutos.toString();
    caloriasController.text = '0';
    observacoesController.clear();
    dataRegistro.value = DateTime.now();
    exercicioSelecionado.value = null;
  }

  void _findExercicioByName(String nome) {
    try {
      final exercicioEncontrado = _dataService.buscarExercicioPorNome(nome);
      exercicioSelecionado.value = exercicioEncontrado ?? {
        'id': -1,
        'value': 0,
        'text': nome,
        'categoria': selectedCategoria.value
      };
    } catch (e) {
      ExercicioLoggerService.e('Erro ao encontrar exercício', 
        component: 'FormController', error: e, context: {'nome': nome});
    }
  }

  void _filtrarExercicios(String categoria) {
    exerciciosFiltrados.value = _dataService.obterExerciciosPorCategoria(categoria);
  }

  void onCategoriaChanged(String? categoria) {
    if (categoria != null) {
      selectedCategoria.value = categoria;
      categoriaController.text = categoria;
      exercicioSelecionado.value = null;
      nomeController.clear();
    }
  }

  void onExercicioSelected(Map<String, dynamic>? exercicio) {
    if (exercicio != null) {
      exercicioSelecionado.value = exercicio;
      nomeController.text = exercicio['text'] ?? '';
      _calcularCalorias();
    }
  }

  void _calcularCalorias() {
    if (exercicioSelecionado.value != null &&
        duracaoController.text.isNotEmpty) {
      try {
        int duracao = int.parse(duracaoController.text);
        double valorPorMinuto =
            exercicioSelecionado.value!['value']?.toDouble() ?? 0.0;
        int calorias = (duracao * valorPorMinuto).round();
        caloriasController.text = calorias.toString();
      } catch (e) {
        ExercicioLoggerService.e('Erro ao calcular calorias', 
          component: 'FormController', error: e, 
          context: {'duracao': duracaoController.text, 'exercicio': exercicioSelecionado.value?['text']});
      }
    }
  }

  void _validateForm() {
    isFormValid.value = nomeController.text.isNotEmpty &&
        duracaoController.text.isNotEmpty &&
        int.tryParse(duracaoController.text) != null &&
        int.tryParse(duracaoController.text)! > 0;
  }

  void onDataSelected(DateTime data) {
    dataRegistro.value = data;
  }

  Future<bool> salvarFormulario() async {
    if (!formKey.currentState!.validate() || !isFormValid.value) {
      Get.snackbar('Erro', 'Por favor, preencha todos os campos obrigatórios');
      return false;
    }

    try {
      isLoading.value = true;

      final exercicio = ExercicioModel(
        id: _exercicioEditando?.id,
        nome: nomeController.text.trim(),
        categoria: selectedCategoria.value,
        duracao: int.parse(duracaoController.text),
        caloriasQueimadas: int.tryParse(caloriasController.text) ?? 0,
        dataRegistro: dataRegistro.value.millisecondsSinceEpoch,
        observacoes: observacoesController.text.trim().isEmpty
            ? null
            : observacoesController.text.trim(),
      );

      final savedExercicio = await saveExercicio(exercicio);

      final isUpdate = _exercicioEditando != null;
      final message = isUpdate
          ? 'Exercício atualizado com sucesso!'
          : 'Exercício registrado com sucesso!';

      Get.snackbar('Sucesso', message);

      _notifyViaEvents(savedExercicio, isUpdate: isUpdate);

      return true;
    } catch (e) {
      final action = _exercicioEditando != null ? 'atualizar' : 'registrar';
      Get.snackbar('Erro', 'Falha ao $action exercício: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _notifyViaEvents(ExercicioModel exercicio, {required bool isUpdate}) {
    try {
      if (isUpdate) {
        _eventService.emitExercicioUpdated(exercicio);
        ExercicioLoggerService.i('Evento de atualização emitido', 
          component: 'FormController', context: {'exerciseName': exercicio.nome});
      } else {
        _eventService.emitExercicioCreated(exercicio);
        ExercicioLoggerService.i('Evento de criação emitido', 
          component: 'FormController', context: {'exerciseName': exercicio.nome});
      }
    } catch (e) {
      ExercicioLoggerService.e('Erro ao emitir evento', 
        component: 'FormController', error: e, 
        context: {'isUpdate': isUpdate, 'exerciseName': exercicio.nome});
      ExercicioLoggerService.i(
          'Exercício ${isUpdate ? 'atualizado' : 'criado'}', 
          component: 'FormController', context: {'exerciseName': exercicio.nome});
    }
  }

  void carregarRegistroParaEdicao(ExercicioModel exercicio) {
    initializeForm(exercicio);
  }

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

  bool get isEditing => _exercicioEditando != null;
  String get formTitle => isEditing ? 'Editar Exercício' : 'Novo Exercício';
  List<String> get categorias => _dataService.categorias;
}
