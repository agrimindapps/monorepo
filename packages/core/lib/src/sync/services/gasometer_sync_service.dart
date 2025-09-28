import 'dart:async';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../interfaces/i_sync_service.dart';
import '../../shared/utils/failure.dart';

/// Serviço de sincronização específico para o app Gasometer
/// Substitui o UnifiedSyncManager para dados de veículos, combustível e manutenção
class GasometerSyncService implements ISyncService {
  @override
  final String serviceId = 'gasometer';
  
  @override
  final String displayName = 'Gasometer Vehicle Sync';
  
  @override
  final String version = '1.0.0';
  
  @override
  final List<String> dependencies = [];
  
  // Estado interno
  bool _isInitialized = false;
  bool _canSync = true;
  bool _hasPendingSync = false;
  DateTime? _lastSync;
  
  // Estatísticas
  int _totalSyncs = 0;
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  int _totalItemsSynced = 0;
  
  // Stream controllers
  final StreamController<SyncServiceStatus> _statusController = 
      StreamController<SyncServiceStatus>.broadcast();
  final StreamController<ServiceProgress> _progressController = 
      StreamController<ServiceProgress>.broadcast();
      
  SyncServiceStatus _currentStatus = SyncServiceStatus.uninitialized;
  
  // Entidades específicas do Gasometer
  final List<String> _entityTypes = [
    'vehicles',
    'fuel_records', 
    'maintenance_records',
    'expenses',
    'categories'
  ];
  
  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      developer.log(
        'Initializing Gasometer Sync Service',
        name: 'GasometerSync',
      );
      
      _isInitialized = true;
      _updateStatus(SyncServiceStatus.idle);
      
      developer.log(
        'Gasometer Sync Service initialized - entities: $_entityTypes',
        name: 'GasometerSync',
      );
      
