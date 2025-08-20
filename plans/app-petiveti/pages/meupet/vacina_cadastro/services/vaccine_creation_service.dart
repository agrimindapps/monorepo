// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../repository/vacina_repository.dart';
import '../config/vacina_config.dart';

/// Service for vaccine creation and editing operations with enhanced business validation
class VaccineCreationService {
  static const _uuid = Uuid();
  final VacinaRepository _repository;

  VaccineCreationService({VacinaRepository? repository})
      : _repository = repository ?? VacinaRepository();

  static Future<VaccineCreationService> initialize() async {
    await VacinaRepository.initialize();
    return VaccineCreationService();
  }

  /// Creates a new VacinaVet from form data
  VacinaVet createVaccineFromFormData({
    required String animalId,
    required String nomeVacina,
    required int dataAplicacao,
    required int proximaDose,
    String? observacoes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return VacinaVet(
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      lastSyncAt: null,
      id: _uuid.v4(),
      animalId: animalId,
      nomeVacina: nomeVacina.trim(),
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes?.trim().isEmpty == true ? null : observacoes?.trim(),
    );
  }

  /// Updates an existing VacinaVet with form data
  VacinaVet updateVaccineFromFormData({
    required VacinaVet existingVaccine,
    required String nomeVacina,
    required int dataAplicacao,
    required int proximaDose,
    String? observacoes,
  }) {
    return VacinaVet(
      createdAt: existingVaccine.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: existingVaccine.isDeleted,
      needsSync: true,
      version: existingVaccine.version + 1,
      lastSyncAt: existingVaccine.lastSyncAt,
      id: existingVaccine.id,
      animalId: existingVaccine.animalId,
      nomeVacina: nomeVacina.trim(),
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes?.trim().isEmpty == true ? null : observacoes?.trim(),
    );
  }

  /// Validates business rules for vaccine creation with enhanced validation
  Future<Map<String, String?>> validateBusinessRules({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) async {
    final errors = <String, String?>{};

    // Basic field validation using VacinaConfig
    final basicValidation = VacinaConfig.validateAllFields(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );
    errors.addAll(basicValidation);

    // Check for duplicate vaccines on same date
    final existingVacinas = await _repository.getVacinas(animalId);
    final sameDate = existingVacinas.where((v) => 
      DateTime.fromMillisecondsSinceEpoch(v.dataAplicacao).day == dataAplicacao.day &&
      DateTime.fromMillisecondsSinceEpoch(v.dataAplicacao).month == dataAplicacao.month &&
      DateTime.fromMillisecondsSinceEpoch(v.dataAplicacao).year == dataAplicacao.year
    ).toList();

    if (sameDate.isNotEmpty) {
      errors['dataAplicacao'] = 'Já existe uma vacina registrada para esta data';
    }

    // Check for same vaccine within minimum interval (avoid duplicate protection)
    final sameVaccine = existingVacinas.where((v) => 
      v.nomeVacina.toLowerCase() == nomeVacina.toLowerCase()
    ).toList();

    if (sameVaccine.isNotEmpty) {
      final lastVaccine = sameVaccine.first;
      final daysDifference = dataAplicacao.difference(
        DateTime.fromMillisecondsSinceEpoch(lastVaccine.dataAplicacao)
      ).inDays;

      final suggestedInterval = VacinaConfig.getSuggestedInterval(nomeVacina);
      final minInterval = (suggestedInterval * 0.8).round(); // 80% of suggested interval

      if (daysDifference < minInterval) {
        errors['nomeVacina'] = 'Esta vacina foi aplicada há apenas $daysDifference dias (mínimo: $minInterval dias)';
      }
    }

    return errors;
  }

  /// Checks if vaccine data meets all business requirements
  Future<bool> isValidForCreation({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) async {
    final errors = await validateBusinessRules(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );
    final hasErrors = errors.values.any((error) => error != null);
    return !hasErrors;
  }

  /// Suggests next dose date based on vaccine name and application date
  DateTime suggestNextDoseDate(String vaccineName, DateTime applicationDate) {
    final interval = VacinaConfig.getSuggestedInterval(vaccineName);
    return applicationDate.add(Duration(days: interval));
  }

  /// Calculates vaccine priority for display purposes
  String calculateVaccinePriority(String vaccineName) {
    return VacinaConfig.getVaccinePriority(vaccineName);
  }

  /// Gets vaccine status based on next dose date
  String getVaccineStatus(DateTime nextDoseDate) {
    return VacinaConfig.getVaccineStatus(nextDoseDate);
  }

  /// Gets user-friendly error message for different exception types
  String getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Operação demorou muito. Verifique sua conexão e tente novamente.';
    } else if (error is SocketException) {
      return 'Sem conexão com a internet. Verifique sua conexão.';
    } else if (error is HttpException) {
      return 'Erro no servidor. Tente novamente em alguns minutos.';
    } else if (error is FormatException) {
      return 'Dados inválidos. Verifique as informações e tente novamente.';
    } else if (error.toString().contains('duplicate')) {
      return 'Esta vacina já foi cadastrada para este animal.';
    } else if (error.toString().contains('not found')) {
      return 'Animal não encontrado. Selecione um animal válido.';
    } else {
      return 'Erro inesperado: ${error.toString()}';
    }
  }

  /// Validates if vaccine can be safely deleted
  bool canDeleteVaccine(VacinaVet vaccine) {
    // Business rules for deletion
    final now = DateTime.now().millisecondsSinceEpoch;
    final applicationDate = vaccine.dataAplicacao;
    
    // Don't allow deletion of vaccines applied more than 1 year ago
    // This preserves important medical history
    final oneYearAgo = now - (365 * 24 * 60 * 60 * 1000);
    
    return applicationDate > oneYearAgo;
  }

  /// Gets warning message for vaccine deletion
  String? getDeletionWarning(VacinaVet vaccine) {
    if (!canDeleteVaccine(vaccine)) {
      return 'Não é possível excluir vacinas antigas (mais de 1 ano). '
             'Isso preserva o histórico médico do animal.';
    }
    
    final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(vaccine.proximaDose);
    final status = getVaccineStatus(nextDoseDate);
    if (status == 'overdue' || status == 'urgent') {
      return 'Esta vacina está próxima do vencimento ou atrasada. '
             'Tem certeza que deseja excluí-la?';
    }
    
    return null;
  }

  /// Logs operation for debugging purposes
  void logOperation(String operation, Map<String, dynamic> data) {
    debugPrint('[$operation] ${data.toString()}');
  }

  /// Validates form data consistency
  bool isFormDataConsistent({
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
  }) {
    // Check if next dose suggestion matches the vaccine name pattern
    final suggestedNextDose = suggestNextDoseDate(nomeVacina, dataAplicacao);
    final daysDifference = proximaDose.difference(suggestedNextDose).inDays.abs();
    
    // Allow up to 7 days difference from suggestion
    return daysDifference <= 7;
  }

  /// Gets consistency warning if form data seems inconsistent
  String? getConsistencyWarning({
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
  }) {
    if (!isFormDataConsistent(
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
    )) {
      return 'A data da próxima dose parece inconsistente com o tipo de vacina. '
             'Verifique se está correta.';
    }
    return null;
  }
}
