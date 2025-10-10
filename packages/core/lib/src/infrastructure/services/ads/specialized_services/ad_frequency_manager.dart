import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import '../../../../domain/entities/ads/ad_frequency_config.dart';
import '../../../../shared/utils/ads_failures.dart';
import '../../../../shared/utils/failure.dart';
import '../models/ad_frequency_state_model.dart';

/// Specialized service for ad frequency management
/// Responsible for tracking and enforcing frequency caps
/// Follows SRP - Single Responsibility: Frequency Capping
class AdFrequencyManager {
  static const String _boxName = 'ads_frequency';

  Box<AdFrequencyStateModel>? _frequencyBox;

  /// Initialize the service
  Future<Either<Failure, void>> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(41)) {
        // Will be registered after code generation
        // Hive.registerAdapter(AdFrequencyStateModelAdapter());
      }

      // Open Hive box
      _frequencyBox = await Hive.openBox<AdFrequencyStateModel>(_boxName);

      // Reset session counters on app start
      await _resetAllSessionCounters();

      return Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to initialize frequency manager: ${e.toString()}',
          code: 'FREQUENCY_INIT_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Check if ad can be shown based on frequency config
  Future<Either<Failure, bool>> canShowAd({
    required String placement,
    required AdFrequencyConfig config,
  }) async {
    try {
      if (_frequencyBox == null) {
        return Left(
          CacheFailure('Frequency manager not initialized'),
        );
      }

      // If frequency capping is disabled, always allow
      if (!config.isEnabled) {
        return Right(true);
      }

      // Get or create state
      final state = _getOrCreateState(placement);

      // Check daily limit
      if (state.isDailyLimitReached(config.maxAdsPerDay)) {
        return Left(AdFrequencyCapFailure.dailyLimitReached());
      }

      // Check session limit
      if (state.isSessionLimitReached(config.maxAdsPerSession)) {
        return Left(AdFrequencyCapFailure.sessionLimitReached());
      }

      // Check hourly limit
      if (config.maxAdsPerHour != null &&
          state.isHourlyLimitReached(config.maxAdsPerHour!)) {
        return Left(AdFrequencyCapFailure.hourlyLimitReached());
      }

      // Check minimum interval
      if (!state.hasMinIntervalPassed(config.minIntervalSeconds)) {
        return Left(AdFrequencyCapFailure.tooSoon());
      }

      return Right(true);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to check frequency: ${e.toString()}',
          code: 'FREQUENCY_CHECK_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Record that an ad was shown
  Future<Either<Failure, void>> recordAdShown(String placement) async {
    try {
      if (_frequencyBox == null) {
        return Left(
          CacheFailure('Frequency manager not initialized'),
        );
      }

      final state = _getOrCreateState(placement);
      state.incrementCounters();

      // Save to Hive
      await _frequencyBox!.put(placement, state);

      return Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to record ad shown: ${e.toString()}',
          code: 'RECORD_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Get ad show count for placement
  Future<Either<Failure, int>> getAdShowCount(String placement) async {
    try {
      if (_frequencyBox == null) {
        return Left(
          CacheFailure('Frequency manager not initialized'),
        );
      }

      final state = _frequencyBox!.get(placement);
      if (state == null) {
        return Right(0);
      }

      return Right(state.totalCount);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to get show count: ${e.toString()}',
          code: 'GET_COUNT_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Reset frequency counters for placement
  Future<Either<Failure, void>> resetFrequency(String placement) async {
    try {
      if (_frequencyBox == null) {
        return Left(
          CacheFailure('Frequency manager not initialized'),
        );
      }

      final state = _frequencyBox!.get(placement);
      if (state != null) {
        state.resetAll();
        await _frequencyBox!.put(placement, state);
      }

      return Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to reset frequency: ${e.toString()}',
          code: 'RESET_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Reset all frequency counters
  Future<Either<Failure, void>> resetAllFrequencies() async {
    try {
      if (_frequencyBox == null) {
        return Left(
          CacheFailure('Frequency manager not initialized'),
        );
      }

      for (final key in _frequencyBox!.keys) {
        final state = _frequencyBox!.get(key);
        if (state != null) {
          state.resetAll();
          await _frequencyBox!.put(key, state);
        }
      }

      return Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to reset all frequencies: ${e.toString()}',
          code: 'RESET_ALL_FAILED',
          details: e,
        ),
      );
    }
  }

  /// Get or create frequency state for placement
  AdFrequencyStateModel _getOrCreateState(String placement) {
    final existing = _frequencyBox!.get(placement);
    if (existing != null) {
      return existing;
    }

    final newState = AdFrequencyStateModel.initial(placement);
    _frequencyBox!.put(placement, newState);
    return newState;
  }

  /// Reset session counters for all placements
  Future<void> _resetAllSessionCounters() async {
    if (_frequencyBox == null) return;

    for (final key in _frequencyBox!.keys) {
      final state = _frequencyBox!.get(key);
      if (state != null) {
        state.resetSession();
        await _frequencyBox!.put(key, state);
      }
    }
  }

  /// Get statistics for all placements
  Map<String, Map<String, int>> getStatistics() {
    if (_frequencyBox == null) return {};

    final stats = <String, Map<String, int>>{};
    for (final key in _frequencyBox!.keys) {
      if (key is! String) continue;
      final state = _frequencyBox!.get(key);
      if (state != null) {
        stats[key] = {
          'daily': state.dailyCount,
          'session': state.sessionCount,
          'hourly': state.hourlyCount,
          'total': state.totalCount,
        };
      }
    }
    return stats;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _frequencyBox?.close();
    _frequencyBox = null;
  }
}
