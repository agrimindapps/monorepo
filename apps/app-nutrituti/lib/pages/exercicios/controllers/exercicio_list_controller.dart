// Dart imports:
import 'dart:async';

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/achievement_model.dart';
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import '../services/exercicio_event_service.dart';
import '../services/exercicio_logger_service.dart';

part 'exercicio_list_controller.g.dart';

/// State class for Exercicio List page
class ExercicioListState {
  final bool isLoading;
  final List<ExercicioModel> registros;
  final double metaMinutosSemanal;
  final double metaCaloriasSemanal;
  final int totalMinutosSemana;
  final int totalCaloriasSemana;
  final List<ExercicioAchievement> achievements;
  final Map<DateTime, List<ExercicioModel>> events;

  const ExercicioListState({
    this.isLoading = false,
    this.registros = const [],
    this.metaMinutosSemanal = 0.0,
    this.metaCaloriasSemanal = 0.0,
    this.totalMinutosSemana = 0,
    this.totalCaloriasSemana = 0,
    this.achievements = const [],
    this.events = const {},
  });

  ExercicioListState copyWith({
    bool? isLoading,
    List<ExercicioModel>? registros,
    double? metaMinutosSemanal,
    double? metaCaloriasSemanal,
    int? totalMinutosSemana,
    int? totalCaloriasSemana,
    List<ExercicioAchievement>? achievements,
    Map<DateTime, List<ExercicioModel>>? events,
  }) {
    return ExercicioListState(
      isLoading: isLoading ?? this.isLoading,
      registros: registros ?? this.registros,
      metaMinutosSemanal: metaMinutosSemanal ?? this.metaMinutosSemanal,
      metaCaloriasSemanal: metaCaloriasSemanal ?? this.metaCaloriasSemanal,
      totalMinutosSemana: totalMinutosSemana ?? this.totalMinutosSemana,
      totalCaloriasSemana: totalCaloriasSemana ?? this.totalCaloriasSemana,
      achievements: achievements ?? this.achievements,
      events: events ?? this.events,
    );
  }
}

/// Provider for ExercicioRepository
@riverpod
ExercicioRepository exercicioRepository(Ref ref) {
  return ExercicioRepository();
}

/// Provider for ExercicioEventService
@riverpod
ExercicioEventService exercicioEventService(Ref ref) {
  return ExercicioEventService();
}

/// Main Exercicio List Notifier
@riverpod
class ExercicioListNotifier extends _$ExercicioListNotifier {
  StreamSubscription<ExercicioModel>? _exercicioCreatedSubscription;
  StreamSubscription<ExercicioModel>? _exercicioUpdatedSubscription;
  StreamSubscription<String>? _exercicioDeletedSubscription;
  StreamSubscription<Map<String, dynamic>>? _metasUpdatedSubscription;

  @override
  Future<ExercicioListState> build() async {
    // Setup event listeners
    _setupEventListeners();

    // Load initial data
    final repository = ref.watch(exercicioRepositoryProvider);

    try {
      final registros = await repository.getExercicios();
      final metas = await repository.getMetasExercicios();

      final totais = _calcularTotaisSemana(registros);
      final events = _updateEventsMap(registros);
      final achievements = _initAchievements(
        registros,
        (metas['minutosSemanal'] as num?)?.toDouble() ?? 0.0,
        (metas['caloriasSemanal'] as num?)?.toDouble() ?? 0.0,
        totais['minutos'] ?? 0,
        totais['calorias'] ?? 0,
      );

      return ExercicioListState(
        isLoading: false,
        registros: registros,
        metaMinutosSemanal: (metas['minutosSemanal'] as num?)?.toDouble() ?? 0.0,
        metaCaloriasSemanal: (metas['caloriasSemanal'] as num?)?.toDouble() ?? 0.0,
        totalMinutosSemana: totais['minutos'] ?? 0,
        totalCaloriasSemana: totais['calorias'] ?? 0,
        achievements: achievements,
        events: events,
      );
    } catch (e) {
      ExercicioLoggerService.e('Erro ao carregar dados',
          component: 'ListNotifier', error: e);
      return const ExercicioListState();
    }
  }

