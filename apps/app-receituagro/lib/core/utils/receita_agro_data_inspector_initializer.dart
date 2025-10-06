import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Inicializador do DatabaseInspectorService específico para o app-receituagro
class ReceitaAgroDataInspectorInitializer {
  static void initialize() {
    if (!kDebugMode) return; // Apenas em modo debug

    final inspector = DatabaseInspectorService.instance;
    inspector.registerCustomBoxes([
      const CustomBoxType(
        key: 'receituagro_culturas',
        displayName: 'Culturas',
        module: 'Dados Agrícolas',
        description:
            'Dados das culturas agrícolas disponíveis no sistema, incluindo informações básicas e características',
      ),

      const CustomBoxType(
        key: 'receituagro_pragas',
        displayName: 'Pragas',
        module: 'Dados Agrícolas',
        description:
            'Base de dados de pragas, incluindo nome comum, científico, família e tipo de praga',
      ),

      const CustomBoxType(
        key: 'receituagro_fitossanitarios',
        displayName: 'Fitossanitários',
        module: 'Dados Agrícolas',
        description:
            'Produtos fitossanitários disponíveis para controle de pragas e doenças',
      ),

      const CustomBoxType(
        key: 'receituagro_diagnosticos',
        displayName: 'Diagnósticos',
        module: 'Dados Agrícolas',
        description:
            'Diagnósticos de pragas em culturas, incluindo recomendações de fitossanitários e dosagens',
      ),
      const CustomBoxType(
        key: 'receituagro_fitossanitarios_info',
        displayName: 'Informações de Fitossanitários',
        module: 'Dados Agrícolas',
        description:
            'Informações detalhadas sobre fitossanitários, incluindo composição e modo de ação',
      ),

      const CustomBoxType(
        key: 'receituagro_plantas_inf',
        displayName: 'Informações de Plantas',
        module: 'Dados Agrícolas',
        description:
            'Informações detalhadas sobre plantas e culturas, incluindo características agronômicas',
      ),

      const CustomBoxType(
        key: 'receituagro_pragas_inf',
        displayName: 'Informações de Pragas',
        module: 'Dados Agrícolas',
        description:
            'Informações detalhadas sobre pragas, incluindo ciclo de vida, sintomas e controle',
      ),
      const CustomBoxType(
        key: 'receituagro_premium_status',
        displayName: 'Status Premium',
        module: 'Premium',
        description:
            'Informações sobre assinatura premium, licenças e funcionalidades liberadas',
      ),
      const CustomBoxType(
        key: 'comentarios',
        displayName: 'Comentários',
        module: 'Usuário',
        description:
            'Comentários e avaliações feitos pelo usuário sobre diagnósticos e produtos',
      ),

      const CustomBoxType(
        key: 'receituagro_user_favorites',
        displayName: 'Favoritos',
        module: 'Usuário',
        description:
            'Lista de favoritos do usuário, incluindo culturas, pragas e fitossanitários salvos',
      ),
      const CustomBoxType(
        key: 'receituagro_app_settings',
        displayName: 'Configurações do App',
        module: 'Sistema',
        description:
            'Configurações do aplicativo, preferências do usuário e dados de sistema',
      ),

      const CustomBoxType(
        key: 'receituagro_subscription_data',
        displayName: 'Dados de Assinatura',
        module: 'Sistema',
        description:
            'Dados de assinatura, informações de pagamento e histórico de transações',
      ),
    ]);

    if (kDebugMode) {
      print('🔍 DatabaseInspectorService inicializado para app-receituagro');
      print('📦 ${inspector.customBoxes.length} boxes registradas');
      print('📊 Módulos disponíveis:');
      final modules = inspector.customBoxes.map((box) => box.module ?? 'Outros').toSet();
      for (final module in modules) {
        final boxCount = inspector.customBoxes.where((box) => box.module == module).length;
        print('   - $module: $boxCount boxes');
      }
    }
  }

  /// Adiciona uma box customizada em runtime
  static void addCustomBox({
    required String key,
    required String displayName,
    required String module,
    String? description,
  }) {
    final inspector = DatabaseInspectorService.instance;
    inspector.addCustomBox(
      CustomBoxType(
        key: key,
        displayName: displayName,
        module: module,
        description: description,
      ),
    );
  }

