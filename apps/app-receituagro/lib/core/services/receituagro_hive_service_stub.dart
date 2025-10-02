import 'dart:developer' as developer;

/// ⚠️ DEPRECATED: This stub class is maintained for backward compatibility only.
///
/// **Migration Guide:**
/// - Use individual repositories directly instead of this service
/// - For fitossanitários: Use `FitossanitarioHiveRepository`
/// - For pragas: Use `PragasHiveRepository`
/// - For culturas: Use `CulturaHiveRepository`
/// - For diagnósticos: Use `DiagnosticoHiveRepository`
///
/// **This class will be REMOVED in the next major version.**
@Deprecated('Use individual repositories directly (FitossanitarioHiveRepository, PragasHiveRepository, etc.)')
class ReceitaAgroHiveService {

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
  // Note: These methods are deprecated. Use repositories directly for new code.
  static dynamic getFitossanitarioById(String id) {
    developer.log('getFitossanitarioById is deprecated. Use FitossanitarioHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return null;
  }

  static dynamic getPragaById(String id) {
    developer.log('getPragaById is deprecated. Use PragasHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return null;
  }

  static dynamic getDiagnosticoById(String id) {
    developer.log('getDiagnosticoById is deprecated. Use DiagnosticoHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return null;
  }

  static dynamic getCulturaById(String id) {
    developer.log('getCulturaById is deprecated. Use CulturaHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return null;
  }

  // List access methods
  // Note: These methods are deprecated. Use repositories directly for new code.
  static List<dynamic> getPragas() {
    developer.log('getPragas is deprecated. Use PragasHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return [];
  }

  static List<dynamic> getCulturas() {
    developer.log('getCulturas is deprecated. Use CulturaHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return [];
  }

  static List<dynamic> getFitossanitarios() {
    developer.log('getFitossanitarios is deprecated. Use FitossanitarioHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return [];
  }

  static List<dynamic> getDiagnosticos() {
    developer.log('getDiagnosticos is deprecated. Use DiagnosticoHiveRepository directly.', 
        name: 'ReceitaAgroHiveService');
    return [];
  }
}