  /// Setup event listeners for decoupled communication
  void _setupEventListeners() {
    final eventService = ref.read(exercicioEventServiceProvider);

    // Listen for exercicios created
    _exercicioCreatedSubscription = eventService.onExercicioCreated((exercicio) {
      ExercicioLoggerService.i('Evento recebido: exercício criado',
          component: 'ListNotifier',
          context: {'exerciseName': exercicio.nome});
      _handleExercicioCreated(exercicio);
    });

    // Listen for exercicios updated
    _exercicioUpdatedSubscription = eventService.onExercicioUpdated((exercicio) {
      ExercicioLoggerService.i('Evento recebido: exercício atualizado',
          component: 'ListNotifier',
          context: {'exerciseName': exercicio.nome});
      _handleExercicioUpdated(exercicio);
    });

    // Listen for exercicios deleted
    _exercicioDeletedSubscription =
        eventService.onExercicioDeleted((exercicioId) {
      ExercicioLoggerService.i('Evento recebido: exercício deletado',
          component: 'ListNotifier', context: {'exercicioId': exercicioId});
      _handleExercicioDeleted(exercicioId);
    });

    // Listen for metas updated
    _metasUpdatedSubscription = eventService.onMetasUpdated((metas) {
      ExercicioLoggerService.i('Evento recebido: metas atualizadas',
          component: 'ListNotifier');
      _handleMetasUpdated(metas);
    });

    // Cleanup subscriptions on dispose
    ref.onDispose(() {
      _exercicioCreatedSubscription?.cancel();
      _exercicioUpdatedSubscription?.cancel();
      _exercicioDeletedSubscription?.cancel();
      _metasUpdatedSubscription?.cancel();
    });
  }

  /// Calculate weekly totals
  Map<String, int> _calcularTotaisSemana(List<ExercicioModel> registros) {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
    final fimSemana = inicioSemana.add(const Duration(days: 6));

    int minutos = 0;
    int calorias = 0;

    for (var exercicio in registros) {
      if (!_isValidTimestamp(exercicio.dataRegistro)) continue;

      final dataExercicio =
          DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);

      if (dataExercicio
              .isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
          dataExercicio.isBefore(fimSemana.add(const Duration(days: 1)))) {
        minutos += exercicio.duracao;
        calorias += exercicio.caloriasQueimadas;
      }
    }

