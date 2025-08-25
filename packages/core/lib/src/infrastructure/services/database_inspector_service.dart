import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/custom_box_type.dart';
import '../../domain/entities/database_record.dart';
import '../../domain/entities/shared_preferences_record.dart';

/// Sistema completo de inspeção e visualização de dados locais
/// Permite visualizar, analisar e gerenciar dados armazenados em Hive Boxes 
/// e SharedPreferences, oferecendo uma ferramenta essencial para debug, 
/// desenvolvimento e monitoramento de dados
class DatabaseInspectorService {
  static DatabaseInspectorService? _instance;
  final List<CustomBoxType> _customBoxes = [];
  
  DatabaseInspectorService._internal();

  /// Singleton instance
  static DatabaseInspectorService get instance {
    _instance ??= DatabaseInspectorService._internal();
    return _instance!;
  }

  /// Boxes customizadas registradas
  List<CustomBoxType> get customBoxes => List.unmodifiable(_customBoxes);

  /// Registra boxes customizadas para inspeção
  void registerCustomBoxes(List<CustomBoxType> boxes) {
    _customBoxes.clear();
    _customBoxes.addAll(boxes);
    
    if (kDebugMode) {
      print('DatabaseInspector: Registered ${boxes.length} custom boxes');
      for (final box in boxes) {
        print('  - ${box.key}: ${box.displayName} (${box.module})');
      }
    }
  }

  /// Adiciona uma box customizada
  void addCustomBox(CustomBoxType box) {
    final existingIndex = _customBoxes.indexWhere((b) => b.key == box.key);
    if (existingIndex >= 0) {
      _customBoxes[existingIndex] = box;
    } else {
      _customBoxes.add(box);
    }
  }

  /// Remove uma box customizada
  void removeCustomBox(String key) {
    _customBoxes.removeWhere((box) => box.key == key);
  }

  /// Obtém o nome de exibição de uma box
  String getBoxDisplayName(String key) {
    final customBox = _customBoxes.where((box) => box.key == key).firstOrNull;
    return customBox?.displayName ?? key;
  }

  /// Obtém a descrição de uma box
  String? getBoxDescription(String key) {
    final customBox = _customBoxes.where((box) => box.key == key).firstOrNull;
    return customBox?.description;
  }

