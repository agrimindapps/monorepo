import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/livestock_repository.dart';

/// Provider especializado para sincronização de dados de livestock
/// 
/// Responsabilidade única: Gerenciar sincronização de dados remotos
/// Seguindo Single Responsibility Principle
@singleton
class LivestockSyncProvider extends ChangeNotifier {
  final LivestockRepository _repository;

  LivestockSyncProvider({
    required LivestockRepository repository,
  }) : _repository = repository;

  // === STATE MANAGEMENT ===
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _errorMessage;
  SyncStatus _syncStatus = SyncStatus.idle;
  double _syncProgress = 0.0;

  // === GETTERS ===
  
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  SyncStatus get syncStatus => _syncStatus;
  double get syncProgress => _syncProgress;
  
  bool get hasSync => _lastSyncTime != null;
  bool get needsSync => 
    _lastSyncTime == null || 
    DateTime.now().difference(_lastSyncTime!).inHours > 1;
    
  String get lastSyncFormatted {
    if (_lastSyncTime == null) return 'Nunca sincronizado';
    
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays} dias atrás';
    }
  }

  // === SYNC OPERATIONS ===

  /// Força sincronização manual
  Future<bool> forceSyncNow({
    void Function(double)? onProgress,
    bool showProgress = true,
  }) async {
    if (_isSyncing) {
      debugPrint('LivestockSyncProvider: Sincronização já em andamento');
      return false;
    }

    _isSyncing = true;
    _errorMessage = null;
    _syncStatus = SyncStatus.syncing;
    _syncProgress = 0.0;
    notifyListeners();

    try {
      // Simula progresso se callback fornecido
      if (showProgress && onProgress != null) {
        _updateProgress(0.1, onProgress);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      final result = await _repository.syncLivestockData();
      
      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _syncStatus = SyncStatus.error;
          debugPrint('LivestockSyncProvider: Erro na sincronização - ${failure.message}');
          return false;
        },
        (_) {
          _lastSyncTime = DateTime.now();
          _syncStatus = SyncStatus.success;
          _syncProgress = 1.0;
          debugPrint('LivestockSyncProvider: Sincronização realizada com sucesso');
          
          if (showProgress && onProgress != null) {
            onProgress(1.0);
          }
          
          return true;
        },
      );
    } catch (e, stackTrace) {
      _errorMessage = 'Erro inesperado na sincronização: $e';
      _syncStatus = SyncStatus.error;
      debugPrint('LivestockSyncProvider: Erro inesperado - $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
      
      // Reset status após 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (_syncStatus != SyncStatus.idle) {
          _syncStatus = SyncStatus.idle;
          notifyListeners();
        }
      });
    }
  }

  /// Sincronização silenciosa em background
  Future<bool> backgroundSync() async {
    if (_isSyncing || !needsSync) {
      return false;
    }

    debugPrint('LivestockSyncProvider: Iniciando sincronização em background');
    return await forceSyncNow(showProgress: false);
  }

  /// Cancela sincronização se possível
  void cancelSync() {
    if (_isSyncing) {
      _syncStatus = SyncStatus.cancelled;
      debugPrint('LivestockSyncProvider: Sincronização cancelada pelo usuário');
      notifyListeners();
    }
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    _syncStatus = SyncStatus.idle;
    notifyListeners();
  }

  /// Reset completo do estado de sincronização
  void resetSyncState() {
    _lastSyncTime = null;
    _errorMessage = null;
    _syncStatus = SyncStatus.idle;
    _syncProgress = 0.0;
    notifyListeners();
  }

  // === PRIVATE METHODS ===

  void _updateProgress(double progress, void Function(double) onProgress) {
    _syncProgress = progress;
    onProgress(progress);
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('LivestockSyncProvider: Disposed');
    super.dispose();
  }
}

/// Status da sincronização
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  cancelled,
}