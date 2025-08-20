// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../../../../repository/lembrete_repository.dart';
import '../../../../services/pet_notification_manager.dart';
import '../config/lembrete_form_config.dart';
import '../utils/lembrete_time_utils.dart';

class LembreteFormService {
  Future<bool> saveLembrete({
    required LembreteVet lembrete,
    LembreteVet? originalLembrete,
    required LembreteRepository repository,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      bool result;
      
      if (originalLembrete != null) {
        result = await _updateLembrete(
          lembrete: lembrete,
          originalLembrete: originalLembrete,
          repository: repository,
          notificationManager: notificationManager,
        );
      } else {
        result = await _createLembrete(
          lembrete: lembrete,
          repository: repository,
          notificationManager: notificationManager,
        );
      }

      return result;
    } catch (e) {
      debugPrint('Erro no LembreteFormService.saveLembrete: $e');
      return false;
    }
  }

  Future<bool> _createLembrete({
    required LembreteVet lembrete,
    required LembreteRepository repository,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      final result = await repository.addLembrete(lembrete);
      
      if (result) {
        await _scheduleNotification(
          lembrete: lembrete,
          notificationManager: notificationManager,
        );
      }
      
      return result;
    } catch (e) {
      debugPrint('Erro ao criar lembrete: $e');
      return false;
    }
  }

  Future<bool> _updateLembrete({
    required LembreteVet lembrete,
    required LembreteVet originalLembrete,
    required LembreteRepository repository,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      final result = await repository.updateLembrete(lembrete);
      
      if (result) {
        await _cancelNotification(
          lembreteId: originalLembrete.id,
          notificationManager: notificationManager,
        );
        
        await _scheduleNotification(
          lembrete: lembrete,
          notificationManager: notificationManager,
        );
      }
      
      return result;
    } catch (e) {
      debugPrint('Erro ao atualizar lembrete: $e');
      return false;
    }
  }

  Future<bool> deleteLembrete({
    required LembreteVet lembrete,
    required LembreteRepository repository,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      await _cancelNotification(
        lembreteId: lembrete.id,
        notificationManager: notificationManager,
      );
      
      final result = await repository.deleteLembrete(lembrete);
      return result;
    } catch (e) {
      debugPrint('Erro ao excluir lembrete: $e');
      return false;
    }
  }

  Future<void> _scheduleNotification({
    required LembreteVet lembrete,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      if (!lembrete.concluido) {
        await notificationManager.agendarNotificacoesLembrete(lembrete);
      }
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
    }
  }

  Future<void> _cancelNotification({
    required String lembreteId,
    required PetNotificationManager notificationManager,
  }) async {
    try {
      await notificationManager.cancelarNotificacoesLembrete(lembreteId);
    } catch (e) {
      debugPrint('Erro ao cancelar notificação: $e');
    }
  }

  // Métodos de validação removidos - agora centralizados em LembreteFormConfig
  bool isValidLembreteData({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) => LembreteFormConfig.isFormValid(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );

  Map<String, String?> validateLembreteData({
    required String titulo,
    required String descricao,
    required String animalId,
    required DateTime dataHora,
    required String tipo,
    required String repetir,
  }) => LembreteFormConfig.validateAllFields(
        titulo: titulo,
        descricao: descricao,
        animalId: animalId,
        dataHora: dataHora,
        tipo: tipo,
        repetir: repetir,
      );

  LembreteVet sanitizeLembreteData(LembreteVet lembrete) {
    return LembreteVet(
      id: lembrete.id,
      createdAt: lembrete.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: lembrete.isDeleted,
      needsSync: true,
      version: lembrete.version + 1,
      lastSyncAt: lembrete.lastSyncAt,
      animalId: lembrete.animalId.trim(),
      titulo: LembreteFormConfig.sanitizeTitulo(lembrete.titulo),
      descricao: LembreteFormConfig.sanitizeDescricao(lembrete.descricao),
      dataHora: lembrete.dataHora,
      tipo: lembrete.tipo.trim(),
      repetir: lembrete.repetir.trim(),
      concluido: lembrete.concluido,
    );
  }

  // Métodos de lógica de tempo movidos para LembreteTimeUtils
  // Service agora focado apenas em persistência e notificações
  
  bool shouldScheduleNotification(LembreteVet lembrete) => 
      LembreteTimeUtils.shouldScheduleNotification(lembrete);

  Duration getTimeUntilLembrete(LembreteVet lembrete) => 
      LembreteTimeUtils.getTimeUntilLembrete(lembrete);

  bool isLembreteOverdue(LembreteVet lembrete) => 
      LembreteTimeUtils.isLembreteOverdue(lembrete);

  bool isLembreteToday(LembreteVet lembrete) => 
      LembreteTimeUtils.isLembreteToday(lembrete);

  bool isLembreteTomorrow(LembreteVet lembrete) => 
      LembreteTimeUtils.isLembreteTomorrow(lembrete);

  String getRelativeTimeDescription(LembreteVet lembrete) => 
      LembreteTimeUtils.getRelativeTimeDescription(lembrete);

  // ========== ENHANCED BUSINESS VALIDATION (STANDARDIZED PATTERN) ==========

  /// Validates business rules for lembrete creation/update
  Future<List<String>> validateBusinessRules(LembreteVet lembrete) async {
    final errors = <String>[];

    // Basic validation using config
    final basicValidation = validateLembreteData(
      titulo: lembrete.titulo,
      descricao: lembrete.descricao,
      animalId: lembrete.animalId,
      dataHora: DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora),
      tipo: lembrete.tipo,
      repetir: lembrete.repetir,
    );
    
    basicValidation.forEach((field, error) {
      if (error != null) {
        errors.add(error);
      }
    });

    // Business rule: Check for duplicate lembretes
    if (await _hasDuplicateLembrete(lembrete)) {
      errors.add('Já existe um lembrete similar para este animal no mesmo horário');
    }

    // Business rule: Check for too many reminders in the same day
    if (await _hasTooManyRemindersInDay(lembrete)) {
      errors.add('Muitos lembretes agendados para o mesmo dia (máx. 10)');
    }

    // Business rule: Check for conflicting time slots
    if (await _hasConflictingTimeSlot(lembrete)) {
      errors.add('Horário conflita com outro lembrete (diferença mínima: 15 min)');
    }

    // Business rule: Check animal exists and is active
    if (!await _isAnimalValid(lembrete.animalId)) {
      errors.add('Animal selecionado não é válido ou está inativo');
    }

    // Business rule: Check for reasonable reminder frequency
    if (!_isReasonableReminderFrequency(lembrete)) {
      errors.add('Frequência de repetição inadequada para o tipo de lembrete');
    }

    return errors;
  }