  /// Carrega dados de uma Hive Box específica
  Future<List<DatabaseRecord>> loadHiveBoxData(String boxKey) async {
    try {
      final box = Hive.box(boxKey);
      final records = <DatabaseRecord>[];

      for (final key in box.keys) {
        try {
          final value = box.get(key);
          final data = _convertToMap(value, key.toString());
          
          records.add(DatabaseRecord(
            id: key.toString(),
            data: data,
            boxKey: boxKey,
          ));
        } catch (e) {
          // Registrar erro mas continuar processamento
          if (kDebugMode) {
            print('Error loading record $key from box $boxKey: $e');
          }
          
          records.add(DatabaseRecord(
            id: key.toString(),
            data: {
              '_error': 'Failed to load record: $e',
              '_originalKey': key.toString(),
            },
            boxKey: boxKey,
          ));
        }
      }

      return records;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading Hive box $boxKey: $e');
      }
      throw Exception('Failed to load Hive box $boxKey: $e');
    }
  }

  /// Carrega dados do SharedPreferences
  Future<List<SharedPreferencesRecord>> loadSharedPreferencesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final records = <SharedPreferencesRecord>[];

      for (final key in keys) {
        try {
          final value = _getSharedPreferencesValue(prefs, key);
          final type = _getSharedPreferencesType(prefs, key);
          
          records.add(SharedPreferencesRecord(
            key: key,
            value: value,
            type: type,
          ));
        } catch (e) {
          if (kDebugMode) {
            print('Error loading SharedPreferences key $key: $e');
          }
        }
      }

      // Ordenar por chave
      records.sort((a, b) => a.key.compareTo(b.key));
      return records;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading SharedPreferences: $e');
      }
      throw Exception('Failed to load SharedPreferences: $e');
    }
  }

  /// Remove uma chave do SharedPreferences
  Future<bool> removeSharedPreferencesKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(key);
      
      if (kDebugMode) {
        print('SharedPreferences key "$key" ${result ? 'removed' : 'not found'}');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing SharedPreferences key $key: $e');
      }
      return false;
    }
  }

  /// Extrai campos únicos de uma lista de registros
  Set<String> extractUniqueFields(List<DatabaseRecord> records) {
    final fields = <String>{};
    
    for (final record in records) {
      fields.addAll(record.fields);
    }
    
    return fields;
  }

  /// Converte registros para formato tabular
  List<List<String>> convertToTableFormat(List<DatabaseRecord> records) {
    if (records.isEmpty) return [];
    
    final fields = extractUniqueFields(records).toList();
    fields.sort(); // Ordenar campos alfabeticamente
    
    // Cabeçalho
    final table = <List<String>>[];
    table.add(['ID', ...fields]);
    
    // Dados
    for (final record in records) {
      final row = <String>[record.id];
      
      for (final field in fields) {
        final value = record.data[field];
        row.add(_formatValueForTable(value));
      }
      
      table.add(row);
    }
    
    return table;
  }

  /// Formata dados como string JSON
  String formatAsJsonString(Map<String, dynamic> data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Exporta dados de uma box para arquivo
  Future<File> exportBoxData(String boxKey) async {
    try {
      final records = await loadHiveBoxData(boxKey);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'hive_box_${boxKey}_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      final exportData = {
        'boxKey': boxKey,
        'displayName': getBoxDisplayName(boxKey),
        'description': getBoxDescription(boxKey),
        'exportedAt': DateTime.now().toIso8601String(),
        'totalRecords': records.length,
        'records': records.map((r) => r.toJson()).toList(),
      };

      await file.writeAsString(formatAsJsonString(exportData));
      
      if (kDebugMode) {
        print('Box data exported to: ${file.path}');
      }
      
      return file;
    } catch (e) {
      throw Exception('Failed to export box data: $e');
    }
  }

  /// Exporta dados do SharedPreferences para arquivo
  Future<File> exportSharedPreferencesData() async {
    try {
      final records = await loadSharedPreferencesData();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'shared_preferences_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      final exportData = {
        'type': 'SharedPreferences',
        'exportedAt': DateTime.now().toIso8601String(),
        'totalKeys': records.length,
        'totalSizeBytes': records.fold<int>(0, (sum, r) => sum + r.sizeInBytes),
        'records': records.map((r) => r.toJson()).toList(),
      };

      await file.writeAsString(formatAsJsonString(exportData));
      
      if (kDebugMode) {
        print('SharedPreferences data exported to: ${file.path}');
      }
      
      return file;
    } catch (e) {
      throw Exception('Failed to export SharedPreferences data: $e');
    }
  }

  /// Obtém todas as boxes Hive disponíveis
  List<String> getAvailableHiveBoxes() {
    // Note: Hive não expõe boxNames diretamente, usar boxes registradas
    final boxNames = <String>[];
    
    // Adicionar boxes customizadas conhecidas
    for (final customBox in _customBoxes) {
      try {
        if (Hive.isBoxOpen(customBox.key)) {
          boxNames.add(customBox.key);
        }
      } catch (e) {
        // Ignorar se box não existir
      }
    }
    
    return boxNames;
  }

  /// Obtém estatísticas de uma box
  Map<String, dynamic> getBoxStats(String boxKey) {
    try {
      final box = Hive.box(boxKey);
      final keys = box.keys.toList();
      
      return {
        'boxKey': boxKey,
        'displayName': getBoxDisplayName(boxKey),
        'totalRecords': keys.length,
        'isOpen': box.isOpen,
        'path': box.path,
        'lazy': box.lazy,
        'sampleKeys': keys.take(5).toList(),
      };
    } catch (e) {
      return {
        'boxKey': boxKey,
        'error': e.toString(),
      };
    }
  }

  /// Obtém estatísticas gerais do banco de dados
  Map<String, dynamic> getGeneralStats() {
    final hiveBoxes = getAvailableHiveBoxes();
    final totalBoxes = hiveBoxes.length;
    int totalRecords = 0;
    
    for (final boxKey in hiveBoxes) {
      try {
        final box = Hive.box(boxKey);
        totalRecords += box.keys.length;
      } catch (e) {
        // Ignorar boxes que não podem ser abertas
      }
    }
    
    return {
      'totalHiveBoxes': totalBoxes,
      'totalHiveRecords': totalRecords,
      'customBoxesRegistered': _customBoxes.length,
      'availableBoxes': hiveBoxes,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Converte valor para Map
  Map<String, dynamic> _convertToMap(dynamic value, String key) {
    if (value == null) {
      return {'_null': true, '_key': key};
    }
    
    if (value is Map) {
      // Converter Map para Map<String, dynamic>
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result[entry.key.toString()] = entry.value;
      }
      return result;
    }
    
    if (value is List) {
      return {
        '_type': 'List',
        '_length': value.length,
        '_items': value.asMap().map((index, item) => MapEntry(index.toString(), item)),
        '_key': key,
      };
    }
    
    // Para tipos primitivos, criar um wrapper
    return {
      '_type': value.runtimeType.toString(),
      '_value': value,
      '_key': key,
    };
  }

  /// Obtém valor do SharedPreferences
  dynamic _getSharedPreferencesValue(SharedPreferences prefs, String key) {
    final value = prefs.get(key);
    return value;
  }

  /// Obtém tipo do valor no SharedPreferences
  String _getSharedPreferencesType(SharedPreferences prefs, String key) {
    final value = prefs.get(key);
    
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is bool) return 'bool';
    if (value is double) return 'double';
    if (value is List<String>) return 'List<String>';
    
    return 'unknown';
  }

  /// Formata valor para tabela
  String _formatValueForTable(dynamic value) {
    if (value == null) return '';
    
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    
    if (value is List) {
      return '[${value.length} items]';
    }
    
    if (value is Map) {
      return '{${value.keys.length} keys}';
    }
    
    return value.toString();
  }
}