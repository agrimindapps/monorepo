// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import '../../../core/providers/dependency_providers.dart';
import '../models/achievement_model.dart';
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import '../services/exercicio_achievement_service.dart';
import '../services/exercicio_business_service.dart';
import '../services/exercicio_cache_service.dart';
import '../services/exercicio_statistics_service.dart';

part 'exercicio_controller.g.dart';

/// State class for Exercicio feature
class ExercicioState {
  final bool isLoading;
  final List<ExercicioModel> registros;
  final double metaMinutosSemanal;
  final double metaCaloriasSemanal;
  final int totalMinutosSemana;
  final int totalCaloriasSemana;
  final List<ExercicioAchievement> achievements;

  const ExercicioState({
    this.isLoading = false,
    this.registros = const [],
    this.metaMinutosSemanal = 0.0,
    this.metaCaloriasSemanal = 0.0,
    this.totalMinutosSemana = 0,
    this.totalCaloriasSemana = 0,
    this.achievements = const [],
  });

  ExercicioState copyWith({
    bool? isLoading,
    List<ExercicioModel>? registros,
    double? metaMinutosSemanal,
    double? metaCaloriasSemanal,
    int? totalMinutosSemana,
    int? totalCaloriasSemana,
    List<ExercicioAchievement>? achievements,
  }) {
    return ExercicioState(
      isLoading: isLoading ?? this.isLoading,
      registros: registros ?? this.registros,
      metaMinutosSemanal: metaMinutosSemanal ?? this.metaMinutosSemanal,
      metaCaloriasSemanal: metaCaloriasSemanal ?? this.metaCaloriasSemanal,
      totalMinutosSemana: totalMinutosSemana ?? this.totalMinutosSemana,
      totalCaloriasSemana: totalCaloriasSemana ?? this.totalCaloriasSemana,
      achievements: achievements ?? this.achievements,
    );
  }
}

/// Provider for ExercicioBusinessService
@riverpod
ExercicioBusinessService exercicioBusinessService(Ref ref) {
  final database = ref.watch(nutritutiDatabaseProvider);
  final repository = ExercicioRepository();
  return ExercicioBusinessService(database, repository);
}

/// Provider for ExercicioStatisticsService
@riverpod
ExercicioStatisticsService exercicioStatisticsService(Ref ref) {
  return ExercicioStatisticsService();
}

/// Provider for ExercicioAchievementService
@riverpod
ExercicioAchievementService exercicioAchievementService(Ref ref) {
  return ExercicioAchievementService();
}

/// Main Exercicio Notifier
@riverpod
class ExercicioNotifier extends _$ExercicioNotifier {
  @override
  Future<ExercicioState> build() async {
    final businessService = ref.watch(exercicioBusinessServiceProvider);

    try {
      await businessService.initialize();

      // Load registros
      final registros = await businessService.carregarExercicios();

      // Load metas
      final metas = await businessService.carregarMetas();
      final metaMinutos = metas['minutos'] ?? 0.0;
      final metaCalorias = metas['calorias'] ?? 0.0;

      // Calculate weekly totals
      final statisticsService = ref.read(exercicioStatisticsServiceProvider);
      final totais = statisticsService.calcularTotaisSemana(registros);

      // Update achievements
      final achievementService = ref.read(exercicioAchievementServiceProvider);
      final achievements = achievementService.avaliarConquistas(
        registros,
        metaMinutos,
        metaCalorias,
      );

      return ExercicioState(
        isLoading: false,
        registros: registros,
        metaMinutosSemanal: metaMinutos,
        metaCaloriasSemanal: metaCalorias,
        totalMinutosSemana: totais['minutos'] ?? 0,
        totalCaloriasSemana: totais['calorias'] ?? 0,
        achievements: achievements,
      );
    } catch (e) {
      throw Exception('Falha ao inicializar serviços: $e');
    }
  }

  /// Add new registro
  Future<void> addRegistro(ExercicioModel exercicio) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final businessService = ref.read(exercicioBusinessServiceProvider);
      final savedExercicio = await businessService.salvarExercicio(exercicio);

      final updatedRegistros = [...currentState.registros, savedExercicio];

      // Invalidate cache when data changes
      ExercicioCacheService.invalidateOnDataChange();

      // Update calculations
      final statisticsService = ref.read(exercicioStatisticsServiceProvider);
      final totais = statisticsService.calcularTotaisSemana(updatedRegistros);

      final achievementService = ref.read(exercicioAchievementServiceProvider);
      final achievements = achievementService.avaliarConquistas(
        updatedRegistros,
        currentState.metaMinutosSemanal,
        currentState.metaCaloriasSemanal,
      );

      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        registros: updatedRegistros,
        totalMinutosSemana: totais['minutos'] ?? 0,
        totalCaloriasSemana: totais['calorias'] ?? 0,
        achievements: achievements,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Falha ao registrar exercício: $e');
    }
  }

  /// Update existing registro
  Future<void> updateRegistro(ExercicioModel exercicio) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final businessService = ref.read(exercicioBusinessServiceProvider);
      final savedExercicio = await businessService.salvarExercicio(exercicio);

      final updatedRegistros = currentState.registros.map((r) {
        return r.id == exercicio.id ? savedExercicio : r;
      }).toList();

      // Invalidate cache when data changes
      ExercicioCacheService.invalidateOnDataChange();

      // Update calculations
      final statisticsService = ref.read(exercicioStatisticsServiceProvider);
      final totais = statisticsService.calcularTotaisSemana(updatedRegistros);

      final achievementService = ref.read(exercicioAchievementServiceProvider);
      final achievements = achievementService.avaliarConquistas(
        updatedRegistros,
        currentState.metaMinutosSemanal,
        currentState.metaCaloriasSemanal,
      );

      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        registros: updatedRegistros,
        totalMinutosSemana: totais['minutos'] ?? 0,
        totalCaloriasSemana: totais['calorias'] ?? 0,
        achievements: achievements,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw Exception('Falha ao atualizar exercício: $e');
    }
  }

  /// Delete registro
  Future<void> deleteRegistro(ExercicioModel exercicio) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      if (exercicio.id != null) {
        final businessService = ref.read(exercicioBusinessServiceProvider);
        await businessService.excluirExercicio(exercicio.id!);

        final updatedRegistros =
            currentState.registros.where((r) => r.id != exercicio.id).toList();

        // Invalidate cache when data changes
        ExercicioCacheService.invalidateOnDataChange();

        // Update calculations
        final statisticsService = ref.read(exercicioStatisticsServiceProvider);
        final totais = statisticsService.calcularTotaisSemana(updatedRegistros);

        final achievementService =
            ref.read(exercicioAchievementServiceProvider);
        final achievements = achievementService.avaliarConquistas(
          updatedRegistros,
          currentState.metaMinutosSemanal,
          currentState.metaCaloriasSemanal,
        );

        state = AsyncValue.data(currentState.copyWith(
          isLoading: false,
          registros: updatedRegistros,
          totalMinutosSemana: totais['minutos'] ?? 0,
          totalCaloriasSemana: totais['calorias'] ?? 0,
          achievements: achievements,
        ));
      }
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
      final businessService = ref.read(exercicioBusinessServiceProvider);
      await businessService.salvarMetas(minutosSemanal, caloriasSemanal);

      // Update achievements
      final achievementService = ref.read(exercicioAchievementServiceProvider);
      final achievements = achievementService.avaliarConquistas(
        currentState.registros,
        minutosSemanal,
        caloriasSemanal,
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
      'Dê ao seu corpo tempo para recuperar-se entre as sessões de treino intenso.',
    ];

    // Select a tip based on day of year
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }
}
