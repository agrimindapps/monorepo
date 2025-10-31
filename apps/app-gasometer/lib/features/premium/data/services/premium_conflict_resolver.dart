import 'package:injectable/injectable.dart';

import '../../domain/entities/premium_status.dart';

/// Service responsible for resolving conflicts between premium statuses
/// Follows SRP by handling only conflict resolution logic
@lazySingleton
class PremiumConflictResolver {
  /// Resolve conflict between two premium statuses
  ///
  /// Resolution rules:
  /// 1. If one is premium and other is not, choose premium
  /// 2. If both are premium, choose the one with later expiration
  /// 3. If neither is premium, choose local status
  PremiumStatus resolveConflict(
    PremiumStatus localStatus,
    PremiumStatus remoteStatus,
  ) {
    // Rule 1: One premium, one free
    if (localStatus.isPremium && !remoteStatus.isPremium) {
      return localStatus;
    }
    if (!localStatus.isPremium && remoteStatus.isPremium) {
      return remoteStatus;
    }

    // Rule 2: Both premium - choose latest expiration
    if (localStatus.isPremium && remoteStatus.isPremium) {
      return _resolveByExpiration(localStatus, remoteStatus);
    }

    // Rule 3: Both free - prefer local
    return localStatus;
  }

  /// Resolve conflict with source priority
  /// Higher priority sources override lower priority ones
  PremiumStatus resolveConflictWithPriority(
    PremiumStatus currentStatus,
    PremiumStatus newStatus,
    PremiumSyncSource source,
  ) {
    final sourcePriority = _getSourcePriority(source);

    // If new status is from higher priority source, use it
    if (sourcePriority >= 2) {
      return newStatus;
    }

    // Otherwise, use conflict resolution rules
    return resolveConflict(currentStatus, newStatus);
  }

  /// Check if statuses are effectively equal
  bool areStatusesEqual(PremiumStatus a, PremiumStatus b) {
    if (a.isPremium != b.isPremium) return false;
    if (a.isExpired != b.isExpired) return false;
    if (a.premiumSource != b.premiumSource) return false;

    // Compare expiration dates (with tolerance of 1 second)
    if (a.expirationDate != null && b.expirationDate != null) {
      final diff = a.expirationDate!.difference(b.expirationDate!).abs();
      return diff.inSeconds <= 1;
    }

    return a.expirationDate == b.expirationDate;
  }

  /// Check if status needs update
  bool needsUpdate(PremiumStatus current, PremiumStatus newStatus) {
    return !areStatusesEqual(current, newStatus);
  }

  /// Merge multiple statuses into one (most permissive wins)
  PremiumStatus mergeStatuses(List<PremiumStatus> statuses) {
    if (statuses.isEmpty) return PremiumStatus.free;
    if (statuses.length == 1) return statuses.first;

    // Find the most permissive status
    var result = statuses.first;

    for (var i = 1; i < statuses.length; i++) {
      result = resolveConflict(result, statuses[i]);
    }

    return result;
  }

  /// Validate status consistency
  bool isStatusValid(PremiumStatus status) {
    // Check if expired status is marked as expired
    if (status.expirationDate != null) {
      final isExpired = DateTime.now().isAfter(status.expirationDate!);
      if (isExpired != status.isExpired) {
        return false;
      }
    }

    // Check if premium without expiration (should not happen)
    if (status.isPremium &&
        status.premiumSource != 'local_license' &&
        status.expirationDate == null) {
      return false;
    }

    return true;
  }

  /// Get recommended action based on conflict
  ConflictResolutionAction getRecommendedAction(
    PremiumStatus localStatus,
    PremiumStatus remoteStatus,
  ) {
    if (areStatusesEqual(localStatus, remoteStatus)) {
      return ConflictResolutionAction.noAction;
    }

    if (localStatus.isPremium && !remoteStatus.isPremium) {
      return ConflictResolutionAction.syncToRemote;
    }

    if (!localStatus.isPremium && remoteStatus.isPremium) {
      return ConflictResolutionAction.syncToLocal;
    }

    if (localStatus.isPremium && remoteStatus.isPremium) {
      final resolved = _resolveByExpiration(localStatus, remoteStatus);
      if (areStatusesEqual(resolved, localStatus)) {
        return ConflictResolutionAction.syncToRemote;
      } else {
        return ConflictResolutionAction.syncToLocal;
      }
    }

    return ConflictResolutionAction.noAction;
  }

  // Private helper methods

  PremiumStatus _resolveByExpiration(
    PremiumStatus status1,
    PremiumStatus status2,
  ) {
    if (status1.expirationDate != null && status2.expirationDate != null) {
      return status1.expirationDate!.isAfter(status2.expirationDate!)
          ? status1
          : status2;
    }

    // Prefer status with expiration date
    if (status1.expirationDate != null) return status1;
    if (status2.expirationDate != null) return status2;

    // Both null - prefer first
    return status1;
  }

  int _getSourcePriority(PremiumSyncSource source) {
    switch (source) {
      case PremiumSyncSource.revenueCat:
        return 3; // Highest priority
      case PremiumSyncSource.firebase:
        return 2;
      case PremiumSyncSource.webhook:
        return 2;
      case PremiumSyncSource.localCache:
        return 1; // Lowest priority
    }
  }
}

/// Enum for conflict resolution actions
enum ConflictResolutionAction {
  noAction,
  syncToLocal,
  syncToRemote,
  requiresManualResolution,
}

/// Enum for premium sync sources
enum PremiumSyncSource { revenueCat, firebase, webhook, localCache }
