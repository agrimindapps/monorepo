// Dart imports:
import 'dart:async';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../repository/vacina_repository.dart';
import '../config/vacina_config.dart';
import 'vaccine_creation_service.dart';

/// Extended service methods for VaccineCreationService
/// Contains business validation methods following the standardized pattern
extension VaccineCreationServiceExtended on VaccineCreationService {
  
  // ========== BUSINESS VALIDATION METHODS ==========

  /// Gets batch operations summary
  Future<Map<String, dynamic>> getBatchOperationsSummary(List<String> animalIds) async {
    int totalRecords = 0;
    final animalStats = <String, Map<String, dynamic>>{};

    for (final animalId in animalIds) {
      final vacinas = await getVaccinesByAnimal(animalId);
      
      if (vacinas.isNotEmpty) {
        totalRecords += vacinas.length;
        
        animalStats[animalId] = {
          'recordCount': vacinas.length,
          'lastVaccine': vacinas.first.nomeVacina,
          'nextDue': vacinas.map((v) => v.proximaDose).reduce((a, b) => a < b ? a : b),
        };
      }
    }

    return {
      'totalAnimals': animalIds.length,
      'totalRecords': totalRecords,
      'animalStats': animalStats,
    };
  }

  /// Exports vaccine data to CSV format
  Future<String> exportVaccineDataToCSV(String animalId) async {
    final vacinas = await getVaccinesByAnimal(animalId);
    
    final csvLines = <String>[
      'Data Aplicação,Nome da Vacina,Próxima Dose,Observações', // Header
    ];

    for (final vacina in vacinas.reversed) {
      final dateApp = DateTime.fromMillisecondsSinceEpoch(vacina.dataAplicacao);
      final dateNext = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
      final dateAppStr = VacinaConfig.formatDate(dateApp);
      final dateNextStr = VacinaConfig.formatDate(dateNext);
      final observations = vacina.observacoes?.replaceAll(',', ';') ?? '';
      
      csvLines.add('$dateAppStr,${vacina.nomeVacina},$dateNextStr,"$observations"');
    }

    return csvLines.join('\n');
  }

  /// Gets creation statistics for an animal
  Future<Map<String, dynamic>> getCreationStatistics(String animalId) async {
    final vacinas = await getVaccinesByAnimal(animalId);
    
    if (vacinas.isEmpty) {
      return {
        'totalRecords': 0,
        'lastVaccination': null,
        'nextDue': null,
        'overdueCount': 0,
        'upcomingCount': 0,
      };
    }

    final now = DateTime.now();
    final overdueVaccines = vacinas.where((v) => 
      DateTime.fromMillisecondsSinceEpoch(v.proximaDose).isBefore(now)
    ).length;
    
    final upcomingVaccines = vacinas.where((v) {
      final nextDose = DateTime.fromMillisecondsSinceEpoch(v.proximaDose);
      return nextDose.isAfter(now) && nextDose.isBefore(now.add(const Duration(days: 30)));
    }).length;

    final lastVaccine = vacinas.first;
    final nextDueVaccine = vacinas.reduce((a, b) => 
      a.proximaDose < b.proximaDose ? a : b
    );

    return {
      'totalRecords': vacinas.length,
      'lastVaccination': DateTime.fromMillisecondsSinceEpoch(lastVaccine.dataAplicacao),
      'nextDue': DateTime.fromMillisecondsSinceEpoch(nextDueVaccine.proximaDose),
      'overdueCount': overdueVaccines,
      'upcomingCount': upcomingVaccines,
    };
  }

