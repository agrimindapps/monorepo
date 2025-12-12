import 'package:core/core.dart' show Equatable;

/// Entidade que representa as features premium disponíveis no Plantis
class PremiumFeatures extends Equatable {
  const PremiumFeatures({
    required this.unlimitedPlants,
    required this.advancedCareReminders,
    required this.plantIdentification,
    required this.expertAdvice,
    required this.weatherIntegration,
    required this.unlimitedPhotoStorage,
    required this.customSpaces,
    required this.advancedAnalytics,
    required this.exportData,
    required this.cloudBackup,
    required this.diseaseDetection,
    required this.growthTracking,
    required this.communityFeatures,
    required this.premiumSupport,
  });

  /// Permite plantas ilimitadas (vs limite de 10 no free)
  final bool unlimitedPlants;

  /// Lembretes avançados de cuidados (rega, fertilização, etc)
  final bool advancedCareReminders;

  /// Identificação de plantas por foto com AI
  final bool plantIdentification;

  /// Consultas com especialistas em jardinagem
  final bool expertAdvice;

  /// Integração com previsão do tempo para cuidados
  final bool weatherIntegration;

  /// Armazenamento ilimitado de fotos das plantas
  final bool unlimitedPhotoStorage;

  /// Criação de espaços personalizados (jardim, varanda, etc)
  final bool customSpaces;

  /// Analytics avançados de crescimento e saúde
  final bool advancedAnalytics;

  /// Exportação de dados em múltiplos formatos
  final bool exportData;

  /// Backup automático na nuvem
  final bool cloudBackup;

  /// Detecção de doenças e pragas por foto
  final bool diseaseDetection;

  /// Rastreamento de crescimento com fotos e medições
  final bool growthTracking;

  /// Acesso a comunidade premium e fóruns
  final bool communityFeatures;

  /// Suporte premium com prioridade
  final bool premiumSupport;

  /// Features premium completas (todas habilitadas)
  static const PremiumFeatures all = PremiumFeatures(
    unlimitedPlants: true,
    advancedCareReminders: true,
    plantIdentification: true,
    expertAdvice: true,
    weatherIntegration: true,
    unlimitedPhotoStorage: true,
    customSpaces: true,
    advancedAnalytics: true,
    exportData: true,
    cloudBackup: true,
    diseaseDetection: true,
    growthTracking: true,
    communityFeatures: true,
    premiumSupport: true,
  );

  /// Features gratuitas (todas desabilitadas)
  static const PremiumFeatures none = PremiumFeatures(
    unlimitedPlants: false,
    advancedCareReminders: false,
    plantIdentification: false,
    expertAdvice: false,
    weatherIntegration: false,
    unlimitedPhotoStorage: false,
    customSpaces: false,
    advancedAnalytics: false,
    exportData: false,
    cloudBackup: false,
    diseaseDetection: false,
    growthTracking: false,
    communityFeatures: false,
    premiumSupport: false,
  );

  @override
  List<Object?> get props => [
    unlimitedPlants,
    advancedCareReminders,
    plantIdentification,
    expertAdvice,
    weatherIntegration,
    unlimitedPhotoStorage,
    customSpaces,
    advancedAnalytics,
    exportData,
    cloudBackup,
    diseaseDetection,
    growthTracking,
    communityFeatures,
    premiumSupport,
  ];

  PremiumFeatures copyWith({
    bool? unlimitedPlants,
    bool? advancedCareReminders,
    bool? plantIdentification,
    bool? expertAdvice,
    bool? weatherIntegration,
    bool? unlimitedPhotoStorage,
    bool? customSpaces,
    bool? advancedAnalytics,
    bool? exportData,
    bool? cloudBackup,
    bool? diseaseDetection,
    bool? growthTracking,
    bool? communityFeatures,
    bool? premiumSupport,
  }) {
    return PremiumFeatures(
      unlimitedPlants: unlimitedPlants ?? this.unlimitedPlants,
      advancedCareReminders:
          advancedCareReminders ?? this.advancedCareReminders,
      plantIdentification: plantIdentification ?? this.plantIdentification,
      expertAdvice: expertAdvice ?? this.expertAdvice,
      weatherIntegration: weatherIntegration ?? this.weatherIntegration,
      unlimitedPhotoStorage:
          unlimitedPhotoStorage ?? this.unlimitedPhotoStorage,
      customSpaces: customSpaces ?? this.customSpaces,
      advancedAnalytics: advancedAnalytics ?? this.advancedAnalytics,
      exportData: exportData ?? this.exportData,
      cloudBackup: cloudBackup ?? this.cloudBackup,
      diseaseDetection: diseaseDetection ?? this.diseaseDetection,
      growthTracking: growthTracking ?? this.growthTracking,
      communityFeatures: communityFeatures ?? this.communityFeatures,
      premiumSupport: premiumSupport ?? this.premiumSupport,
    );
  }
}

/// Limites de uso baseados no status premium
class UsageLimits extends Equatable {
  const UsageLimits({
    required this.maxPlants,
    required this.maxPhotosPerPlant,
    required this.maxSpaces,
    required this.maxComments,
  });

  /// Número máximo de plantas
  final int maxPlants;

  /// Número máximo de fotos por planta
  final int maxPhotosPerPlant;

  /// Número máximo de espaços personalizados
  final int maxSpaces;

  /// Número máximo de comentários/notas
  final int maxComments;

  /// Limites para usuários premium (ilimitados)
  static const UsageLimits premium = UsageLimits(
    maxPlants: -1, // -1 = ilimitado
    maxPhotosPerPlant: -1,
    maxSpaces: -1,
    maxComments: -1,
  );

  /// Limites para usuários gratuitos
  static const UsageLimits free = UsageLimits(
    maxPlants: 10,
    maxPhotosPerPlant: 5,
    maxSpaces: 2,
    maxComments: 50,
  );

  /// Se tem limite ilimitado
  bool get isUnlimited => maxPlants == -1;

  @override
  List<Object?> get props => [
    maxPlants,
    maxPhotosPerPlant,
    maxSpaces,
    maxComments,
  ];

  UsageLimits copyWith({
    int? maxPlants,
    int? maxPhotosPerPlant,
    int? maxSpaces,
    int? maxComments,
  }) {
    return UsageLimits(
      maxPlants: maxPlants ?? this.maxPlants,
      maxPhotosPerPlant: maxPhotosPerPlant ?? this.maxPhotosPerPlant,
      maxSpaces: maxSpaces ?? this.maxSpaces,
      maxComments: maxComments ?? this.maxComments,
    );
  }
}
