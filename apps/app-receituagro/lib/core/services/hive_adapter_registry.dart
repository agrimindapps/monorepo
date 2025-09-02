import 'package:hive_flutter/hive_flutter.dart';

import '../models/comentario_hive.dart';
import '../models/cultura_hive.dart';
import '../models/diagnostico_hive.dart';
import '../models/favorito_item_hive.dart';
import '../models/fitossanitario_hive.dart';
import '../models/fitossanitario_info_hive.dart';
import '../models/plantas_inf_hive.dart';
import '../models/pragas_hive.dart';
import '../models/pragas_inf_hive.dart';
import '../models/premium_status_hive.dart';

/// Registry centralizado para registro de todos os adapters Hive
/// Responsável por registrar todos os type adapters necessários
class HiveAdapterRegistry {
  static bool _isRegistered = false;

  /// Registra todos os adapters Hive necessários
  static Future<void> registerAdapters() async {
    if (_isRegistered) {
      return;
    }

    try {
      // Registra adapters das classes Hive
      Hive.registerAdapter(CulturaHiveAdapter());
      Hive.registerAdapter(PragasHiveAdapter());
      Hive.registerAdapter(FitossanitarioHiveAdapter());
      Hive.registerAdapter(DiagnosticoHiveAdapter());
      Hive.registerAdapter(FitossanitarioInfoHiveAdapter());
      Hive.registerAdapter(PlantasInfHiveAdapter());
      Hive.registerAdapter(PragasInfHiveAdapter());
      Hive.registerAdapter(PremiumStatusHiveAdapter());
      Hive.registerAdapter(ComentarioHiveAdapter());
      Hive.registerAdapter(FavoritoItemHiveAdapter());

      _isRegistered = true;
      
    } catch (e) {
      throw Exception('Erro ao registrar adapters Hive: $e');
    }
  }

  /// Verifica se os adapters já foram registrados
  static bool get isRegistered => _isRegistered;

  /// Lista de boxes que serão criadas
  static const Map<String, String> boxNames = {
    'culturas': 'receituagro_culturas',
    'pragas': 'receituagro_pragas',
    'fitossanitarios': 'receituagro_fitossanitarios',
    'diagnosticos': 'receituagro_diagnosticos',
    'fitossanitarios_info': 'receituagro_fitossanitarios_info',
    'plantas_inf': 'receituagro_plantas_inf',
    'pragas_inf': 'receituagro_pragas_inf',
    'premium_status': 'receituagro_premium_status',
    'comentarios': 'comentarios',
    'favoritos': 'receituagro_user_favorites',
  };

  /// Abre todas as boxes necessárias
  static Future<void> openBoxes() async {
    try {
      await Future.wait([
        Hive.openBox<CulturaHive>(boxNames['culturas']!),
        Hive.openBox<PragasHive>(boxNames['pragas']!),
        Hive.openBox<FitossanitarioHive>(boxNames['fitossanitarios']!),
        Hive.openBox<DiagnosticoHive>(boxNames['diagnosticos']!),
        Hive.openBox<FitossanitarioInfoHive>(boxNames['fitossanitarios_info']!),
        Hive.openBox<PlantasInfHive>(boxNames['plantas_inf']!),
        Hive.openBox<PragasInfHive>(boxNames['pragas_inf']!),
        Hive.openBox<PremiumStatusHive>(boxNames['premium_status']!),
        Hive.openBox<ComentarioHive>(boxNames['comentarios']!),
        Hive.openBox<FavoritoItemHive>(boxNames['favoritos']!),
      ]);
      
    } catch (e) {
      throw Exception('Erro ao abrir boxes Hive: $e');
    }
  }

  /// Fecha todas as boxes
  static Future<void> closeBoxes() async {
    try {
      await Future.wait([
        _closeBoxIfOpen(boxNames['culturas']!),
        _closeBoxIfOpen(boxNames['pragas']!),
        _closeBoxIfOpen(boxNames['fitossanitarios']!),
        _closeBoxIfOpen(boxNames['diagnosticos']!),
        _closeBoxIfOpen(boxNames['fitossanitarios_info']!),
        _closeBoxIfOpen(boxNames['plantas_inf']!),
        _closeBoxIfOpen(boxNames['pragas_inf']!),
        _closeBoxIfOpen(boxNames['premium_status']!),
        _closeBoxIfOpen(boxNames['comentarios']!),
        _closeBoxIfOpen(boxNames['favoritos']!),
      ]);
      
    } catch (e) {
      throw Exception('Erro ao fechar boxes Hive: $e');
    }
  }

  /// Helper para fechar box se estiver aberta
  static Future<void> _closeBoxIfOpen(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
  }

  /// Limpa todas as boxes (útil para desenvolvimento)
  static Future<void> clearAllBoxes() async {
    try {
      if (Hive.isBoxOpen(boxNames['culturas']!)) {
        await Hive.box<CulturaHive>(boxNames['culturas']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['pragas']!)) {
        await Hive.box<PragasHive>(boxNames['pragas']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['fitossanitarios']!)) {
        await Hive.box<FitossanitarioHive>(boxNames['fitossanitarios']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['diagnosticos']!)) {
        await Hive.box<DiagnosticoHive>(boxNames['diagnosticos']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['fitossanitarios_info']!)) {
        await Hive.box<FitossanitarioInfoHive>(boxNames['fitossanitarios_info']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['plantas_inf']!)) {
        await Hive.box<PlantasInfHive>(boxNames['plantas_inf']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['pragas_inf']!)) {
        await Hive.box<PragasInfHive>(boxNames['pragas_inf']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['premium_status']!)) {
        await Hive.box<PremiumStatusHive>(boxNames['premium_status']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['comentarios']!)) {
        await Hive.box<ComentarioHive>(boxNames['comentarios']!).clear();
      }
      if (Hive.isBoxOpen(boxNames['favoritos']!)) {
        await Hive.box<FavoritoItemHive>(boxNames['favoritos']!).clear();
      }
      
    } catch (e) {
      throw Exception('Erro ao limpar boxes Hive: $e');
    }
  }
}