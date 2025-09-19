import 'package:core/core.dart';
import 'data/models/comentario_model.dart';

/// Configuração de sincronização específica do Plantis
/// Apps simples com poucas entidades e sync básico
class PlantisSyncConfig {
  /// Configura o sistema de sincronização para o Plantis
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.simple(
        appName: 'plantis',
        syncInterval: const Duration(minutes: 10), // Sync menos frequente
        conflictStrategy: ConflictStrategy.timestamp, // Simples timestamp
      ),
      entities: [
        // Entidade principal - Plantas
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: Plant.fromMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),
        
        // Cuidados/Tasks relacionadas às plantas
        EntitySyncRegistration<PlantCare>.simple(
          entityType: PlantCare,
          collectionName: 'plant_care',
          fromMap: PlantCare.fromMap,
          toMap: (care) => care.toFirebaseMap(),
        ),
        
        // Lembretes e notificações
        EntitySyncRegistration<PlantReminder>.simple(
          entityType: PlantReminder,
          collectionName: 'plant_reminders',
          fromMap: PlantReminder.fromMap,
          toMap: (reminder) => reminder.toFirebaseMap(),
        ),

        // Comentários das plantas
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (comentario) => comentario.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração para desenvolvimento
  static Future<void> configureDevelopment() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.development(
        appName: 'plantis',
        syncInterval: const Duration(minutes: 2),
      ),
      entities: [
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'dev_plants',
          fromMap: Plant.fromMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),

        // Comentários das plantas (desenvolvimento)
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'dev_comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (comentario) => comentario.toFirebaseMap(),
        ),
      ],
    );
  }

  /// Configuração offline-first para áreas rurais com internet limitada
  static Future<void> configureOfflineFirst() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      config: AppSyncConfig.offlineFirst(
        appName: 'plantis',
        syncInterval: const Duration(hours: 6), // Sync muito esporádico
      ),
      entities: [
        EntitySyncRegistration<Plant>(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: Plant.fromMap,
          toMap: (Plant plant) => plant.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 100, // Lotes maiores quando sync
        ),

        // Comentários das plantas (offline-first)
        EntitySyncRegistration<ComentarioModel>(
          entityType: ComentarioModel,
          collectionName: 'comentarios',
          fromMap: ComentarioModel.fromFirebaseMap,
          toMap: (ComentarioModel comentario) => comentario.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.localWins, // Local sempre vence
          enableRealtime: false, // Sem tempo real para economizar bateria
          syncInterval: const Duration(hours: 12),
          batchSize: 50, // Lotes menores para comentários
        ),
      ],
    );
  }
}

// Modelos simples do Plantis

class Plant extends BaseSyncEntity {
  const Plant({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    required this.name,
    required this.species,
    this.notes = '',
    this.isActive = true,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  final String name;
  final String species;
  final String notes;
  final bool isActive;

  static Plant fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return Plant(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      name: (map['name'] as String?) ?? '',
      species: (map['species'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'name': name,
      'species': species,
      'notes': notes,
      'is_active': isActive,
    };
  }

  @override
  Plant copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? name,
    String? species,
    String? notes,
    bool? isActive,
  }) {
    return Plant(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      name: name ?? this.name,
      species: species ?? this.species,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Plant markAsDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  Plant markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  Plant markAsDeleted() => copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  Plant incrementVersion() => copyWith(version: version + 1);

  @override
  Plant withUserId(String userId) => copyWith(userId: userId);

  @override
  Plant withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        species,
        notes,
        isActive,
      ];
}

class PlantCare extends BaseSyncEntity {
  const PlantCare({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    required this.plantId,
    required this.careType,
    this.notes = '',
    this.isCompleted = false,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  final String plantId;
  final String careType; // 'watering', 'fertilizing', 'pruning', etc.
  final String notes;
  final bool isCompleted;

  static PlantCare fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return PlantCare(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantId: (map['plant_id'] as String?) ?? '',
      careType: (map['care_type'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      isCompleted: (map['is_completed'] as bool?) ?? false,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'plant_id': plantId,
      'care_type': careType,
      'notes': notes,
      'is_completed': isCompleted,
    };
  }

  @override
  PlantCare copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? plantId,
    String? careType,
    String? notes,
    bool? isCompleted,
  }) {
    return PlantCare(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      plantId: plantId ?? this.plantId,
      careType: careType ?? this.careType,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  PlantCare markAsDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  PlantCare markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  PlantCare markAsDeleted() => copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  PlantCare incrementVersion() => copyWith(version: version + 1);

  @override
  PlantCare withUserId(String userId) => copyWith(userId: userId);

  @override
  PlantCare withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [
        ...super.props,
        plantId,
        careType,
        notes,
        isCompleted,
      ];
}

class PlantReminder extends BaseSyncEntity {
  const PlantReminder({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    required this.plantId,
    required this.title,
    required this.reminderDate,
    this.isActive = true,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
          lastSyncAt: lastSyncAt,
          isDirty: isDirty,
          isDeleted: isDeleted,
          version: version,
          userId: userId,
          moduleName: moduleName,
        );

  final String plantId;
  final String title;
  final DateTime reminderDate;
  final bool isActive;

  static PlantReminder fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return PlantReminder(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plantId: (map['plant_id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      reminderDate: DateTime.parse((map['reminder_date'] as String?) ?? DateTime.now().toIso8601String()),
      isActive: (map['is_active'] as bool?) ?? true,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'plant_id': plantId,
      'title': title,
      'reminder_date': reminderDate.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  PlantReminder copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? plantId,
    String? title,
    DateTime? reminderDate,
    bool? isActive,
  }) {
    return PlantReminder(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      plantId: plantId ?? this.plantId,
      title: title ?? this.title,
      reminderDate: reminderDate ?? this.reminderDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  PlantReminder markAsDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  PlantReminder markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  PlantReminder markAsDeleted() => copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  PlantReminder incrementVersion() => copyWith(version: version + 1);

  @override
  PlantReminder withUserId(String userId) => copyWith(userId: userId);

  @override
  PlantReminder withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [
        ...super.props,
        plantId,
        title,
        reminderDate,
        isActive,
      ];
}