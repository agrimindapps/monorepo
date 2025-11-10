import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Service para carregar dados de HiveBoxes com segurança
///
/// Responsabilidades:
/// - Abrir/fechar boxes com estratégia segura
/// - Ler registros tratando erros individuais
/// - Converter dados para DatabaseRecord
/// - Evitar erros de "box já aberta"
class HiveBoxLoaderService {
  HiveBoxLoaderService._();

  /// Carrega dados de uma HiveBox com estratégia segura: abrir → ler → fechar
  ///
  /// Isso evita erros de "box já aberta" e trata cenários:
  /// - Box já aberta (usa instância existente sem reabrir)
  /// - Box fechada (abre, lê e fecha)
  /// - Erros de leitura individual (pula registro com erro)
  static Future<List<DatabaseRecord>> loadBoxDataSafely(String boxKey) async {
    try {
      // Verificar se box já está aberta ANTES de tentar abrir
      final wasAlreadyOpen = Hive.isBoxOpen(boxKey);

      // Se já está aberta, usar instância existente sem especificar tipo
      // para evitar conflito com boxes tipadas (ex: Box<ComentarioHive>)
      Box<dynamic> box;
      if (wasAlreadyOpen) {
        box = Hive.box<dynamic>(boxKey);
      } else {
        box = await Hive.openBox<dynamic>(boxKey);
      }

      final records = <DatabaseRecord>[];

      for (var i = 0; i < box.length; i++) {
        try {
          final key = box.keyAt(i);
          final value = box.getAt(i);

          if (value != null) {
            final dataMap =
                value is Map<String, dynamic>
                    ? value
                    : <String, dynamic>{'raw': value};

            records.add(
              DatabaseRecord(
                id: key?.toString() ?? i.toString(),
                data: dataMap,
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Erro ao ler registro $i da box $boxKey: $e');
          }
        }
      }

      // Fecha box somente se foi aberta por este método
      if (!wasAlreadyOpen && box.isOpen) {
        await box.close();
      }

      return records;
    } catch (e) {
      // Fallback para box já aberta
      if (e.toString().contains('already open')) {
        return _loadFromOpenBox(boxKey);
      }

      throw Exception('Failed to load Hive box $boxKey: $e');
    }
  }

  /// Fallback: carrega dados de box já aberta
  static Future<List<DatabaseRecord>> _loadFromOpenBox(String boxKey) async {
    try {
      final box = Hive.box<dynamic>(boxKey);
      final records = <DatabaseRecord>[];

      for (var i = 0; i < box.length; i++) {
        try {
          final key = box.keyAt(i);
          final value = box.getAt(i);

          if (value != null) {
            final dataMap =
                value is Map<String, dynamic>
                    ? value
                    : <String, dynamic>{'raw': value};

            records.add(
              DatabaseRecord(
                id: key?.toString() ?? i.toString(),
                data: dataMap,
              ),
            );
          }
        } catch (readError) {
          if (kDebugMode) {
            print('Erro ao ler registro $i: $readError');
          }
        }
      }

      return records;
    } catch (fallbackError) {
      throw Exception('Failed to load Hive box $boxKey: $fallbackError');
    }
  }
}
