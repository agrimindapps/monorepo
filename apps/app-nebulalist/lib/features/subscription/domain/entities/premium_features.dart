import 'package:equatable/equatable.dart';

/// Features premium disponíveis no Nebulalist
class PremiumFeatures extends Equatable {
  const PremiumFeatures({
    this.unlimitedLists = false,
    this.unlimitedTasks = false,
    this.cloudSync = false,
    this.sharedLists = false,
    this.smartReminders = false,
    this.advancedCategories = false,
    this.detailedStatistics = false,
    this.premiumThemes = false,
    this.dataExport = false,
    this.prioritySupport = false,
    this.offlineMode = false,
    this.recurringTasks = false,
  });

  /// Listas ilimitadas
  final bool unlimitedLists;

  /// Tarefas ilimitadas
  final bool unlimitedTasks;

  /// Sincronização na nuvem
  final bool cloudSync;

  /// Listas compartilhadas
  final bool sharedLists;

  /// Lembretes inteligentes (localização, contexto)
  final bool smartReminders;

  /// Categorias e tags avançadas
  final bool advancedCategories;

  /// Estatísticas detalhadas
  final bool detailedStatistics;

  /// Temas premium nebula
  final bool premiumThemes;

  /// Exportação de dados
  final bool dataExport;

  /// Suporte prioritário
  final bool prioritySupport;

  /// Modo offline avançado
  final bool offlineMode;

  /// Tarefas recorrentes
  final bool recurringTasks;

  /// Todas as features ativadas
  static const PremiumFeatures all = PremiumFeatures(
    unlimitedLists: true,
    unlimitedTasks: true,
    cloudSync: true,
    sharedLists: true,
    smartReminders: true,
    advancedCategories: true,
    detailedStatistics: true,
    premiumThemes: true,
    dataExport: true,
    prioritySupport: true,
    offlineMode: true,
    recurringTasks: true,
  );

  /// Nenhuma feature (plano gratuito)
  static const PremiumFeatures none = PremiumFeatures();

  /// Features básicas (plano gratuito com algumas features)
  static const PremiumFeatures basic = PremiumFeatures(
    offlineMode: true,
  );

  @override
  List<Object?> get props => [
        unlimitedLists,
        unlimitedTasks,
        cloudSync,
        sharedLists,
        smartReminders,
        advancedCategories,
        detailedStatistics,
        premiumThemes,
        dataExport,
        prioritySupport,
        offlineMode,
        recurringTasks,
      ];

  PremiumFeatures copyWith({
    bool? unlimitedLists,
    bool? unlimitedTasks,
    bool? cloudSync,
    bool? sharedLists,
    bool? smartReminders,
    bool? advancedCategories,
    bool? detailedStatistics,
    bool? premiumThemes,
    bool? dataExport,
    bool? prioritySupport,
    bool? offlineMode,
    bool? recurringTasks,
  }) {
    return PremiumFeatures(
      unlimitedLists: unlimitedLists ?? this.unlimitedLists,
      unlimitedTasks: unlimitedTasks ?? this.unlimitedTasks,
      cloudSync: cloudSync ?? this.cloudSync,
      sharedLists: sharedLists ?? this.sharedLists,
      smartReminders: smartReminders ?? this.smartReminders,
      advancedCategories: advancedCategories ?? this.advancedCategories,
      detailedStatistics: detailedStatistics ?? this.detailedStatistics,
      premiumThemes: premiumThemes ?? this.premiumThemes,
      dataExport: dataExport ?? this.dataExport,
      prioritySupport: prioritySupport ?? this.prioritySupport,
      offlineMode: offlineMode ?? this.offlineMode,
      recurringTasks: recurringTasks ?? this.recurringTasks,
    );
  }
}

/// Limites de uso baseados no tipo de plano
class UsageLimits extends Equatable {
  const UsageLimits({
    this.maxLists = 5,
    this.maxTasksPerList = 20,
    this.maxCategories = 3,
    this.maxSharedUsers = 0,
    this.maxReminders = 5,
    this.isUnlimited = false,
  });

  /// Máximo de listas
  final int maxLists;

  /// Máximo de tarefas por lista
  final int maxTasksPerList;

  /// Máximo de categorias
  final int maxCategories;

  /// Máximo de usuários por lista compartilhada
  final int maxSharedUsers;

  /// Máximo de lembretes ativos
  final int maxReminders;

  /// Se é ilimitado (premium)
  final bool isUnlimited;

  /// Limites premium (ilimitado)
  static const UsageLimits premium = UsageLimits(
    maxLists: -1, // -1 = ilimitado
    maxTasksPerList: -1,
    maxCategories: -1,
    maxSharedUsers: 10,
    maxReminders: -1,
    isUnlimited: true,
  );

  /// Limites gratuitos
  static const UsageLimits free = UsageLimits(
    maxLists: 5,
    maxTasksPerList: 20,
    maxCategories: 3,
    maxSharedUsers: 0,
    maxReminders: 5,
    isUnlimited: false,
  );

  @override
  List<Object?> get props => [
        maxLists,
        maxTasksPerList,
        maxCategories,
        maxSharedUsers,
        maxReminders,
        isUnlimited,
      ];
}
