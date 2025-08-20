// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../repository/despesa_repository.dart';
import '../config/despesa_config.dart';

class DespesaFormService {
  Future<bool> saveDespesa({
    required DespesaVet despesa,
    DespesaVet? originalDespesa,
    required DespesaRepository repository,
  }) async {
    try {
      // Sanitize data before saving
      final sanitizedDespesa = sanitizeDespesaData(despesa);

      bool result;
      if (originalDespesa != null) {
        result = await _updateDespesa(
          despesa: sanitizedDespesa,
          originalDespesa: originalDespesa,
          repository: repository,
        );
      } else {
        result = await _createDespesa(
          despesa: sanitizedDespesa,
          repository: repository,
        );
      }

      return result;
    } catch (e) {
      debugPrint('Erro no DespesaFormService.saveDespesa: $e');
      return false;
    }
  }

  Future<bool> _createDespesa({
    required DespesaVet despesa,
    required DespesaRepository repository,
  }) async {
    try {
      if (!isValidDespesaData(despesa)) {
        throw Exception('Dados da despesa são inválidos');
      }

      final result = await repository.addDespesa(despesa);
      return result;
    } catch (e) {
      debugPrint('Erro ao criar despesa: $e');
      return false;
    }
  }

  Future<bool> _updateDespesa({
    required DespesaVet despesa,
    required DespesaVet originalDespesa,
    required DespesaRepository repository,
  }) async {
    try {
      if (!isValidDespesaData(despesa)) {
        throw Exception('Dados da despesa são inválidos');
      }

      final result = await repository.updateDespesa(despesa);
      return result;
    } catch (e) {
      debugPrint('Erro ao atualizar despesa: $e');
      return false;
    }
  }

  Future<bool> deleteDespesa({
    required DespesaVet despesa,
    required DespesaRepository repository,
  }) async {
    try {
      final result = await repository.deleteDespesa(despesa);
      return result;
    } catch (e) {
      debugPrint('Erro ao excluir despesa: $e');
      return false;
    }
  }

  bool isValidDespesaData(DespesaVet despesa) {
    return despesa.animalId.isNotEmpty &&
           despesa.tipo.isNotEmpty &&
           despesa.valor > 0 &&
           despesa.valor <= 999999.99 &&
           despesa.descricao.length <= 255 &&
           _isValidDate(despesa.dataDespesa);
  }