  /// Remove uma box customizada
  static void removeCustomBox(String key) {
    final inspector = DatabaseInspectorService.instance;
    inspector.removeCustomBox(key);
  }

  /// Obtém estatísticas específicas do ReceitaAgro por módulo
  static Map<String, dynamic> getModuleStats() {
    final inspector = DatabaseInspectorService.instance;
    final availableBoxes = inspector.getAvailableHiveBoxes();
    final moduleStats = <String, Map<String, dynamic>>{};
    
    for (final boxKey in availableBoxes) {
      final boxStats = inspector.getBoxStats(boxKey);
      final customBox = inspector.customBoxes.where((box) => box.key == boxKey).firstOrNull;
      
      if (customBox != null) {
        final module = customBox.module ?? 'Outros';
        
        if (!moduleStats.containsKey(module)) {
          moduleStats[module] = {
            'totalBoxes': 0,
            'totalRecords': 0,
            'boxes': <Map<String, dynamic>>[],
          };
        }
        
        moduleStats[module]!['totalBoxes'] = (moduleStats[module]!['totalBoxes'] as int) + 1;
        moduleStats[module]!['totalRecords'] = (moduleStats[module]!['totalRecords'] as int) + (boxStats['totalRecords'] as int? ?? 0);
        (moduleStats[module]!['boxes'] as List<Map<String, dynamic>>).add({
          'key': boxKey,
          'displayName': customBox.displayName,
          'description': customBox.description,
          'totalRecords': boxStats['totalRecords'] ?? 0,
          'isOpen': boxStats['isOpen'] ?? false,
          'hasError': boxStats.containsKey('error'),
        });
      }
    }

    return {
      'appName': 'ReceitaAgro',
      'totalModules': moduleStats.keys.length,
      'totalRegisteredBoxes': inspector.customBoxes.length,
      'totalAvailableBoxes': availableBoxes.length,
      'moduleStats': moduleStats,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Lista boxes por módulo específico
  static List<Map<String, dynamic>> getBoxesByModule(String module) {
    final inspector = DatabaseInspectorService.instance;
    final moduleBoxes = inspector.customBoxes.where((box) => box.module == module);
    
    return moduleBoxes.map((box) {
      final stats = inspector.getBoxStats(box.key);
      return {
        'key': box.key,
        'displayName': box.displayName,
        'description': box.description,
        'totalRecords': stats['totalRecords'] ?? 0,
        'isOpen': stats['isOpen'] ?? false,
        'hasError': stats.containsKey('error'),
        'error': stats['error'],
      };
    }).toList();
  }

  /// Verifica saúde geral do sistema de dados
  static Map<String, dynamic> getSystemHealth() {
    final inspector = DatabaseInspectorService.instance;
    final availableBoxes = inspector.getAvailableHiveBoxes();
    final registeredBoxes = inspector.customBoxes;
    
    int healthyBoxes = 0;
    int errorBoxes = 0;
    int totalRecords = 0;
    final List<String> issues = [];
    
    for (final box in registeredBoxes) {
      final stats = inspector.getBoxStats(box.key);
      
      if (availableBoxes.contains(box.key)) {
        if (stats.containsKey('error')) {
          errorBoxes++;
          issues.add('Box "${box.displayName}" com erro: ${stats['error']}');
        } else {
          healthyBoxes++;
          totalRecords += (stats['totalRecords'] as int? ?? 0);
        }
      } else {
        errorBoxes++;
        issues.add('Box "${box.displayName}" não disponível');
      }
    }
    
    final healthPercentage = registeredBoxes.isEmpty 
        ? 0.0 
        : (healthyBoxes / registeredBoxes.length) * 100;
    
    return {
      'healthPercentage': healthPercentage,
      'totalRegisteredBoxes': registeredBoxes.length,
      'healthyBoxes': healthyBoxes,
      'errorBoxes': errorBoxes,
      'totalRecords': totalRecords,
      'issues': issues,
      'status': healthPercentage >= 90 
          ? 'Excelente' 
          : healthPercentage >= 70 
              ? 'Bom' 
              : healthPercentage >= 50 
                  ? 'Regular' 
                  : 'Crítico',
      'checkedAt': DateTime.now().toIso8601String(),
    };
  }
}
