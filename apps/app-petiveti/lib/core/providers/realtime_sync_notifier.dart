import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/animals/presentation/providers/animals_providers.dart';
import '../../features/appointments/presentation/providers/appointments_providers.dart';
import '../../features/medications/presentation/providers/medications_providers.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../../features/weight/presentation/providers/weight_providers.dart';
import 'core_services_providers.dart';

part 'realtime_sync_notifier.g.dart';

/// Estado do realtime sync
class RealtimeSyncState {
  const RealtimeSyncState({
    this.isListening = false,
    this.lastSyncTime,
    this.error,
  });

  final bool isListening;
  final DateTime? lastSyncTime;
  final String? error;

  RealtimeSyncState copyWith({
    bool? isListening,
    DateTime? lastSyncTime,
    String? error,
  }) {
    return RealtimeSyncState(
      isListening: isListening ?? this.isListening,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      error: error,
    );
  }
}

/// Notifier para sincronização em tempo real com Firebase
/// Escuta mudanças em coleções e atualiza o banco local + invalida providers
@Riverpod(keepAlive: true)
class RealtimeSyncNotifier extends _$RealtimeSyncNotifier {
  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};
  String? _userId;

  @override
  RealtimeSyncState build() {
    ref.onDispose(_disposeSubscriptions);
    return const RealtimeSyncState();
  }

  void _disposeSubscriptions() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  /// Inicia o listener de sync para o usuário
  Future<void> startListening(String userId) async {
    if (_userId == userId && state.isListening) {
      debugPrint('[PetivetiRealtimeSync] Already listening for user: $userId');
      return;
    }

    _userId = userId;
    _disposeSubscriptions();

    try {
      final firestore = ref.read(firebaseFirestoreProvider);

      // Escuta animals
      _setupCollectionListener(
        firestore: firestore,
        userId: userId,
        collectionName: 'animals',
        onData: _handleAnimalsChange,
      );

      // Escuta medications
      _setupCollectionListener(
        firestore: firestore,
        userId: userId,
        collectionName: 'medications',
        onData: _handleMedicationsChange,
      );

      // Escuta appointments
      _setupCollectionListener(
        firestore: firestore,
        userId: userId,
        collectionName: 'appointments',
        onData: _handleAppointmentsChange,
      );

      // Escuta weights
      _setupCollectionListener(
        firestore: firestore,
        userId: userId,
        collectionName: 'weights',
        onData: _handleWeightsChange,
      );

      // Escuta user_settings
      _setupCollectionListener(
        firestore: firestore,
        userId: userId,
        collectionName: 'user_settings',
        onData: _handleUserSettingsChange,
      );

      state = state.copyWith(isListening: true, error: null);
      debugPrint('[PetivetiRealtimeSync] Started listening for user: $userId');
    } catch (e) {
      debugPrint('[PetivetiRealtimeSync] Error starting listeners: $e');
      state = state.copyWith(isListening: false, error: e.toString());
    }
  }

  /// Para de escutar mudanças
  void stopListening() {
    _disposeSubscriptions();
    _userId = null;
    state = state.copyWith(isListening: false);
    debugPrint('[PetivetiRealtimeSync] Stopped listening');
  }

  /// Configura listener para uma coleção
  void _setupCollectionListener({
    required FirebaseFirestore firestore,
    required String userId,
    required String collectionName,
    required void Function(QuerySnapshot) onData,
  }) {
    // ignore: cancel_subscriptions - stored in _subscriptions and cancelled in _disposeSubscriptions
    final subscription = firestore
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .snapshots()
        .listen(
          onData,
          onError: (Object error) {
            debugPrint(
              '[PetivetiRealtimeSync] Error in $collectionName listener: $error',
            );
          },
        );

    _subscriptions[collectionName] = subscription;
  }

  /// Processa mudanças em animals
  void _handleAnimalsChange(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return;

    debugPrint(
      '[PetivetiRealtimeSync] Animals changed: ${snapshot.docChanges.length} docs',
    );

    // Invalida providers relacionados para recarregar dados
    ref.invalidate(animalsProvider);
    ref.invalidate(animalsStreamProvider);

    state = state.copyWith(lastSyncTime: DateTime.now());
  }

  /// Processa mudanças em medications
  void _handleMedicationsChange(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return;

    debugPrint(
      '[PetivetiRealtimeSync] Medications changed: ${snapshot.docChanges.length} docs',
    );

    // Invalida providers relacionados para recarregar dados
    ref.invalidate(medicationsProvider);
    ref.invalidate(medicationsStreamProvider);
    ref.invalidate(activeMedicationsStreamProvider);

    state = state.copyWith(lastSyncTime: DateTime.now());
  }

  /// Processa mudanças em appointments
  void _handleAppointmentsChange(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return;

    debugPrint(
      '[PetivetiRealtimeSync] Appointments changed: ${snapshot.docChanges.length} docs',
    );

    // Invalida providers relacionados para recarregar dados
    ref.invalidate(appointmentsProvider);

    state = state.copyWith(lastSyncTime: DateTime.now());
  }

  /// Processa mudanças em weights
  void _handleWeightsChange(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return;

    debugPrint(
      '[PetivetiRealtimeSync] Weights changed: ${snapshot.docChanges.length} docs',
    );

    // Invalida providers relacionados para recarregar dados
    ref.invalidate(weightsProvider);

    state = state.copyWith(lastSyncTime: DateTime.now());
  }

  /// Processa mudanças em user_settings
  void _handleUserSettingsChange(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) return;

    debugPrint(
      '[PetivetiRealtimeSync] UserSettings changed: ${snapshot.docChanges.length} docs',
    );

    // Invalida providers relacionados para recarregar dados
    ref.invalidate(settingsProvider);

    state = state.copyWith(lastSyncTime: DateTime.now());
  }
}
