import 'dart:developer' as developer;

// EMERGENCY FIX: Minimal imports during system stabilization
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import '../di/injection_container.dart' as di;
// import '../repositories/cultura_hive_repository.dart'; // imported via DI

/// Serviço para carregar dados de culturas dos assets JSON
class CulturasDataLoader {
  static bool _isLoaded = false;

  /// EMERGENCY FIX: Culturas data loading temporarily disabled
  /// This prevents app crashes while we fix the Hive system
  static Future<void> loadCulturasData() async {
    try {
      developer.log('🔧 [EMERGENCY] Carregamento de culturas temporariamente desabilitado',
          name: 'CulturasDataLoader');
      print('🔧 [EMERGENCY] Carregamento de culturas temporariamente desabilitado');
      
      // Mark as loaded to prevent repeated attempts
      _isLoaded = true;
      
      developer.log('✅ [EMERGENCY] Sistema estabilizado - carregamento de culturas será implementado após correção do Hive',
          name: 'CulturasDataLoader');
    } catch (e) {
      developer.log('❌ [EMERGENCY] Erro mínimo durante desabilitação: $e',
          name: 'CulturasDataLoader');
    }
  }

  /// Força recarregamento dos dados (para desenvolvimento)
  static Future<void> forceReload() async {
    _isLoaded = false;
    await loadCulturasData();
  }

  /// Verifica se dados estão carregados (temporarily always returns true)
  static Future<bool> isDataLoaded() async {
    return _isLoaded;
  }

  /// Obtém estatísticas de carregamento (emergency stub)
  static Future<Map<String, dynamic>> getStats() async {
    return {
      'total_culturas': 0,
      'is_loaded': _isLoaded,
      'sample_culturas': <String>[],
      'emergency_mode': true,
    };
  }
}
