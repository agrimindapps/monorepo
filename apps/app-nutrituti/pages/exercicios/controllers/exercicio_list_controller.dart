// Dart imports:
import 'dart:async';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/achievement_model.dart';
import '../models/exercicio_model.dart';
import '../services/exercicio_event_service.dart';
import '../services/exercicio_logger_service.dart';
import 'exercicio_base_controller.dart';

// ============================================================================
// CONTROLLER LISTA - EXERCÍCIOS
// ============================================================================

// REFACTOR: PRIORIDADE ALTA - Separação de Responsabilidades
// - Controller específico para a página de lista de exercícios
// - Gerencia exibição, metas, conquistas e estatísticas
// - Herda funcionalidades básicas do ExercicioBaseController

class ExercicioListController extends ExercicioBaseController {
  // Estados específicos da lista
  final RxDouble metaMinutosSemanal = 0.0.obs;
  final RxDouble metaCaloriasSemanal = 0.0.obs;
  final RxInt totalMinutosSemana = 0.obs;
  final RxInt totalCaloriasSemana = 0.obs;
  final RxList<ExercicioAchievement> achievements =
      <ExercicioAchievement>[].obs;

  // Mapa de eventos para o calendário
  final RxMap<DateTime, List<ExercicioModel>> events =
      <DateTime, List<ExercicioModel>>{}.obs;

  // Event service para comunicação desacoplada
  final _eventService = ExercicioEventService();
  
