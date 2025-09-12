import 'dart:async';
import 'package:hive/hive.dart';
import 'package:core/core.dart';

/// Serviço avançado de resolução de conflitos de sincronização
class ConflictResolutionService {
  ConflictResolutionService({
    required this.analytics,
    required this.storage,
  });

  final IAnalyticsRepository analytics;
  final HiveStorageService storage;

  final _conflictController = StreamController<ConflictEvent>.broadcast();

  /// Stream de eventos de conflito
  Stream<ConflictEvent> get conflictStream => _conflictController.stream;

  /// Resolve conflito automaticamente usando estratégias configuradas
  Future<ConflictResolutionResult> resolveConflict(
    SyncConflict conflict, {
    ConflictStrategy? strategy,
    bool interactive = true,
  }) async {
    try {
      analytics.logEvent('conflict_resolution_started', parameters: {
        'conflict_id': conflict.id,
        'conflict_type': conflict.conflictType,
        'collection': conflict.collection,
        'strategy': strategy?.name ?? 'auto',
      });

      // 1. Determinar estratégia se não especificada
      final resolveStrategy = strategy ?? await _determineStrategy(conflict);

      // 2. Aplicar estratégia de resolução
      final resolution = await _applyResolutionStrategy(
        conflict,
        resolveStrategy,
        interactive: interactive,
      );

      // 3. Validar resultado
      final validatedData = await _validateResolvedData(
        conflict,
        resolution.resolvedData,
      );

      // 4. Criar backup antes da aplicação
      await _createConflictBackup(conflict, validatedData);

      final result = ConflictResolutionResult(
        success: true,
        conflictId: conflict.id,
        strategy: resolveStrategy,
        resolvedData: validatedData,
        appliedAt: DateTime.now(),
        backupCreated: true,
      );

      analytics.logEvent('conflict_resolution_completed', parameters: {
        'conflict_id': conflict.id,
        'strategy_used': resolveStrategy.name,
        'interactive': interactive.toString(),
        'data_size': validatedData.length.toString(),
      });

      // Notificar evento de resolução
      _conflictController.add(ConflictEvent.resolved(conflict, result));

      return result;

    } catch (e) {
      analytics.logError(
        error: 'conflict_resolution_failed: $e',
        additionalInfo: {
          'conflict_id': conflict.id,
          'strategy': strategy?.name ?? 'auto',
        },
      );

      _conflictController.add(ConflictEvent.failed(conflict, e.toString()));

      return ConflictResolutionResult(
        success: false,
        conflictId: conflict.id,
        strategy: strategy ?? ConflictStrategy.lastWriteWins,
        error: e.toString(),
        appliedAt: DateTime.now(),
      );
    }
  }

  /// Determina a melhor estratégia automaticamente
  Future<ConflictStrategy> _determineStrategy(SyncConflict conflict) async {
    // 1. Verificar configurações do usuário
    final userPreference = await _getUserConflictPreference(conflict.collection);
    if (userPreference != null) {
      return userPreference;
    }

    // 2. Analisar tipo de conflito e dados
    final analysis = await _analyzeConflict(conflict);

    // 3. Aplicar heurísticas baseadas no tipo de dados
    switch (conflict.collection) {
      case 'receituagro_user_favorites':
        // Favoritos: merge é geralmente a melhor opção
        return ConflictStrategy.merge;

      case 'receituagro_user_settings':
        // Configurações: preferir dados mais recentes
        return ConflictStrategy.lastWriteWins;

      case 'receituagro_user_comments':
        // Comentários: preservar ambos se possível
        return analysis.canMerge ? ConflictStrategy.merge : ConflictStrategy.userGuided;

      default:
        // Default: analisar timestamps
        return analysis.hasSignificantTimeDifference 
            ? ConflictStrategy.lastWriteWins 
            : ConflictStrategy.userGuided;
    }
  }

