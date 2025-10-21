// Dart imports:
import 'dart:async';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import '../models/exercicio_model.dart';
import '../repository/exercicio_repository.dart';
import 'exercicio_logger_service.dart';

/// Service responsável pela persistência híbrida (local + nuvem) de exercícios
/// Implementa padrão offline-first com sincronização automática
class ExercicioPersistenceService {
  static const String _boxName = 'exercicios_box';
  static const String _syncQueueBoxName = 'exercicios_sync_queue';
  static const String _metadataBoxName = 'exercicios_metadata';
  
  late Box<Map<String, dynamic>> _exerciciosBox;
  late Box<Map<String, dynamic>> _syncQueueBox;
  late Box<String> _metadataBox;
  
  final ExercicioRepository _cloudRepository = ExercicioRepository();
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Inicializa o serviço de persistência
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Inicializar Hive se ainda não foi inicializado
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }
      
      // Abrir boxes do Hive
      _exerciciosBox = await Hive.openBox<Map<String, dynamic>>(_boxName);
      _syncQueueBox = await Hive.openBox<Map<String, dynamic>>(_syncQueueBoxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      
      // Configurar listener de conectividade
      _setupConnectivityListener();
      
      _isInitialized = true;
      
      // Executar sincronização inicial se houver conectividade
      _syncIfConnected();
      
      ExercicioLoggerService.i('ExercicioPersistenceService inicializado com sucesso', 
        component: 'PersistenceService');
    } catch (e) {
      ExercicioLoggerService.e('Erro ao inicializar ExercicioPersistenceService', 
        component: 'PersistenceService', error: e);
      rethrow;
    }
  }

  /// Configura listener para mudanças de conectividade
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          _syncIfConnected();
        }
      },
    );
  }

  /// Executa sincronização se houver conectividade
  Future<void> _syncIfConnected() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.any((result) => result != ConnectivityResult.none) && !_isSyncing) {
      await _syncWithCloud();
    }
  }

  /// Salva exercício localmente e agenda sincronização
  Future<ExercicioModel> saveExercicio(ExercicioModel exercicio) async {
    await _ensureInitialized();
    
    try {
      // Gerar ID local se não existir
      final localId = exercicio.id ?? _generateLocalId();
      final exercicioComId = ExercicioModel(
        id: localId,
        nome: exercicio.nome,
        categoria: exercicio.categoria,
        duracao: exercicio.duracao,
        caloriasQueimadas: exercicio.caloriasQueimadas,
        dataRegistro: exercicio.dataRegistro,
        observacoes: exercicio.observacoes,
      );

      // Salvar localmente
      final exercicioData = exercicioComId.toJson();
      await _exerciciosBox.put(localId, exercicioData);
      
      // Adicionar à fila de sincronização
      await _addToSyncQueue('save', exercicioComId);
      
      // Tentar sincronizar imediatamente se houver conectividade
      _syncIfConnected();
      
      ExercicioLoggerService.i('Exercício salvo localmente', 
        component: 'PersistenceService', context: {'exerciseName': exercicioComId.nome});
      return exercicioComId;
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao salvar exercício', 
        component: 'PersistenceService', error: e);
      rethrow;
    }
  }

  /// Carrega todos os exercícios (prioriza dados locais)
  Future<List<ExercicioModel>> loadExercicios() async {
    await _ensureInitialized();
    
    try {
      final List<ExercicioModel> exercicios = [];
      
      // Carregar dados locais
      for (final exercicioData in _exerciciosBox.values) {
        try {
          final exercicio = ExercicioModel.fromJson(Map<String, dynamic>.from(exercicioData));
          exercicios.add(exercicio);
        } catch (e) {
          ExercicioLoggerService.e('Erro ao deserializar exercício', 
            component: 'PersistenceService', error: e);
        }
      }
      
      // Ordenar por data de registro (mais recente primeiro)
      exercicios.sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
      
      ExercicioLoggerService.i('Carregados exercícios do cache local', 
        component: 'PersistenceService', context: {'count': exercicios.length});
      
      // Executar sincronização em background
      _syncIfConnected();
      
      return exercicios;
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao carregar exercícios', 
        component: 'PersistenceService', error: e);
      return [];
    }
  }

  /// Exclui exercício localmente e agenda sincronização
  Future<void> deleteExercicio(String exercicioId) async {
    await _ensureInitialized();
    
    try {
      // Verificar se o exercício existe localmente
      if (!_exerciciosBox.containsKey(exercicioId)) {
        throw Exception('Exercício não encontrado localmente');
      }
      
      // Carregar dados do exercício antes de excluir
      final exercicioData = _exerciciosBox.get(exercicioId);
      if (exercicioData != null) {
        final exercicio = ExercicioModel.fromJson(Map<String, dynamic>.from(exercicioData));
        
        // Remover localmente
        await _exerciciosBox.delete(exercicioId);
        
        // Adicionar à fila de sincronização
        await _addToSyncQueue('delete', exercicio);
        
        // Tentar sincronizar imediatamente se houver conectividade
        _syncIfConnected();
        
        ExercicioLoggerService.i('Exercício excluído localmente', 
          component: 'PersistenceService', context: {'exerciseName': exercicio.nome});
      }
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao excluir exercício', 
        component: 'PersistenceService', error: e);
      rethrow;
    }
  }

  /// Adiciona operação à fila de sincronização
  Future<void> _addToSyncQueue(String operation, ExercicioModel exercicio) async {
    try {
      final queueItem = {
        'operation': operation,
        'exercicio': exercicio.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'attempts': 0,
      };
      
      final queueKey = '${operation}_${exercicio.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _syncQueueBox.put(queueKey, queueItem);
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao adicionar item à fila de sincronização', 
        component: 'PersistenceService', error: e);
    }
  }

  /// Sincroniza dados locais com a nuvem
  Future<void> _syncWithCloud() async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      
      // Verificar conectividade
      final connectivityResults = await _connectivity.checkConnectivity();
      if (connectivityResults.every((result) => result == ConnectivityResult.none)) {
        return;
      }
      
      ExercicioLoggerService.i('Iniciando sincronização com a nuvem', 
        component: 'PersistenceService');
      
      // 1. Carregar dados da nuvem e atualizar cache local
      await _syncDownFromCloud();
      
      // 2. Processar fila de sincronização (upload)
      await _processSyncQueue();
      
      // 3. Atualizar timestamp da última sincronização
      await _metadataBox.put('last_sync', DateTime.now().toIso8601String());
      
      ExercicioLoggerService.i('Sincronização com a nuvem concluída', 
        component: 'PersistenceService');
      
    } catch (e) {
      ExercicioLoggerService.e('Erro durante sincronização', 
        component: 'PersistenceService', error: e);
    } finally {
      _isSyncing = false;
    }
  }

  /// Baixa dados da nuvem e atualiza cache local
  Future<void> _syncDownFromCloud() async {
    try {
      final cloudExercicios = await _cloudRepository.getExercicios();
      
      for (final cloudExercicio in cloudExercicios) {
        if (cloudExercicio.id != null) {
          // Verificar se o exercício local é mais recente
          final localData = _exerciciosBox.get(cloudExercicio.id!);
          
          if (localData == null) {
            // Novo exercício da nuvem
            await _exerciciosBox.put(cloudExercicio.id!, cloudExercicio.toJson());
          } else {
            // Exercício existe localmente - verificar qual é mais recente
            final localExercicio = ExercicioModel.fromJson(Map<String, dynamic>.from(localData));
            
            // Por simplicidade, usar data de registro como critério
            // Em uma implementação mais robusta, usaríamos timestamps de modificação
            if (cloudExercicio.dataRegistro > localExercicio.dataRegistro) {
              await _exerciciosBox.put(cloudExercicio.id!, cloudExercicio.toJson());
            }
          }
        }
      }
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao sincronizar dados da nuvem', 
        component: 'PersistenceService', error: e);
    }
  }

  /// Processa fila de sincronização para upload
  Future<void> _processSyncQueue() async {
    try {
      final queueItems = _syncQueueBox.keys.toList();
      
      for (final queueKey in queueItems) {
        final queueData = _syncQueueBox.get(queueKey);
        if (queueData == null) continue;
        
        try {
          final operation = queueData['operation'] as String;
          final exercicioData = queueData['exercicio'] as Map<String, dynamic>;
          final exercicio = ExercicioModel.fromJson(exercicioData);
          
          bool success = false;
          
          if (operation == 'save') {
            final savedExercicio = await _cloudRepository.saveExercicio(exercicio);
            
            // Atualizar dados locais com ID da nuvem se necessário
            if (savedExercicio.id != exercicio.id) {
              await _exerciciosBox.delete(exercicio.id!);
              await _exerciciosBox.put(savedExercicio.id!, savedExercicio.toJson());
            }
            
            success = true;
            
          } else if (operation == 'delete' && exercicio.id != null) {
            await _cloudRepository.deleteExercicio(exercicio.id!);
            success = true;
          }
          
          if (success) {
            // Remover da fila após sucesso
            await _syncQueueBox.delete(queueKey);
            ExercicioLoggerService.i('Item sincronizado com sucesso', 
              component: 'PersistenceService', 
              context: {'operation': operation, 'exerciseName': exercicio.nome});
          }
          
        } catch (e) {
          // Incrementar contador de tentativas
          final attempts = (queueData['attempts'] as int? ?? 0) + 1;
          
          if (attempts >= 3) {
            // Remover após 3 tentativas falhadas
            await _syncQueueBox.delete(queueKey);
            ExercicioLoggerService.w('Item removido da fila após 3 tentativas', 
              component: 'PersistenceService', error: e);
          } else {
            // Atualizar contador de tentativas
            queueData['attempts'] = attempts;
            await _syncQueueBox.put(queueKey, queueData);
          }
        }
      }
      
    } catch (e) {
      ExercicioLoggerService.e('Erro ao processar fila de sincronização', 
        component: 'PersistenceService', error: e);
    }
  }

  /// Força sincronização manual
  Future<void> forceSync() async {
    await _syncWithCloud();
  }

  /// Gera ID local único
  String _generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${_exerciciosBox.length}';
  }

  /// Garante que o serviço está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Obtém informações sobre o estado da sincronização
  Map<String, dynamic> getSyncInfo() {
    if (!_isInitialized) {
      return {'status': 'not_initialized'};
    }
    
    final lastSync = _metadataBox.get('last_sync');
    final queueSize = _syncQueueBox.length;
    final localCount = _exerciciosBox.length;
    
    return {
      'status': _isSyncing ? 'syncing' : 'idle',
      'last_sync': lastSync,
      'queue_size': queueSize,
      'local_count': localCount,
      'is_initialized': _isInitialized,
    };
  }

  /// Limpa todos os dados locais (usar com cuidado)
  Future<void> clearLocalData() async {
    await _ensureInitialized();
    
    await _exerciciosBox.clear();
    await _syncQueueBox.clear();
    await _metadataBox.clear();
    
    ExercicioLoggerService.i('Dados locais limpos', 
      component: 'PersistenceService');
  }

  /// Dispose do serviço
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    
    if (_isInitialized) {
      await _exerciciosBox.close();
      await _syncQueueBox.close();
      await _metadataBox.close();
    }
    
    _isInitialized = false;
  }
}