  // Subscriptions para eventos
  StreamSubscription<ExercicioModel>? _exercicioCreatedSubscription;
  StreamSubscription<ExercicioModel>? _exercicioUpdatedSubscription;
  StreamSubscription<String>? _exercicioDeletedSubscription;
  StreamSubscription<Map<String, dynamic>>? _metasUpdatedSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupEventListeners();
    loadData();
    _initAchievements();
  }

  @override
  void onClose() {
    // Cleanup de subscriptions para evitar vazamentos de memória
    _exercicioCreatedSubscription?.cancel();
    _exercicioUpdatedSubscription?.cancel();
    _exercicioDeletedSubscription?.cancel();
    _metasUpdatedSubscription?.cancel();
    super.onClose();
  }

  /// Configura listeners para eventos desacoplados
  void _setupEventListeners() {
    // Listen para exercícios criados
    _exercicioCreatedSubscription = _eventService.onExercicioCreated((exercicio) {
      ExercicioLoggerService.i('Evento recebido: exercício criado', 
        component: 'ListController', context: {'exerciseName': exercicio.nome});
      _handleExercicioCreated(exercicio);
    });

    // Listen para exercícios atualizados
    _exercicioUpdatedSubscription = _eventService.onExercicioUpdated((exercicio) {
      ExercicioLoggerService.i('Evento recebido: exercício atualizado', 
        component: 'ListController', context: {'exerciseName': exercicio.nome});
      _handleExercicioUpdated(exercicio);
    });

    // Listen para exercícios deletados
    _exercicioDeletedSubscription = _eventService.onExercicioDeleted((exercicioId) {
      ExercicioLoggerService.i('Evento recebido: exercício deletado', 
        component: 'ListController', context: {'exercicioId': exercicioId});
      _handleExercicioDeleted(exercicioId);
    });

    // Listen para metas atualizadas
    _metasUpdatedSubscription = _eventService.onMetasUpdated((metas) {
      ExercicioLoggerService.i('Evento recebido: metas atualizadas', 
        component: 'ListController');
      _handleMetasUpdated(metas);
    });
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await fetchAllExercicios();

      // Atualizar estatísticas específicas da lista
      _calcularTotaisSemana();
      _updateEventsMap();
      _atualizarAchievements();
    } finally {
      isLoading.value = false;
    }
  }

  void _calcularTotaisSemana() {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    int minutos = 0;
    int calorias = 0;

    for (var exercicio in registros) {
      if (!isValidTimestamp(exercicio.dataRegistro)) continue;

      final dataExercicio =
          DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);

      if (dataExercicio
              .isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
          dataExercicio.isBefore(fimSemana.add(const Duration(days: 1)))) {
        minutos += exercicio.duracao;
        calorias += exercicio.caloriasQueimadas;
      }
    }

    totalMinutosSemana.value = minutos;
    totalCaloriasSemana.value = calorias;
  }

  void _updateEventsMap() {
    events.clear();
    for (var exercicio in registros) {
      if (!isValidTimestamp(exercicio.dataRegistro)) continue;

      try {
        final date =
            DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);
        final day = DateTime(date.year, date.month, date.day);

        if (events[day] == null) {
          events[day] = [];
        }
        events[day]!.add(exercicio);
      } catch (e) {
        ExercicioLoggerService.e('Erro ao processar timestamp', 
          component: 'ListController', 
          context: {'timestamp': exercicio.dataRegistro, 'exerciseName': exercicio.nome});
      }
    }
  }

  void _initAchievements() {
    achievements.value = [
      ExercicioAchievement(
        title: 'Primeiro Passo',
        description: 'Registre seu primeiro exercício',
        isUnlocked: registros.isNotEmpty,
      ),
      ExercicioAchievement(
        title: 'Constância',
        description: 'Registre exercícios em ${ExercicioConstants.conquistaDiasConsecutivos} dias consecutivos',
        isUnlocked: false,
      ),
      ExercicioAchievement(
        title: 'Queimando Calorias',
        description: 'Queime mais de 1000 calorias em uma semana',
        isUnlocked: totalCaloriasSemana.value > 1000,
      ),
      ExercicioAchievement(
        title: 'Meta Atingida',
        description: 'Atinja sua meta semanal de minutos de exercício',
        isUnlocked: metaMinutosSemanal.value > 0 &&
            totalMinutosSemana.value >= metaMinutosSemanal.value,
      ),
    ];
  }

  void _atualizarAchievements() {
    bool tem7DiasConsecutivos = _verificarDiasConsecutivos(ExercicioConstants.conquistaDiasConsecutivos);

    achievements.value = [
      ExercicioAchievement(
        title: 'Primeiro Passo',
        description: 'Registre seu primeiro exercício',
        isUnlocked: registros.isNotEmpty,
      ),
      ExercicioAchievement(
        title: 'Constância',
        description: 'Registre exercícios em ${ExercicioConstants.conquistaDiasConsecutivos} dias consecutivos',
        isUnlocked: tem7DiasConsecutivos,
      ),
      ExercicioAchievement(
        title: 'Queimando Calorias',
        description: 'Queime mais de 1000 calorias em uma semana',
        isUnlocked: totalCaloriasSemana.value > 1000,
      ),
      ExercicioAchievement(
        title: 'Meta Atingida',
        description: 'Atinja sua meta semanal de minutos de exercício',
        isUnlocked: metaMinutosSemanal.value > 0 &&
            totalMinutosSemana.value >= metaMinutosSemanal.value,
      ),
    ];
  }

  bool _verificarDiasConsecutivos(int dias) {
    if (registros.isEmpty) return false;

    final hoje = DateTime.now();
    Set<DateTime> diasComExercicio = {};

    for (var exercicio in registros) {
      if (!isValidTimestamp(exercicio.dataRegistro)) continue;

      final data = DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);
      final dataNormalizada = DateTime(data.year, data.month, data.day);
      diasComExercicio.add(dataNormalizada);
    }

    // Verificar sequência de dias consecutivos
    int contador = 0;
    DateTime dataAtual = DateTime(hoje.year, hoje.month, hoje.day);

    while (diasComExercicio.contains(dataAtual)) {
      contador++;
      if (contador >= dias) return true;
      dataAtual = dataAtual.subtract(const Duration(days: 1));
    }

    return false;
  }

  // Métodos de interface públicos
  Future<void> onRefresh() async {
    await loadData();
  }

  List<ExercicioModel> getExerciciosParaData(DateTime data) {
    final day = DateTime(data.year, data.month, data.day);
    return events[day] ?? [];
  }

  Future<void> excluirExercicio(String exercicioId) async {
    try {
      isLoading.value = true;

      await deleteExercicio(exercicioId);

      registros.removeWhere((exercicio) => exercicio.id == exercicioId);

      // Recalcular totais e conquistas
      _calcularTotaisSemana();
      _updateEventsMap();
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Exercício excluído com sucesso!');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMetaExercicios(
      double minutosSemanal, double caloriasSemanal) async {
    try {
      await super.saveMetasExercicios({
        'minutosSemanal': minutosSemanal,
        'caloriasSemanal': caloriasSemanal,
      });

      metaMinutosSemanal.value = minutosSemanal;
      metaCaloriasSemanal.value = caloriasSemanal;

      // Atualizar conquistas
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Meta de exercícios definida com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao definir meta de exercícios: $e');
    }
  }

  String getTipOfTheDay() {
    final tips = [
      'Tente fazer pelo menos 150 minutos de exercícios aeróbicos moderados por semana.',
      'Inclua exercícios de força muscular pelo menos 2 vezes por semana.',
      'Faça pequenas pausas durante o dia para se movimentar, mesmo que por 5 minutos.',
      'Encontre uma atividade que você realmente goste para manter a motivação.',
      'Combine diferentes tipos de exercícios para trabalhar diferentes grupos musculares.',
      'Beber água antes, durante e após o exercício é essencial para a hidratação.',
      'Alongue-se antes e depois dos exercícios para prevenir lesões.',
      'Monitore sua frequência cardíaca para garantir que está treinando na intensidade correta.',
      'Comece devagar e aumente gradualmente a intensidade e duração dos exercícios.',
    ];

    // Selecionar uma dica baseada no dia do ano
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  // ========================================================================
  // EVENT HANDLERS - Comunicação desacoplada via eventos
  // ========================================================================

  /// Handler para exercício criado via eventos
  void _handleExercicioCreated(ExercicioModel exercicio) {
    // Adicionar novo exercício à lista
    registros.add(exercicio);
    
    // Atualizar estatísticas
    _refreshStatistics();
    
    ExercicioLoggerService.i('Lista atualizada: exercício criado', 
      component: 'ListController', context: {'exerciseName': exercicio.nome});
  }

  /// Handler para exercício atualizado via eventos
  void _handleExercicioUpdated(ExercicioModel exercicio) {
    // Atualizar exercício existente na lista
    final index = registros.indexWhere((r) => r.id == exercicio.id);
    if (index != -1) {
      registros[index] = exercicio;
      
      // Atualizar estatísticas
      _refreshStatistics();
      
      ExercicioLoggerService.i('Lista atualizada: exercício atualizado', 
        component: 'ListController', context: {'exerciseName': exercicio.nome});
    }
  }

  /// Handler para exercício deletado via eventos
  void _handleExercicioDeleted(String exercicioId) {
    // Remover exercício da lista
    final removedCount = registros.length;
    registros.removeWhere((exercicio) => exercicio.id == exercicioId);
    
    if (registros.length < removedCount) {
      // Atualizar estatísticas
      _refreshStatistics();
      
      ExercicioLoggerService.i('Lista atualizada: exercício removido', 
        component: 'ListController', context: {'exercicioId': exercicioId});
    }
  }

  /// Handler para metas atualizadas via eventos
  void _handleMetasUpdated(Map<String, dynamic> metas) {
    metaMinutosSemanal.value = (metas['metaMinutos'] ?? 0.0).toDouble();
    metaCaloriasSemanal.value = (metas['metaCalorias'] ?? 0.0).toDouble();
    
    // Atualizar conquistas baseadas nas novas metas
    _atualizarAchievements();
    
    ExercicioLoggerService.i('Metas atualizadas via evento', 
      component: 'ListController');
  }

  /// Método auxiliar para refresh de estatísticas
  void _refreshStatistics() {
    _updateEventsMap();
    _calcularTotaisSemana();
    _atualizarAchievements();
    update(); // Notificar UI sobre mudanças
  }

  // ========================================================================
  // MÉTODOS DE COMPATIBILIDADE (DEPRECATED)
  // ========================================================================

  /// @deprecated Use eventos via ExercicioEventService
  /// Método para atualizar a lista quando um exercício for adicionado/editado
  @Deprecated('Use ExercicioEventService para comunicação desacoplada')
  void refreshFromForm(ExercicioModel exercicio, {required bool isUpdate}) {
    if (isUpdate) {
      _handleExercicioUpdated(exercicio);
    } else {
      _handleExercicioCreated(exercicio);
    }
  }

  // COMPATIBILITY: Métodos para manter compatibilidade com a interface anterior
  Future<void> addRegistro(ExercicioModel exercicio) async {
    try {
      isLoading.value = true;

      final savedExercicio = await saveExercicio(exercicio);
      registros.add(savedExercicio);

      // Recalcular totais e conquistas
      _calcularTotaisSemana();
      _updateEventsMap();
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Exercício registrado com sucesso!');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRegistro(ExercicioModel exercicio) async {
    try {
      isLoading.value = true;

      final savedExercicio = await saveExercicio(exercicio);

      final index = registros.indexWhere((r) => r.id == exercicio.id);
      if (index != -1) {
        registros[index] = savedExercicio;
      }

      // Recalcular totais e conquistas
      _calcularTotaisSemana();
      _updateEventsMap();
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Exercício atualizado com sucesso!');
    } finally {
      isLoading.value = false;
    }
  }
}
