import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/livestock/data/models/bovine_model.dart';
import '../../features/livestock/data/models/equine_model.dart';
import '../../features/livestock/data/models/livestock_enums_adapter.dart';

/// Inicializador do Hive para configuração de adapters
/// 
/// Centraliza o registro de todos os adapters Hive do app
/// Garante que todos os modelos estejam disponíveis para persistência local
class HiveInitializer {
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
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserModelAdapter());
        debugPrint('HiveInitializer: UserModelAdapter registrado (TypeId: 1)');
      }
    } catch (e) {
      debugPrint('HiveInitializer: Erro ao registrar adapters de auth - $e');
      rethrow;
    }
  }
  
  /// Registra adapters relacionados ao livestock
  static void _registerLivestockAdapters() {
    try {
      // BovineModel - TypeId: 0
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BovineModelAdapter());
        debugPrint('HiveInitializer: BovineModelAdapter registrado (TypeId: 0)');
      }
      
      // EquineModel - TypeId: 2
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(EquineModelAdapter());
        debugPrint('HiveInitializer: EquineModelAdapter registrado (TypeId: 2)');
      }
      
      // Enums adapters - TypeIds: 10-19
      _registerEnumAdapters();
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