import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../database/sync/adapters/favoritos_drift_sync_adapter.dart';
import '../../../database/sync/adapters/comentarios_drift_sync_adapter.dart';
import '../../../database/sync/models/sync_results.dart';

/// Coordenador de Sincronização (Sync Coordinator)
///
/// Responsável por orquestrar a sincronização de todas as entidades do app.
/// Implementa o padrão "Store-Forward" (Offline-First).
///
/// **Funcionalidades:**
/// - Monitora conectividade
/// - Dispara sincronização periódica
/// - Gerencia ciclo de vida dos adapters
@lazySingleton
class SyncCoordinator {
  final ConnectivityService _connectivityService;
  final FavoritosDriftSyncAdapter _favoritosAdapter;
  final ComentariosDriftSyncAdapter _comentariosAdapter;

  Timer? _syncTimer;
  bool _isSyncing = false;

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
      }
    });

    // Configura timer periódico (ex: a cada 15 minutos)
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      syncAll();
    });

    // Sync inicial
    syncAll();
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
  }
}