      return const Right(null);
      
    } catch (e) {
      _updateStatus(SyncServiceStatus.failed);
      return Left(SyncFailure('Failed to initialize Gasometer sync: $e'));
    }
  }
  
  @override
  bool get canSync => _isInitialized && _canSync;
  
  @override
  Future<bool> get hasPendingSync async => _hasPendingSync;
  
  @override
  Stream<SyncServiceStatus> get statusStream => _statusController.stream;
  
  @override
  Stream<ServiceProgress> get progressStream => _progressController.stream;
  
  @override
  Future<Either<Failure, SyncResult>> sync() async {
    if (!canSync) {
      return Left(SyncFailure('Gasometer sync service cannot sync in current state'));
    }
    
    try {
      _updateStatus(SyncServiceStatus.syncing);
      _hasPendingSync = false;
      _totalSyncs++;
      
      final startTime = DateTime.now();
      
      developer.log(
        'Starting full sync for Gasometer entities',
        name: 'GasometerSync',
      );
      
      int totalSynced = 0;
      
      // Sincronizar cada tipo de entidade
      for (int i = 0; i < _entityTypes.length; i++) {
        final entityType = _entityTypes[i];
        
        _emitProgress(ServiceProgress(
          serviceId: serviceId,
          operation: 'Syncing $entityType',
          current: i + 1,
          total: _entityTypes.length,
          currentItem: entityType,
        ));
        
        // Simular sincronização de entidade
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Simular items sincronizados por entidade
        final itemsCount = _getEntityItemsCount(entityType);
        totalSynced += itemsCount;
        
        developer.log(
          'Synced $itemsCount items for $entityType',
          name: 'GasometerSync',
        );
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      _lastSync = endTime;
      _successfulSyncs++;
      _totalItemsSynced += totalSynced;
      _updateStatus(SyncServiceStatus.completed);
      
      final result = SyncResult(
        success: true,
        itemsSynced: totalSynced,
        duration: duration,
        metadata: {
          'entities_synced': _entityTypes,
          'app': 'gasometer',
          'sync_type': 'full',
        },
      );
      
      developer.log(
        'Gasometer sync completed: $totalSynced items in ${duration.inMilliseconds}ms',
        name: 'GasometerSync',
      );
      
      return Right(result);
      
    } catch (e) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);
      return Left(SyncFailure('Gasometer sync failed: $e'));
    }
  }
  
  @override
  Future<Either<Failure, SyncResult>> syncSpecific(List<String> ids) async {
    if (!canSync) {
      return Left(SyncFailure('Gasometer sync service cannot sync in current state'));
    }
    
    try {
      _updateStatus(SyncServiceStatus.syncing);
      final startTime = DateTime.now();
      
      developer.log(
        'Starting specific sync for Gasometer items: ${ids.length}',
        name: 'GasometerSync',
      );
      
      // Simular sync de items específicos
      await Future.delayed(Duration(milliseconds: ids.length * 50));
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      _lastSync = endTime;
      _successfulSyncs++;
      _totalItemsSynced += ids.length;
      _updateStatus(SyncServiceStatus.completed);
      
      final result = SyncResult(
        success: true,
        itemsSynced: ids.length,
        duration: duration,
        metadata: {
          'sync_type': 'specific',
          'item_ids': ids,
          'app': 'gasometer',
        },
      );
      
      return Right(result);
      
    } catch (e) {
      _failedSyncs++;
      _updateStatus(SyncServiceStatus.failed);
      return Left(SyncFailure('Gasometer specific sync failed: $e'));
    }
  }
  
  @override
  Future<void> stopSync() async {
    _updateStatus(SyncServiceStatus.paused);
    developer.log('Gasometer sync stopped', name: 'GasometerSync');
  }
  
  @override
  Future<bool> checkConnectivity() async {
    // Verificação específica para Gasometer pode incluir endpoints financeiros
    return true; // Implementação simplificada
  }
  
  @override
  Future<Either<Failure, void>> clearLocalData() async {
    try {
      developer.log(
        'Clearing local data for Gasometer',
        name: 'GasometerSync',
      );
      
      _lastSync = null;
      _hasPendingSync = false;
      _totalSyncs = 0;
      _successfulSyncs = 0;
      _failedSyncs = 0;
      _totalItemsSynced = 0;
      
      return const Right(null);
      
    } catch (e) {
      return Left(CacheFailure('Failed to clear Gasometer local data: $e'));
    }
  }
  
  @override
  Future<SyncStatistics> getStatistics() async {
    return SyncStatistics(
      serviceId: serviceId,
      totalSyncs: _totalSyncs,
      successfulSyncs: _successfulSyncs,
      failedSyncs: _failedSyncs,
      lastSyncTime: _lastSync,
      totalItemsSynced: _totalItemsSynced,
      metadata: {
        'entity_types': _entityTypes,
        'avg_items_per_sync': _successfulSyncs > 0 ? (_totalItemsSynced / _successfulSyncs).round() : 0,
      },
    );
  }
  
  @override
  Future<void> dispose() async {
    developer.log(
      'Disposing Gasometer Sync Service',
      name: 'GasometerSync',
    );
    
    await _statusController.close();
    await _progressController.close();
    
    _isInitialized = false;
    _updateStatus(SyncServiceStatus.disposing);
  }
  
  // Métodos específicos do Gasometer
  
  /// Force sync específico para dados financeiros (alta prioridade)
  Future<Either<Failure, SyncResult>> syncFinancialData() async {
    final financialEntities = ['expenses', 'fuel_records', 'maintenance_records'];
    return await syncSpecific(financialEntities);
  }
  
  /// Sync apenas veículos (usado frequentemente)
  Future<Either<Failure, SyncResult>> syncVehicles() async {
    return await syncSpecific(['vehicles']);
  }
  
  /// Marca dados como pendentes (usado quando offline)
  void markDataAsPending() {
    _hasPendingSync = true;
    developer.log('Gasometer data marked as pending sync', name: 'GasometerSync');
  }
  
  // Métodos privados
  
  void _updateStatus(SyncServiceStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
      
      developer.log(
        'Gasometer sync status changed to ${status.name}',
        name: 'GasometerSync',
      );
    }
  }
  
  void _emitProgress(ServiceProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
  
  int _getEntityItemsCount(String entityType) {
    // Simular contagem de items por tipo de entidade
    switch (entityType) {
      case 'vehicles':
        return 3; // Poucos veículos por usuário
      case 'fuel_records':
        return 15; // Muitos registros de combustível
      case 'maintenance_records':
        return 8; // Registros de manutenção moderados
      case 'expenses':
        return 12; // Várias despesas
      case 'categories':
        return 5; // Poucas categorias
      default:
        return 1;
    }
  }
}

/// Factory para criar GasometerSyncService
class GasometerSyncServiceFactory {
  static GasometerSyncService create() {
    return GasometerSyncService();
  }
  
  /// Registra o serviço no SyncServiceFactory global
  static void registerInFactory() {
    // Este método será chamado durante a inicialização do app
    // SyncServiceFactory.instance.register(
    //   'gasometer',
    //   () => GasometerSyncServiceFactory.create(),
    //   displayName: 'Gasometer Vehicle Sync',
    //   description: 'Sync service for vehicle, fuel, and maintenance data',
    //   version: '1.0.0',
    // );
  }
}