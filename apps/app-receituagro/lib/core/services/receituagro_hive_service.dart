import 'dart:developer' as developer;
import 'package:hive/hive.dart';

/// Versão temporária simplificada do ReceitaAgroHiveService
/// Para ser usada enquanto os adapters Hive não forem gerados
class ReceitaAgroHiveService {
  static bool _isInitialized = false;
  
  // Nome das boxes
  static const String _boxCulturas = 'receituagro_culturas';
  static const String _boxDiagnosticos = 'receituagro_diagnosticos';
  static const String _boxFitossanitarios = 'receituagro_fitossanitarios';
  static const String _boxFitossanitariosInfo = 'receituagro_fitossanitarios_info';
  static const String _boxPlantasInf = 'receituagro_plantas_inf';
  static const String _boxPragas = 'receituagro_pragas';
  static const String _boxPragasInf = 'receituagro_pragas_inf';

  /// Inicialização do serviço
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await _registerAdapters();
    _isInitialized = true;
  }

  /// Registra adapters (versão temporária)
  static Future<void> _registerAdapters() async {
    developer.log('Adapters Hive não registrados - executar: dart run build_runner build', name: 'ReceitaAgroHiveService');
  }

  /// Abre todas as boxes necessárias
  static Future<void> openBoxes() async {
    await initialize();

    try {
      // Versão temporária usando Map ao invés de objetos tipados
      await Future.wait([
        Hive.openBox<Map>(_boxCulturas),
        Hive.openBox<Map>(_boxDiagnosticos), 
        Hive.openBox<Map>(_boxFitossanitarios),
        Hive.openBox<Map>(_boxFitossanitariosInfo),
        Hive.openBox<Map>(_boxPlantasInf),
        Hive.openBox<Map>(_boxPragas),
        Hive.openBox<Map>(_boxPragasInf),
      ]);
      
      developer.log('Todas as boxes foram abertas com sucesso', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao abrir boxes: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  // ==================== MÉTODOS TEMPORÁRIOS ====================
  
  /// Obtém todas as pragas (versão temporária)
  static List<Map<String, dynamic>> getPragas() {
    try {
      if (!Hive.isBoxOpen(_boxPragas)) return [];
      
      final box = Hive.box<Map>(_boxPragas);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      developer.log('Erro ao obter pragas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém praga por ID (versão temporária)
  static Map<String, dynamic>? getPragaById(String id) {
    try {
      if (!Hive.isBoxOpen(_boxPragas)) return null;
      
      final box = Hive.box<Map>(_boxPragas);
      final praga = box.get(id);
      return praga?.cast<String, dynamic>();
    } catch (e) {
      developer.log('Erro ao obter praga por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todos os fitossanitários (versão temporária)
  static List<Map<String, dynamic>> getFitossanitarios() {
    try {
      if (!Hive.isBoxOpen(_boxFitossanitarios)) return [];
      
      final box = Hive.box<Map>(_boxFitossanitarios);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      developer.log('Erro ao obter fitossanitários: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém fitossanitário por ID (versão temporária)
  static Map<String, dynamic>? getFitossanitarioById(String id) {
    try {
      if (!Hive.isBoxOpen(_boxFitossanitarios)) return null;
      
      final box = Hive.box<Map>(_boxFitossanitarios);
      final fitossanitario = box.get(id);
      return fitossanitario?.cast<String, dynamic>();
    } catch (e) {
      developer.log('Erro ao obter fitossanitário por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todos os diagnósticos (versão temporária)
  static List<Map<String, dynamic>> getDiagnosticos() {
    try {
      if (!Hive.isBoxOpen(_boxDiagnosticos)) return [];
      
      final box = Hive.box<Map>(_boxDiagnosticos);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      developer.log('Erro ao obter diagnósticos: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém diagnóstico por ID (versão temporária)
  static Map<String, dynamic>? getDiagnosticoById(String id) {
    try {
      if (!Hive.isBoxOpen(_boxDiagnosticos)) return null;
      
      final box = Hive.box<Map>(_boxDiagnosticos);
      final diagnostico = box.get(id);
      return diagnostico?.cast<String, dynamic>();
    } catch (e) {
      developer.log('Erro ao obter diagnóstico por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }
  
  /// Obtém todas as culturas (versão temporária)
  static List<Map<String, dynamic>> getCulturas() {
    try {
      if (!Hive.isBoxOpen(_boxCulturas)) return [];
      
      final box = Hive.box<Map>(_boxCulturas);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      developer.log('Erro ao obter culturas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
  
  /// Obtém cultura por ID (versão temporária)  
  static Map<String, dynamic>? getCulturaById(String id) {
    try {
      if (!Hive.isBoxOpen(_boxCulturas)) return null;
      
      final box = Hive.box<Map>(_boxCulturas);
      final cultura = box.get(id);
      return cultura?.cast<String, dynamic>();
    } catch (e) {
      developer.log('Erro ao obter cultura por ID: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  /// Salva dados temporários para teste
  static Future<void> saveTestData() async {
    try {
      await openBoxes();
      
      // Dados de teste para pragas
      final pragasBox = Hive.box<Map>(_boxPragas);
      await pragasBox.put('1', {
        'idReg': '1',
        'nomeComum': 'Lagarta-da-soja',
        'nomeCientifico': 'Anticarsia gemmatalis',
        'tipoPraga': '1',
        'dominio': 'Eukaryota',
        'reino': 'Animalia',
        'familia': 'Erebidae',
      });
      
      // Dados de teste para culturas
      final culturasBox = Hive.box<Map>(_boxCulturas);
      await culturasBox.put('1', {
        'id': '1',
        'nomeCultura': 'Soja',
        'descricao': 'Glycine max',
      });
      
      developer.log('Dados de teste salvos com sucesso', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao salvar dados de teste: $e', name: 'ReceitaAgroHiveService');
    }
  }
  
  /// Fecha todas as boxes
  static Future<void> closeBoxes() async {
    try {
      await Future.wait([
        if (Hive.isBoxOpen(_boxCulturas)) Hive.box(_boxCulturas).close(),
        if (Hive.isBoxOpen(_boxDiagnosticos)) Hive.box(_boxDiagnosticos).close(),
        if (Hive.isBoxOpen(_boxFitossanitarios)) Hive.box(_boxFitossanitarios).close(),
        if (Hive.isBoxOpen(_boxFitossanitariosInfo)) Hive.box(_boxFitossanitariosInfo).close(),
        if (Hive.isBoxOpen(_boxPlantasInf)) Hive.box(_boxPlantasInf).close(),
        if (Hive.isBoxOpen(_boxPragas)) Hive.box(_boxPragas).close(),
        if (Hive.isBoxOpen(_boxPragasInf)) Hive.box(_boxPragasInf).close(),
      ]);
      
      developer.log('Todas as boxes foram fechadas', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Erro ao fechar boxes: $e', name: 'ReceitaAgroHiveService');
    }
  }
}