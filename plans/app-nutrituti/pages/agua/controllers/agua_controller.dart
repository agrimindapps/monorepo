// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/achievement_model.dart';
import '../models/beber_agua_model.dart';
import '../repository/agua_repository.dart';

class AguaController extends GetxController {
  final AguaRepository repository = AguaRepository();

  // Variáveis observáveis
  final RxDouble dailyWaterGoal = 2000.0.obs;
  final RxDouble todayProgress = 0.0.obs;
  final RxList<BeberAgua> registros = <BeberAgua>[].obs;
  final RxList<WaterAchievement> achievements = <WaterAchievement>[].obs;
  final RxBool isLoading = false.obs;

  // Dicas de saúde relacionadas à água
  final List<String> healthTips = [
    'Beber água ajuda a melhorar a concentração',
    'A hidratação é essencial para a saúde da pele',
    'Beba água antes, durante e depois de exercícios',
    'Água ajuda no funcionamento do intestino',
    'Mantenha uma garrafa de água sempre por perto',
  ];

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    initAchievements();
    scheduleReminders();
  }

  // Inicializar as conquistas disponíveis
  void initAchievements() {
    achievements.value = [
      WaterAchievement(
        title: '🌱 Iniciante',
        description: 'Registrou água por 3 dias seguidos',
      ),
      WaterAchievement(
        title: '💧 Hidratado',
        description: 'Atingiu a meta diária 7 dias seguidos',
      ),
      WaterAchievement(
        title: '🌊 Mestre da Hidratação',
        description: 'Completou 30 dias seguidos',
      ),
    ];

    loadUnlockedAchievements();
  }

  // Carregar conquistas desbloqueadas
  Future<void> loadUnlockedAchievements() async {
    List<String> unlockedAchievements =
        await repository.getUnlockedAchievements();

    for (var achievement in achievements) {
      if (unlockedAchievements.contains(achievement.title)) {
        achievement.unlock();
      }
    }
  }

  // Carregar dados iniciais
  Future<void> loadInitialData() async {
    isLoading.value = true;

    try {
      dailyWaterGoal.value = await repository.getDailyGoal();
      todayProgress.value = await repository.getTodayProgress();
      await loadRegistros();
      checkAndUpdateStreak();
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Carregar registros do repositório
  Future<void> loadRegistros() async {
    registros.value = await repository.getAll();
  }

  // Adicionar novo registro de água
  Future<void> addRegistro(BeberAgua registro) async {
    await repository.add(registro);
    await repository.updateTodayProgress(registro.quantidade);
    todayProgress.value = await repository.getTodayProgress();
    await loadRegistros();
    checkGoalAchievement();
  }

  // Atualizar registro existente
  Future<void> updateRegistro(BeberAgua registro) async {
    await repository.updated(registro);
    await loadRegistros();
  }

  // Deletar registro
  Future<void> deleteRegistro(BeberAgua registro) async {
    await repository.delete(registro);
    await loadRegistros();
  }

  // Atualizar meta diária
  Future<void> updateDailyGoal(double newGoal) async {
    await repository.setDailyGoal(newGoal);
    dailyWaterGoal.value = newGoal;
  }

  // Verificar e atualizar sequência de dias
  Future<void> checkAndUpdateStreak() async {
    final lastUpdate = await repository.getLastUpdate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastUpdate != null) {
      final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final yesterday = DateTime(today.year, today.month, today.day - 1);

      if (lastUpdateDate.isBefore(yesterday)) {
        // Reiniciar sequência se passou mais de um dia
        await repository.resetStreak();
      }
    }

    // Atualizar data da última atualização
    await repository.setLastUpdate(today.millisecondsSinceEpoch);
  }

  // Verificar conquistas baseadas na meta
  Future<void> checkGoalAchievement() async {
    if (todayProgress.value >= dailyWaterGoal.value) {
      int currentStreak = await repository.incrementStreak();

      // Verificar e desbloquear conquistas baseadas na sequência
      if (currentStreak >= 3) {
        unlockAchievement('🌱 Iniciante');
      }

      if (currentStreak >= 7) {
        unlockAchievement('💧 Hidratado');
      }

      if (currentStreak >= 30) {
        unlockAchievement('🌊 Mestre da Hidratação');
      }
    }
  }

  // Desbloquear uma conquista
  Future<void> unlockAchievement(String title) async {
    int index = achievements.indexWhere((a) => a.title == title);
    if (index != -1 && !achievements[index].isUnlocked) {
      achievements[index].unlock();
      await repository.addUnlockedAchievement(title);
      update(); // Notificar aos ouvintes que houve alteração
    }
  }

  // Agendar lembretes para beber água
  void scheduleReminders() {
    // Implementação futura para notificações
  }

  // Obter dica do dia
  String getTipOfTheDay() {
    return healthTips[DateTime.now().day % healthTips.length];
  }
}
