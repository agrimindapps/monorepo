import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/livestock/data/models/livestock_enums_adapter.dart';
import '../../features/markets/data/models/market_enums_adapter.dart';
import '../../features/news/data/models/commodity_price_model.dart';
import '../../features/news/data/models/news_article_model.dart';
import '../../features/weather/data/models/rain_gauge_model.dart';
import '../../features/weather/data/models/weather_measurement_model.dart';
import '../../features/weather/data/models/weather_statistics_model.dart';

/// A utility class to centralize the initialization of Hive and the registration
/// of all `TypeAdapter`s used in the application.
///
/// This ensures that all models are available for local persistence before the
/// app runs.
class HiveInitializer {
  HiveInitializer._();

  /// Initializes Hive and registers all necessary adapters.
  ///
  /// This method should be called once at application startup.
  static Future<void> initialize() async {
    try {
      Logger.info('HiveInitializer: Starting Hive setup...');
      await Hive.initFlutter();

      _registerAuthAdapters();
      _registerLivestockAdapters();
      _registerWeatherAdapters();
      _registerSubscriptionAdapters();
      _registerNewsAdapters();
      _registerMarketsAdapters();

      Logger.info('HiveInitializer: Hive setup completed successfully.');
    } catch (e, stackTrace) {
      Logger.error(
        'HiveInitializer: A critical error occurred during initialization.',
        error: e,
        stackTrace: stackTrace,
      );
      // Rethrowing is important to halt app startup if Hive fails.
      rethrow;
    }
  }

  /// A generic helper to safely register a [TypeAdapter].
  static void _registerAdapter<T>(TypeAdapter<T> adapter, int typeId) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter<T>(adapter);
      Logger.debug('HiveInitializer: ${adapter.runtimeType} registered (TypeId: $typeId)');
    }
  }

  /// Registers adapters related to authentication.
  static void _registerAuthAdapters() {
    // TODO: Implement auth model adapters once they are created.
    // Example: _registerAdapter(UserModelAdapter(), 1);
    Logger.info('HiveInitializer: Auth adapters skipped (awaiting code generation).');
  }

  /// Registers adapters related to the livestock feature.
  static void _registerLivestockAdapters() {
    _registerEnumAdapters();
    // TODO: Implement livestock model adapters once they are created.
    // Example: _registerAdapter(AnimalModelAdapter(), 20);
    Logger.info('HiveInitializer: Livestock model adapters skipped (awaiting code generation).');
  }

  /// Registers all enum adapters.
  static void _registerEnumAdapters() {
    _registerAdapter(BovineAptitudeAdapter(), 10);
    _registerAdapter(BreedingSystemAdapter(), 11);
  }

  /// Registers adapters related to the weather feature.
  static void _registerWeatherAdapters() {
    _registerAdapter(RainGaugeModelAdapter(), 51);
    _registerAdapter(WeatherMeasurementModelAdapter(), 50);
    _registerAdapter(WeatherStatisticsModelAdapter(), 52);
    Logger.info('HiveInitializer: Weather adapters registered.');
  }

  /// Registers adapters related to subscriptions.
  static void _registerSubscriptionAdapters() {
    // TODO: Implement subscription model adapters once they are created.
    Logger.info('HiveInitializer: Subscription adapters skipped (awaiting implementation).');
  }

  /// Registers adapters related to the news feature.
  static void _registerNewsAdapters() {
    _registerAdapter(CommodityPriceModelAdapter(), 30);
    _registerAdapter(NewsArticleModelAdapter(), 31);
    Logger.info('HiveInitializer: News adapters registered.');
  }

  /// Registers adapters related to the markets feature.
  static void _registerMarketsAdapters() {
    registerMarketAdapters();
    Logger.info('HiveInitializer: Markets adapters registered.');
  }

  /// Deletes all data from all Hive boxes.
  ///
  /// **WARNING**: This is a destructive operation and should only be used
  /// in development or testing environments.
  static Future<void> clearAllData() async {
    if (kDebugMode) {
      try {
        Logger.warning('HiveInitializer: Clearing all Hive data...');
        await Hive.deleteFromDisk();
        Logger.info('HiveInitializer: All Hive data cleared successfully.');
      } catch (e, stackTrace) {
        Logger.error('HiveInitializer: Failed to clear Hive data.', error: e, stackTrace: stackTrace);
        rethrow;
      }
    } else {
      Logger.error('HiveInitializer: clearAllData() was called in a non-debug build. Operation aborted.');
    }
  }

  /// Closes all open Hive boxes.
  static Future<void> closeAll() async {
    try {
      Logger.info('HiveInitializer: Closing all open Hive boxes...');
      await Hive.close();
      Logger.info('HiveInitializer: All boxes closed.');
    } catch (e, stackTrace) {
      Logger.error('HiveInitializer: Error while closing Hive boxes.', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}