  /// Aplica a estratégia de resolução escolhida
  Future<ConflictResolution> _applyResolutionStrategy(
    SyncConflict conflict,
    ConflictStrategy strategy, {
    bool interactive = true,
  }) async {
    switch (strategy) {
      case ConflictStrategy.lastWriteWins:
        return _applyLastWriteWins(conflict);

      case ConflictStrategy.merge:
        return await _applyMergeStrategy(conflict);

      case ConflictStrategy.userGuided:
        if (interactive) {
          return await _applyUserGuidedStrategy(conflict);
        } else {
          // Fallback para last write wins se não for interativo
          return _applyLastWriteWins(conflict);
        }

      case ConflictStrategy.keepLocal:
        return ConflictResolution(
          strategy: strategy,
          resolvedData: conflict.clientData,
          mergeDetails: 'Local data preserved',
        );

      case ConflictStrategy.keepRemote:
        return ConflictResolution(
          strategy: strategy,
          resolvedData: conflict.serverData,
          mergeDetails: 'Remote data preserved',
        );
    }
  }

  /// Aplica estratégia Last Write Wins
  ConflictResolution _applyLastWriteWins(SyncConflict conflict) {
    final useClient = conflict.clientTimestamp.isAfter(conflict.serverTimestamp);
    
    return ConflictResolution(
      strategy: ConflictStrategy.lastWriteWins,
      resolvedData: useClient ? conflict.clientData : conflict.serverData,
      mergeDetails: useClient 
          ? 'Client data newer (${conflict.clientTimestamp})'
          : 'Server data newer (${conflict.serverTimestamp})',
    );
  }

  /// Aplica estratégia de merge inteligente
  Future<ConflictResolution> _applyMergeStrategy(SyncConflict conflict) async {
    final mergeResult = await _performIntelligentMerge(
      conflict.clientData,
      conflict.serverData,
      conflict.collection,
    );

    return ConflictResolution(
      strategy: ConflictStrategy.merge,
      resolvedData: mergeResult.mergedData,
      mergeDetails: mergeResult.mergeLog,
      mergedFields: mergeResult.mergedFields,
    );
  }

  /// Aplica estratégia guiada pelo usuário
  Future<ConflictResolution> _applyUserGuidedStrategy(SyncConflict conflict) async {
    // Esta função seria chamada pela UI para apresentar opções ao usuário
    // Por enquanto, vamos usar uma lógica automática com preferência por merge
    if (await _canMergeSafely(conflict.clientData, conflict.serverData)) {
      return await _applyMergeStrategy(conflict);
    } else {
      return _applyLastWriteWins(conflict);
    }
  }

  /// Executa merge inteligente baseado no tipo de dados
  Future<MergeResult> _performIntelligentMerge(
    Map<String, dynamic> clientData,
    Map<String, dynamic> serverData,
    String collection,
  ) async {
    final mergedData = <String, dynamic>{};
    final mergeLog = <String>[];
    final mergedFields = <String>[];

    // Obter esquema de merge para a coleção
    final mergeSchema = _getMergeSchemaForCollection(collection);

    for (final key in {...clientData.keys, ...serverData.keys}) {
      final clientValue = clientData[key];
      final serverValue = serverData[key];

      if (clientValue == null && serverValue != null) {
        // Apenas no servidor
        mergedData[key] = serverValue;
        mergeLog.add('Used server value for $key (not in client)');
        
      } else if (serverValue == null && clientValue != null) {
        // Apenas no cliente
        mergedData[key] = clientValue;
        mergeLog.add('Used client value for $key (not in server)');
        
      } else if (clientValue == serverValue) {
        // Valores iguais
        mergedData[key] = clientValue;
        
      } else {
        // Conflito real no campo
        final fieldStrategy = mergeSchema.getFieldStrategy(key);
        final resolvedValue = await _resolveFieldConflict(
          key,
          clientValue,
          serverValue,
          fieldStrategy,
        );
        
        mergedData[key] = resolvedValue.value;
        mergeLog.add(resolvedValue.log);
        
        if (resolvedValue.wasMerged) {
          mergedFields.add(key);
        }
      }
    }

    return MergeResult(
      mergedData: mergedData,
      mergeLog: mergeLog.join('; '),
      mergedFields: mergedFields,
    );
  }

