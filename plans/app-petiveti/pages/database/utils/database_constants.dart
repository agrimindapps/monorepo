// Flutter imports:
import 'package:flutter/material.dart';

class DatabaseConstants {
  // Grid dimensions
  static const double defaultColumnWidth = 150.0;
  static const double idColumnWidth = 100.0;
  static const double maxColumnWidth = 300.0;
  static const double minColumnWidth = 80.0;

  // Grid styling
  static const double rowHeight = 46.0;
  static const double columnHeight = 50.0;
  static const double gridElevation = 2.0;
  static const double cardBorderRadius = 12.0;

  // Search
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const int maxSearchResults = 1000;

  // Export
  static const int maxExportRecords = 10000;
  static const List<String> supportedExportFormats = ['json', 'csv'];

  // Colors
  static const Color gridBorderColor = Color(0xFFE0E0E0);
  static const Color gridBackgroundColor = Colors.white;
  static const Color activatedBorderColor = Colors.blue;
  static const Color activatedColor = Color(0xFFE3F2FD);
  static const Color headerBackgroundColor = Color(0xFFF5F5F5);

  // Text styles
  static const TextStyle cellTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle columnTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle footerTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
    color: Colors.grey,
  );

  // Field name mappings for better display
  static const Map<String, String> fieldDisplayNames = {
    'id': 'ID',
    'nome': 'Nome',
    'especie': 'Espécie',
    'raca': 'Raça',
    'idade': 'Idade',
    'peso': 'Peso',
    'data': 'Data',
    'valor': 'Valor',
    'descricao': 'Descrição',
    'veterinario': 'Veterinário',
    'motivo': 'Motivo',
    'diagnostico': 'Diagnóstico',
    'medicamento': 'Medicamento',
    'dosagem': 'Dosagem',
    'frequencia': 'Frequência',
    'vacina': 'Vacina',
    'proxima_dose': 'Próxima Dose',
    'status': 'Status',
    'lembrete': 'Lembrete',
    'categoria': 'Categoria',
    'observacoes': 'Observações',
    'created_at': 'Criado em',
    'updated_at': 'Atualizado em',
  };

  // Column width mapping based on field type
  static const Map<String, double> fieldColumnWidths = {
    'id': idColumnWidth,
    'nome': 200.0,
    'especie': 120.0,
    'raca': 150.0,
    'idade': 80.0,
    'peso': 100.0,
    'data': 120.0,
    'valor': 100.0,
    'descricao': 250.0,
    'veterinario': 180.0,
    'motivo': 200.0,
    'diagnostico': 250.0,
    'medicamento': 200.0,
    'dosagem': 100.0,
    'frequencia': 120.0,
    'vacina': 150.0,
    'proxima_dose': 120.0,
    'status': 100.0,
    'lembrete': 200.0,
    'categoria': 120.0,
    'observacoes': 250.0,
    'created_at': 140.0,
    'updated_at': 140.0,
  };

  // Loading and error messages
  static const String loadingMessage = 'Carregando dados...';
  static const String noDataMessage = 'Nenhum dado encontrado';
  static const String errorLoadingMessage = 'Erro ao carregar dados';
  static const String searchPlaceholder = 'Pesquisar em todos os campos...';
  static const String exportSuccessMessage = 'Dados exportados com sucesso';
  static const String exportErrorMessage = 'Erro ao exportar dados';

  // Validation
  static const int maxRecordsToDisplay = 5000;
  static const int maxFieldsToDisplay = 50;

  static String getFieldDisplayName(String fieldName) {
    return fieldDisplayNames[fieldName] ?? _formatFieldName(fieldName);
  }

  static String _formatFieldName(String fieldName) {
    // Convert snake_case to Title Case
    return fieldName
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static double getColumnWidth(String fieldName) {
    return fieldColumnWidths[fieldName] ?? defaultColumnWidth;
  }
}
