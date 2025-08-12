// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/15_medicamento_model.dart';
import '../../../../repository/medicamento_repository.dart';
import '../config/medicamento_config.dart';

class MedicamentoCadastroService {
  final MedicamentoRepository _repository;

  MedicamentoCadastroService({MedicamentoRepository? repository})
      : _repository = repository ?? MedicamentoRepository();

  static Future<MedicamentoCadastroService> initialize() async {
    await MedicamentoRepository.initialize();
    return MedicamentoCadastroService();
  }

  Future<bool> saveMedicamento({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required int inicioTratamento,
    required int fimTratamento,
    String? observacoes,
    MedicamentoVet? existingMedicamento,
  }) async {
    try {
      final medicamento = MedicamentoVet(
        id: existingMedicamento?.id ?? const Uuid().v4(),
        createdAt: existingMedicamento?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
        needsSync: existingMedicamento?.needsSync ?? true,
        version: existingMedicamento == null ? 1 : existingMedicamento.version + 1,
        lastSyncAt: existingMedicamento?.lastSyncAt,
        animalId: animalId,
        nomeMedicamento: nomeMedicamento,
        dosagem: dosagem,
        frequencia: frequencia,
        duracao: duracao,
        inicioTratamento: inicioTratamento,
        fimTratamento: fimTratamento,
        observacoes: observacoes?.isEmpty == true ? null : observacoes,
      );

      if (existingMedicamento == null) {
        return await _repository.addMedicamento(medicamento);
      } else {
        return await _repository.updateMedicamento(medicamento);
      }
    } catch (e) {
      throw Exception('Erro ao salvar medicamento: ${e.toString()}');
    }
  }

  Future<MedicamentoVet?> getMedicamentoById(String id) async {
    try {
      return await _repository.getMedicamentoById(id);
    } catch (e) {
      throw Exception('Erro ao buscar medicamento: ${e.toString()}');
    }
  }

  Future<bool> deleteMedicamento(MedicamentoVet medicamento) async {
    try {
      return await _repository.deleteMedicamento(medicamento);
    } catch (e) {
      throw Exception('Erro ao deletar medicamento: ${e.toString()}');
    }
  }

  Future<List<MedicamentoVet>> getMedicamentosForAnimal(String animalId) async {
    try {
      return await _repository.getMedicamentos(animalId);
    } catch (e) {
      throw Exception('Erro ao buscar medicamentos: ${e.toString()}');
    }
  }

  bool validateMedicamentoData({
    required String animalId,
    required String nomeMedicamento,
    required String dosagem,
    required String frequencia,
    required String duracao,
    required DateTime inicioTratamento,
    required DateTime fimTratamento,
  }) {
    return animalId.isNotEmpty &&
           nomeMedicamento.trim().isNotEmpty &&
           dosagem.trim().isNotEmpty &&
           frequencia.trim().isNotEmpty &&
           duracao.trim().isNotEmpty &&
           (fimTratamento.isAfter(inicioTratamento) || 
            fimTratamento.isAtSameMomentAs(inicioTratamento));
  }

  Duration calculateTreatmentDuration(DateTime inicio, DateTime fim) {
    return fim.difference(inicio);
  }

