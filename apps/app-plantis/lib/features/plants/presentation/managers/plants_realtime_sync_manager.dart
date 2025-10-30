import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../domain/entities/plant.dart';

/// Manages real-time data synchronization
class PlantsRealtimeSyncManager {
  final Ref ref;

  PlantsRealtimeSyncManager(this.ref);

  /// Convert sync entity to domain Plant
  Plant? convertSyncPlantToDomain(dynamic syncPlant) {
    try {
      if (syncPlant == null) return null;

      if (syncPlant is Plant) {
        if (syncPlant.id.isEmpty) return null;
        return syncPlant;
      }

      if (syncPlant is Map<String, dynamic>) {
        if (!syncPlant.containsKey('id') || !syncPlant.containsKey('name')) {
          return null;
        }
        return Plant.fromJson(syncPlant);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if data has actually changed
  bool hasDataChanged(List<Plant> currentPlants, List<Plant> newPlants) {
    if (currentPlants.length != newPlants.length) {
      return true;
    }

    for (int i = 0; i < currentPlants.length; i++) {
      final currentPlant = currentPlants[i];
      Plant? newPlant;
      try {
        newPlant = newPlants.firstWhere((p) => p.id == currentPlant.id);
      } catch (e) {
        return true;
      }

      if (currentPlant.updatedAt != newPlant.updatedAt) {
        return true;
      }
    }

    return false;
  }

  /// Wait for authentication initialization with timeout
  Future<bool> waitForAuthenticationWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final authStateNotifier = AuthStateNotifier.instance;

    if (authStateNotifier.isInitialized) {
      return true;
    }

    try {
      await authStateNotifier.initializedStream
          .where((isInitialized) => isInitialized)
          .timeout(timeout)
          .first;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    final authStateNotifier = AuthStateNotifier.instance;
    return authStateNotifier.isAuthenticated;
  }
}