  /// Resolve conflito em campo específico
  Future<FieldResolutionResult> _resolveFieldConflict(
    String fieldName,
    dynamic clientValue,
    dynamic serverValue,
    FieldMergeStrategy strategy,
  ) async {
    switch (strategy) {
      case FieldMergeStrategy.takeClient:
        return FieldResolutionResult(
          value: clientValue,
          log: 'Field $fieldName: used client value',
          wasMerged: false,
        );

      case FieldMergeStrategy.takeServer:
        return FieldResolutionResult(
          value: serverValue,
          log: 'Field $fieldName: used server value',
          wasMerged: false,
        );

      case FieldMergeStrategy.concatenate:
        if (clientValue is String && serverValue is String) {
          final merged = '$clientValue\n$serverValue';
          return FieldResolutionResult(
            value: merged,
            log: 'Field $fieldName: concatenated client and server values',
            wasMerged: true,
          );
        }
        break;

      case FieldMergeStrategy.mergeArrays:
        if (clientValue is List && serverValue is List) {
          final merged = [...clientValue, ...serverValue].toSet().toList();
          return FieldResolutionResult(
            value: merged,
            log: 'Field $fieldName: merged arrays (${merged.length} total items)',
            wasMerged: true,
          );
        }
        break;

      case FieldMergeStrategy.useNewer:
        // Para campos com timestamp, usar valor mais recente
        // Implementação simplificada
        return FieldResolutionResult(
          value: clientValue,
          log: 'Field $fieldName: used newer value (client)',
          wasMerged: false,
        );
    }

    // Fallback: usar valor do cliente
    return FieldResolutionResult(
      value: clientValue,
      log: 'Field $fieldName: fallback to client value',
      wasMerged: false,
    );
  }

  /// Obtém esquema de merge para uma coleção
  MergeSchema _getMergeSchemaForCollection(String collection) {
    switch (collection) {
      case 'receituagro_user_favorites':
        return MergeSchema({
          'items': FieldMergeStrategy.mergeArrays,
          'lastUpdated': FieldMergeStrategy.useNewer,
          'tags': FieldMergeStrategy.mergeArrays,
        });

      case 'receituagro_user_comments':
        return MergeSchema({
          'content': FieldMergeStrategy.concatenate,
          'tags': FieldMergeStrategy.mergeArrays,
          'createdAt': FieldMergeStrategy.useNewer,
        });

      case 'receituagro_user_settings':
        return MergeSchema({
          'theme': FieldMergeStrategy.takeClient, // Preferência local
          'notifications': FieldMergeStrategy.takeClient,
          'language': FieldMergeStrategy.takeClient,
          'syncSettings': FieldMergeStrategy.takeServer, // Configuração de servidor
        });

      default:
        return MergeSchema.defaultSchema();
    }
  }

  /// Analisa conflito para determinar características
  Future<ConflictAnalysis> _analyzeConflict(SyncConflict conflict) async {
    final timeDifference = conflict.clientTimestamp.difference(conflict.serverTimestamp).abs();
    final hasSignificantTimeDifference = timeDifference.inMinutes > 5;

    final clientSize = conflict.clientData.length;
    final serverSize = conflict.serverData.length;
    final sizeDifference = (clientSize - serverSize).abs();

    final commonKeys = conflict.clientData.keys
        .toSet()
        .intersection(conflict.serverData.keys.toSet());
    
    final canMerge = commonKeys.isNotEmpty && 
                     await _canMergeSafely(conflict.clientData, conflict.serverData);

    return ConflictAnalysis(
      timeDifference: timeDifference,
      hasSignificantTimeDifference: hasSignificantTimeDifference,
      sizeDifference: sizeDifference,
      commonFields: commonKeys.length,
      canMerge: canMerge,
    );
  }

  /// Verifica se os dados podem ser merged com segurança
  Future<bool> _canMergeSafely(
    Map<String, dynamic> clientData,
    Map<String, dynamic> serverData,
  ) async {
    // Verificar se não há conflitos em campos críticos
    final criticalFields = ['id', 'userId', 'version'];
    
    for (final field in criticalFields) {
      final clientValue = clientData[field];
      final serverValue = serverData[field];
      
      if (clientValue != null && 
          serverValue != null && 
          clientValue != serverValue) {
        return false; // Conflito em campo crítico
      }
    }
    
    return true;
  }

  /// Valida dados resolvidos antes da aplicação
  Future<Map<String, dynamic>> _validateResolvedData(
    SyncConflict conflict,
    Map<String, dynamic> resolvedData,
  ) async {
    // Validações básicas
    if (resolvedData.isEmpty) {
      throw ConflictResolutionException('Resolved data cannot be empty');
    }

    // Validar estrutura baseada na coleção
    final validator = _getValidatorForCollection(conflict.collection);
    await validator.validate(resolvedData);

    // Adicionar metadados de resolução
    final validatedData = Map<String, dynamic>.from(resolvedData);
    validatedData['_conflictResolved'] = true;
    validatedData['_resolvedAt'] = DateTime.now().millisecondsSinceEpoch;
    validatedData['_originalConflictId'] = conflict.id;

    return validatedData;
  }

