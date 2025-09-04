import 'package:core/core.dart' hide IConflictResolver;
import 'package:core/src/sync/entity_sync_registration.dart'
    show IConflictResolver, ConflictStrategy;
import 'package:dartz/dartz.dart';

/// Configuração de sincronização específica do Gasometer
/// Apps complexos com múltiplas entidades relacionadas
class GasometerSyncConfig {
  /// Configura o sistema de sincronização para o Gasometer
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.advanced(
        appName: 'gasometer',
        syncInterval: const Duration(minutes: 2),
        conflictStrategy: ConflictStrategy.version,
        enableOrchestration: true,
      ),
      entities: [
        // Entidades críticas (alta prioridade)
        EntitySyncRegistration<Vehicle>.advanced(
          entityType: Vehicle,
          collectionName: 'vehicles',
          fromMap: Vehicle.fromMap,
          toMap: (v) => v.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.version,
          priority: SyncPriority.high,
          customResolver: VehicleConflictResolver(),
        ),

        // Entidades de alta frequência
        EntitySyncRegistration<FuelSupply>.advanced(
          entityType: FuelSupply,
          collectionName: 'fuel_supplies',
          fromMap: FuelSupply.fromMap,
          toMap: (f) => f.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.custom,
          priority: SyncPriority.critical, // Combustível é crítico
          customResolver: FuelSupplyConflictResolver(),
        ),

        // Entidades relacionais
        EntitySyncRegistration<Maintenance>.advanced(
          entityType: Maintenance,
          collectionName: 'maintenance_records',
          fromMap: Maintenance.fromMap,
          toMap: (m) => m.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.timestamp,
          priority: SyncPriority.normal,
        ),

        // Entidades financeiras
        EntitySyncRegistration<Expense>.advanced(
          entityType: Expense,
          collectionName: 'expenses',
          fromMap: Expense.fromMap,
          toMap: (e) => e.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.version,
          priority: SyncPriority.high, // Dados financeiros são importantes
          customResolver: ExpenseConflictResolver(),
        ),

        // Entidades de telemetria (baixa prioridade, grandes volumes)
        EntitySyncRegistration<OdometerReading>(
          entityType: OdometerReading,
          collectionName: 'odometer_readings',
          fromMap: OdometerReading.fromMap,
          toMap: (OdometerReading o) => o.toFirebaseMap(),
          conflictStrategy: ConflictStrategy.timestamp,
          priority: SyncPriority.low,
          batchSize: 500, // Lotes grandes para telemetria
          enableRealtime: false, // Não precisa de tempo real
          syncInterval: const Duration(minutes: 10),
        ),
      ],
    );
  }

  /// Configuração de desenvolvimento com debug habilitado
  static Future<void> configureDevelopment() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.development(
        appName: 'gasometer',
        syncInterval: const Duration(seconds: 30), // Sync mais frequente
      ),
      entities: await _getEntitiesForDevelopment(),
    );
  }

  /// Configuração offline-first para demonstrações
  static Future<void> configureOfflineFirst() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'gasometer',
      config: AppSyncConfig.offlineFirst(
        appName: 'gasometer',
        syncInterval: const Duration(hours: 2), // Sync esporádico
      ),
      entities: await _getBasicEntities(),
    );
  }

  // Métodos privados para configurações específicas

  static Future<List<EntitySyncRegistration>>
      _getEntitiesForDevelopment() async {
    return [
      // Configurações simplificadas para desenvolvimento
      EntitySyncRegistration<Vehicle>.simple(
        entityType: Vehicle,
        collectionName: 'dev_vehicles',
        fromMap: Vehicle.fromMap,
        toMap: (v) => v.toFirebaseMap(),
      ),
      EntitySyncRegistration<FuelSupply>.simple(
        entityType: FuelSupply,
        collectionName: 'dev_fuel_supplies',
        fromMap: FuelSupply.fromMap,
        toMap: (f) => f.toFirebaseMap(),
      ),
    ];
  }

  static Future<List<EntitySyncRegistration>> _getBasicEntities() async {
    return [
      // Apenas entidades essenciais para modo offline
      EntitySyncRegistration<Vehicle>(
        entityType: Vehicle,
        collectionName: 'vehicles',
        fromMap: Vehicle.fromMap,
        toMap: (Vehicle v) => v.toFirebaseMap(),
        conflictStrategy: ConflictStrategy.localWins, // Local vence offline
        enableRealtime: false,
        syncInterval: const Duration(hours: 1),
      ),
    ];
  }
}

/// Resolver de conflitos customizado para Vehicle
class VehicleConflictResolver implements IConflictResolver<Vehicle> {
  @override
  ConflictStrategy get strategy => ConflictStrategy.custom;

