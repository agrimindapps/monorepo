import 'dart:developer' as developer;

import 'package:hive/hive.dart';

import '../models/cultura_hive.dart';
import '../models/diagnostico_hive.dart';
import '../models/fitossanitario_hive.dart';
import '../models/pragas_hive.dart';
import 'hive_adapter_registry.dart';

/// ReceitaAgroHiveService - Serviço para acesso aos dados Hive
/// Utiliza os adapters gerados automaticamente
class ReceitaAgroHiveService {
  static bool _isInitialized = false;
  

  /// Inicialização do serviço
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _registerAdapters();
    _isInitialized = true;
  }

  /// Registra adapters Hive
  static Future<void> _registerAdapters() async {
    try {
      await HiveAdapterRegistry.registerAdapters();
      developer.log('Adapters Hive registrados com sucesso', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao registrar adapters Hive: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  /// Abre todas as boxes necessárias
  static Future<void> openBoxes() async {
    await initialize();

    try {
      await HiveAdapterRegistry.openBoxes();
      developer.log('Todas as boxes foram abertas com sucesso', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao abrir boxes: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  // ==================== MÉTODOS DE ACESSO AOS DADOS ====================
  
  /// Obtém todas as pragas
  static List<PragasHive> getPragas() {
    try {
      final boxName = HiveAdapterRegistry.boxNames['pragas']!;
      if (!Hive.isBoxOpen(boxName)) return [];
      
      final box = Hive.box<PragasHive>(boxName);
      return box.values.toList();
    } catch (e) {
      developer.log('Erro ao obter pragas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém praga por ID
  static PragasHive? getPragaById(String id) {
    try {
      final boxName = HiveAdapterRegistry.boxNames['pragas']!;
      if (!Hive.isBoxOpen(boxName)) return null;
      
      final box = Hive.box<PragasHive>(boxName);
      return box.get(id);
    } catch (e) {
      developer.log('Erro ao obter praga por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todos os fitossanitários
  static List<FitossanitarioHive> getFitossanitarios() {
    try {
      final boxName = HiveAdapterRegistry.boxNames['fitossanitarios']!;
      if (!Hive.isBoxOpen(boxName)) return [];
      
      final box = Hive.box<FitossanitarioHive>(boxName);
      return box.values.toList();
    } catch (e) {
      developer.log('Erro ao obter fitossanitários: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém fitossanitário por ID
  static FitossanitarioHive? getFitossanitarioById(String id) {
    try {
      final boxName = HiveAdapterRegistry.boxNames['fitossanitarios']!;
      if (!Hive.isBoxOpen(boxName)) return null;
      
      final box = Hive.box<FitossanitarioHive>(boxName);
      return box.get(id);
    } catch (e) {
      developer.log('Erro ao obter fitossanitário por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todos os diagnósticos
  static List<DiagnosticoHive> getDiagnosticos() {
    try {
      final boxName = HiveAdapterRegistry.boxNames['diagnosticos']!;
      if (!Hive.isBoxOpen(boxName)) return [];
      
      final box = Hive.box<DiagnosticoHive>(boxName);
      return box.values.toList();
    } catch (e) {
      developer.log('Erro ao obter diagnósticos: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém diagnóstico por ID
  static DiagnosticoHive? getDiagnosticoById(String id) {
    try {
      final boxName = HiveAdapterRegistry.boxNames['diagnosticos']!;
      if (!Hive.isBoxOpen(boxName)) return null;
      
      final box = Hive.box<DiagnosticoHive>(boxName);
      return box.get(id);
    } catch (e) {
      developer.log('Erro ao obter diagnóstico por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todas as culturas
  static List<CulturaHive> getCulturas() {
    try {
      final boxName = HiveAdapterRegistry.boxNames['culturas']!;
      if (!Hive.isBoxOpen(boxName)) return [];
      
      final box = Hive.box<CulturaHive>(boxName);
      return box.values.toList();
    } catch (e) {
      developer.log('Erro ao obter culturas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém cultura por ID
  static CulturaHive? getCulturaById(String id) {
    try {
      final boxName = HiveAdapterRegistry.boxNames['culturas']!;
      if (!Hive.isBoxOpen(boxName)) return null;
      
      final box = Hive.box<CulturaHive>(boxName);
      return box.get(id);
    } catch (e) {
      developer.log('Erro ao obter cultura por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  /// Salva dados temporários para teste
  static Future<void> saveTestData() async {
    try {
      await openBoxes();
      
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Dados de teste para pragas
      final pragasBoxName = HiveAdapterRegistry.boxNames['pragas']!;
      final pragasBox = Hive.box<PragasHive>(pragasBoxName);
      final pragaTest = PragasHive(
        objectId: '1',
        createdAt: now,
        updatedAt: now,
        idReg: '1',
        nomeComum: 'Lagarta-da-soja',
        nomeCientifico: 'Anticarsia gemmatalis',
        tipoPraga: '1',
        dominio: 'Eukaryota',
        reino: 'Animalia',
        familia: 'Erebidae',
      );
      await pragasBox.put('1', pragaTest);
      
      // Dados de teste para culturas
      final culturasBoxName = HiveAdapterRegistry.boxNames['culturas']!;
      final culturasBox = Hive.box<CulturaHive>(culturasBoxName);
      final culturaTest = CulturaHive(
        objectId: '1',
        createdAt: now,
        updatedAt: now,
        idReg: '1',
        cultura: 'Soja',
      );
      await culturasBox.put('1', culturaTest);
      
      developer.log('Dados de teste salvos com sucesso', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao salvar dados de teste: $e', name: 'ReceitaAgroHiveService');
    }
  }
  
  /// Fecha todas as boxes
  static Future<void> closeBoxes() async {
    try {
      await HiveAdapterRegistry.closeBoxes();
      developer.log('Todas as boxes foram fechadas', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao fechar boxes: $e', name: 'ReceitaAgroHiveService');
    }
  }
}