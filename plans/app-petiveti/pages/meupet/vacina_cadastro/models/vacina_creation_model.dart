// Project imports:
import '../../../../models/16_vacina_model.dart';

/// Business logic model for vaccine creation and editing
class VacinaCreationModel {
  
  /// Calculates default next dose date based on application date
  static int calculateDefaultNextDose(int applicationDate) {
    final appDate = DateTime.fromMillisecondsSinceEpoch(applicationDate);
    return appDate.add(const Duration(days: 365)).millisecondsSinceEpoch;
  }

  /// Validates if next dose is appropriate for the application date
  static bool isValidNextDoseInterval(int applicationDate, int nextDoseDate) {
    final appDate = DateTime.fromMillisecondsSinceEpoch(applicationDate);
    final nextDate = DateTime.fromMillisecondsSinceEpoch(nextDoseDate);
    
    // Next dose must be at least 1 day after application
    final minNextDate = appDate.add(const Duration(days: 1));
    
    // Next dose should not be more than 10 years in the future
    final maxNextDate = appDate.add(const Duration(days: 365 * 10));
    
    return nextDate.isAfter(minNextDate) && nextDate.isBefore(maxNextDate);
  }

  /// Checks if application date is valid (not in future, not too old)
  static bool isValidApplicationDate(int applicationDate) {
    final appDate = DateTime.fromMillisecondsSinceEpoch(applicationDate);
    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = now.add(const Duration(hours: 24)); // Allow up to tomorrow
    
    return appDate.isAfter(minDate) && appDate.isBefore(maxDate);
  }

  /// Suggests next dose date based on vaccine name patterns
  static int suggestNextDoseDate(String vaccineName, int applicationDate) {
    final appDate = DateTime.fromMillisecondsSinceEpoch(applicationDate);
    final lowerVaccineName = vaccineName.toLowerCase();
    
    // Common vaccine intervals
    if (lowerVaccineName.contains('raiva') || lowerVaccineName.contains('rabies')) {
      // Rabies: annual
      return appDate.add(const Duration(days: 365)).millisecondsSinceEpoch;
    } else if (lowerVaccineName.contains('v8') || lowerVaccineName.contains('v10') || 
               lowerVaccineName.contains('v12') || lowerVaccineName.contains('múltipla')) {
      // Multiple vaccines: annual
      return appDate.add(const Duration(days: 365)).millisecondsSinceEpoch;
    } else if (lowerVaccineName.contains('puppy') || lowerVaccineName.contains('filhote')) {
      // Puppy vaccines: 3-4 weeks
      return appDate.add(const Duration(days: 21)).millisecondsSinceEpoch;
    } else if (lowerVaccineName.contains('reforço') || lowerVaccineName.contains('boost')) {
      // Booster: 6 months
      return appDate.add(const Duration(days: 180)).millisecondsSinceEpoch;
    }
    
    // Default: 1 year
    return appDate.add(const Duration(days: 365)).millisecondsSinceEpoch;
  }

  /// Validates vaccine name format and content
  static String? validateVaccineName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'O nome da vacina é obrigatório';
    }
    
    final trimmedName = name.trim();
    
    if (trimmedName.length < 2) {
      return 'O nome da vacina deve ter pelo menos 2 caracteres';
    }
    
    if (trimmedName.length > 100) {
      return 'O nome da vacina deve ter no máximo 100 caracteres';
    }
    
    // Check for invalid characters
    if (trimmedName.contains('<') || trimmedName.contains('>') || 
        trimmedName.contains('"') || trimmedName.contains("'")) {
      return 'Nome da vacina contém caracteres inválidos';
    }
    
    return null;
  }

  /// Validates observations field
  static String? validateObservations(String? observations) {
    if (observations != null && observations.length > 500) {
      return 'Observações devem ter no máximo 500 caracteres';
    }
    
    // Check for potentially dangerous content
    if (observations != null) {
      final lower = observations.toLowerCase();
      if (lower.contains('<script') || lower.contains('javascript:')) {
        return 'Observações contêm conteúdo inválido';
      }
    }
    
    return null;
  }

  /// Creates a VacinaVet object from form data
  static VacinaVet createVaccineFromForm({
    required int createdAt,
    required int updatedAt,
    required bool isDeleted,
    required bool needsSync,
    required int version,
    required int? lastSyncAt,
    required String id,
    required String animalId,
    required String nomeVacina,
    required int dataAplicacao,
    required int proximaDose,
    String? observacoes,
  }) {
    return VacinaVet(
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      needsSync: needsSync,
      version: version,
      lastSyncAt: lastSyncAt,
      id: id,
      animalId: animalId,
      nomeVacina: nomeVacina.trim(),
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes?.trim().isEmpty == true ? null : observacoes?.trim(),
    );
  }

  /// Updates an existing VacinaVet with form data
  static VacinaVet updateVaccineFromForm({
    required VacinaVet existingVacine,
    required String nomeVacina,
    required int dataAplicacao,
    required int proximaDose,
    String? observacoes,
  }) {
    return VacinaVet(
      createdAt: existingVacine.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: existingVacine.isDeleted,
      needsSync: true,
      version: existingVacine.version + 1,
      lastSyncAt: existingVacine.lastSyncAt,
      id: existingVacine.id,
      animalId: existingVacine.animalId,
      nomeVacina: nomeVacina.trim(),
      dataAplicacao: dataAplicacao,
      proximaDose: proximaDose,
      observacoes: observacoes?.trim().isEmpty == true ? null : observacoes?.trim(),
    );
  }

  /// Calculates vaccine priority based on next dose date
  static VaccinePriority calculateVaccinePriority(int nextDoseDate) {
    final now = DateTime.now();
    final nextDose = DateTime.fromMillisecondsSinceEpoch(nextDoseDate);
    final daysDifference = nextDose.difference(now).inDays;
    
    if (daysDifference < 0) {
      return VaccinePriority.overdue;
    } else if (daysDifference <= 7) {
      return VaccinePriority.urgent;
    } else if (daysDifference <= 30) {
      return VaccinePriority.upcoming;
    } else {
      return VaccinePriority.normal;
    }
  }

  /// Gets display text for vaccine priority
  static String getPriorityDisplayText(VaccinePriority priority) {
    switch (priority) {
      case VaccinePriority.overdue:
        return 'Atrasada';
      case VaccinePriority.urgent:
        return 'Urgente';
      case VaccinePriority.upcoming:
        return 'Próxima';
      case VaccinePriority.normal:
        return 'Normal';
    }
  }

  /// Sanitizes vaccine name input
  static String sanitizeVaccineName(String input) {
    return input.trim()
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitizes observations input
  static String sanitizeObservations(String input) {
    return input.trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

/// Enum for vaccine priority levels
enum VaccinePriority {
  overdue,
  urgent,
  upcoming,
  normal,
}
