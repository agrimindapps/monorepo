import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

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
    // ⚠️ TEMPORARIAMENTE DESABILITADO: Enum adapters removidos devido a conflito
    // com riverpod_generator (incompatibilidade hive_generator)
    debugPrint('HiveInitializer: Enum adapters skipped (awaiting manual implementation)');
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
    // ⚠️ TEMPORARIAMENTE DESABILITADO
    debugPrint('HiveInitializer: Weather adapters skipped (awaiting manual implementation)');
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
    // ⚠️ TEMPORARIAMENTE DESABILITADO
    debugPrint('HiveInitializer: News adapters skipped (awaiting manual implementation)');
  }

  /// Registra adapters relacionados aos markets
  static void _registerMarketsAdapters() {
    // ⚠️ TEMPORARIAMENTE DESABILITADO: Enum adapters + JSON serialization conflicts
    debugPrint('HiveInitializer: Markets adapters skipped (awaiting manual implementation)');
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