    return {'minutos': minutos, 'calorias': calorias};
  }

  /// Update events map for calendar
  Map<DateTime, List<ExercicioModel>> _updateEventsMap(
      List<ExercicioModel> registros) {
    final Map<DateTime, List<ExercicioModel>> events = {};

    for (var exercicio in registros) {
      if (!_isValidTimestamp(exercicio.dataRegistro)) continue;

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
            component: 'ListNotifier',
            context: {
              'timestamp': exercicio.dataRegistro,
              'exerciseName': exercicio.nome
            });
      }
    }

    return events;
  }

  /// Initialize achievements
  List<ExercicioAchievement> _initAchievements(
    List<ExercicioModel> registros,
    double metaMinutos,
    double metaCalorias,
    int totalMinutos,
    int totalCalorias,
  ) {
    bool tem7DiasConsecutivos =
        _verificarDiasConsecutivos(registros, ExercicioConstants.conquistaDiasConsecutivos);

    return [
      ExercicioAchievement(
        title: 'Primeiro Passo',
        description: 'Registre seu primeiro exercício',
        isUnlocked: registros.isNotEmpty,
      ),
      ExercicioAchievement(
        title: 'Constância',
        description:
            'Registre exercícios em ${ExercicioConstants.conquistaDiasConsecutivos} dias consecutivos',
        isUnlocked: tem7DiasConsecutivos,
      ),
      ExercicioAchievement(
        title: 'Queimando Calorias',
        description: 'Queime mais de 1000 calorias em uma semana',
        isUnlocked: totalCalorias > 1000,
      ),
      ExercicioAchievement(
        title: 'Meta Atingida',
        description: 'Atinja sua meta semanal de minutos de exercício',
        isUnlocked: metaMinutos > 0 && totalMinutos >= metaMinutos,
      ),
    ];
  }

  /// Verify consecutive days
  bool _verificarDiasConsecutivos(List<ExercicioModel> registros, int dias) {
    if (registros.isEmpty) return false;

    final hoje = DateTime.now();
    Set<DateTime> diasComExercicio = {};

    for (var exercicio in registros) {
      if (!_isValidTimestamp(exercicio.dataRegistro)) continue;

      final data = DateTime.fromMillisecondsSinceEpoch(exercicio.dataRegistro);
      final dataNormalizada = DateTime(data.year, data.month, data.day);
      diasComExercicio.add(dataNormalizada);
    }

    // Check consecutive days sequence
    int contador = 0;
    DateTime dataAtual = DateTime(hoje.year, hoje.month, hoje.day);

    while (diasComExercicio.contains(dataAtual)) {
      contador++;
      if (contador >= dias) return true;
      dataAtual = dataAtual.subtract(const Duration(days: 1));
    }

    return false;
  }

  /// Validate timestamp
  bool _isValidTimestamp(int timestamp) {
    try {
      DateTime.fromMillisecondsSinceEpoch(timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========================================================================
  // PUBLIC METHODS
  // ========================================================================

  /// Refresh data
  Future<void> onRefresh() async {
    ref.invalidateSelf();
  }

  /// Get exercicios for a specific date
  List<ExercicioModel> getExerciciosParaData(DateTime data) {
    final currentState = state.value;
    if (currentState == null) return [];

    final day = DateTime(data.year, data.month, data.day);
    return currentState.events[day] ?? [];
  }

  /// Delete exercicio
  Future<void> excluirExercicio(String exercicioId) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(exercicioRepositoryProvider);
      await repository.deleteExercicio(exercicioId);

      final updatedRegistros =
          currentState.registros.where((e) => e.id != exercicioId).toList();

      final totais = _calcularTotaisSemana(updatedRegistros);
      final events = _updateEventsMap(updatedRegistros);
      final achievements = _initAchievements(
        updatedRegistros,
        currentState.metaMinutosSemanal,
        currentState.metaCaloriasSemanal,
        totais['minutos'] ?? 0,
        totais['calorias'] ?? 0,
      );

      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        registros: updatedRegistros,
        totalMinutosSemana: totais['minutos'] ?? 0,
        totalCaloriasSemana: totais['calorias'] ?? 0,
        achievements: achievements,
        events: events,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Falha ao excluir exercício: $e');
    }
  }

  /// Save exercise goals
  Future<void> saveMetaExercicios(
      double minutosSemanal, double caloriasSemanal) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(exercicioRepositoryProvider);
      await repository.saveMetasExercicios({
        'minutosSemanal': minutosSemanal,
        'caloriasSemanal': caloriasSemanal,
      });

      final achievements = _initAchievements(
        currentState.registros,
        minutosSemanal,
        caloriasSemanal,
        currentState.totalMinutosSemana,
        currentState.totalCaloriasSemana,
      );

      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        metaMinutosSemanal: minutosSemanal,
        metaCaloriasSemanal: caloriasSemanal,
        achievements: achievements,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Falha ao definir meta de exercícios: $e');
    }
  }

  /// Get tip of the day
  String getTipOfTheDay() {
    const tips = [
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

    // Select a tip based on day of year
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  // ========================================================================
  // EVENT HANDLERS - Decoupled communication via events
  // ========================================================================

  /// Handler for exercicio created via events
  void _handleExercicioCreated(ExercicioModel exercicio) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Add new exercicio to list
    final updatedRegistros = [...currentState.registros, exercicio];

    // Update statistics
    await _refreshStatistics(currentState, updatedRegistros);

    ExercicioLoggerService.i('Lista atualizada: exercício criado',
        component: 'ListNotifier', context: {'exerciseName': exercicio.nome});
  }

  /// Handler for exercicio updated via events
  void _handleExercicioUpdated(ExercicioModel exercicio) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Update existing exercicio in list
    final updatedRegistros = currentState.registros.map((r) {
      return r.id == exercicio.id ? exercicio : r;
    }).toList();

    // Update statistics
    await _refreshStatistics(currentState, updatedRegistros);

    ExercicioLoggerService.i('Lista atualizada: exercício atualizado',
        component: 'ListNotifier', context: {'exerciseName': exercicio.nome});
  }

  /// Handler for exercicio deleted via events
  void _handleExercicioDeleted(String exercicioId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Remove exercicio from list
    final updatedRegistros =
        currentState.registros.where((e) => e.id != exercicioId).toList();

    // Update statistics
    await _refreshStatistics(currentState, updatedRegistros);

    ExercicioLoggerService.i('Lista atualizada: exercício removido',
        component: 'ListNotifier', context: {'exercicioId': exercicioId});
  }

  /// Handler for metas updated via events
  void _handleMetasUpdated(Map<String, dynamic> metas) async {
    final currentState = state.value;
    if (currentState == null) return;

    final metaMinutos = (metas['metaMinutos'] ?? 0.0).toDouble();
    final metaCalorias = (metas['metaCalorias'] ?? 0.0).toDouble();

    final achievements = _initAchievements(
      currentState.registros,
      (metaMinutos as num).toDouble(),
      (metaCalorias as num).toDouble(),
      currentState.totalMinutosSemana,
      currentState.totalCaloriasSemana,
    );

    state = AsyncValue.data(currentState.copyWith(
      metaMinutosSemanal: (metaMinutos as num?)?.toDouble(),
      metaCaloriasSemanal: (metaCalorias as num?)?.toDouble(),
      achievements: achievements,
    ));

    ExercicioLoggerService.i('Metas atualizadas via evento',
        component: 'ListNotifier');
  }

  /// Helper method to refresh statistics
  Future<void> _refreshStatistics(
      ExercicioListState currentState, List<ExercicioModel> registros) async {
    final totais = _calcularTotaisSemana(registros);
    final events = _updateEventsMap(registros);
    final achievements = _initAchievements(
      registros,
      currentState.metaMinutosSemanal,
      currentState.metaCaloriasSemanal,
      totais['minutos'] ?? 0,
      totais['calorias'] ?? 0,
    );

    state = AsyncValue.data(currentState.copyWith(
      registros: registros,
      totalMinutosSemana: totais['minutos'] ?? 0,
      totalCaloriasSemana: totais['calorias'] ?? 0,
      achievements: achievements,
      events: events,
    ));
  }
}
