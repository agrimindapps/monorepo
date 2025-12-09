import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../database/sync/adapters/comentarios_drift_sync_adapter.dart';
import '../../../database/sync/adapters/favoritos_drift_sync_adapter.dart';

/// Coordenador de Sincronização (Sync Coordinator)
///
/// Responsável por orquestrar a sincronização de todas as entidades do app.
/// Implementa o padrão "Store-Forward" (Offline-First).
///
/// **Funcionalidades:**
/// - Monitora conectividade
/// - Dispara sincronização periódica
/// - Gerencia ciclo de vida dos adapters
/// - Escuta mudanças em tempo real do Firestore

class SyncCoordinator {
  final ConnectivityService _connectivityService;
  final FavoritosDriftSyncAdapter _favoritosAdapter;
  final ComentariosDriftSyncAdapter _comentariosAdapter;

  Timer? _syncTimer;
  bool _isSyncing = false;
  StreamSubscription<void>? _favoritosRealtimeSubscription;
  StreamSubscription<void>? _comentariosRealtimeSubscription;

  SyncCoordinator(
    this._connectivityService,
    this._favoritosAdapter,
    this._comentariosAdapter,
  );

  /// Inicializa o coordenador
  void initialize() {
    developer.log('Inicializando SyncCoordinator...', name: 'SyncCoordinator');

    // Escuta mudanças de conectividade
    _connectivityService.connectivityStream.listen((bool isOnline) {
      if (isOnline) {
        developer.log(
          'Conexão restabelecida. Iniciando sync...',
          name: 'SyncCoordinator',
        );
        syncAll();
        _startRealtimeListeners();
      } else {
        _stopRealtimeListeners();
      }
    });

    // Configura timer periódico (ex: a cada 15 minutos)
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      syncAll();
    });

    // Sync inicial
    syncAll();
    
    // Inicia listeners em tempo real
    _startRealtimeListeners();
  }

  /// Inicia os listeners em tempo real do Firestore
  void _startRealtimeListeners() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      developer.log(
        'Usuário não logado. Realtime listeners não iniciados.',
        name: 'SyncCoordinator',
      );
      return;
    }

    developer.log(
      'Iniciando listeners em tempo real para userId: $userId',
      name: 'SyncCoordinator',
    );

    // Listener de Favoritos
    _favoritosRealtimeSubscription?.cancel();
    _favoritosRealtimeSubscription = _favoritosAdapter.watchRemoteChanges(userId).listen(
      (_) {
        developer.log(
          '✅ [REALTIME] Favoritos atualizados via listener',
          name: 'SyncCoordinator',
        );
      },
      onError: (Object? error) {
        developer.log(
          '❌ [REALTIME] Erro no listener de favoritos: $error',
          name: 'SyncCoordinator',
        );
      },
    );

    // Listener de Comentários
    _comentariosRealtimeSubscription?.cancel();
    _comentariosRealtimeSubscription = _comentariosAdapter.watchRemoteChanges(userId).listen(
      (_) {
        developer.log(
          '✅ [REALTIME] Comentários atualizados via listener',
          name: 'SyncCoordinator',
        );
      },
      onError: (Object? error) {
        developer.log(
          '❌ [REALTIME] Erro no listener de comentários: $error',
          name: 'SyncCoordinator',
        );
      },
    );
  }

  /// Para os listeners em tempo real
  void _stopRealtimeListeners() {
    developer.log(
      'Parando listeners em tempo real',
      name: 'SyncCoordinator',
    );
    _favoritosRealtimeSubscription?.cancel();
    _favoritosRealtimeSubscription = null;
    _comentariosRealtimeSubscription?.cancel();
    _comentariosRealtimeSubscription = null;
  }

  /// Executa sincronização de todas as entidades
  Future<void> syncAll() async {
    if (_isSyncing) {
      developer.log(
        'Sync já em andamento. Ignorando.',
        name: 'SyncCoordinator',
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      developer.log(
        'Usuário não logado. Sync abortado.',
        name: 'SyncCoordinator',
      );
      return;
    }

    _isSyncing = true;
    developer.log(
      'Iniciando sincronização completa...',
      name: 'SyncCoordinator',
    );

    try {
      // 1. Favoritos
      await _syncEntity(
        'Favoritos Push',
        () => _favoritosAdapter.pushDirtyRecords(userId),
      );
      await _syncEntity(
        'Favoritos Pull',
        () => _favoritosAdapter.pullRemoteChanges(userId),
      );

      // 2. Comentários
      await _syncEntity(
        'Comentarios Push',
        () => _comentariosAdapter.pushDirtyRecords(userId),
      );
      await _syncEntity(
        'Comentarios Pull',
        () => _comentariosAdapter.pullRemoteChanges(userId),
      );

      developer.log(
        'Sincronização completa finalizada.',
        name: 'SyncCoordinator',
      );
    } catch (e) {
      developer.log(
        'Erro fatal no SyncCoordinator: $e',
        name: 'SyncCoordinator',
        error: e,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Helper para executar sync de uma entidade com tratamento de erro
  Future<void> _syncEntity(
    String name,
    Future<Either<Failure, dynamic>> Function() syncAction,
  ) async {
    developer.log('Sincronizando $name...', name: 'SyncCoordinator');
    final result = await syncAction();

    result.fold(
      (failure) => developer.log(
        'Erro ao sincronizar $name: ${failure.message}',
        name: 'SyncCoordinator',
      ),
      (success) {
        if (success is SyncPushResult) {
          developer.log(
            'Sync $name concluído: ${success.summary}',
            name: 'SyncCoordinator',
          );
        } else {
          developer.log(
            'Sync $name concluído com sucesso.',
            name: 'SyncCoordinator',
          );
        }
      },
    );
  }

  void dispose() {
    _syncTimer?.cancel();
    _stopRealtimeListeners();
  }
}
