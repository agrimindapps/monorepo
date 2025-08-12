/// Monitor para detectar vazamentos de memória em stream subscriptions
library;

// Dart imports:
import 'dart:async';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../constants/timeout_constants.dart';
import 'composite_subscription.dart';

/// Detector de vazamentos de memória para subscriptions
class MemoryLeakDetector {
  static final MemoryLeakDetector _instance = MemoryLeakDetector._internal();
  factory MemoryLeakDetector() => _instance;
  MemoryLeakDetector._internal();

  static MemoryLeakDetector get instance => _instance;

  final Map<String, Set<String>> _activeSubscriptions = {};
  final Map<String, DateTime> _subscriptionTimestamps = {};

  /// Registrar uma nova subscription
  void registerSubscription(String ownerId, String subscriptionId,
      {String? description}) {
    _activeSubscriptions.putIfAbsent(ownerId, () => <String>{});
    _activeSubscriptions[ownerId]!.add(subscriptionId);
    _subscriptionTimestamps[subscriptionId] = DateTime.now();

    if (kDebugMode) {
      log('📈 Subscription registered: $subscriptionId for $ownerId ${description != null ? '($description)' : ''}',
          name: 'MemoryLeakDetector');
    }
  }

  /// Remover uma subscription quando cancelada
  void unregisterSubscription(String ownerId, String subscriptionId) {
    _activeSubscriptions[ownerId]?.remove(subscriptionId);
    _subscriptionTimestamps.remove(subscriptionId);

    if (kDebugMode) {
      log('📉 Subscription unregistered: $subscriptionId for $ownerId',
          name: 'MemoryLeakDetector');
    }

    // Remover owner se não tem mais subscriptions
    if (_activeSubscriptions[ownerId]?.isEmpty ?? false) {
      _activeSubscriptions.remove(ownerId);
    }
  }

  /// Dispose completo de um owner (controller, widget, etc.)
  void disposeOwner(String ownerId) {
    final subscriptions = _activeSubscriptions.remove(ownerId);

    if (subscriptions != null && subscriptions.isNotEmpty) {
      if (kDebugMode) {
        log('⚠️ MEMORY LEAK DETECTED: $ownerId disposed with ${subscriptions.length} active subscriptions: $subscriptions',
            name: 'MemoryLeakDetector');
      }

      // Remover timestamps das subscriptions do owner
      for (final subscriptionId in subscriptions) {
        _subscriptionTimestamps.remove(subscriptionId);
      }
    } else {
      if (kDebugMode) {
        log('✅ Owner disposed cleanly: $ownerId', name: 'MemoryLeakDetector');
      }
    }
  }

  /// Obter estatísticas atuais
  MemoryLeakStats getStats() {
    final totalSubscriptions = _subscriptionTimestamps.length;
    final totalOwners = _activeSubscriptions.length;
    final oldSubscriptions = _getOldSubscriptions();

    return MemoryLeakStats(
      totalActiveSubscriptions: totalSubscriptions,
      totalActiveOwners: totalOwners,
      oldSubscriptions: oldSubscriptions,
      ownerDetails: Map.from(_activeSubscriptions),
    );
  }

  /// Obter subscriptions antigas (possivelmente vazadas)
  List<String> _getOldSubscriptions(
      {Duration threshold = TimeoutConstants.memoryCheckInterval}) {
    final now = DateTime.now();
    final oldSubscriptions = <String>[];

    _subscriptionTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp) > threshold) {
        oldSubscriptions.add(id);
      }
    });

    return oldSubscriptions;
  }

  /// Log de estatísticas completas
  void logStats() {
    final stats = getStats();

    if (kDebugMode) {
      log('📊 Memory Leak Stats:', name: 'MemoryLeakDetector');
      log('  - Total subscriptions: ${stats.totalActiveSubscriptions}',
          name: 'MemoryLeakDetector');
      log('  - Total owners: ${stats.totalActiveOwners}',
          name: 'MemoryLeakDetector');
      log('  - Old subscriptions: ${stats.oldSubscriptions.length}',
          name: 'MemoryLeakDetector');

      if (stats.oldSubscriptions.isNotEmpty) {
        log('  ⚠️ Potentially leaked subscriptions: ${stats.oldSubscriptions}',
            name: 'MemoryLeakDetector');
      }

      stats.ownerDetails.forEach((owner, subscriptions) {
        log('  - $owner: ${subscriptions.length} subscriptions',
            name: 'MemoryLeakDetector');
      });
    }
  }

  /// Detectar vazamentos automaticamente
  void detectLeaks() {
    final stats = getStats();

    if (stats.oldSubscriptions.isNotEmpty) {
      if (kDebugMode) {
        log('🚨 MEMORY LEAK ALERT: Found ${stats.oldSubscriptions.length} old subscriptions',
            name: 'MemoryLeakDetector');

        for (final subscriptionId in stats.oldSubscriptions) {
          final timestamp = _subscriptionTimestamps[subscriptionId];
          if (timestamp != null) {
            final age = DateTime.now().difference(timestamp);
            log('  - $subscriptionId (age: ${age.inMinutes} minutes)',
                name: 'MemoryLeakDetector');
          }
        }
      }
    }
  }

  /// Limpar todas as estatísticas (útil para testes)
  void clear() {
    _activeSubscriptions.clear();
    _subscriptionTimestamps.clear();
  }
}

/// Dados estatísticos sobre vazamentos de memória
class MemoryLeakStats {
  final int totalActiveSubscriptions;
  final int totalActiveOwners;
  final List<String> oldSubscriptions;
  final Map<String, Set<String>> ownerDetails;

  const MemoryLeakStats({
    required this.totalActiveSubscriptions,
    required this.totalActiveOwners,
    required this.oldSubscriptions,
    required this.ownerDetails,
  });

  bool get hasLeaks => oldSubscriptions.isNotEmpty;

  @override
  String toString() {
    return 'MemoryLeakStats(subscriptions: $totalActiveSubscriptions, owners: $totalActiveOwners, leaks: ${oldSubscriptions.length})';
  }
}

/// Extensão para CompositeSubscription com monitoring
extension CompositeSubscriptionMonitoring on CompositeSubscription {
  /// Adiciona subscription com monitoring automático
  StreamSubscription<T> addListenWithMonitoring<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    required String ownerId,
    String? description,
  }) {
    final subscriptionId =
        '${ownerId}_${DateTime.now().millisecondsSinceEpoch}';

    final subscription = stream.listen(
      onData,
      onError: onError,
      onDone: () {
        MemoryLeakDetector.instance
            .unregisterSubscription(ownerId, subscriptionId);
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );

    MemoryLeakDetector.instance.registerSubscription(ownerId, subscriptionId,
        description: description);
    add(subscription);

    return subscription;
  }
}

/// Mixin atualizado com monitoring
mixin SubscriptionManagerMixinWithMonitoring {
  final CompositeSubscription _subscriptions = CompositeSubscription();

  /// ID único para este owner (deve ser implementado pela classe)
  String get ownerId;

  /// Getter para acessar o composite subscription
  CompositeSubscription get subscriptions => _subscriptions;

  /// Listen com monitoring automático
  StreamSubscription<T> listenToWithMonitoring<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    String? description,
  }) {
    return _subscriptions.addListenWithMonitoring(
      stream,
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
      ownerId: ownerId,
      description: description,
    );
  }

  /// Dispose com monitoring
  void disposeSubscriptionsWithMonitoring() {
    MemoryLeakDetector.instance.disposeOwner(ownerId);
    _subscriptions.dispose();
  }
}
