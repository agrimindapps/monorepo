// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/achievement_model.dart';
import '../models/exercicio_model.dart';
import '../services/exercicio_achievement_service.dart';
import '../services/exercicio_business_service.dart';
import '../services/exercicio_cache_service.dart';
import '../services/exercicio_statistics_service.dart';

class ExercicioController extends GetxController {
  // Services especializados
  final ExercicioBusinessService _businessService = ExercicioBusinessService();
  final ExercicioStatisticsService _statisticsService = ExercicioStatisticsService();
  final ExercicioAchievementService _achievementService = ExercicioAchievementService();

  final RxBool isLoading = false.obs;
  final RxList<ExercicioModel> registros = <ExercicioModel>[].obs;
  final RxDouble metaMinutosSemanal = 0.0.obs;
  final RxDouble metaCaloriasSemanal = 0.0.obs;
  final RxInt totalMinutosSemana = 0.obs;
  final RxInt totalCaloriasSemana = 0.obs;
  final RxList<ExercicioAchievement> achievements =
      <ExercicioAchievement>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _businessService.initialize();
      await fetchData();
      _initAchievements();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao inicializar serviços: $e');
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
        description: 'Registre exercícios em 7 dias consecutivos',
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

  Future<void> fetchData() async {
    try {
      isLoading.value = true;

      // Carregar registros
      registros.value = await _businessService.carregarExercicios();

      // Carregar metas
      final metas = await _businessService.carregarMetas();
      metaMinutosSemanal.value = metas['minutos']!;
      metaCaloriasSemanal.value = metas['calorias']!;

      // Calcular totais da semana atual
      _calcularTotaisSemana();

      // Atualizar conquistas
      _atualizarAchievements();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar dados de exercícios: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calcularTotaisSemana() {
    final totais = _statisticsService.calcularTotaisSemana(registros);
    totalMinutosSemana.value = totais['minutos']!;
    totalCaloriasSemana.value = totais['calorias']!;
  }

  void _atualizarAchievements() {
    achievements.value = _achievementService.avaliarConquistas(
      registros,
      metaMinutosSemanal.value,
      metaCaloriasSemanal.value,
    );
  }


  Future<void> addRegistro(ExercicioModel exercicio) async {
    try {
      isLoading.value = true;

      final savedExercicio = await _businessService.salvarExercicio(exercicio);
      registros.add(savedExercicio);

      // Invalidar cache quando dados mudam
      ExercicioCacheService.invalidateOnDataChange();

      // Atualizar cálculos
      _calcularTotaisSemana();
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Exercício registrado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao registrar exercício: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRegistro(ExercicioModel exercicio) async {
    try {
      isLoading.value = true;

      final savedExercicio = await _businessService.salvarExercicio(exercicio);

      final index = registros.indexWhere((r) => r.id == exercicio.id);
      if (index != -1) {
        registros[index] = savedExercicio;
      }

      // Invalidar cache quando dados mudam
      ExercicioCacheService.invalidateOnDataChange();

      // Atualizar cálculos
      _calcularTotaisSemana();
      _atualizarAchievements();

      Get.snackbar('Sucesso', 'Exercício atualizado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao atualizar exercício: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRegistro(ExercicioModel exercicio) async {
    try {
      isLoading.value = true;

      if (exercicio.id != null) {
        await _businessService.excluirExercicio(exercicio.id!);

        registros.removeWhere((r) => r.id == exercicio.id);

        // Invalidar cache quando dados mudam
        ExercicioCacheService.invalidateOnDataChange();

        // Atualizar cálculos
        _calcularTotaisSemana();
        _atualizarAchievements();

        Get.snackbar('Sucesso', 'Exercício excluído com sucesso!');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao excluir exercício: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveMetaExercicios(
      double minutosSemanal, double caloriasSemanal) async {
    try {
      await _businessService.salvarMetas(minutosSemanal, caloriasSemanal);

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
      'Dê ao seu corpo tempo para recuperar-se entre as sessões de treino intenso.',
    ];

    // Selecionar uma dica baseada no dia do ano
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }
}
