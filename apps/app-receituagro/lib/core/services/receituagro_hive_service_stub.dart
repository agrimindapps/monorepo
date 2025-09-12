import 'dart:developer' as developer;

import '../repositories/cultura_hive_repository.dart';
import '../repositories/diagnostico_hive_repository.dart';
import '../repositories/fitossanitario_hive_repository.dart';
import '../repositories/pragas_hive_repository.dart';
import '../di/injection_container.dart';

/// Stub/adapter class to replace the removed ReceitaAgroHiveService
/// Provides the same interface but delegates to individual repository instances
/// This maintains compatibility while using the new architecture
class ReceitaAgroHiveService {
  static CulturaHiveRepository get _culturaRepo => sl<CulturaHiveRepository>();
  static PragasHiveRepository get _pragasRepo => sl<PragasHiveRepository>();
  static FitossanitarioHiveRepository get _fitossanitarioRepo => sl<FitossanitarioHiveRepository>();
  static DiagnosticoHiveRepository get _diagnosticoRepo => sl<DiagnosticoHiveRepository>();

  // Initialization methods
  static Future<void> initialize() async {
    try {
      developer.log('Initializing ReceitaAgro data repositories', name: 'ReceitaAgroHiveService');
      // Individual repositories handle their own initialization
      // This is called during app startup via injection_container
      developer.log('ReceitaAgro repositories initialized', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Error initializing ReceitaAgro repositories: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  static Future<void> openBoxes() async {
    try {
      developer.log('Opening ReceitaAgro Hive boxes', name: 'ReceitaAgroHiveService');
      // Individual repositories handle their own box opening
      developer.log('ReceitaAgro Hive boxes opened', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Error opening ReceitaAgro Hive boxes: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  static Future<void> closeBoxes() async {
    try {
      developer.log('Closing ReceitaAgro Hive boxes', name: 'ReceitaAgroHiveService');
      // Individual repositories handle their own box closing
      developer.log('ReceitaAgro Hive boxes closed', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Error closing ReceitaAgro Hive boxes: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  static Future<void> saveTestData() async {
    try {
      developer.log('Saving test data to repositories', name: 'ReceitaAgroHiveService');
      // Individual repositories handle their own test data
      // This would typically populate each repository with sample data
      developer.log('Test data saved to repositories', name: 'ReceitaAgroHiveService');
    } catch (e) {
      developer.log('Error saving test data: $e', name: 'ReceitaAgroHiveService');
      rethrow;
    }
  }

  // Individual entity access methods
  static dynamic getFitossanitarioById(String id) {
    try {
      return _fitossanitarioRepo.getById(id);
    } catch (e) {
      developer.log('Error getting fitossanitario by id $id: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  static dynamic getPragaById(String id) {
    try {
      return _pragasRepo.getById(id);
    } catch (e) {
      developer.log('Error getting praga by id $id: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  static dynamic getDiagnosticoById(String id) {
    try {
      return _diagnosticoRepo.getById(id);
    } catch (e) {
      developer.log('Error getting diagnostico by id $id: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  static dynamic getCulturaById(String id) {
    try {
      return _culturaRepo.getById(id);
    } catch (e) {
      developer.log('Error getting cultura by id $id: $e', name: 'ReceitaAgroHiveService');
      return null;
    }
  }

  // List access methods
  static List<dynamic> getPragas() {
    try {
      return _pragasRepo.getAll();
    } catch (e) {
      developer.log('Error getting pragas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }

  static List<dynamic> getCulturas() {
    try {
      return _culturaRepo.getAll();
    } catch (e) {
      developer.log('Error getting culturas: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }

  static List<dynamic> getFitossanitarios() {
    try {
      return _fitossanitarioRepo.getAll();
    } catch (e) {
      developer.log('Error getting fitossanitarios: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }

  static List<dynamic> getDiagnosticos() {
    try {
      return _diagnosticoRepo.getAll();
    } catch (e) {
      developer.log('Error getting diagnosticos: $e', name: 'ReceitaAgroHiveService');
      return [];
    }
  }
}