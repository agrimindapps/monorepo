// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../models/achievement_model.dart';
import '../models/peso_model.dart';
import '../repository/peso_repository.dart';

class PesoController extends GetxController {
  final PesoRepository repository = PesoRepository();

  // Variáveis observáveis
  final RxDouble pesoMeta = 0.0.obs;
  final RxDouble pesoAtual = 0.0.obs;
  final RxDouble pesoInicial = 0.0.obs;
  final RxList<PesoModel> registros = <PesoModel>[].obs;
  final RxList<WeightAchievement> achievements = <WeightAchievement>[].obs;
  final RxBool isLoading = false.obs;

  // Dicas de saúde relacionadas ao peso
  final List<String> healthTips = [
    'Exercícios regulares são essenciais para a perda de peso saudável',
    'Uma boa hidratação ajuda no controle do peso',
    'Dormir bem é importante para o metabolismo',
    'Priorize alimentos naturais em vez de processados',
    'Estabelecer metas realistas aumenta suas chances de sucesso',
  ];

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    initAchievements();
  }

  // Inicializar as conquistas disponíveis
  void initAchievements() {
    achievements.value = [
      WeightAchievement(
        title: '🌱 Primeiro Passo',
        description: 'Registrou seu peso por 7 dias seguidos',
      ),
      WeightAchievement(
        title: '🏃 Em Progresso',
        description: 'Perdeu 5% do seu peso inicial',
      ),
      WeightAchievement(
        title: '🏆 Meta Alcançada',
        description: 'Alcançou seu peso meta',
      ),
    ];

    loadUnlockedAchievements();
  }

  // Carregar conquistas desbloqueadas
  Future<void> loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedAchievements =
        prefs.getStringList('weight_achievements') ?? [];

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
      await loadRegistros();
      await loadMetaPeso();
      await loadPesoInicial();
      updatePesoAtual();
      checkProgressAchievements();
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

  // Carregar meta de peso das preferências
  Future<void> loadMetaPeso() async {
    final prefs = await SharedPreferences.getInstance();
    pesoMeta.value = prefs.getDouble('peso_meta') ?? 0.0;
  }

  // Carregar peso inicial das preferências
  Future<void> loadPesoInicial() async {
    final prefs = await SharedPreferences.getInstance();
    pesoInicial.value = prefs.getDouble('peso_inicial') ?? 0.0;

    // Se não tiver peso inicial salvo e existirem registros, usa o primeiro registro
    if (pesoInicial.value == 0.0 && registros.isNotEmpty) {
      var registrosOrdenados = [...registros]
        ..sort((a, b) => a.dataRegistro.compareTo(b.dataRegistro));

      if (registrosOrdenados.isNotEmpty) {
        pesoInicial.value = registrosOrdenados.first.peso;
        savePesoInicial(pesoInicial.value);
      }
    }
  }

  // Atualizar o peso atual com o registro mais recente
  void updatePesoAtual() {
    if (registros.isNotEmpty) {
      var registrosOrdenados = [...registros]
        ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));

      if (registrosOrdenados.isNotEmpty) {
        pesoAtual.value = registrosOrdenados.first.peso;
      }
    }
  }

  // Adicionar novo registro de peso
  Future<void> addRegistro(PesoModel registro) async {
    await repository.add(registro);
    await loadRegistros();
    updatePesoAtual();

    // Se for o primeiro registro, define como peso inicial
    if (pesoInicial.value == 0.0) {
      pesoInicial.value = registro.peso;
      savePesoInicial(pesoInicial.value);
    }

    checkProgressAchievements();
  }

  // Atualizar registro existente
  Future<void> updateRegistro(PesoModel registro) async {
    await repository.updated(registro);
    await loadRegistros();
    updatePesoAtual();
    checkProgressAchievements();
  }

  // Deletar registro
  Future<void> deleteRegistro(PesoModel registro) async {
    await repository.delete(registro);
    await loadRegistros();
    updatePesoAtual();
  }

  // Salvar meta de peso
  Future<void> saveMetaPeso(double meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('peso_meta', meta);
    pesoMeta.value = meta;
  }

  // Salvar peso inicial
  Future<void> savePesoInicial(double peso) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('peso_inicial', peso);
    pesoInicial.value = peso;
  }

  // Verificar conquistas baseadas no progresso
  Future<void> checkProgressAchievements() async {
    // Verificar sequência de registros
    checkConsistencyAchievement();

    // Verificar porcentagem de perda de peso
    if (pesoInicial.value > 0 && pesoAtual.value > 0) {
      double percentageLost =
          ((pesoInicial.value - pesoAtual.value) / pesoInicial.value) * 100;

      if (percentageLost >= 5) {
        unlockAchievement('🏃 Em Progresso');
      }
    }

    // Verificar se alcançou a meta
    if (pesoMeta.value > 0 && pesoAtual.value <= pesoMeta.value) {
      unlockAchievement('🏆 Meta Alcançada');
    }
  }

  // Verifica a consistência de registros (dias seguidos)
  Future<void> checkConsistencyAchievement() async {
    if (registros.length >= 7) {
      // Verifica se há pelo menos 7 registros em dias diferentes
      var registrosOrdenados = [...registros]
        ..sort((a, b) => a.dataRegistro.compareTo(b.dataRegistro));

      Set<String> uniqueDays = {};

      for (var registro in registrosOrdenados) {
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        String dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dayKey);
      }

      if (uniqueDays.length >= 7) {
        unlockAchievement('🌱 Primeiro Passo');
      }
    }
  }

  // Desbloquear uma conquista
  Future<void> unlockAchievement(String title) async {
    int index = achievements.indexWhere((a) => a.title == title);
    if (index != -1 && !achievements[index].isUnlocked) {
      achievements[index].unlock();

      // Salvar conquista desbloqueada
      final prefs = await SharedPreferences.getInstance();
      List<String> unlockedAchievements =
          prefs.getStringList('weight_achievements') ?? [];

      if (!unlockedAchievements.contains(title)) {
        unlockedAchievements.add(title);
        await prefs.setStringList('weight_achievements', unlockedAchievements);
      }

      update(); // Notificar aos ouvintes que houve alteração
    }
  }

  // Obter dica do dia
  String getTipOfTheDay() {
    return healthTips[DateTime.now().day % healthTips.length];
  }

  // Calcular IMC (Índice de Massa Corporal)
  double calculateIMC(double peso, double altura) {
    if (altura <= 0) return 0;
    return peso / (altura * altura);
  }

  // Obter classificação do IMC
  String getIMCClassification(double imc) {
    if (imc < 18.5) {
      return 'Abaixo do Peso';
    } else if (imc >= 18.5 && imc < 25) {
      return 'Peso Normal';
    } else if (imc >= 25 && imc < 30) {
      return 'Sobrepeso';
    } else if (imc >= 30 && imc < 35) {
      return 'Obesidade Grau I';
    } else if (imc >= 35 && imc < 40) {
      return 'Obesidade Grau II';
    } else {
      return 'Obesidade Grau III';
    }
  }
}
