import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/favoritos/presentation/notifiers/favoritos_notifier.dart';
import '../services/receituagro_realtime_service.dart';
import 'core_providers.dart';

part 'realtime_sync_notifier.g.dart';

/// Provider para monitorar mudanças em tempo real do Firebase
/// e sincronizar diretamente com o Drift (banco local)
@Riverpod(keepAlive: true)
class RealtimeSyncNotifier extends _$RealtimeSyncNotifier {
  final List<StreamSubscription<void>> _subscriptions = [];
  String? _currentUserId;

  @override
  Future<void> build() async {
    developer.log(
      '[RealtimeSync] Initializing Drift-based realtime sync',
      name: 'RealtimeSync',
    );

    // Escuta mudanças no estado de autenticação
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUserId) {
        _currentUserId = user.uid;
        _setupRealtimeListeners(user.uid);
      } else if (user == null) {
        _cancelSubscriptions();
        _currentUserId = null;
      }
    });

    // Se já está logado, configura listeners
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      _setupRealtimeListeners(currentUser.uid);
    }

    ref.onDispose(() {
      _cancelSubscriptions();
    });
  }

  /// Configura listeners de tempo real para cada coleção
  void _setupRealtimeListeners(String userId) {
    _cancelSubscriptions();

    developer.log(
      '[RealtimeSync] Setting up realtime listeners for user: $userId',
      name: 'RealtimeSync',
    );

    // Listener para Favoritos - salva no Drift e invalida provider
    final favoritosAdapter = ref.read(favoritosSyncAdapterProvider);
    _subscriptions.add(
      favoritosAdapter.watchRemoteChanges(userId).listen(
        (_) {
          developer.log(
            '[RealtimeSync] Favoritos updated from Firebase -> Drift',
            name: 'RealtimeSync',
          );
          // Invalida o provider de favoritos para atualizar a UI
          ref.invalidate(favoritosProvider);
        },
        onError: (Object e) {
          developer.log(
            '[RealtimeSync] Error in favoritos stream: $e',
            name: 'RealtimeSync',
          );
        },
      ),
    );

    // Listener para Comentários - salva no Drift e invalida provider
    final comentariosAdapter = ref.read(comentariosSyncAdapterProvider);
    _subscriptions.add(
      comentariosAdapter.watchRemoteChanges(userId).listen(
        (_) {
          developer.log(
            '[RealtimeSync] Comentarios updated from Firebase -> Drift',
            name: 'RealtimeSync',
          );
          // TODO: Invalida o provider de comentários quando existir
        },
        onError: (Object e) {
          developer.log(
            '[RealtimeSync] Error in comentarios stream: $e',
            name: 'RealtimeSync',
          );
        },
      ),
    );

    developer.log(
      '[RealtimeSync] Realtime listeners active for: favoritos, comentarios',
      name: 'RealtimeSync',
    );
  }

  /// Cancela todas as subscriptions ativas
  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    developer.log(
      '[RealtimeSync] Subscriptions cancelled',
      name: 'RealtimeSync',
    );
  }

  /// Força uma sincronização manual
  Future<void> forceSync() async {
    try {
      await ReceitaAgroRealtimeService.instance.forceSync();
      // Invalida os providers para forçar atualização da UI
      ref.invalidate(favoritosProvider);
      developer.log(
        '[RealtimeSync] Force sync completed and providers invalidated',
        name: 'RealtimeSync',
      );
    } catch (e) {
      developer.log(
        '[RealtimeSync] Error forcing sync: $e',
        name: 'RealtimeSync',
      );
    }
  }
}
