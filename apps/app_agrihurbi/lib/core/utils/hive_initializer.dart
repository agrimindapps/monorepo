import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import generated model adapters
// import '../../features/auth/data/models/user_model.dart';
// import '../../features/livestock/data/models/bovine_model.dart';
// import '../../features/livestock/data/models/equine_model.dart';
import '../../features/livestock/data/models/livestock_enums_adapter.dart';

// Import weather models
import '../../features/weather/data/models/rain_gauge_model.dart';
import '../../features/weather/data/models/weather_measurement_model.dart';
import '../../features/weather/data/models/weather_statistics_model.dart';

// Import subscription models
import '../../features/subscription/data/models/subscription_model.dart';

// Import news models
import '../../features/news/data/models/commodity_price_model.dart';
import '../../features/news/data/models/news_article_model.dart';

/// Inicializador do Hive para configuração de adapters
/// 
/// Centraliza o registro de todos os adapters Hive do app
/// Garante que todos os modelos estejam disponíveis para persistência local
class HiveInitializer {
  // Private constructor to prevent instantiation
  HiveInitializer._();
  /// Inicializa o Hive com todos os adapters necessários
  static Future<void> initialize() async {
    try {
      debugPrint('HiveInitializer: Iniciando configuração do Hive');
      
      // Inicializar Hive
      await Hive.initFlutter();
      
      // Registrar adapters de autenticação
      _registerAuthAdapters();
      
      // Registrar adapters de livestock
      _registerLivestockAdapters();
      
      // Registrar adapters de weather
      _registerWeatherAdapters();
      
      // Registrar adapters de subscription
      _registerSubscriptionAdapters();
      
      // Registrar adapters de news
      _registerNewsAdapters();
      
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
      // UserModel - TypeId: 1
      // TODO: Uncomment when UserModelAdapter is generated
      // if (!Hive.isAdapterRegistered(1)) {
      //   Hive.registerAdapter(UserModelAdapter());
      //   debugPrint('HiveInitializer: UserModelAdapter registrado (TypeId: 1)');
      // }
      debugPrint('HiveInitializer: Auth adapters skipped (awaiting code generation)');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de auth - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao livestock
  static void _registerLivestockAdapters() {
    try {
      // TODO: Uncomment when model adapters are generated
      // BovineModel - TypeId: 0
      // if (!Hive.isAdapterRegistered(0)) {
      //   Hive.registerAdapter(BovineModelAdapter());
      //   debugPrint('HiveInitializer: BovineModelAdapter registrado (TypeId: 0)');
      // }
      
      // EquineModel - TypeId: 2
      // if (!Hive.isAdapterRegistered(2)) {
      //   Hive.registerAdapter(EquineModelAdapter());
      //   debugPrint('HiveInitializer: EquineModelAdapter registrado (TypeId: 2)');
      // }
      
      // Enums adapters - TypeIds: 10-19
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
      // BovineAptitude - TypeId: 10
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(BovineAptitudeAdapter());
        debugPrint('HiveInitializer: BovineAptitudeAdapter registrado (TypeId: 10)');
      }
      
      // BreedingSystem - TypeId: 11  
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(BreedingSystemAdapter());
        debugPrint('HiveInitializer: BreedingSystemAdapter registrado (TypeId: 11)');
      }
      
      // Outros enum adapters podem ser adicionados aqui conforme necessário
      // EquineType - TypeId: 12 (quando implementado)
      // if (!Hive.isAdapterRegistered(12)) {
      //   Hive.registerAdapter(EquineTypeAdapter());
      //   debugPrint('HiveInitializer: EquineTypeAdapter registrado (TypeId: 12)');
      // }
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
      // RainGaugeModel - TypeId: 51
      if (!Hive.isAdapterRegistered(51)) {
        Hive.registerAdapter(RainGaugeModelAdapter());
        debugPrint('HiveInitializer: RainGaugeModelAdapter registrado (TypeId: 51)');
      }
      
      // WeatherMeasurementModel - TypeId: 50
      if (!Hive.isAdapterRegistered(50)) {
        Hive.registerAdapter(WeatherMeasurementModelAdapter());
        debugPrint('HiveInitializer: WeatherMeasurementModelAdapter registrado (TypeId: 50)');
      }
      
      // WeatherStatisticsModel - TypeId: 52
      if (!Hive.isAdapterRegistered(52)) {
        Hive.registerAdapter(WeatherStatisticsModelAdapter());
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
      // SubscriptionModel - TypeId: 16
      if (!Hive.isAdapterRegistered(16)) {
        Hive.registerAdapter(SubscriptionModelAdapter());
        debugPrint('HiveInitializer: SubscriptionModelAdapter registrado (TypeId: 16)');
      }
      
      // SubscriptionTierModel - TypeId: 17
      if (!Hive.isAdapterRegistered(17)) {
        Hive.registerAdapter(SubscriptionTierModelAdapter());
        debugPrint('HiveInitializer: SubscriptionTierModelAdapter registrado (TypeId: 17)');
      }
      
      // PaymentMethodModel - TypeId: 21
      if (!Hive.isAdapterRegistered(21)) {
        Hive.registerAdapter(PaymentMethodModelAdapter());
        debugPrint('HiveInitializer: PaymentMethodModelAdapter registrado (TypeId: 21)');
      }
      
      debugPrint('HiveInitializer: Subscription adapters registrados');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de subscription - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao news
  static void _registerNewsAdapters() {
    try {
      // CommodityPriceModel - TypeId: 30
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(CommodityPriceModelAdapter());
        debugPrint('HiveInitializer: CommodityPriceModelAdapter registrado (TypeId: 30)');
      }
      
      // NewsArticleModel - TypeId: 31
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter(NewsArticleModelAdapter());
        debugPrint('HiveInitializer: NewsArticleModelAdapter registrado (TypeId: 31)');
      }
      
      debugPrint('HiveInitializer: News adapters registrados');
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de news - $e');
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