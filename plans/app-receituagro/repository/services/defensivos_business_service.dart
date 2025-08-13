// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../../core/models/database.dart';
import 'defensivos_data_access.dart';
import 'defensivos_formatter.dart';

/// Business Service para Defensivos
/// Responsabilidade única: lógica de negócio e processamento de dados
class DefensivosBusinessService {
  final DefensivosDataAccess _dataAccess;
  final DefensivosFormatter _formatter;
  
  DefensivosBusinessService(this._dataAccess, this._formatter);
  
  /// Extrai categorias únicas de um campo
  List<String> extractUniqueCategories({
    required List<Map<String, dynamic>> source,
    required String field,
    String separator = ',',
  }) {
    final uniqueCategories = <String>{};

    for (final row in source) {
      final fieldValue = row[field]?.toString() ?? '';
      if (fieldValue.trim().isEmpty) continue;

      for (final item in fieldValue.split(separator)) {
        final trimmed = item.trim().toLowerCase();
        if (trimmed.isNotEmpty) {
          uniqueCategories.add(trimmed);
        }
      }
    }

    final result = uniqueCategories.toList()..sort();
    return result;
  }
  
  /// Extrai fabricantes únicos
  List<String> extractUniqueManufacturers() {
    final manufacturers = _dataAccess.getAllFitossanitarios()
        .map((item) => item['fabricante'].toString().toLowerCase())
        .where((fab) => fab.isNotEmpty && fab != '-')
        .toSet()
        .toList()
      ..sort();

    return manufacturers;
  }
  
  /// Valida se um item de categoria é válido
  bool isValidCategoryItem(String item) {
    return item.isNotEmpty && item != '-' && item != 'null';
  }
  
  /// Cria lista de categorias formatada
  List<Map<String, dynamic>> createCategoryList({
    required List<String> items,
    required String countField,
  }) {
    return items
        .where((item) => isValidCategoryItem(item))
        .map((item) => _formatter.createCategoryItem(
            item, _dataAccess.countRecordsByField(countField, item)))
        .toList();
  }
  
  /// Filtra e ordena items por campo
  List<Map<String, dynamic>> filterAndSortItems(String value, String field) {
    return _dataAccess.getFitossanitariosByField(field, value)
      ..sort((a, b) => a['nomeComum'].compareTo(b['nomeComum']));
  }
  
  /// Filtra e ordena items por fabricante
  List<Map<String, dynamic>> filterAndSortManufacturerItems(String value) {
    final items = _dataAccess.getAllFitossanitarios()
        .where((row) => row['fabricante']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();
    
    items.sort((a, b) => a['nomeComum'].compareTo(b['nomeComum']));
    return items;
  }
  
  /// Processa diagnósticos raw
  List<Map<String, dynamic>> processDiagnostics(
      List<Map<String, dynamic>> rawData) {
    
    final processedData = rawData.map((row) {
      final diagnostico = _formatter.createBaseDiagnosticItem(row);
      final item = diagnostico.toMap();

      _formatter.enrichDiagnosticItem(
        item: item,
        row: row,
        pragas: _dataAccess.getAllPragas(),
        culturas: _dataAccess.getAllCulturas(),
        defensivos: _dataAccess.getAllFitossanitarios(),
      );

      return item;
    }).toList();

    return Database()
        .orderList(processedData, 'cultura', null, false)
        .cast<Map<String, dynamic>>();
  }
  
  /// Organiza dados por cultura
  List<Map<String, dynamic>> organizePorCultura(
    List<Map<String, dynamic>> list,
    int type,
  ) {
    final grouped = groupBy(list, (item) => item['cultura']);
    final field = type == 1 ? 'nomePraga' : 'nomeDefensivo';

    return grouped.entries
        .map((entry) => _createCultureGroup(entry.key, entry.value, field))
        .toList();
  }
  
  /// Cria grupo de cultura
  Map<String, dynamic> _createCultureGroup(
    String culture,
    List<dynamic> items,
    String sortField,
  ) {
    return {
      'cultura': culture,
      'indicacoes': Database().orderList(items, sortField, null, false),
    };
  }
  
  /// Combina dados básicos do defensivo com informações extras
  Map<String, dynamic> combineDefensivoInfo(
    Map<String, dynamic> basicData,
    Map<String, dynamic>? extraInfo,
  ) {
    final result = {
      'nomeComum': basicData['nomeComum'] ?? '',
      'formulacao': basicData['formulacao'] ?? '',
      'registroMAPA': basicData['registroMAPA'] ?? '',
      'fabricante': basicData['fabricante'] ?? '',
      'modoAcao': basicData['modoAcao'] ?? '',
      'classeAgronomica': basicData['classeAgronomica'] ?? '',
      'classeQuimica': basicData['classeQuimica'] ?? '',
      'toxicologica': basicData['toxicologica'] ?? '',
      'ambiental': basicData['ambiental'] ?? '',
      'grupo': basicData['grupo'] ?? '',
      'subgrupo': basicData['subgrupo'] ?? '',
    };

    // Adicionar informações extras se disponíveis
    if (extraInfo != null) {
      result.addAll({
        'tecnologia': extraInfo['tecnologia'] ?? '',
        'embalagens': extraInfo['embalagens'] ?? '',
        'manejoIntegrado': extraInfo['manejoIntegrado'] ?? '',
        'manejoResistencia': extraInfo['manejoResistencia'] ?? '',
        'pHumanas': extraInfo['pHumanas'] ?? '',
        'pAmbientais': extraInfo['pAmbiental'] ?? '',
        'compatibilidade': extraInfo['compatibilidade'] ?? '',
      });
    }

    return result;
  }
}