  @override
  Future<Either<Failure, Vehicle>> resolveConflict(
      Vehicle localVersion, Vehicle remoteVersion) async {
    try {
      // Lógica específica para veículos
      // Exemplo: manter dados mais recentes, mas preservar configurações locais

      final newerVersion = localVersion.updatedAt?.isAfter(
                  remoteVersion.updatedAt ??
                      DateTime.fromMillisecondsSinceEpoch(0)) ==
              true
          ? localVersion
          : remoteVersion;

      // Mesclar campos específicos
      final resolved = newerVersion.copyWith(
        // Preservar configurações locais importantes
        isDefault: localVersion.isDefault, // Preferência local
        customSettings: _mergeCustomSettings(
            localVersion.customSettings, remoteVersion.customSettings),
        // Usar dados mais recentes para o resto
        version: (localVersion.version > remoteVersion.version
                ? localVersion.version
                : remoteVersion.version) +
            1,
      );

      return Right(resolved);
    } catch (e) {
      return Left(SyncFailure('Vehicle conflict resolution failed: $e'));
    }
  }

  Map<String, dynamic> _mergeCustomSettings(
    Map<String, dynamic>? local,
    Map<String, dynamic>? remote,
  ) {
    if (local == null && remote == null) return {};
    if (local == null) return remote!;
    if (remote == null) return local;

    // Merge inteligente: local vence para preferências, remoto para dados
    final merged = <String, dynamic>{...remote};

    // Campos que sempre preservam valor local
    const localPriority = ['notifications', 'display_preferences', 'alerts'];

    for (final key in localPriority) {
      if (local.containsKey(key)) {
        merged[key] = local[key];
      }
    }

    return merged;
  }

  @override
  bool canAutoResolve(Vehicle localVersion, Vehicle remoteVersion) {
    // Pode resolver automaticamente se não houver mudanças críticas
    return localVersion.plateNumber == remoteVersion.plateNumber &&
        localVersion.vehicleType == remoteVersion.vehicleType;
  }
}

/// Resolver de conflitos customizado para FuelSupply
class FuelSupplyConflictResolver implements IConflictResolver<FuelSupply> {
  @override
  ConflictStrategy get strategy => ConflictStrategy.custom;

