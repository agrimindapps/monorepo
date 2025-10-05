import 'package:hive_flutter/hive_flutter.dart';

// Generated Hive Adapters
import '../../features/auth/data/models/user_model.dart';
import '../../features/livestock/data/models/bovine_model.dart';
import '../../features/livestock/data/models/equine_model.dart';
import '../../features/livestock/data/models/livestock_enums_adapter.dart';
import '../../features/markets/data/models/market_enums_adapter.dart';
import '../../features/markets/data/models/market_model.dart';
import '../../features/news/data/models/commodity_price_model.dart';
import '../../features/news/data/models/news_article_model.dart';
import '../../features/settings/data/models/settings_model.dart';
import '../../features/weather/data/models/rain_gauge_model.dart';
import '../../features/weather/data/models/weather_measurement_model.dart';
import '../../features/weather/data/models/weather_statistics_model.dart';

/// Registra todos os adapters Hive do app-agrihurbi
///
/// IMPORTANTE: Chamar APÓS Hive.initFlutter() e ANTES de abrir qualquer box
void registerAgrihurbiHiveAdapters() {
  // === MODEL ADAPTERS (Generated) ===

  // Auth Models
  if (!Hive.isAdapterRegistered(20)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  // Livestock Models
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BovineModelAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(EquineModelAdapter());
  }

  // Settings Models
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(SettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(25)) {
    Hive.registerAdapter(NotificationSettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(26)) {
    Hive.registerAdapter(DataSettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(28)) {
    Hive.registerAdapter(PrivacySettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(29)) {
    Hive.registerAdapter(DisplaySettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(30)) {
    Hive.registerAdapter(SecuritySettingsModelAdapter());
  }

  if (!Hive.isAdapterRegistered(31)) {
    Hive.registerAdapter(BackupSettingsModelAdapter());
  }

  // News Models
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(NewsArticleModelAdapter());
  }

  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(CommodityPriceModelAdapter());
  }

  // Market Models
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(MarketModelAdapter());
  }

  // Weather Models
  if (!Hive.isAdapterRegistered(40)) {
    Hive.registerAdapter(RainGaugeModelAdapter());
  }

  if (!Hive.isAdapterRegistered(41)) {
    Hive.registerAdapter(WeatherMeasurementModelAdapter());
  }

  if (!Hive.isAdapterRegistered(42)) {
    Hive.registerAdapter(WeatherStatisticsModelAdapter());
  }

  // === ENUM ADAPTERS (Manual) ===

  // Livestock Enums
  registerLivestockEnumAdapters();

  // Market Enums
  registerMarketAdapters();

  print('✅ AgriHurbi Hive Adapters registered successfully');
  print('   - Model Adapters: 16 registered');
  print('   - Enum Adapters: Livestock (5) + Market (2)');
}