  /// Creates vaccine with business validation
  Future<bool> createVaccineWithValidation({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) async {
    final validationErrors = await validateBusinessRules(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );

    final hasErrors = validationErrors.values.any((error) => error != null);
    if (hasErrors) {
      throw Exception('Validation failed: ${validationErrors.values.where((e) => e != null).join(', ')}');
    }

    final vacina = createVaccineFromFormData(
      animalId: animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao.millisecondsSinceEpoch,
      proximaDose: proximaDose.millisecondsSinceEpoch,
      observacoes: observacoes,
    );

    // Use repository directly since we need access to it
    final repository = VacinaRepository();
    return await repository.addVacina(vacina);
  }

  /// Updates vaccine with business validation
  Future<bool> updateVaccineWithValidation({
    required VacinaVet existingVaccine,
    required String nomeVacina,
    required DateTime dataAplicacao,
    required DateTime proximaDose,
    String? observacoes,
  }) async {
    final validationErrors = await validateBusinessRules(
      animalId: existingVaccine.animalId,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes,
    );

    final hasErrors = validationErrors.values.any((error) => error != null);
    if (hasErrors) {
      throw Exception('Validation failed: ${validationErrors.values.where((e) => e != null).join(', ')}');
    }

    final updatedVaccine = updateVaccineFromFormData(
      existingVaccine: existingVaccine,
      nomeVacina: nomeVacina,
      dataAplicacao: dataAplicacao.millisecondsSinceEpoch,
      proximaDose: proximaDose.millisecondsSinceEpoch,
      observacoes: observacoes,
    );

    // Use repository directly since we need access to it
    final repository = VacinaRepository();
    return await repository.updateVacina(updatedVaccine);
  }

  /// Deletes vaccine if business rules allow
  Future<bool> deleteVaccineWithValidation(String vacinaId) async {
    final repository = VacinaRepository();
    final vacina = await repository.getVacinaById(vacinaId);
    if (vacina == null) {
      throw Exception('Vacina não encontrada');
    }

    if (!canDeleteVaccine(vacina)) {
      final warning = getDeletionWarning(vacina);
      throw Exception(warning ?? 'Não é possível excluir esta vacina');
    }

    return await repository.deleteVacina(vacina);
  }

  /// Gets vaccines by animal
  Future<List<VacinaVet>> getVaccinesByAnimal(String animalId) async {
    try {
      final repository = VacinaRepository();
      return await repository.getVacinas(animalId);
    } catch (e) {
      throw Exception('Erro ao buscar vacinas: ${e.toString()}');
    }
  }

  /// Generates vaccination schedule suggestions
  Future<List<Map<String, dynamic>>> generateVaccinationSchedule({
    required String animalId,
    required String animalType,
    required DateTime birthDate,
    bool isPuppy = false,
  }) async {
    final schedule = <Map<String, dynamic>>[];
    final now = DateTime.now();
    
    // Get recommended vaccines for animal type
    final recommendedVaccines = VacinaConfig.categorias[animalType] ?? [];
    
    for (final vaccineName in recommendedVaccines) {
      final interval = VacinaConfig.getSuggestedInterval(vaccineName);
      final priority = VacinaConfig.getVaccinePriority(vaccineName);
      
      // For puppies, start vaccines at appropriate age
      DateTime suggestedDate;
      if (isPuppy && vaccineName.contains('Filhote')) {
        if (vaccineName.contains('1ª dose')) {
          suggestedDate = birthDate.add(const Duration(days: 45)); // 6-7 weeks
        } else if (vaccineName.contains('2ª dose')) {
          suggestedDate = birthDate.add(const Duration(days: 66)); // 9-10 weeks
        } else if (vaccineName.contains('3ª dose')) {
          suggestedDate = birthDate.add(const Duration(days: 87)); // 12-13 weeks
        } else {
          suggestedDate = now.add(Duration(days: interval));
        }
      } else {
        suggestedDate = now.add(Duration(days: interval));
      }
      
      schedule.add({
        'vaccineName': vaccineName,
        'suggestedDate': suggestedDate,
        'priority': priority,
        'interval': interval,
        'status': 'scheduled',
      });
    }
    
    // Sort by priority and date
    schedule.sort((a, b) {
      final priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      final aPriority = priorityOrder[a['priority']] ?? 4;
      final bPriority = priorityOrder[b['priority']] ?? 4;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      return (a['suggestedDate'] as DateTime).compareTo(b['suggestedDate'] as DateTime);
    });
    
    return schedule;
  }

  /// Validates vaccine conflicts with existing schedule
  Future<List<String>> validateVaccineConflicts({
    required String animalId,
    required String nomeVacina,
    required DateTime dataAplicacao,
  }) async {
    final conflicts = <String>[];
    final existingVacinas = await getVaccinesByAnimal(animalId);
    
    for (final existing in existingVacinas) {
      final existingDate = DateTime.fromMillisecondsSinceEpoch(existing.dataAplicacao);
      final daysDifference = dataAplicacao.difference(existingDate).inDays.abs();
      
      // Check for same vaccine too close together
      if (existing.nomeVacina.toLowerCase() == nomeVacina.toLowerCase()) {
        final suggestedInterval = VacinaConfig.getSuggestedInterval(nomeVacina);
        final minInterval = (suggestedInterval * 0.8).round();
        
        if (daysDifference < minInterval) {
          conflicts.add('${existing.nomeVacina} já aplicada há $daysDifference dias (mínimo: $minInterval dias)');
        }
      }
      
      // Check for incompatible vaccines on same day
      if (daysDifference == 0 && existing.nomeVacina != nomeVacina) {
        conflicts.add('Outra vacina (${existing.nomeVacina}) já agendada para esta data');
      }
    }
    
    return conflicts;
  }

  /// Gets vaccine recommendations based on animal profile
  Future<List<Map<String, dynamic>>> getVaccineRecommendations({
    required String animalId,
    required String animalType,
    required DateTime birthDate,
    bool isIndoor = false,
  }) async {
    final recommendations = <Map<String, dynamic>>[];
    final existingVacinas = await getVaccinesByAnimal(animalId);
    final existingVaccineNames = existingVacinas.map((v) => v.nomeVacina.toLowerCase()).toList();
    
    // Get all vaccines for animal type
    final allVaccines = VacinaConfig.categorias[animalType] ?? [];
    
    for (final vaccineName in allVaccines) {
      if (!existingVaccineNames.contains(vaccineName.toLowerCase())) {
        final priority = VacinaConfig.getVaccinePriority(vaccineName);
        final interval = VacinaConfig.getSuggestedInterval(vaccineName);
        final suggestedDate = DateTime.now().add(Duration(days: interval));
        
        // Adjust recommendations for indoor animals
        bool isRecommended = true;
        String reason = 'Vacina essencial para $animalType';
        
        if (isIndoor && ['Giardia', 'Leishmaniose'].contains(vaccineName)) {
          isRecommended = false;
          reason = 'Opcional para animais que ficam em casa';
        }
        
        recommendations.add({
          'vaccineName': vaccineName,
          'priority': priority,
          'suggestedDate': suggestedDate,
          'isRecommended': isRecommended,
          'reason': reason,
          'interval': interval,
        });
      }
    }
    
    // Sort by priority
    recommendations.sort((a, b) {
      final priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
      final aPriority = priorityOrder[a['priority']] ?? 4;
      final bPriority = priorityOrder[b['priority']] ?? 4;
      return aPriority.compareTo(bPriority);
    });
    
    return recommendations;
  }

  /// Checks if vaccine schedule is up to date
  Future<Map<String, dynamic>> checkVaccinationStatus(String animalId) async {
    final vacinas = await getVaccinesByAnimal(animalId);
    final now = DateTime.now();
    
    int upToDate = 0;
    int overdue = 0;
    int upcoming = 0;
    final overdueVaccines = <String>[];
    final upcomingVaccines = <String>[];
    
    for (final vacina in vacinas) {
      final nextDose = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
      final daysUntil = nextDose.difference(now).inDays;
      
      if (daysUntil < 0) {
        overdue++;
        overdueVaccines.add(vacina.nomeVacina);
      } else if (daysUntil <= 30) {
        upcoming++;
        upcomingVaccines.add(vacina.nomeVacina);
      } else {
        upToDate++;
      }
    }
    
    String status;
    if (overdue > 0) {
      status = 'overdue';
    } else if (upcoming > 0) {
      status = 'upcoming';
    } else {
      status = 'up_to_date';
    }
    
    return {
      'status': status,
      'upToDate': upToDate,
      'overdue': overdue,
      'upcoming': upcoming,
      'overdueVaccines': overdueVaccines,
      'upcomingVaccines': upcomingVaccines,
      'totalVaccines': vacinas.length,
    };
  }
}