  @override
  Future<Either<Failure, FuelSupply>> resolveConflict(
      FuelSupply localVersion, FuelSupply remoteVersion) async {
    try {
      // Para combustível, sempre usar versão com maior quantidade (mais conservador)
      if (localVersion.quantity != remoteVersion.quantity) {
        final resolved = localVersion.quantity > remoteVersion.quantity
            ? localVersion
            : remoteVersion;
        return Right(resolved.incrementVersion() as FuelSupply);
      }

      // Se quantidades iguais, usar mais recente
      final localTime = localVersion.updatedAt ??
          localVersion.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final remoteTime = remoteVersion.updatedAt ??
          remoteVersion.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final resolved =
          localTime.isAfter(remoteTime) ? localVersion : remoteVersion;
      return Right(resolved.incrementVersion() as FuelSupply);
    } catch (e) {
      return Left(SyncFailure('FuelSupply conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(FuelSupply localVersion, FuelSupply remoteVersion) =>
      true;
}

/// Resolver de conflitos customizado para Expense
class ExpenseConflictResolver implements IConflictResolver<Expense> {
  @override
  ConflictStrategy get strategy => ConflictStrategy.custom;

  @override
  Future<Either<Failure, Expense>> resolveConflict(
      Expense localVersion, Expense remoteVersion) async {
    try {
      // Para despesas, sempre usar versão com maior valor (mais conservador)
      // Evita perda de dados financeiros

      if (localVersion.amount != remoteVersion.amount) {
        // Se valores diferentes, usar o maior (mais seguro)
        final winner = localVersion.amount > remoteVersion.amount
            ? localVersion
            : remoteVersion;
        final resolved = winner.copyWith(
          version: (localVersion.version > remoteVersion.version
                  ? localVersion.version
                  : remoteVersion.version) +
              1,
        );
        return Right(resolved);
      }

      // Se valores iguais, usar timestamp mais recente
      final localTime = localVersion.updatedAt ??
          localVersion.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final remoteTime = remoteVersion.updatedAt ??
          remoteVersion.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final resolved =
          localTime.isAfter(remoteTime) ? localVersion : remoteVersion;
      return Right(resolved);
    } catch (e) {
      return Left(ConflictResolutionFailure(
          'Failed to resolve expense conflict: $e',
          localVersion,
          remoteVersion));
    }
  }

  @override
  bool canAutoResolve(Expense localVersion, Expense remoteVersion) {
    // Pode resolver automaticamente se não há mudanças críticas em campos financeiros
    return localVersion.category == remoteVersion.category &&
        localVersion.paymentMethod == remoteVersion.paymentMethod;
  }
}

// Placeholder classes (serão definidas nos modelos reais do app)
class Vehicle extends BaseSyncEntity {
  const Vehicle({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    required this.plateNumber,
    required this.vehicleType,
    this.isDefault = false,
    this.customSettings = const {},
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

  final String plateNumber;
  final String vehicleType;
  final bool isDefault;
  final Map<String, dynamic> customSettings;

  static Vehicle fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return Vehicle(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      plateNumber: (map['plate_number'] as String?) ?? '',
      vehicleType: (map['vehicle_type'] as String?) ?? '',
      isDefault: (map['is_default'] as bool?) ?? false,
      customSettings: Map<String, dynamic>.from(
          (map['custom_settings'] as Map<dynamic, dynamic>?) ?? {}),
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'is_default': isDefault,
      'custom_settings': customSettings,
    };
  }

  Vehicle copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    String? plateNumber,
    String? vehicleType,
    bool? isDefault,
    Map<String, dynamic>? customSettings,
    bool? conflictResolved,
    String? conflictDetails,
  }) {
    return Vehicle(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isDefault: isDefault ?? this.isDefault,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  @override
  Vehicle markAsDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  Vehicle markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  Vehicle markAsDeleted() =>
      copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  Vehicle incrementVersion() => copyWith(version: version + 1);

  @override
  Vehicle withUserId(String userId) => copyWith(userId: userId);

  @override
  Vehicle withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [
        ...super.props,
        plateNumber,
        vehicleType,
        isDefault,
        customSettings,
      ];
}

// Placeholder classes para outras entidades
class FuelSupply extends BaseSyncEntity {
  const FuelSupply({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    required this.quantity,
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

  final double quantity;

  static FuelSupply fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return FuelSupply(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      quantity: ((map['quantity'] as num?) ?? 0.0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    return {
      ...baseFirebaseFields,
      'quantity': quantity,
    };
  }

  @override
  FuelSupply copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    double? quantity,
  }) {
    return FuelSupply(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  FuelSupply markAsDirty() =>
      copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  FuelSupply markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  FuelSupply markAsDeleted() =>
      copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  FuelSupply incrementVersion() => copyWith(version: version + 1);

  @override
  FuelSupply withUserId(String userId) => copyWith(userId: userId);

  @override
  FuelSupply withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [...super.props, quantity];
}

// Placeholder classes simples
class Maintenance extends BaseSyncEntity {
  const Maintenance({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
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

  static Maintenance fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return Maintenance(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() => baseFirebaseFields;

  @override
  Maintenance copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) =>
      Maintenance(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        userId: userId ?? this.userId,
        moduleName: moduleName ?? this.moduleName,
      );

  @override
  Maintenance markAsDirty() =>
      copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  Maintenance markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  Maintenance markAsDeleted() =>
      copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  Maintenance incrementVersion() => copyWith(version: version + 1);

  @override
  Maintenance withUserId(String userId) => copyWith(userId: userId);

  @override
  Maintenance withModule(String moduleName) => copyWith(moduleName: moduleName);
}

class Expense extends BaseSyncEntity {
  const Expense({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
    this.amount = 0.0,
    this.category = '',
    this.paymentMethod = '',
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

  final double amount;
  final String category;
  final String paymentMethod;

  static Expense fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return Expense(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      amount: ((map['amount'] as num?) ?? 0.0).toDouble(),
      category: (map['category'] as String?) ?? '',
      paymentMethod: (map['payment_method'] as String?) ?? '',
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() => {
        ...baseFirebaseFields,
        'amount': amount,
        'category': category,
        'payment_method': paymentMethod,
      };

  @override
  Expense copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    double? amount,
    String? category,
    String? paymentMethod,
  }) =>
      Expense(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        userId: userId ?? this.userId,
        moduleName: moduleName ?? this.moduleName,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );

  @override
  Expense markAsDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  Expense markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  Expense markAsDeleted() =>
      copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  Expense incrementVersion() => copyWith(version: version + 1);

  @override
  Expense withUserId(String userId) => copyWith(userId: userId);

  @override
  Expense withModule(String moduleName) => copyWith(moduleName: moduleName);

  @override
  List<Object?> get props => [...super.props, amount, category, paymentMethod];
}

class OdometerReading extends BaseSyncEntity {
  const OdometerReading({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool isDirty = false,
    bool isDeleted = false,
    int version = 1,
    String? userId,
    String? moduleName,
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

  static OdometerReading fromMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return OdometerReading(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
    );
  }

  @override
  Map<String, dynamic> toFirebaseMap() => baseFirebaseFields;

  @override
  OdometerReading copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
  }) =>
      OdometerReading(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        isDirty: isDirty ?? this.isDirty,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
        userId: userId ?? this.userId,
        moduleName: moduleName ?? this.moduleName,
      );

  @override
  OdometerReading markAsDirty() =>
      copyWith(isDirty: true, updatedAt: DateTime.now());

  @override
  OdometerReading markAsSynced({DateTime? syncTime}) => copyWith(
        isDirty: false,
        lastSyncAt: syncTime ?? DateTime.now(),
      );

  @override
  OdometerReading markAsDeleted() =>
      copyWith(isDeleted: true, updatedAt: DateTime.now());

  @override
  OdometerReading incrementVersion() => copyWith(version: version + 1);

  @override
  OdometerReading withUserId(String userId) => copyWith(userId: userId);

  @override
  OdometerReading withModule(String moduleName) =>
      copyWith(moduleName: moduleName);
}
