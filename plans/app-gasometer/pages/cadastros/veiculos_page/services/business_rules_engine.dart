// Flutter

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../config/business_rules.dart';

// Local imports

/// Engine that processes business rules and makes decisions
///
/// This engine evaluates business rules based on current configuration
/// and provides contextual decisions for various operations.
class VeiculosBusinessRulesEngine {
  final VeiculosBusinessRules _rules;

  VeiculosBusinessRulesEngine({VeiculosBusinessRules? rules})
      : _rules = rules ?? VeiculosBusinessRules.instance;

  /// ========================================
  /// VEHICLE CREATION RULES
  /// ========================================

  /// Evaluate if a new vehicle can be created
  BusinessRuleResult canCreateVehicle({
    required int currentVehicleCount,
    Map<String, dynamic>? additionalContext,
  }) {
    // Check vehicle limit
    if (!_rules.canCreateVehicle(currentVehicleCount)) {
      return BusinessRuleResult.denied(
        reason: 'Limite de ${_rules.maxVehicles} veículos atingido.',
        suggestedAction: _rules.isPremiumEnabled
            ? 'Remova um veículo existente ou entre em contato com o suporte.'
            : 'Remova um veículo existente ou faça upgrade para Premium.',
        ruleViolated: 'max_vehicles_limit',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Veículo pode ser criado.',
      remainingQuota: _rules.maxVehicles - currentVehicleCount,
    );
  }

  /// Evaluate vehicle data before creation/update
  BusinessRuleResult validateVehicleData({
    required Map<String, dynamic> vehicleData,
  }) {
    final violations = <String>[];

    // Validate year
    final year = vehicleData['year'] as int?;
    if (year != null && !_rules.isValidVehicleYear(year)) {
      violations.add(
          'Ano do veículo deve estar entre ${_rules.minVehicleYear} e ${_rules.maxVehicleYear}.');
    }

    // Validate required fields based on business rules
    final requiredFields = _getRequiredFieldsForProfile();
    for (final field in requiredFields) {
      if (!vehicleData.containsKey(field) ||
          vehicleData[field] == null ||
          vehicleData[field].toString().isEmpty) {
        violations.add('Campo obrigatório: ${_getFieldDisplayName(field)}');
      }
    }

    if (violations.isNotEmpty) {
      return BusinessRuleResult.denied(
        reason: 'Dados do veículo inválidos.',
        details: violations,
        ruleViolated: 'vehicle_data_validation',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Dados do veículo válidos.',
    );
  }

  /// ========================================
  /// OPERATION PERMISSION RULES
  /// ========================================

  /// Evaluate if export operation is allowed
  BusinessRuleResult canExport({
    required int vehicleCount,
    String? exportFormat,
  }) {
    if (!_rules.isOperationAllowed(BusinessOperation.export)) {
      return BusinessRuleResult.denied(
        reason: _rules.getRestrictionMessage(BusinessOperation.export),
        suggestedAction:
            'Faça upgrade para Premium para acessar recursos de exportação.',
        ruleViolated: 'export_permission',
      );
    }

    // Additional validation for large exports
    if (vehicleCount > 50 && !_rules.isBulkOperationsEnabled) {
      return BusinessRuleResult.denied(
        reason:
            'Exportação de mais de 50 veículos requer funcionalidades Premium.',
        suggestedAction: 'Reduza a seleção ou faça upgrade para Premium.',
        ruleViolated: 'bulk_export_limit',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Exportação autorizada.',
      additionalInfo: {'max_vehicles': vehicleCount},
    );
  }

  /// Evaluate if advanced statistics can be accessed
  BusinessRuleResult canAccessAdvancedStats() {
    if (!_rules.isOperationAllowed(BusinessOperation.advancedStats)) {
      return BusinessRuleResult.denied(
        reason: _rules.getRestrictionMessage(BusinessOperation.advancedStats),
        suggestedAction:
            'Faça upgrade para Premium para acessar estatísticas avançadas.',
        ruleViolated: 'advanced_stats_permission',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Estatísticas avançadas disponíveis.',
    );
  }

  /// Evaluate bulk operation permissions
  BusinessRuleResult canPerformBulkOperation({
    required String operationType,
    required int itemCount,
  }) {
    if (!_rules.isOperationAllowed(BusinessOperation.bulkOperations)) {
      return BusinessRuleResult.denied(
        reason: _rules.getRestrictionMessage(BusinessOperation.bulkOperations),
        suggestedAction: 'Faça upgrade para Premium para operações em lote.',
        ruleViolated: 'bulk_operations_permission',
      );
    }

    // Enterprise-specific limits
    if (itemCount > 20 && _rules.config.profileName != 'Enterprise') {
      return BusinessRuleResult.denied(
        reason:
            'Operações em lote com mais de 20 itens requerem plano Enterprise.',
        suggestedAction: 'Reduza a seleção ou faça upgrade para Enterprise.',
        ruleViolated: 'enterprise_bulk_limit',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Operação em lote autorizada.',
      additionalInfo: {
        'operation_type': operationType,
        'item_count': itemCount,
      },
    );
  }

  /// ========================================
  /// IMPORT RULES
  /// ========================================

  /// Evaluate file import permissions
  BusinessRuleResult canImportFile({
    required double fileSizeMB,
    required String fileType,
  }) {
    if (fileSizeMB > _rules.maxImportFileSizeMB) {
      return BusinessRuleResult.denied(
        reason: 'Arquivo excede o limite de ${_rules.maxImportFileSizeMB}MB.',
        suggestedAction: _rules.isPremiumEnabled
            ? 'Reduza o tamanho do arquivo ou divida em múltiplos arquivos.'
            : 'Faça upgrade para Premium para aumentar o limite de importação.',
        ruleViolated: 'file_size_limit',
      );
    }

    // Validate file type based on business rules
    final allowedTypes = _getAllowedImportTypes();
    if (!allowedTypes.contains(fileType.toLowerCase())) {
      return BusinessRuleResult.denied(
        reason: 'Tipo de arquivo não suportado: $fileType',
        details: ['Tipos permitidos: ${allowedTypes.join(', ')}'],
        ruleViolated: 'file_type_restriction',
      );
    }

    return BusinessRuleResult.allowed(
      message: 'Importação de arquivo autorizada.',
      additionalInfo: {
        'file_size_mb': fileSizeMB,
        'file_type': fileType,
      },
    );
  }

  /// ========================================
  /// HELPER METHODS
  /// ========================================

  List<String> _getRequiredFieldsForProfile() {
    final baseFields = ['marca', 'modelo', 'ano', 'placa'];

    if (_rules.isPremiumEnabled) {
      return [...baseFields, 'chassi', 'renavan', 'cor'];
    }

    return baseFields;
  }

  String _getFieldDisplayName(String field) {
    const fieldNames = {
      'marca': 'Marca',
      'modelo': 'Modelo',
      'ano': 'Ano',
      'placa': 'Placa',
      'chassi': 'Chassi',
      'renavan': 'Renavan',
      'cor': 'Cor',
      'odometroInicial': 'Odômetro Inicial',
      'combustivel': 'Combustível',
    };

    return fieldNames[field] ?? field;
  }

  List<String> _getAllowedImportTypes() {
    final baseTypes = ['csv', 'txt'];

    if (_rules.isPremiumEnabled) {
      return [...baseTypes, 'xlsx', 'json'];
    }

    return baseTypes;
  }

  /// ========================================
  /// RULE EVALUATION CONTEXT
  /// ========================================

  /// Get current rule evaluation context
  Map<String, dynamic> getRuleContext() {
    return {
      'profile': _rules.config.profileName,
      'max_vehicles': _rules.maxVehicles,
      'is_premium': _rules.isPremiumEnabled,
      'timestamp': DateTime.now().toIso8601String(),
      'engine_version': '1.0.0',
    };
  }

  /// Log rule evaluation for debugging
  void logRuleEvaluation(String operation, BusinessRuleResult result) {
    if (kDebugMode) {
      debugPrint(
          '[BusinessRulesEngine] $operation: ${result.isAllowed ? 'ALLOWED' : 'DENIED'}');
      if (!result.isAllowed) {
        debugPrint('[BusinessRulesEngine] Reason: ${result.reason}');
        debugPrint('[BusinessRulesEngine] Rule: ${result.ruleViolated}');
      }
    }
  }
}

/// ========================================
/// RESULT CLASSES
/// ========================================

class BusinessRuleResult {
  final bool isAllowed;
  final String? reason;
  final String? message;
  final String? suggestedAction;
  final String? ruleViolated;
  final List<String>? details;
  final Map<String, dynamic>? additionalInfo;
  final int? remainingQuota;

  BusinessRuleResult._({
    required this.isAllowed,
    this.reason,
    this.message,
    this.suggestedAction,
    this.ruleViolated,
    this.details,
    this.additionalInfo,
    this.remainingQuota,
  });

  factory BusinessRuleResult.allowed({
    String? message,
    Map<String, dynamic>? additionalInfo,
    int? remainingQuota,
  }) {
    return BusinessRuleResult._(
      isAllowed: true,
      message: message,
      additionalInfo: additionalInfo,
      remainingQuota: remainingQuota,
    );
  }

  factory BusinessRuleResult.denied({
    required String reason,
    String? suggestedAction,
    String? ruleViolated,
    List<String>? details,
  }) {
    return BusinessRuleResult._(
      isAllowed: false,
      reason: reason,
      suggestedAction: suggestedAction,
      ruleViolated: ruleViolated,
      details: details,
    );
  }

  /// Get user-friendly message
  String getUserMessage() {
    if (isAllowed) {
      return message ?? 'Operação autorizada.';
    } else {
      final buffer = StringBuffer(reason ?? 'Operação não autorizada.');

      if (details != null && details!.isNotEmpty) {
        buffer.write('\n\nDetalhes:');
        for (final detail in details!) {
          buffer.write('\n• $detail');
        }
      }

      if (suggestedAction != null) {
        buffer.write('\n\nSugestão: $suggestedAction');
      }

      return buffer.toString();
    }
  }

  /// Convert to map for logging/debugging
  Map<String, dynamic> toMap() {
    return {
      'is_allowed': isAllowed,
      'reason': reason,
      'message': message,
      'suggested_action': suggestedAction,
      'rule_violated': ruleViolated,
      'details': details,
      'additional_info': additionalInfo,
      'remaining_quota': remainingQuota,
    };
  }
}