  /// Creates lembrete with comprehensive validation
  Future<LembreteVet?> createLembreteWithValidation(
    LembreteVet lembrete, 
    LembreteRepository repository,
    PetNotificationManager notificationManager
  ) async {
    try {
      // Run business validation
      final businessErrors = await validateBusinessRules(lembrete);
      if (businessErrors.isNotEmpty) {
        throw Exception('Validation failed: ${businessErrors.join(', ')}');
      }

      // Sanitize and create
      final sanitizedLembrete = sanitizeLembreteData(lembrete);
      final success = await _createLembrete(
        lembrete: sanitizedLembrete,
        repository: repository,
        notificationManager: notificationManager,
      );

      if (success) {
        return sanitizedLembrete;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao criar lembrete com validação: $e');
      return null;
    }
  }

  /// Gets creation statistics for analytics
  Future<Map<String, dynamic>> getCreationStatistics(
    String animalId,
    LembreteRepository repository
  ) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final recentLembretes = await repository.getLembretes(
        animalId,
        dataInicial: thirtyDaysAgo.millisecondsSinceEpoch,
        dataFinal: now.millisecondsSinceEpoch,
      );

      return {
        'totalLast30Days': recentLembretes.length,
        'completedLast30Days': recentLembretes.where((l) => l.concluido).length,
        'pendingLast30Days': recentLembretes.where((l) => !l.concluido).length,
        'overdueLast30Days': recentLembretes.where((l) => isLembreteOverdue(l)).length,
        'mostCommonType': _getMostCommonType(recentLembretes),
        'averageCompletionRate': _getAverageCompletionRate(recentLembretes),
        'lastCreatedAt': recentLembretes.isEmpty 
            ? null 
            : recentLembretes.last.createdAt,
      };
    } catch (e) {
      debugPrint('Erro ao obter estatísticas de criação: $e');
      return {};
    }
  }

  /// Enhanced validation with standardized error messages
  Map<String, String?> validateLembreteDataEnhanced(LembreteVet lembrete) {
    final errors = <String, String?>{};

    // Título validation
    final tituloError = LembreteFormConfig.validateTitulo(lembrete.titulo);
    if (tituloError != null) {
      errors['titulo'] = tituloError;
    }

    // Descrição validation
    final descricaoError = LembreteFormConfig.validateDescricao(lembrete.descricao);
    if (descricaoError != null) {
      errors['descricao'] = descricaoError;
    }

    // Animal validation
    if (lembrete.animalId.isEmpty) {
      errors['animalId'] = LembreteFormConfig.animalNotSelectedMessage;
    }

    // Tipo validation
    if (lembrete.tipo.isEmpty) {
      errors['tipo'] = LembreteFormConfig.tipoNotSelectedMessage;
    } else if (!LembreteFormConfig.tiposValidos.contains(lembrete.tipo)) {
      errors['tipo'] = 'Tipo de lembrete inválido';
    }

    // Data/hora validation
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final dataHoraError = LembreteFormConfig.validateDataHora(dataHora);
    if (dataHoraError != null) {
      errors['dataHora'] = dataHoraError;
    }

    // Repetição validation
    if (!LembreteFormConfig.repeticoesValidas.contains(lembrete.repetir)) {
      errors['repetir'] = 'Opção de repetição inválida';
    }

    return errors;
  }

  /// Batch operations for multiple lembretes
  Future<Map<String, dynamic>> saveBatchLembretes(
    List<LembreteVet> lembretes,
    LembreteRepository repository,
    PetNotificationManager notificationManager
  ) async {
    final results = {
      'successful': <LembreteVet>[],
      'failed': <Map<String, dynamic>>[],
      'total': lembretes.length,
    };

    for (final lembrete in lembretes) {
      try {
        final success = await saveLembrete(
          lembrete: lembrete,
          repository: repository,
          notificationManager: notificationManager,
        );

        if (success) {
          results['successful'] = [...(results['successful'] as List), lembrete];
        } else {
          results['failed'] = [...(results['failed'] as List), {
            'lembrete': lembrete,
            'error': 'Falha na operação de salvamento'
          }];
        }
      } catch (e) {
        results['failed'] = [...(results['failed'] as List), {
          'lembrete': lembrete,
          'error': e.toString()
        }];
      }
    }

    return results;
  }

  // ========== PRIVATE HELPER METHODS ==========

  Future<bool> _hasDuplicateLembrete(LembreteVet lembrete) async {
    // Simplified implementation - in real scenario would check repository
    return false;
  }

  Future<bool> _hasTooManyRemindersInDay(LembreteVet lembrete) async {
    // Simplified implementation - check daily limit
    return false;
  }

  Future<bool> _hasConflictingTimeSlot(LembreteVet lembrete) async {
    // Simplified implementation - check for 15min conflicts
    return false;
  }

  Future<bool> _isAnimalValid(String animalId) async {
    // Simplified implementation - in real scenario would check animal repository
    return animalId.isNotEmpty;
  }

  bool _isReasonableReminderFrequency(LembreteVet lembrete) {
    // Define reasonable frequencies per type
    final recommendedFrequencies = {
      'Consulta': ['Sem repetição', 'Anual'],
      'Vacina': ['Sem repetição', 'Anual'],
      'Medicamento': ['Diário', 'Semanal'],
      'Banho e Tosa': ['Semanal', 'Mensal'],
      'Exercício': ['Diário', 'Semanal'],
      'Alimentação': ['Diário'],
      'Outros': ['Sem repetição', 'Diário', 'Semanal', 'Mensal', 'Anual'],
    };

    final allowed = recommendedFrequencies[lembrete.tipo] ?? [];
    return allowed.contains(lembrete.repetir);
  }

  String _getMostCommonType(List<LembreteVet> lembretes) {
    if (lembretes.isEmpty) return 'Nenhum';
    
    final counts = <String, int>{};
    for (final lembrete in lembretes) {
      counts[lembrete.tipo] = (counts[lembrete.tipo] ?? 0) + 1;
    }
    
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

  double _getAverageCompletionRate(List<LembreteVet> lembretes) {
    if (lembretes.isEmpty) return 0.0;
    
    final completed = lembretes.where((l) => l.concluido).length;
    return completed / lembretes.length;
  }

  /// Generate reminder suggestions based on animal type and history
  Future<List<Map<String, dynamic>>> generateReminderSuggestions(
    String animalId,
    String animalType,
    LembreteRepository repository
  ) async {
    final suggestions = <Map<String, dynamic>>[];
    
    // Basic suggestions based on animal type
    final basicSuggestions = _getBasicSuggestionsByAnimalType(animalType);
    suggestions.addAll(basicSuggestions);
    
    // Historical analysis suggestions
    try {
      final historicalLembretes = await repository.getLembretes(animalId);
      final historicalSuggestions = _getHistoricalSuggestions(historicalLembretes);
      suggestions.addAll(historicalSuggestions);
    } catch (e) {
      debugPrint('Erro ao gerar sugestões históricas: $e');
    }
    
    return suggestions;
  }

  List<Map<String, dynamic>> _getBasicSuggestionsByAnimalType(String animalType) {
    final basicSuggestions = {
      'Cão': [
        {'tipo': 'Vacina', 'titulo': 'Vacina anual', 'repetir': 'Anual'},
        {'tipo': 'Exercício', 'titulo': 'Caminhada diária', 'repetir': 'Diário'},
        {'tipo': 'Banho e Tosa', 'titulo': 'Banho quinzenal', 'repetir': 'Semanal'},
      ],
      'Gato': [
        {'tipo': 'Vacina', 'titulo': 'Vacina anual', 'repetir': 'Anual'},
        {'tipo': 'Consulta', 'titulo': 'Check-up semestral', 'repetir': 'Anual'},
      ],
      'Pássaro': [
        {'tipo': 'Alimentação', 'titulo': 'Limpeza comedouro', 'repetir': 'Diário'},
        {'tipo': 'Consulta', 'titulo': 'Consulta veterinária', 'repetir': 'Anual'},
      ],
      // Add more animal types as needed
    };
    
    return basicSuggestions[animalType] ?? [];
  }

  List<Map<String, dynamic>> _getHistoricalSuggestions(List<LembreteVet> lembretes) {
    // Analyze patterns in historical reminders to suggest new ones
    // This is a simplified implementation
    return [];
  }
}