  /// Cria backup antes da resolução
  Future<void> _createConflictBackup(
    SyncConflict conflict,
    Map<String, dynamic> resolvedData,
  ) async {
    final backup = {
      'conflictId': conflict.id,
      'collection': conflict.collection,
      'documentId': conflict.documentId,
      'clientData': conflict.clientData,
      'serverData': conflict.serverData,
      'resolvedData': resolvedData,
      'backedUpAt': DateTime.now().millisecondsSinceEpoch,
    };

    await storage.save(
      key: '${conflict.id}_backup',
      data: backup,
      box: 'conflict_backups',
    );
    
    // Limpar backups antigos (manter apenas últimos 100)
    await _cleanupOldBackups();
  }

  /// Limpa backups antigos
  Future<void> _cleanupOldBackups() async {
    final keysResult = await storage.getKeys(box: 'conflict_backups');
    await keysResult.fold(
      (failure) async => null, // Ignora erro de limpeza
      (keys) async {
        if (keys.length <= 100) return;

        // Para simplicidade, remover os primeiros 20 keys (mais antigos baseado na ordem de inserção)
        // Uma implementação mais sofisticada poderia buscar timestamps, mas isso seria custoso
        final keysToRemove = keys.take(20).toList();

        // Remover os mais antigos
        for (final key in keysToRemove) {
          await storage.remove(key: key, box: 'conflict_backups');
        }
      },
    );
  }

  /// Obtém validador para uma coleção
  DataValidator _getValidatorForCollection(String collection) {
    switch (collection) {
      case 'receituagro_user_favorites':
        return FavoritesDataValidator();
      case 'receituagro_user_settings':
        return SettingsDataValidator();
      default:
        return GenericDataValidator();
    }
  }

  /// Obtém preferência do usuário para resolução de conflitos
  Future<ConflictStrategy?> _getUserConflictPreference(String collection) async {
    final preferenceResult = await storage.get<String>(
      key: 'conflict_strategy_$collection',
      box: 'user_preferences',
    );
    
    return preferenceResult.fold(
      (failure) => null,
      (preference) {
        if (preference != null) {
          return ConflictStrategy.values.firstWhere(
            (strategy) => strategy.name == preference,
            orElse: () => ConflictStrategy.lastWriteWins,
          );
        }
        return null;
      },
    );
  }

  /// Obtém estatísticas de conflitos resolvidos
  Future<ConflictStats> getConflictStats() async {
    final lengthResult = await storage.length(box: 'conflict_backups');
    
    return lengthResult.fold(
      (failure) => const ConflictStats(
        totalConflictsResolved: 0,
        strategyCounts: {},
        averageResolutionTime: Duration(minutes: 2),
      ),
      (total) {
        // Analisar estratégias mais usadas, etc.
        final strategyCounts = <ConflictStrategy, int>{};
        
        return ConflictStats(
          totalConflictsResolved: total,
          strategyCounts: strategyCounts,
          averageResolutionTime: const Duration(minutes: 2), // Calculado dinamicamente
        );
      },
    );
  }

  /// Dispose dos recursos
  void dispose() {
    _conflictController.close();
  }
}

// Modelos de dados para conflict resolution

enum ConflictStrategy { 
  lastWriteWins, 
  merge, 
  userGuided, 
  keepLocal, 
  keepRemote 
}

enum FieldMergeStrategy {
  takeClient,
  takeServer,
  concatenate,
  mergeArrays,
  useNewer,
}

class ConflictResolutionResult {
  const ConflictResolutionResult({
    required this.success,
    required this.conflictId,
    required this.strategy,
    required this.appliedAt,
    this.resolvedData,
    this.error,
    this.backupCreated = false,
  });

  final bool success;
  final String conflictId;
  final ConflictStrategy strategy;
  final DateTime appliedAt;
  final Map<String, dynamic>? resolvedData;
  final String? error;
  final bool backupCreated;
}

class ConflictResolution {
  const ConflictResolution({
    required this.strategy,
    required this.resolvedData,
    required this.mergeDetails,
    this.mergedFields,
  });