  bool _isValidDate(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final oneYearAgo = now.subtract(const Duration(days: 365));
      final oneYearFromNow = now.add(const Duration(days: 365));
      
      return date.isAfter(oneYearAgo) && date.isBefore(oneYearFromNow);
    } catch (e) {
      return false;
    }
  }

  Map<String, String?> validateDespesaData(DespesaVet despesa) {
    final errors = <String, String?>{};

    if (despesa.animalId.isEmpty) {
      errors['animalId'] = 'Animal deve ser selecionado';
    }

    if (despesa.tipo.isEmpty) {
      errors['tipo'] = 'Tipo é obrigatório';
    }

    if (despesa.valor <= 0) {
      errors['valor'] = 'Valor deve ser maior que zero';
    } else if (despesa.valor > 999999.99) {
      errors['valor'] = 'Valor muito alto';
    }

    if (despesa.descricao.length > 255) {
      errors['descricao'] = 'Descrição muito longa (máx. 255 caracteres)';
    }

    if (!_isValidDate(despesa.dataDespesa)) {
      errors['dataDespesa'] = 'Data inválida';
    }

    return errors;
  }

  DespesaVet sanitizeDespesaData(DespesaVet despesa) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return DespesaVet(
      id: despesa.id,
      createdAt: despesa.createdAt,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: despesa.version + 1,
      lastSyncAt: despesa.lastSyncAt,
      animalId: despesa.animalId.trim(),
      dataDespesa: despesa.dataDespesa,
      tipo: _sanitizeText(despesa.tipo),
      descricao: _sanitizeText(despesa.descricao),
      valor: _sanitizeValue(despesa.valor),
    );
  }

  String _sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  double _sanitizeValue(double value) {
    // Round to 2 decimal places
    return double.parse(value.toStringAsFixed(2));
  }

  Future<DespesaVet?> getDespesaById({
    required String id,
    required DespesaRepository repository,
  }) async {
    try {
      return await repository.getDespesaById(id);
    } catch (e) {
      debugPrint('Erro ao buscar despesa por ID: $e');
      return null;
    }
  }

  Future<List<DespesaVet>> getDespesasByAnimal({
    required String animalId,
    required DespesaRepository repository,
    DateTime? dataInicial,
    DateTime? dataFinal,
  }) async {
    try {
      return await repository.getDespesas(
        animalId,
        dataInicial: dataInicial?.millisecondsSinceEpoch,
        dataFinal: dataFinal?.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Erro ao buscar despesas do animal: $e');
      return [];
    }
  }

  double calculateTotalValue(List<DespesaVet> despesas) {
    return despesas.fold(0.0, (sum, despesa) => sum + despesa.valor);
  }

  Map<String, double> groupByTipo(List<DespesaVet> despesas) {
    final grouped = <String, double>{};
    for (final despesa in despesas) {
      grouped[despesa.tipo] = (grouped[despesa.tipo] ?? 0) + despesa.valor;
    }
    return grouped;
  }

  Map<String, int> countByTipo(List<DespesaVet> despesas) {
    final counts = <String, int>{};
    for (final despesa in despesas) {
      counts[despesa.tipo] = (counts[despesa.tipo] ?? 0) + 1;
    }
    return counts;
  }

  List<DespesaVet> sortByDate(List<DespesaVet> despesas, {bool ascending = false}) {
    final sorted = List<DespesaVet>.from(despesas);
    sorted.sort((a, b) {
      final comparison = a.dataDespesa.compareTo(b.dataDespesa);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  List<DespesaVet> sortByValue(List<DespesaVet> despesas, {bool ascending = false}) {
    final sorted = List<DespesaVet>.from(despesas);
    sorted.sort((a, b) {
      final comparison = a.valor.compareTo(b.valor);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  List<DespesaVet> filterByType(List<DespesaVet> despesas, String tipo) {
    return despesas.where((despesa) => despesa.tipo == tipo).toList();
  }

  List<DespesaVet> filterByDateRange(
    List<DespesaVet> despesas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return despesas.where((despesa) {
      final date = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<DespesaVet> filterByValueRange(
    List<DespesaVet> despesas,
    double minValue,
    double maxValue,
  ) {
    return despesas.where((despesa) {
      return despesa.valor >= minValue && despesa.valor <= maxValue;
    }).toList();
  }

  String formatValue(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String formatValueWithCurrency(double value) {
    return 'R\$ ${formatValue(value)}';
  }

  double parseValue(String valueString) {
    try {
      final cleanValue = valueString
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  bool isValidValueString(String value) {
    try {
      final parsedValue = parseValue(value);
      return parsedValue > 0 && parsedValue <= 999999.99;
    } catch (e) {
      return false;
    }
  }

  bool isValidDateString(String date) {
    return parseDate(date) != null;
  }

  List<String> getValidationErrors(DespesaVet despesa) {
    final errors = <String>[];
    final validation = validateDespesaData(despesa);
    
    validation.forEach((field, error) {
      if (error != null) {
        errors.add('$field: $error');
      }
    });
    
    return errors;
  }

  Map<String, dynamic> generateSummary(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return {
        'total': 0.0,
        'count': 0,
        'average': 0.0,
        'highest': null,
        'lowest': null,
        'byType': <String, double>{},
      };
    }

    final total = calculateTotalValue(despesas);
    final average = total / despesas.length;
    final sorted = sortByValue(despesas, ascending: false);
    
    return {
      'total': total,
      'count': despesas.length,
      'average': average,
      'highest': sorted.first,
      'lowest': sorted.last,
      'byType': groupByTipo(despesas),
    };
  }

  Future<bool> duplicateDespesa({
    required DespesaVet originalDespesa,
    required DespesaRepository repository,
    DateTime? newDate,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final duplicatedDespesa = DespesaVet(
        id: '', // Will be generated
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        needsSync: true,
        version: 1,
        lastSyncAt: null,
        animalId: originalDespesa.animalId,
        dataDespesa: newDate?.millisecondsSinceEpoch ?? now,
        tipo: originalDespesa.tipo,
        descricao: '${originalDespesa.descricao} (Cópia)',
        valor: originalDespesa.valor,
      );

      return await repository.addDespesa(duplicatedDespesa);
    } catch (e) {
      debugPrint('Erro ao duplicar despesa: $e');
      return false;
    }
  }

  // ========== ENHANCED BUSINESS VALIDATION (STANDARDIZED PATTERN) ==========

  /// Validates business rules for despesa creation/update
  Future<List<String>> validateBusinessRules(DespesaVet despesa) async {
    final errors = <String>[];

    // Basic validation
    final basicValidation = validateDespesaData(despesa);
    basicValidation.forEach((field, error) {
      if (error != null) {
        errors.add(error);
      }
    });

    // Business rule: Check for duplicate despesas
    if (await _hasDuplicateDespesa(despesa)) {
      errors.add('Já existe uma despesa similar para este animal na mesma data');
    }

    // Business rule: Check animal exists and is active
    if (!await _isAnimalValid(despesa.animalId)) {
      errors.add('Animal selecionado não é válido ou está inativo');
    }

    // Business rule: Check for suspicious high values
    if (_isSuspiciouslyHighValue(despesa.valor, despesa.tipo)) {
      errors.add('Valor parece muito alto para o tipo de despesa selecionado');
    }

    // Business rule: Check for future dates beyond limit
    if (_isFutureDateBeyondLimit(despesa.dataDespesa)) {
      errors.add('Data não pode ser mais de 30 dias no futuro');
    }

    return errors;
  }

  /// Creates despesa with comprehensive validation
  Future<DespesaVet?> createDespesaWithValidation(
    DespesaVet despesa, 
    DespesaRepository repository
  ) async {
    try {
      // Run business validation
      final businessErrors = await validateBusinessRules(despesa);
      if (businessErrors.isNotEmpty) {
        throw Exception('Validation failed: ${businessErrors.join(', ')}');
      }

      // Sanitize and create
      final sanitizedDespesa = sanitizeDespesaData(despesa);
      final success = await _createDespesa(
        despesa: sanitizedDespesa,
        repository: repository,
      );

      if (success) {
        return sanitizedDespesa;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao criar despesa com validação: $e');
      return null;
    }
  }

  /// Gets creation statistics for analytics
  Future<Map<String, dynamic>> getCreationStatistics(
    String animalId,
    DespesaRepository repository
  ) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentDespesas = await getDespesasByAnimal(
        animalId: animalId,
        repository: repository,
        dataInicial: thirtyDaysAgo,
        dataFinal: now,
      );

      return {
        'totalLast30Days': recentDespesas.length,
        'totalValueLast30Days': calculateTotalValue(recentDespesas),
        'averageValueLast30Days': recentDespesas.isEmpty 
            ? 0.0 
            : calculateTotalValue(recentDespesas) / recentDespesas.length,
        'mostCommonType': _getMostCommonType(recentDespesas),
        'lastCreatedAt': recentDespesas.isEmpty 
            ? null 
            : recentDespesas.last.createdAt,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de criação: $e');
      return {};
    }
  }

  /// Enhanced validation with standardized error messages
  Map<String, String?> validateDespesaDataEnhanced(DespesaVet despesa) {
    final errors = <String, String?>{};

    // Animal validation
    if (despesa.animalId.isEmpty) {
      errors['animalId'] = DespesaConfig.animalNotSelectedMessage;
    }

    // Tipo validation
    if (despesa.tipo.isEmpty) {
      errors['tipo'] = DespesaConfig.tipoNotSelectedMessage;
    } else if (!DespesaConfig.tiposDespesa.contains(despesa.tipo)) {
      errors['tipo'] = 'Tipo de despesa inválido';
    }

    // Valor validation
    if (despesa.valor <= 0) {
      errors['valor'] = DespesaConfig.valueTooLowMessage;
    } else if (despesa.valor > DespesaConfig.valorMaximo) {
      errors['valor'] = DespesaConfig.valueTooHighMessage;
    }

    // Descrição validation
    if (despesa.descricao.length > DespesaConfig.descricaoMaxLength) {
      errors['descricao'] = DespesaConfig.descriptionTooLongMessage;
    }

    // Data validation
    if (!_isValidDateEnhanced(despesa.dataDespesa)) {
      errors['dataDespesa'] = DespesaConfig.invalidDateMessage;
    }

    return errors;
  }

  // ========== PRIVATE HELPER METHODS ==========

  Future<bool> _hasDuplicateDespesa(DespesaVet despesa) async {
    // Simplified implementation - in real scenario would check repository
    return false;
  }

  Future<bool> _isAnimalValid(String animalId) async {
    // Simplified implementation - in real scenario would check animal repository
    return animalId.isNotEmpty;
  }

  bool _isSuspiciouslyHighValue(double valor, String tipo) {
    // Define suspicious thresholds per type
    final thresholds = {
      'Consulta': 500.0,
      'Medicamento': 1000.0,
      'Vacina': 300.0,
      'Exame': 800.0,
      'Cirurgia': 5000.0,
      'Emergência': 3000.0,
      'Banho e Tosa': 200.0,
      'Alimentação': 500.0,
      'Petiscos': 100.0,
      'Brinquedos': 200.0,
      'Acessórios': 300.0,
      'Hospedagem': 1000.0,
      'Transporte': 500.0,
      'Seguro': 2000.0,
      'Outros': 1000.0,
    };

    final threshold = thresholds[tipo] ?? 1000.0;
    return valor > threshold * 2; // 2x the normal threshold
  }

  bool _isFutureDateBeyondLimit(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 30));
    
    return date.isAfter(maxFutureDate);
  }

  bool _isValidDateEnhanced(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final minDate = now.subtract(const Duration(days: DespesaConfig.maxDateRangeInPast));
      final maxDate = now.add(const Duration(days: DespesaConfig.maxDateRangeInFuture));
      
      return date.isAfter(minDate) && date.isBefore(maxDate);
    } catch (e) {
      return false;
    }
  }

  String _getMostCommonType(List<DespesaVet> despesas) {
    if (despesas.isEmpty) return 'Nenhum';
    
    final counts = countByTipo(despesas);
    var mostCommon = '';
    var maxCount = 0;
    
    counts.forEach((tipo, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = tipo;
      }
    });
    
    return mostCommon;
  }
}
