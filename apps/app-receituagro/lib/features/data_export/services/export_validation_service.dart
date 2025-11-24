

import '../domain/entities/export_request.dart';

/// Service specialized in validating export requests
/// Principle: Single Responsibility - Only handles validation logic

class ExportValidationService {
  /// Validates if user can request a new export
  bool canRequestExport({
    required List<ExportRequest> history,
    int maxPendingRequests = 3,
  }) {
    final pendingCount = history
        .where(
          (req) =>
              req.status == ExportRequestStatus.pending ||
              req.status == ExportRequestStatus.processing,
        )
        .length;

    return pendingCount < maxPendingRequests;
  }

  /// Validates if data types are available for export
  bool areDataTypesAvailable(Set<DataType> requestedTypes) {
    // All types are available except diagnostics (example business rule)
    return !requestedTypes.contains(DataType.diagnostics);
  }

  /// Validates export request parameters
  String? validateExportRequest({
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) {
    if (userId.trim().isEmpty) {
      return 'ID do usuário é obrigatório';
    }

    if (dataTypes.isEmpty) {
      return 'Selecione pelo menos um tipo de dado para exportar';
    }

    if (dataTypes.contains(DataType.diagnostics)) {
      return 'Diagnósticos não estão disponíveis para exportação no momento';
    }

    return null; // Valid
  }

  /// Checks if export request is expired
  bool isExportExpired(ExportRequest request, {int expirationDays = 7}) {
    if (request.completionDate == null) return false;

    final now = DateTime.now();
    final difference = now.difference(request.completionDate!);

    return difference.inDays > expirationDays;
  }

  /// Gets error message for validation failure
  String getValidationErrorMessage(String? validationError) {
    if (validationError == null) return 'Erro de validação';
    return validationError;
  }

  /// Checks if export is downloadable
  bool isDownloadable(ExportRequest request) {
    return request.status == ExportRequestStatus.completed &&
        request.downloadUrl != null &&
        !isExportExpired(request);
  }
}