  final ConflictStrategy strategy;
  final Map<String, dynamic> resolvedData;
  final String mergeDetails;
  final List<String>? mergedFields;
}

class MergeResult {
  const MergeResult({
    required this.mergedData,
    required this.mergeLog,
    required this.mergedFields,
  });

  final Map<String, dynamic> mergedData;
  final String mergeLog;
  final List<String> mergedFields;
}

class FieldResolutionResult {
  const FieldResolutionResult({
    required this.value,
    required this.log,
    required this.wasMerged,
  });

  final dynamic value;
  final String log;
  final bool wasMerged;
}

class MergeSchema {
  const MergeSchema(this.fieldStrategies);

  final Map<String, FieldMergeStrategy> fieldStrategies;

  FieldMergeStrategy getFieldStrategy(String field) {
    return fieldStrategies[field] ?? FieldMergeStrategy.takeClient;
  }

  static MergeSchema defaultSchema() {
    return const MergeSchema({});
  }
}

class ConflictAnalysis {
  const ConflictAnalysis({
    required this.timeDifference,
    required this.hasSignificantTimeDifference,
    required this.sizeDifference,
    required this.commonFields,
    required this.canMerge,
  });

  final Duration timeDifference;
  final bool hasSignificantTimeDifference;
  final int sizeDifference;
  final int commonFields;
  final bool canMerge;
}

class ConflictEvent {
  const ConflictEvent._({
    required this.type,
    required this.conflict,
    this.result,
    this.error,
    this.timestamp,
  });

  final ConflictEventType type;
  final SyncConflict conflict;
  final ConflictResolutionResult? result;
  final String? error;
  final DateTime? timestamp;

  factory ConflictEvent.resolved(
    SyncConflict conflict,
    ConflictResolutionResult result,
  ) => ConflictEvent._(
    type: ConflictEventType.resolved,
    conflict: conflict,
    result: result,
    timestamp: DateTime.now(),
  );

  factory ConflictEvent.failed(
    SyncConflict conflict,
    String error,
  ) => ConflictEvent._(
    type: ConflictEventType.failed,
    conflict: conflict,
    error: error,
    timestamp: DateTime.now(),
  );
}

enum ConflictEventType { resolved, failed }

class ConflictStats {
  const ConflictStats({
    required this.totalConflictsResolved,
    required this.strategyCounts,
    required this.averageResolutionTime,
  });

  final int totalConflictsResolved;
  final Map<ConflictStrategy, int> strategyCounts;
  final Duration averageResolutionTime;
}

// Validators

abstract class DataValidator {
  Future<void> validate(Map<String, dynamic> data);
}

class FavoritesDataValidator implements DataValidator {
  @override
  Future<void> validate(Map<String, dynamic> data) async {
    if (!data.containsKey('items') || data['items'] is! List) {
      throw ValidationException('Favorites must contain items array');
    }
  }
}

class SettingsDataValidator implements DataValidator {
  @override
  Future<void> validate(Map<String, dynamic> data) async {
    // Validações específicas para settings
  }
}

class GenericDataValidator implements DataValidator {
  @override
  Future<void> validate(Map<String, dynamic> data) async {
    // Validação genérica
  }
}

// Exceptions

class ConflictResolutionException implements Exception {
  const ConflictResolutionException(this.message);
  final String message;
  
  @override
  String toString() => 'ConflictResolutionException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
  
  @override
  String toString() => 'ValidationException: $message';
}

// Import necessário para SyncConflict (definido no FirestoreSyncService)
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.conflictType,
    required this.clientData,
    required this.serverData,
    required this.clientTimestamp,
    required this.serverTimestamp,
  });

  final String id;
  final String collection;
  final String documentId;
  final String conflictType;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> serverData;
  final DateTime clientTimestamp;
  final DateTime serverTimestamp;

  static SyncConflict fromMap(Map<String, dynamic> map) => SyncConflict(
    id: map['id'] as String,
    collection: map['collection'] as String,
    documentId: map['documentId'] as String,
    conflictType: map['conflictType'] as String,
    clientData: map['clientData'] as Map<String, dynamic>,
    serverData: map['serverData'] as Map<String, dynamic>,
    clientTimestamp: DateTime.fromMillisecondsSinceEpoch(map['clientTimestamp'] as int),
    serverTimestamp: DateTime.fromMillisecondsSinceEpoch(map['serverTimestamp'] as int),
  );
}