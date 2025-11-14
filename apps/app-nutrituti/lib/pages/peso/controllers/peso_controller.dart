// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../drift_database/nutrituti_database.dart';
import '../../../../core/services/firebase_firestore_service.dart';
import '../models/achievement_model.dart';
import '../models/peso_model.dart';
import '../repository/peso_repository.dart';

part 'peso_controller.g.dart';

/// State class for Peso feature
class PesoState {
  final double pesoMeta;
  final double pesoAtual;
  final double pesoInicial;
  final List<PesoModel> registros;
  final List<WeightAchievement> achievements;
  final bool isLoading;

  const PesoState({
    this.pesoMeta = 0.0,
    this.pesoAtual = 0.0,
    this.pesoInicial = 0.0,
    this.registros = const [],
    this.achievements = const [],
    this.isLoading = false,
  });

  PesoState copyWith({
    double? pesoMeta,
    double? pesoAtual,
    double? pesoInicial,
    List<PesoModel>? registros,
    List<WeightAchievement>? achievements,
    bool? isLoading,
  }) {
    return PesoState(
      pesoMeta: pesoMeta ?? this.pesoMeta,
      pesoAtual: pesoAtual ?? this.pesoAtual,
      pesoInicial: pesoInicial ?? this.pesoInicial,
      registros: registros ?? this.registros,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for PesoRepository
@riverpod
PesoRepository pesoRepository(PesoRepositoryRef ref) {
  return PesoRepository(
    FirestoreService(FirebaseFirestore.instance),
    GetIt.I<NutitutiDatabase>(),
  );
}

/// Main Peso Notifier
@riverpod
class PesoNotifier extends _$PesoNotifier {
  // Dicas de saúde relacionadas ao peso
  static const List<String> healthTips = [
    'Exercícios regulares são essenciais para a perda de peso saudável',
    'Uma boa hidratação ajuda no controle do peso',
    'Dormir bem é importante para o metabolismo',
    'Priorize alimentos naturais em vez de processados',
    'Estabelecer metas realistas aumenta suas chances de sucesso',
  ];

  @override
  Future<PesoState> build() async {
    try {
      final repository = ref.watch(pesoRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();

      // Load registros
      final registros = await repository.getAll();

      // Load peso meta
      final pesoMeta = prefs.getDouble('peso_meta') ?? 0.0;

      // Load peso inicial
      double pesoInicial = prefs.getDouble('peso_inicial') ?? 0.0;

      // If no peso inicial saved and registros exist, use first registro
      if (pesoInicial == 0.0 && registros.isNotEmpty) {
        var registrosOrdenados = [...registros]
          ..sort((a, b) => a.dataRegistro.compareTo(b.dataRegistro));

        if (registrosOrdenados.isNotEmpty) {
          pesoInicial = registrosOrdenados.first.peso;
          await prefs.setDouble('peso_inicial', pesoInicial);
        }
      }

      // Calculate current peso
      double pesoAtual = 0.0;
      if (registros.isNotEmpty) {
        var registrosOrdenados = [...registros]
          ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));

        if (registrosOrdenados.isNotEmpty) {
          pesoAtual = registrosOrdenados.first.peso;
        }
      }

      // Initialize achievements
      final achievements = await _initializeAchievements(
        registros,
        pesoMeta,
        pesoAtual,
        pesoInicial,
      );

      return PesoState(
        pesoMeta: pesoMeta,
        pesoAtual: pesoAtual,
        pesoInicial: pesoInicial,
        registros: registros,
        achievements: achievements,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      return const PesoState();
    }
  }

  /// Initialize achievements
  Future<List<WeightAchievement>> _initializeAchievements(
    List<PesoModel> registros,
    double pesoMeta,
    double pesoAtual,
    double pesoInicial,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedAchievements =
        prefs.getStringList('weight_achievements') ?? [];

    final achievements = [
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

    for (var achievement in achievements) {
      if (unlockedAchievements.contains(achievement.title)) {
        achievement.unlock();
      }
    }

    return achievements;
  }

  /// Add new peso registro
  Future<void> addRegistro(PesoModel registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(pesoRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();

      await repository.add(registro);
      final updatedRegistros = await repository.getAll();

      // Update current peso
      double pesoAtual = currentState.pesoAtual;
      if (updatedRegistros.isNotEmpty) {
        var registrosOrdenados = [...updatedRegistros]
          ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));

        if (registrosOrdenados.isNotEmpty) {
          pesoAtual = registrosOrdenados.first.peso;
        }
      }

      // If first registro, set as peso inicial
      double pesoInicial = currentState.pesoInicial;
      if (pesoInicial == 0.0) {
        pesoInicial = registro.peso;
        await prefs.setDouble('peso_inicial', pesoInicial);
      }

      final updatedState = currentState.copyWith(
        registros: updatedRegistros,
        pesoAtual: pesoAtual,
        pesoInicial: pesoInicial,
        isLoading: false,
      );

      state = AsyncValue.data(updatedState);
      await _checkProgressAchievements();
    } catch (e) {
      debugPrint('Erro ao adicionar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Update existing registro
  Future<void> updateRegistro(PesoModel registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(pesoRepositoryProvider);

      await repository.updated(registro);
      final updatedRegistros = await repository.getAll();

      // Update current peso
      double pesoAtual = currentState.pesoAtual;
      if (updatedRegistros.isNotEmpty) {
        var registrosOrdenados = [...updatedRegistros]
          ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));

        if (registrosOrdenados.isNotEmpty) {
          pesoAtual = registrosOrdenados.first.peso;
        }
      }

      state = AsyncValue.data(
        currentState.copyWith(
          registros: updatedRegistros,
          pesoAtual: pesoAtual,
          isLoading: false,
        ),
      );

      await _checkProgressAchievements();
    } catch (e) {
      debugPrint('Erro ao atualizar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Delete registro
  Future<void> deleteRegistro(PesoModel registro) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final repository = ref.read(pesoRepositoryProvider);

      await repository.delete(registro);
      final updatedRegistros = await repository.getAll();

      // Update current peso
      double pesoAtual = currentState.pesoAtual;
      if (updatedRegistros.isNotEmpty) {
        var registrosOrdenados = [...updatedRegistros]
          ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));

        if (registrosOrdenados.isNotEmpty) {
          pesoAtual = registrosOrdenados.first.peso;
        }
      }

      state = AsyncValue.data(
        currentState.copyWith(
          registros: updatedRegistros,
          pesoAtual: pesoAtual,
          isLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('Erro ao deletar registro: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Save peso meta
  Future<void> saveMetaPeso(double meta) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('peso_meta', meta);

      state = AsyncValue.data(
        currentState.copyWith(pesoMeta: meta, isLoading: false),
      );
    } catch (e) {
      debugPrint('Erro ao salvar meta de peso: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Save peso inicial
  Future<void> savePesoInicial(double peso) async {
    final currentState = await future;
    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('peso_inicial', peso);

      state = AsyncValue.data(
        currentState.copyWith(pesoInicial: peso, isLoading: false),
      );
    } catch (e) {
      debugPrint('Erro ao salvar peso inicial: $e');
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  /// Check progress achievements
  Future<void> _checkProgressAchievements() async {
    final currentState = await future;

    // Check consistency achievement
    await _checkConsistencyAchievement(currentState.registros);

    // Check percentage of weight lost
    if (currentState.pesoInicial > 0 && currentState.pesoAtual > 0) {
      double percentageLost =
          ((currentState.pesoInicial - currentState.pesoAtual) /
              currentState.pesoInicial) *
          100;

      if (percentageLost >= 5) {
        await unlockAchievement('🏃 Em Progresso');
      }
    }

    // Check if meta reached
    if (currentState.pesoMeta > 0 &&
        currentState.pesoAtual <= currentState.pesoMeta) {
      await unlockAchievement('🏆 Meta Alcançada');
    }
  }

  /// Check consistency achievement (consecutive days)
  Future<void> _checkConsistencyAchievement(List<PesoModel> registros) async {
    if (registros.length >= 7) {
      // Check if at least 7 registros on different days
      var registrosOrdenados = [...registros]
        ..sort((a, b) => a.dataRegistro.compareTo(b.dataRegistro));

      Set<String> uniqueDays = {};

      for (var registro in registrosOrdenados) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(
          registro.dataRegistro,
        );
        String dayKey = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dayKey);
      }

      if (uniqueDays.length >= 7) {
        await unlockAchievement('🌱 Primeiro Passo');
      }
    }
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String title) async {
    final currentState = await future;
    final achievements = [...currentState.achievements];

    final index = achievements.indexWhere((a) => a.title == title);
    if (index != -1 && !achievements[index].isUnlocked) {
      achievements[index].unlock();

      // Save unlocked achievement
      final prefs = await SharedPreferences.getInstance();
      List<String> unlockedAchievements =
          prefs.getStringList('weight_achievements') ?? [];

      if (!unlockedAchievements.contains(title)) {
        unlockedAchievements.add(title);
        await prefs.setStringList('weight_achievements', unlockedAchievements);
      }

      state = AsyncValue.data(
        currentState.copyWith(achievements: achievements),
      );
    }
  }

  /// Get tip of the day
  String getTipOfTheDay() {
    return healthTips[DateTime.now().day % healthTips.length];
  }

  /// Calculate IMC (Body Mass Index)
  double calculateIMC(double peso, double altura) {
    if (altura <= 0) return 0;
    return peso / (altura * altura);
  }

  /// Get IMC classification
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