  bool isTreatmentActive(MedicamentoVet medicamento) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return medicamento.inicioTratamento <= now && medicamento.fimTratamento >= now;
  }

  int getDaysRemaining(MedicamentoVet medicamento) {
    final now = DateTime.now();
    final endDate = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
    
    if (endDate.isBefore(now)) return 0;
    
    return endDate.difference(now).inDays;
  }

  // ========== ENHANCED BUSINESS VALIDATION (STANDARDIZED PATTERN) ==========

  /// Validates business rules for medicamento creation/update
  Future<List<String>> validateBusinessRules(MedicamentoVet medicamento) async {
    final errors = <String>[];

    // Basic validation using config
    final basicValidation = MedicamentoConfig.validateAllFields(
      animalId: medicamento.animalId,
      nomeMedicamento: medicamento.nomeMedicamento,
      dosagem: medicamento.dosagem,
      frequencia: medicamento.frequencia,
      duracao: medicamento.duracao,
      dataInicio: DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento),
      dataFim: DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento),
      observacoes: medicamento.observacoes,
    );
    
    basicValidation.forEach((field, error) {
      if (error != null) {
        errors.add(error);
      }
    });

    // Business rule: Check for overlapping treatments
    if (await _hasOverlappingTreatment(medicamento)) {
      errors.add('Já existe tratamento sobreposto para este animal no período selecionado');
    }

    // Business rule: Check for duplicate medications in same period
    if (await _hasDuplicateMedication(medicamento)) {
      errors.add('Medicamento já está sendo administrado neste período');
    }

    // Business rule: Check for too many active medications
    if (await _hasTooManyActiveMedications(medicamento)) {
      errors.add('Animal possui muitos medicamentos ativos (máx. 10)');
    }

    // Business rule: Check animal exists and is active
    if (!await _isAnimalValid(medicamento.animalId)) {
      errors.add('Animal selecionado não é válido ou está inativo');
    }

    // Business rule: Check for dangerous medication combinations
    if (await _hasDangerousCombination(medicamento)) {
      errors.add('Combinação de medicamentos pode ser perigosa - consulte veterinário');
    }

    // Business rule: Check treatment duration for specific medication types
    if (!_isReasonableTreatmentDuration(medicamento)) {
      errors.add('Duração do tratamento inadequada para este tipo de medicamento');
    }

    return errors;
  }

  /// Creates medicamento with comprehensive validation
  Future<MedicamentoVet?> createMedicamentoWithValidation(
    MedicamentoVet medicamento, 
    MedicamentoRepository repository
  ) async {
    try {
      // Run business validation
      final businessErrors = await validateBusinessRules(medicamento);
      if (businessErrors.isNotEmpty) {
        throw Exception('Validation failed: ${businessErrors.join(', ')}');
      }

      // Sanitize and create
      final sanitizedMedicamento = sanitizeMedicamentoData(medicamento);
      final success = await repository.addMedicamento(sanitizedMedicamento);

      if (success) {
        return sanitizedMedicamento;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao criar medicamento com validação: $e');
      return null;
    }
  }

  /// Gets creation statistics for analytics
  Future<Map<String, dynamic>> getCreationStatistics(
    String animalId
  ) async {
    try {
      final allMedicamentos = await _repository.getMedicamentos(animalId);
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentMedicamentos = allMedicamentos.where((m) {
        final createdAt = DateTime.fromMillisecondsSinceEpoch(m.createdAt);
        return createdAt.isAfter(thirtyDaysAgo);
      }).toList();

      final activeMedicamentos = allMedicamentos.where((m) => isTreatmentActive(m)).toList();

      return {
        'totalLast30Days': recentMedicamentos.length,
        'totalActive': activeMedicamentos.length,
        'totalAll': allMedicamentos.length,
        'mostCommonMedication': _getMostCommonMedication(allMedicamentos),
        'averageTreatmentDuration': _getAverageTreatmentDuration(allMedicamentos),
        'longestTreatment': _getLongestTreatment(allMedicamentos),
        'shortestTreatment': _getShortestTreatment(allMedicamentos),
        'lastCreatedAt': allMedicamentos.isEmpty 
            ? null 
            : allMedicamentos.last.createdAt,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de criação: $e');
      return {};
    }
  }

  /// Enhanced validation with standardized error messages
  Map<String, String?> validateMedicamentoDataEnhanced(MedicamentoVet medicamento) {
    return MedicamentoConfig.validateAllFields(
      animalId: medicamento.animalId,
      nomeMedicamento: medicamento.nomeMedicamento,
      dosagem: medicamento.dosagem,
      frequencia: medicamento.frequencia,
      duracao: medicamento.duracao,
      dataInicio: DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento),
      dataFim: DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento),
      observacoes: medicamento.observacoes,
    );
  }

  /// Sanitize medicamento data
  MedicamentoVet sanitizeMedicamentoData(MedicamentoVet medicamento) {
    return MedicamentoVet(
      id: medicamento.id,
      createdAt: medicamento.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: medicamento.isDeleted,
      needsSync: medicamento.needsSync,
      version: medicamento.version,
      lastSyncAt: medicamento.lastSyncAt,
      animalId: medicamento.animalId.trim(),
      nomeMedicamento: _sanitizeText(medicamento.nomeMedicamento),
      dosagem: _sanitizeText(medicamento.dosagem),
      frequencia: _sanitizeText(medicamento.frequencia),
      duracao: _sanitizeText(medicamento.duracao),
      inicioTratamento: medicamento.inicioTratamento,
      fimTratamento: medicamento.fimTratamento,
      observacoes: medicamento.observacoes?.isEmpty == true ? null : _sanitizeText(medicamento.observacoes ?? ''),
    );
  }

  /// Batch operations for multiple medicamentos
  Future<Map<String, dynamic>> saveBatchMedicamentos(
    List<MedicamentoVet> medicamentos
  ) async {
    final results = {
      'successful': <MedicamentoVet>[],
      'failed': <Map<String, dynamic>>[],
      'total': medicamentos.length,
    };

    for (final medicamento in medicamentos) {
      try {
        final success = await saveMedicamento(
          animalId: medicamento.animalId,
          nomeMedicamento: medicamento.nomeMedicamento,
          dosagem: medicamento.dosagem,
          frequencia: medicamento.frequencia,
          duracao: medicamento.duracao,
          inicioTratamento: medicamento.inicioTratamento,
          fimTratamento: medicamento.fimTratamento,
          observacoes: medicamento.observacoes,
        );

        if (success) {
          results['successful'] = [...(results['successful'] as List), medicamento];
        } else {
          results['failed'] = [...(results['failed'] as List), {
            'medicamento': medicamento,
            'error': 'Falha na operação de salvamento'
          }];
        }
      } catch (e) {
        results['failed'] = [...(results['failed'] as List), {
          'medicamento': medicamento,
          'error': e.toString()
        }];
      }
    }

    return results;
  }

  /// Generate CSV export for medications
  Future<String> generateCSVExport(String animalId) async {
    try {
      final medicamentos = await _repository.getMedicamentos(animalId);
      
      final csvData = StringBuffer();
      csvData.writeln('Nome,Dosagem,Frequência,Duração,Início,Fim,Observações');
      
      for (final medicamento in medicamentos) {
        final inicio = DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento);
        final fim = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
        
        csvData.writeln([
          _escapeCsvField(medicamento.nomeMedicamento),
          _escapeCsvField(medicamento.dosagem),
          _escapeCsvField(medicamento.frequencia),
          _escapeCsvField(medicamento.duracao),
          MedicamentoConfig.dateFormatDisplay,
          MedicamentoConfig.dateFormatDisplay,
          _escapeCsvField(medicamento.observacoes ?? ''),
        ].join(','));
      }
      
      return csvData.toString();
    } catch (e) {
      throw Exception('Erro ao gerar CSV: $e');
    }
  }

  // ========== PRIVATE HELPER METHODS ==========

  Future<bool> _hasOverlappingTreatment(MedicamentoVet medicamento) async {
    try {
      final existingMedicamentos = await _repository.getMedicamentos(medicamento.animalId);
      
      for (final existing in existingMedicamentos) {
        if (existing.id == medicamento.id) continue; // Skip self when updating
        
        final existingStart = DateTime.fromMillisecondsSinceEpoch(existing.inicioTratamento);
        final existingEnd = DateTime.fromMillisecondsSinceEpoch(existing.fimTratamento);
        final newStart = DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento);
        final newEnd = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
        
        // Check for overlap
        if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false; // If error occurs, assume no overlap
    }
  }

  Future<bool> _hasDuplicateMedication(MedicamentoVet medicamento) async {
    try {
      final existingMedicamentos = await _repository.getMedicamentos(medicamento.animalId);
      
      return existingMedicamentos.any((existing) =>
        existing.id != medicamento.id &&
        existing.nomeMedicamento.toLowerCase() == medicamento.nomeMedicamento.toLowerCase() &&
        isTreatmentActive(existing)
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasTooManyActiveMedications(MedicamentoVet medicamento) async {
    try {
      final existingMedicamentos = await _repository.getMedicamentos(medicamento.animalId);
      final activeMedicamentos = existingMedicamentos.where((m) => isTreatmentActive(m)).toList();
      
      // Allow up to 10 active medications
      return activeMedicamentos.length >= 10;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isAnimalValid(String animalId) async {
    // Simplified implementation - in real scenario would check animal repository
    return animalId.isNotEmpty;
  }

  Future<bool> _hasDangerousCombination(MedicamentoVet medicamento) async {
    // Simplified implementation - would check drug interaction database
    return false;
  }

  bool _isReasonableTreatmentDuration(MedicamentoVet medicamento) {
    final duration = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento)
        .difference(DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento));
    
    // Basic checks for common medication types
    final name = medicamento.nomeMedicamento.toLowerCase();
    
    if (name.contains('antibiótico') || name.contains('antibiotic')) {
      return duration.inDays >= 3 && duration.inDays <= 21; // 3-21 days typical
    }
    
    if (name.contains('anti-inflamatório') || name.contains('anti-inflammatory')) {
      return duration.inDays >= 1 && duration.inDays <= 14; // 1-14 days typical
    }
    
    // For other medications, allow reasonable range
    return duration.inHours >= MedicamentoConfig.minTreatmentDurationHours && 
           duration.inDays <= MedicamentoConfig.maxTreatmentDurationDays;
  }

  String _sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _getMostCommonMedication(List<MedicamentoVet> medicamentos) {
    if (medicamentos.isEmpty) return 'Nenhum';
    
    final counts = <String, int>{};
    for (final medicamento in medicamentos) {
      counts[medicamento.nomeMedicamento] = (counts[medicamento.nomeMedicamento] ?? 0) + 1;
    }
    
    var mostCommon = '';
    var maxCount = 0;
    
    counts.forEach((name, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = name;
      }
    });
    
    return mostCommon;
  }

  double _getAverageTreatmentDuration(List<MedicamentoVet> medicamentos) {
    if (medicamentos.isEmpty) return 0.0;
    
    final totalDays = medicamentos.fold<int>(0, (sum, medicamento) {
      final duration = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento)
          .difference(DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento));
      return sum + duration.inDays;
    });
    
    return totalDays / medicamentos.length;
  }

  Duration _getLongestTreatment(List<MedicamentoVet> medicamentos) {
    if (medicamentos.isEmpty) return Duration.zero;
    
    var longest = Duration.zero;
    for (final medicamento in medicamentos) {
      final duration = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento)
          .difference(DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento));
      if (duration > longest) {
        longest = duration;
      }
    }
    
    return longest;
  }

  Duration _getShortestTreatment(List<MedicamentoVet> medicamentos) {
    if (medicamentos.isEmpty) return Duration.zero;
    
    var shortest = const Duration(days: 999999);
    for (final medicamento in medicamentos) {
      final duration = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento)
          .difference(DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento));
      if (duration < shortest) {
        shortest = duration;
      }
    }
    
    return shortest == const Duration(days: 999999) ? Duration.zero : shortest;
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Generate medication suggestions based on common patterns
  Future<List<Map<String, dynamic>>> generateMedicationSuggestions(
    String animalId,
    String animalType
  ) async {
    final suggestions = <Map<String, dynamic>>[];
    
    // Basic suggestions based on animal type
    final basicSuggestions = _getBasicSuggestionsByAnimalType(animalType);
    suggestions.addAll(basicSuggestions);
    
    // Historical analysis suggestions
    try {
      final historicalMedicamentos = await _repository.getMedicamentos(animalId);
      final historicalSuggestions = _getHistoricalSuggestions(historicalMedicamentos);
      suggestions.addAll(historicalSuggestions);
    } catch (e) {
      debugPrint('Erro ao gerar sugestões históricas: $e');
    }
    
    return suggestions;
  }

  List<Map<String, dynamic>> _getBasicSuggestionsByAnimalType(String animalType) {
    final basicSuggestions = {
      'Cão': [
        {'nome': 'Dipirona', 'dosagem': '500mg', 'frequencia': '8 em 8 horas'},
        {'nome': 'Amoxicilina', 'dosagem': '250mg', 'frequencia': '12 em 12 horas'},
        {'nome': 'Prednisolona', 'dosagem': '5mg', 'frequencia': '1x ao dia'},
      ],
      'Gato': [
        {'nome': 'Meloxicam', 'dosagem': '0,5mg', 'frequencia': '1x ao dia'},
        {'nome': 'Enrofloxacina', 'dosagem': '50mg', 'frequencia': '1x ao dia'},
        {'nome': 'Maropitant', 'dosagem': '16mg', 'frequencia': '1x ao dia'},
      ],
      // Add more animal types as needed
    };
    
    return basicSuggestions[animalType] ?? [];
  }

  List<Map<String, dynamic>> _getHistoricalSuggestions(List<MedicamentoVet> medicamentos) {
    // Analyze patterns in historical medications to suggest new ones
    // This is a simplified implementation
    return [];
  }
}
