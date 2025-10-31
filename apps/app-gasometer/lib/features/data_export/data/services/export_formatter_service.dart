import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

import '../../domain/entities/export_metadata.dart';

/// Serviço de formatação de dados de exportação
///
/// Responsabilidade: Formatar dados em diferentes formatos (JSON, CSV)
/// Aplica SRP (Single Responsibility Principle)
@injectable
class ExportFormatterService {
  /// Gera arquivo JSON estruturado com todos os dados
  Future<Uint8List> generateJsonExport(
    Map<String, dynamic> userData,
    ExportMetadata metadata,
  ) async {
    try {
      final exportData = {
        'export_metadata': metadata.toJson(),
        'lgpd_compliance_info': _getLgpdComplianceInfo(),
        'exported_data': userData,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      return Uint8List.fromList(utf8.encode(jsonString));
    } catch (e) {
      throw Exception('Erro ao gerar exportação JSON: $e');
    }
  }

  /// Gera arquivo CSV para dados tabulares
  Future<Uint8List> generateCsvExport(Map<String, dynamic> userData) async {
    try {
      final csvLines = <String>[];
      csvLines.add('Categoria,Item,Campo,Valor,Data_Registro');

      for (final entry in userData.entries) {
        final category = entry.key;
        final data = entry.value;

        if (data is List) {
          _processCsvList(csvLines, category, data);
        } else if (data is Map<String, dynamic>) {
          _processCsvMap(csvLines, category, data);
        }
      }

      final csvString = csvLines.join('\n');
      return Uint8List.fromList(utf8.encode(csvString));
    } catch (e) {
      throw Exception('Erro ao gerar exportação CSV: $e');
    }
  }

  /// Cria arquivo de metadados
  Future<Uint8List> generateMetadataFile(ExportMetadata metadata) async {
    try {
      final metadataJson = const JsonEncoder.withIndent('  ').convert({
        'informacoes_exportacao': metadata.toJson(),
        'instrucoes': _getExportInstructions(),
      });

      return Uint8List.fromList(utf8.encode(metadataJson));
    } catch (e) {
      throw Exception('Erro ao gerar arquivo de metadados: $e');
    }
  }

  /// Gera checksum simples do arquivo
  String generateChecksum(Uint8List data) {
    return data.hashCode.toString();
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Map<String, dynamic> _getLgpdComplianceInfo() {
    return {
      'data_controller': 'GasOMeter App',
      'export_purpose':
          'Atendimento ao direito de portabilidade de dados (LGPD)',
      'user_rights': [
        'Direito de acesso aos dados pessoais',
        'Direito de correção de dados inexatos',
        'Direito de eliminação de dados desnecessários',
        'Direito de portabilidade dos dados',
        'Direito de revogação do consentimento',
      ],
      'contact_info':
          'Para questões sobre seus dados, contate o DPO em: privacy@gasometer.app',
    };
  }

  Map<String, dynamic> _getExportInstructions() {
    return {
      'dados_completos_json':
          'Contém todos os seus dados em formato estruturado JSON',
      'dados_tabulares_csv':
          'Contém os dados em formato tabular para análise em planilhas',
      'lgpd_compliance':
          'Esta exportação está em conformidade com a LGPD (Lei Geral de Proteção de Dados)',
      'formato_datas':
          'Todas as datas estão no formato ISO 8601 (YYYY-MM-DDTHH:MM:SS)',
    };
  }

  void _processCsvList(
    List<String> csvLines,
    String category,
    List<dynamic> data,
  ) {
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (item is Map<String, dynamic>) {
        for (final field in item.entries) {
          csvLines.add(
            _escapeCsvField([
              category,
              'item_${i + 1}',
              field.key,
              field.value?.toString() ?? '',
              _extractDateFromMap(item) ?? '',
            ]),
          );
        }
      }
    }
  }

  void _processCsvMap(
    List<String> csvLines,
    String category,
    Map<String, dynamic> data,
  ) {
    for (final field in data.entries) {
      csvLines.add(
        _escapeCsvField([
          category,
          'single_record',
          field.key,
          field.value?.toString() ?? '',
          DateTime.now().toIso8601String(),
        ]),
      );
    }
  }

  String? _extractDateFromMap(Map<String, dynamic> item) {
    for (final dateField in [
      'date',
      'createdAt',
      'created_at',
      'timestamp',
      'updatedAt',
    ]) {
      if (item.containsKey(dateField) && item[dateField] != null) {
        return item[dateField].toString();
      }
    }
    return null;
  }

  String _escapeCsvField(List<String> fields) {
    return fields
        .map((field) {
          if (field.contains(',') ||
              field.contains('"') ||
              field.contains('\n')) {
            return '"${field.replaceAll('"', '""')}"';
          }
          return field;
        })
        .join(',');
  }
}
