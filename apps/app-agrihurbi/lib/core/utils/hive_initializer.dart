import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/livestock/data/models/livestock_enums_adapter.dart';
import '../../features/markets/data/models/market_enums_adapter.dart';
import '../../features/news/data/models/commodity_price_model.dart';
import '../../features/news/data/models/news_article_model.dart';
import '../../features/weather/data/models/rain_gauge_model.dart';
import '../../features/weather/data/models/weather_measurement_model.dart';
import '../../features/weather/data/models/weather_statistics_model.dart';

/// Inicializador do Hive para configuração de adapters
/// 
/// Centraliza o registro de todos os adapters Hive do app
/// Garante que todos os modelos estejam disponíveis para persistência local
class HiveInitializer {
  HiveInitializer._();
  /// Inicializa o Hive com todos os adapters necessários
  static Future<void> initialize() async {
    try {
      debugPrint('HiveInitializer: Iniciando configuração do Hive');
      await Hive.initFlutter();
      _registerAuthAdapters();
      _registerLivestockAdapters();
      _registerWeatherAdapters();
      _registerSubscriptionAdapters();
      _registerNewsAdapters();
      _registerMarketsAdapters();
      
      debugPrint('HiveInitializer: Configuração do Hive concluída');
    } catch (e, stackTrace) {
      debugPrint('HiveInitializer: Erro na inicialização - $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados à autenticação
  static void _registerAuthAdapters() {
    try {
      debugPrint('HiveInitializer: Auth adapters skipped (awaiting code generation)');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de auth - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao livestock
  static void _registerLivestockAdapters() {
    try {
      _registerEnumAdapters();
      
      debugPrint('HiveInitializer: Livestock model adapters skipped (awaiting code generation)');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de livestock - $e');
      rethrow;
    }
  }
  
  /// Registra adapters de enums
  static void _registerEnumAdapters() {
    try {
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(BovineAptitudeAdapter());
        debugPrint('HiveInitializer: BovineAptitudeAdapter registrado (TypeId: 10)');
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(BreedingSystemAdapter());
        debugPrint('HiveInitializer: BreedingSystemAdapter registrado (TypeId: 11)');
      }
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de enums - $e');
      rethrow;
    }
  }
  
  /// Limpa todos os dados do Hive (apenas para desenvolvimento)
  static Future<void> clearAll() async {
    try {
      debugPrint('HiveInitializer: Limpando todos os dados do Hive');
      
      await Hive.deleteFromDisk();
      
      debugPrint('HiveInitializer: Dados limpos com sucesso');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao limpar dados - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao weather
  static void _registerWeatherAdapters() {
    try {
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter<RainGaugeModel>(RainGaugeModelAdapter());
        debugPrint('HiveInitializer: RainGaugeModelAdapter registrado (TypeId: 51)');
      }
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter<WeatherMeasurementModel>(WeatherMeasurementModelAdapter());
        debugPrint('HiveInitializer: WeatherMeasurementModelAdapter registrado (TypeId: 50)');
      }
      if (!Hive.isAdapterRegistered(52)) {
        Hive.registerAdapter<WeatherStatisticsModel>(WeatherStatisticsModelAdapter());
        debugPrint('HiveInitializer: WeatherStatisticsModelAdapter registrado (TypeId: 52)');
      }
      
      debugPrint('HiveInitializer: Weather adapters registrados');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de weather - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados à subscription
  static void _registerSubscriptionAdapters() {
    try {

      debugPrint('HiveInitializer: Subscription adapters skipped (awaiting implementation)');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de subscription - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao news
  static void _registerNewsAdapters() {
    try {
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter<CommodityPriceModel>(CommodityPriceModelAdapter());
        debugPrint('HiveInitializer: CommodityPriceModelAdapter registrado (TypeId: 30)');
      }
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter<NewsArticleModel>(NewsArticleModelAdapter());
        debugPrint('HiveInitializer: NewsArticleModelAdapter registrado (TypeId: 31)');
      }
      
      debugPrint('HiveInitializer: News adapters registrados');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de news - $e');
      rethrow;
    }
  }

  /// Registra adapters relacionados aos markets
  static void _registerMarketsAdapters() {
    try {
      registerMarketAdapters();
      
      debugPrint('HiveInitializer: Markets adapters registrados');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de markets - $e');
      rethrow;
    }
  }

  /// Fecha todas as boxes abertas
  static Future<void> closeAll() async {
    try {
      debugPrint('HiveInitializer: Fechando todas as boxes');
      
      await Hive.close();
      
      debugPrint('HiveInitializer: Todas as boxes fechadas');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao fechar boxes - $e');
      rethrow;
    }
  }
}