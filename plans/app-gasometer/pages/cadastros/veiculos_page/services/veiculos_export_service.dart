// Internal dependencies

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../repository/veiculos_repository.dart';
import '../constants/veiculos_page_constants.dart';
import 'business_rules_engine.dart';
import 'error_handler.dart';
import 'service_manager.dart';

// Local imports

/// Service responsible for vehicle data export operations
class VeiculosExportService implements ILifecycleService {
  final VeiculosRepository _repository;
  final VeiculosBusinessRulesEngine _rulesEngine;

  VeiculosExportService(this._repository,
      [VeiculosBusinessRulesEngine? rulesEngine])
      : _rulesEngine = rulesEngine ?? VeiculosBusinessRulesEngine();

  /// Export vehicles to CSV format with business rules validation
  Future<String> exportToCsv() async {
    try {
      final veiculosLista = await _repository.getVeiculos();

      // Check if export is allowed by business rules
      final exportPermission =
          _rulesEngine.canExport(vehicleCount: veiculosLista.length);
      if (!exportPermission.isAllowed) {
        throw ExportException(
          exportPermission.getUserMessage(),
          StructuredError(
            type: ErrorType.business,
            severity: ErrorSeverity.medium,
            technicalMessage: 'Export denied: ${exportPermission.ruleViolated}',
            userMessage: exportPermission.getUserMessage(),
            context: 'CSV Export',
            suggestedAction: exportPermission.suggestedAction,
          ),
        );
      }

      return _generateCsvContent(veiculosLista);
    } catch (e) {
      if (e is ExportException) {
        rethrow;
      }
      final error =
          VeiculosErrorHandler.handleExportError(Exception(e.toString()));
      throw ExportException(error.userMessage, error);
    }
  }

  /// Generate CSV content from vehicle list
  String _generateCsvContent(List<VeiculoCar> veiculos) {
    const csvHeader = VeiculosPageConstants.csvHeader;

    final csvRows = veiculos.map((veiculo) {
      final combustivelTipo =
          VeiculosPageConstants.getCombustivelName(veiculo.combustivel);
      final marca = _escapeField(veiculo.marca);
      final modelo = _escapeField(veiculo.modelo);
      final placa = _escapeField(veiculo.placa);
      final renavan = _escapeField(veiculo.renavan);
      final chassi = _escapeField(veiculo.chassi);
      final cor = _escapeField(veiculo.cor);

      return '$marca${VeiculosPageConstants.csvSeparator}'
          '$modelo${VeiculosPageConstants.csvSeparator}'
          '${veiculo.ano}${VeiculosPageConstants.csvSeparator}'
          '$placa${VeiculosPageConstants.csvSeparator}'
          '${veiculo.odometroInicial}${VeiculosPageConstants.csvSeparator}'
          '${veiculo.odometroAtual}${VeiculosPageConstants.csvSeparator}'
          '$combustivelTipo${VeiculosPageConstants.csvSeparator}'
          '$renavan${VeiculosPageConstants.csvSeparator}'
          '$chassi${VeiculosPageConstants.csvSeparator}'
          '$cor${VeiculosPageConstants.csvSeparator}'
          '${veiculo.vendido}${VeiculosPageConstants.csvSeparator}'
          '${veiculo.valorVenda}';
    }).join(VeiculosPageConstants.csvRowSeparator);

    return csvHeader + csvRows;
  }

  /// Escape field for CSV format to prevent injection
  String _escapeField(String field) {
    if (VeiculosPageConstants.needsCsvEscape(field)) {
      return '"${field.replaceAll(VeiculosPageConstants.csvQuote, VeiculosPageConstants.csvEscapedQuote)}"';
    }
    return field;
  }

  /// Export vehicles to JSON format (future enhancement)
  Future<String> exportToJson() async {
    try {
      final veiculos = await _repository.getVeiculos();
      // TODO: Implement JSON export
      return '[]'; // Placeholder
    } catch (e) {
      final error =
          VeiculosErrorHandler.handleExportError(Exception(e.toString()));
      throw ExportException(error.userMessage, error);
    }
  }

  /// Validate export data before processing
  bool validateExportData(List<VeiculoCar> veiculos) {
    return veiculos.isNotEmpty;
  }

  /// Get export statistics
  Map<String, dynamic> getExportStats(List<VeiculoCar> veiculos) {
    return {
      'total_vehicles': veiculos.length,
      'exported_at': DateTime.now().toIso8601String(),
      'format': 'CSV',
    };
  }

  // ========================================
  // ILifecycleService Implementation
  // ========================================

  @override
  String get serviceName => 'VeiculosExportService';

  @override
  Future<void> init() async {
    // Initialize any required resources for export operations
    // Currently no initialization required for this service
  }

  @override
  Future<void> dispose() async {
    // Cleanup any resources used by the export service
    // Currently no cleanup required for this service
  }

  @override
  Future<bool> isHealthy() async {
    try {
      // Check if the service can access its dependencies
      await _repository.getSelectedVeiculoId();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Exception for export operations
class ExportException implements Exception {
  final String message;
  final StructuredError? structuredError;

  ExportException(this.message, [this.structuredError]);

  @override
  String toString() => message;
}
