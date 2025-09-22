import 'package:core/core.dart';
import '../weight.dart';

/// Entidade Weight para sincronização
/// Dados de monitoramento de peso com funcionalidades específicas:
/// - Health tracking para tendências de peso
/// - Single-user weight management (usuário único)
/// - Offline-first para registros frequentes
/// - Alertas para mudanças significativas de peso
class WeightSyncEntity extends BaseSyncEntity {
  const WeightSyncEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
    required this.animalId,
    required this.weight,
    required this.date,
    this.notes,
    this.bodyConditionScore,
    this.measurementMethod = WeightMeasurementMethod.scale,
    this.accuracy = WeightAccuracy.normal,
    this.environmentalFactors = const [],
    this.vetRecommendedWeight,
    this.isTargetWeight = false,
    this.previousWeight,
    this.weightGoalId,
    this.photosUrls = const [],
    this.measurements = const {},
  });

  /// Informações básicas do peso
  final String animalId;
  final double weight; // in kg
  final DateTime date;
  final String? notes;
  final int? bodyConditionScore; // 1-9 scale (1 = underweight, 5 = ideal, 9 = obese)

  /// Informações de registro (single user)
  final WeightMeasurementMethod measurementMethod;
  final WeightAccuracy accuracy;
  final List<String> environmentalFactors; // ['after_meal', 'morning', 'after_exercise', etc.]

  /// Informações veterinárias
  final double? vetRecommendedWeight;
  final bool isTargetWeight; // Se é um peso meta
  final double? previousWeight; // Para cálculo rápido de diferença
  final String? weightGoalId; // Relacionado a um plano de peso

  /// Mídia e medições adicionais
  final List<String> photosUrls; // Fotos do animal na pesagem
  final Map<String, double> measurements; // {'chest': 45.0, 'neck': 25.0} em cm

  /// Getters computados para compatibilidade
  BodyCondition get bodyCondition {
    if (bodyConditionScore == null) return BodyCondition.unknown;

    if (bodyConditionScore! <= 3) return BodyCondition.underweight;
    if (bodyConditionScore! <= 6) return BodyCondition.ideal;
    return BodyCondition.overweight;
  }

  String get formattedWeight {
    return '${weight.toStringAsFixed(2)} kg';
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    return difference <= 7;
  }

  /// Getters específicos de pet care
  bool get hasPhotos => photosUrls.isNotEmpty;
  bool get hasAdditionalMeasurements => measurements.isNotEmpty;
  bool get isVetRecommended => vetRecommendedWeight != null;
  bool get isSignificantChange {
    if (previousWeight == null) return false;
    final difference = (weight - previousWeight!).abs();
    return difference >= 0.1; // 100g ou mais
  }

  WeightTrend get trend {
    if (previousWeight == null) return WeightTrend.stable;
    final difference = weight - previousWeight!;
    if (difference > 0.05) return WeightTrend.gaining;
    if (difference < -0.05) return WeightTrend.losing;
    return WeightTrend.stable;
  }

  double? get weightDifference {
    if (previousWeight == null) return null;
    return weight - previousWeight!;
  }

  double? get percentageChange {
    if (previousWeight == null || previousWeight == 0) return null;
    return ((weight - previousWeight!) / previousWeight!) * 100;
  }

  bool get requiresVetAttention {
    if (percentageChange == null) return false;
    return percentageChange!.abs() > 10 || // Mudança de mais de 10%
           bodyCondition == BodyCondition.underweight ||
           bodyCondition == BodyCondition.overweight;
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    final Map<String, dynamic> map = {
      ...baseFirebaseFields,
      'animal_id': animalId,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
      'body_condition_score': bodyConditionScore,

      // Informações de registro
      'measurement_method': measurementMethod.toString().split('.').last,
      'accuracy': accuracy.toString().split('.').last,
      'environmental_factors': environmentalFactors,

      // Informações veterinárias
      'vet_recommended_weight': vetRecommendedWeight,
      'is_target_weight': isTargetWeight,
      'previous_weight': previousWeight,
      'weight_goal_id': weightGoalId,

      // Mídia e medições
      'photos_urls': photosUrls,
      'measurements': measurements,

      // Metadados computados
      'body_condition': bodyCondition.toString().split('.').last,
      'formatted_weight': formattedWeight,
      'is_recent': isRecent,
      'has_photos': hasPhotos,
      'has_additional_measurements': hasAdditionalMeasurements,
      'is_vet_recommended': isVetRecommended,
      'is_significant_change': isSignificantChange,
      'trend': trend.toString().split('.').last,
      'weight_difference': weightDifference,
      'percentage_change': percentageChange,
      'requires_vet_attention': requiresVetAttention,
    };

    // Remover valores nulos
    map.removeWhere((key, value) => value == null);
    return map;
  }

  static WeightSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return WeightSyncEntity(
      id: baseFields['id'],
      createdAt: baseFields['createdAt'],
      updatedAt: baseFields['updatedAt'],
      lastSyncAt: baseFields['lastSyncAt'],
      isDirty: baseFields['isDirty'] ?? false,
      isDeleted: baseFields['isDeleted'] ?? false,
      version: baseFields['version'] ?? 1,
      userId: baseFields['userId'],
      moduleName: baseFields['moduleName'],

      // Campos específicos do peso
      animalId: map['animal_id'] as String,
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      bodyConditionScore: map['body_condition_score'] as int?,

      // Informações de registro
      measurementMethod: _parseWeightMeasurementMethod(map['measurement_method'] as String?),
      accuracy: _parseWeightAccuracy(map['accuracy'] as String?),
      environmentalFactors: (map['environmental_factors'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],

      // Informações veterinárias
      vetRecommendedWeight: (map['vet_recommended_weight'] as num?)?.toDouble(),
      isTargetWeight: map['is_target_weight'] as bool? ?? false,
      previousWeight: (map['previous_weight'] as num?)?.toDouble(),
      weightGoalId: map['weight_goal_id'] as String?,

      // Mídia e medições
      photosUrls: (map['photos_urls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      measurements: Map<String, double>.from(
        (map['measurements'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
    );
  }

  static WeightMeasurementMethod _parseWeightMeasurementMethod(String? methodString) {
    if (methodString == null) return WeightMeasurementMethod.scale;

    try {
      return WeightMeasurementMethod.values.firstWhere(
        (method) => method.toString().split('.').last == methodString,
        orElse: () => WeightMeasurementMethod.scale,
      );
    } catch (e) {
      return WeightMeasurementMethod.scale;
    }
  }

  static WeightAccuracy _parseWeightAccuracy(String? accuracyString) {
    if (accuracyString == null) return WeightAccuracy.normal;

    try {
      return WeightAccuracy.values.firstWhere(
        (accuracy) => accuracy.toString().split('.').last == accuracyString,
        orElse: () => WeightAccuracy.normal,
      );
    } catch (e) {
      return WeightAccuracy.normal;
    }
  }

  @override
  WeightSyncEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? animalId,
    double? weight,
    DateTime? date,
    String? notes,
    int? bodyConditionScore,
    WeightMeasurementMethod? measurementMethod,
    WeightAccuracy? accuracy,
    List<String>? environmentalFactors,
    double? vetRecommendedWeight,
    bool? isTargetWeight,
    double? previousWeight,
    String? weightGoalId,
    List<String>? photosUrls,
    Map<String, double>? measurements,
  }) {
    return WeightSyncEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      animalId: animalId ?? this.animalId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      measurementMethod: measurementMethod ?? this.measurementMethod,
      accuracy: accuracy ?? this.accuracy,
      environmentalFactors: environmentalFactors ?? this.environmentalFactors,
      vetRecommendedWeight: vetRecommendedWeight ?? this.vetRecommendedWeight,
      isTargetWeight: isTargetWeight ?? this.isTargetWeight,
      previousWeight: previousWeight ?? this.previousWeight,
      weightGoalId: weightGoalId ?? this.weightGoalId,
      photosUrls: photosUrls ?? this.photosUrls,
      measurements: measurements ?? this.measurements,
    );
  }

  @override
  WeightSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  WeightSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  WeightSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  WeightSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  WeightSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  WeightSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Adiciona foto
  WeightSyncEntity addPhoto(String photoUrl) {
    if (photosUrls.contains(photoUrl)) return this;

    return copyWith(
      photosUrls: [...photosUrls, photoUrl],
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove foto
  WeightSyncEntity removePhoto(String photoUrl) {
    if (!photosUrls.contains(photoUrl)) return this;

    return copyWith(
      photosUrls: photosUrls.where((url) => url != photoUrl).toList(),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Atualiza medição adicional
  WeightSyncEntity updateMeasurement(String type, double value) {
    final newMeasurements = Map<String, double>.from(measurements);
    newMeasurements[type] = value;

    return copyWith(
      measurements: newMeasurements,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove medição
  WeightSyncEntity removeMeasurement(String type) {
    if (!measurements.containsKey(type)) return this;

    final newMeasurements = Map<String, double>.from(measurements);
    newMeasurements.remove(type);

    return copyWith(
      measurements: newMeasurements,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Adiciona fator ambiental
  WeightSyncEntity addEnvironmentalFactor(String factor) {
    if (environmentalFactors.contains(factor)) return this;

    return copyWith(
      environmentalFactors: [...environmentalFactors, factor],
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Define peso anterior para cálculos
  WeightSyncEntity withPreviousWeight(double previousWeight) {
    return copyWith(
      previousWeight: previousWeight,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca como peso meta
  WeightSyncEntity markAsTarget() {
    return copyWith(
      isTargetWeight: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Converte para entidade Weight legada (para compatibilidade)
  Weight toLegacyWeight() {
    return Weight(
      id: id,
      animalId: animalId,
      weight: weight,
      date: date,
      notes: notes,
      bodyConditionScore: bodyConditionScore,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isDeleted: isDeleted,
    );
  }

  /// Cria WeightSyncEntity a partir de entidade Weight legada
  static WeightSyncEntity fromLegacyWeight(Weight weight, {
    String? userId,
    String? moduleName,
  }) {
    return WeightSyncEntity(
      id: weight.id,
      createdAt: weight.createdAt,
      updatedAt: weight.updatedAt,
      userId: userId,
      moduleName: moduleName ?? 'petiveti',
      animalId: weight.animalId,
      weight: weight.weight,
      date: weight.date,
      notes: weight.notes,
      bodyConditionScore: weight.bodyConditionScore,
      isDirty: true, // Marca como sujo para sync inicial
    );
  }

  /// Calcula diferença em relação a um peso anterior
  WeightDifference? calculateDifference(WeightSyncEntity? previousWeight) {
    if (previousWeight == null) return null;

    final difference = weight - previousWeight.weight;
    final percentageChange = (difference / previousWeight.weight) * 100;
    final daysDifference = date.difference(previousWeight.date).inDays;

    return WeightDifference(
      difference: difference,
      percentageChange: percentageChange,
      daysDifference: daysDifference,
      trend: difference > 0 ? WeightTrend.gaining :
             difference < 0 ? WeightTrend.losing : WeightTrend.stable,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    animalId,
    weight,
    date,
    notes,
    bodyConditionScore,
    measurementMethod,
    accuracy,
    environmentalFactors,
    vetRecommendedWeight,
    isTargetWeight,
    previousWeight,
    weightGoalId,
    photosUrls,
    measurements,
  ];
}

/// Método de medição do peso
enum WeightMeasurementMethod {
  scale,          // Balança comum
  veterinaryScale, // Balança veterinária
  estimate,       // Estimativa visual
  carrierWeigh,   // Pesagem com transporte
  humanScale,     // Balança humana (menos precisa)
}

extension WeightMeasurementMethodExtension on WeightMeasurementMethod {
  String get displayName {
    switch (this) {
      case WeightMeasurementMethod.scale:
        return 'Balança';
      case WeightMeasurementMethod.veterinaryScale:
        return 'Balança Veterinária';
      case WeightMeasurementMethod.estimate:
        return 'Estimativa';
      case WeightMeasurementMethod.carrierWeigh:
        return 'Com Transporte';
      case WeightMeasurementMethod.humanScale:
        return 'Balança Humana';
    }
  }

  double get accuracyFactor {
    switch (this) {
      case WeightMeasurementMethod.scale:
        return 0.95;
      case WeightMeasurementMethod.veterinaryScale:
        return 0.99;
      case WeightMeasurementMethod.estimate:
        return 0.70;
      case WeightMeasurementMethod.carrierWeigh:
        return 0.90;
      case WeightMeasurementMethod.humanScale:
        return 0.85;
    }
  }
}

/// Precisão da medição
enum WeightAccuracy {
  high,    // Muito precisa
  normal,  // Precisão normal
  low,     // Pouco precisa
  estimate // Estimativa
}

extension WeightAccuracyExtension on WeightAccuracy {
  String get displayName {
    switch (this) {
      case WeightAccuracy.high:
        return 'Alta Precisão';
      case WeightAccuracy.normal:
        return 'Precisão Normal';
      case WeightAccuracy.low:
        return 'Baixa Precisão';
      case WeightAccuracy.estimate:
        return 'Estimativa';
    }
  }
}