// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/16_vacina_model.dart';

/// Central vaccine utilities for app-petiveti
class VacinaUtils {
  
  /// Common vaccine types with icons
  static const Map<String, String> vaccineIcons = {
    'V8': '💉',
    'V10': '💉', 
    'V11': '💉',
    'Antirrábica': '🦠',
    'Gripe Canina': '🤧',
    'Leishmaniose': '🕷️',
    'Giardia': '🦠',
    'Bordetella': '🫁',
    'Lyme': '🦠',
    'Coronavirus': '🦠',
    'Tríplice Felina': '💉',
    'Quádrupla Felina': '💉',
    'Quíntupla Felina': '💉',
    'Leucemia Felina': '🩸',
    'PIF': '😷',
    'Calicivirus': '🦠',
    'Herpesvirus': '🦠',
    'Panleucopenia': '🩸',
    'Rinotraqueíte': '👃',
    'Clamidiose': '👁️',
    'Outros': '💊',
  };

  /// Common vaccine types for dogs
  static const List<String> dogVaccines = [
    'V8',
    'V10',
    'V11', 
    'Antirrábica',
    'Gripe Canina',
    'Leishmaniose',
    'Giardia',
    'Bordetella',
    'Lyme',
    'Coronavirus',
  ];

  /// Common vaccine types for cats
  static const List<String> catVaccines = [
    'Tríplice Felina',
    'Quádrupla Felina', 
    'Quíntupla Felina',
    'Antirrábica',
    'Leucemia Felina',
    'PIF',
    'Calicivirus',
    'Herpesvirus',
    'Panleucopenia',
    'Rinotraqueíte',
    'Clamidiose',
  ];

  /// Get icon for vaccine type
  static String getVaccineIcon(String vaccineName) {
    for (final entry in vaccineIcons.entries) {
      if (vaccineName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return vaccineIcons['Outros']!;
  }

  /// Get color for vaccine status
  static Color getVaccineStatusColor(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final in30Days = now + (30 * 24 * 60 * 60 * 1000);
    
    if (vaccine.proximaDose < now) {
      return const Color(0xFFE53935); // Red - overdue
    } else if (vaccine.proximaDose <= in30Days) {
      return const Color(0xFFFF9800); // Orange - upcoming
    } else {
      return const Color(0xFF4CAF50); // Green - up to date
    }
  }

  /// Get status text for vaccine
  static String getVaccineStatusText(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final in30Days = now + (30 * 24 * 60 * 60 * 1000);
    
    if (vaccine.proximaDose < now) {
      return 'Atrasada';
    } else if (vaccine.proximaDose <= in30Days) {
      return 'Próxima do vencimento';
    } else {
      return 'Em dia';
    }
  }

  /// Converts timestamp to formatted date string
  static String timestampToDateString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Converts timestamp to display time
  static String timestampToTimeString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formats timestamp to dd/MM/yyyy HH:mm format
  static String timestampToDateTimeString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${timestampToDateString(timestamp)} ${timestampToTimeString(timestamp)}';
  }

  /// Gets the current timestamp
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Adds days to a timestamp
  static int addDaysToTimestamp(int timestamp, int days) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.add(Duration(days: days)).millisecondsSinceEpoch;
  }

  /// Adds months to a timestamp
  static int addMonthsToTimestamp(int timestamp, int months) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime(date.year, date.month + months, date.day).millisecondsSinceEpoch;
  }

  /// Adds years to a timestamp
  static int addYearsToTimestamp(int timestamp, int years) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime(date.year + years, date.month, date.day).millisecondsSinceEpoch;
  }

  /// Calculates age of vaccine record in days
  static int getVaccineAge(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((now - vaccine.dataAplicacao) / (24 * 60 * 60 * 1000)).floor();
  }

  /// Calculates days until next dose
  static int getDaysUntilNextDose(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return ((vaccine.proximaDose - now) / (24 * 60 * 60 * 1000)).floor();
  }

  /// Calculates days between two timestamps
  static int daysBetweenTimestamps(int start, int end) {
    return ((end - start) / (24 * 60 * 60 * 1000)).floor();
  }

  /// Checks if vaccine is recent (applied within last 30 days)
  static bool isRecentVaccine(VacinaVet vaccine) {
    return getVaccineAge(vaccine) <= 30;
  }

  /// Checks if vaccine is overdue
  static bool isOverdue(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return vaccine.proximaDose < now;
  }

  /// Checks if vaccine is upcoming (due within 30 days)
  static bool isUpcoming(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final in30Days = now + (30 * 24 * 60 * 60 * 1000);
    return vaccine.proximaDose >= now && vaccine.proximaDose <= in30Days;
  }

  /// Checks if vaccine is up to date
  static bool isUpToDate(VacinaVet vaccine) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final in30Days = now + (30 * 24 * 60 * 60 * 1000);
    return vaccine.proximaDose > in30Days;
  }

  /// Groups vaccines by month/year
  static Map<String, List<VacinaVet>> groupVaccinesByMonth(List<VacinaVet> vaccines) {
    final Map<String, List<VacinaVet>> grouped = {};
    
    for (final vaccine in vaccines) {
      final date = DateTime.fromMillisecondsSinceEpoch(vaccine.dataAplicacao);
      final key = '${date.month.toString().padLeft(2, '0')}/${date.year}';
      
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(vaccine);
    }
    
    return grouped;
  }

  /// Groups vaccines by year
  static Map<String, List<VacinaVet>> groupVaccinesByYear(List<VacinaVet> vaccines) {
    final Map<String, List<VacinaVet>> grouped = {};
    
    for (final vaccine in vaccines) {
      final date = DateTime.fromMillisecondsSinceEpoch(vaccine.dataAplicacao);
      final key = date.year.toString();
      
      grouped.putIfAbsent(key, () => []).add(vaccine);
    }
    
    return grouped;
  }

  /// Groups vaccines by status
  static Map<String, List<VacinaVet>> groupVaccinesByStatus(List<VacinaVet> vaccines) {
    final Map<String, List<VacinaVet>> grouped = {
      'overdue': [],
      'upcoming': [],
      'upToDate': [],
    };
    
    for (final vaccine in vaccines) {
      if (isOverdue(vaccine)) {
        grouped['overdue']!.add(vaccine);
      } else if (isUpcoming(vaccine)) {
        grouped['upcoming']!.add(vaccine);
      } else {
        grouped['upToDate']!.add(vaccine);
      }
    }
    
    return grouped;
  }

  /// Sorts vaccines by application date (newest first)
  static List<VacinaVet> sortByApplicationDate(List<VacinaVet> vaccines, {bool ascending = false}) {
    final sorted = List<VacinaVet>.from(vaccines);
    sorted.sort((a, b) => ascending 
        ? a.dataAplicacao.compareTo(b.dataAplicacao)
        : b.dataAplicacao.compareTo(a.dataAplicacao));
    return sorted;
  }

  /// Sorts vaccines by next dose date
  static List<VacinaVet> sortByNextDoseDate(List<VacinaVet> vaccines, {bool ascending = true}) {
    final sorted = List<VacinaVet>.from(vaccines);
    sorted.sort((a, b) => ascending 
        ? a.proximaDose.compareTo(b.proximaDose)
        : b.proximaDose.compareTo(a.proximaDose));
    return sorted;
  }

  /// Sorts vaccines by urgency (overdue first, then upcoming)
  static List<VacinaVet> sortByUrgency(List<VacinaVet> vaccines) {
    final sorted = List<VacinaVet>.from(vaccines);
    sorted.sort((a, b) {
      final aOverdue = isOverdue(a);
      final bOverdue = isOverdue(b);
      final aUpcoming = isUpcoming(a);
      final bUpcoming = isUpcoming(b);
      
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      if (aUpcoming && !bUpcoming) return -1;
      if (!aUpcoming && bUpcoming) return 1;
      
      // Same category, sort by next dose date
      return a.proximaDose.compareTo(b.proximaDose);
    });
    return sorted;
  }

  /// Gets unique vaccine names from a list
  static List<String> getUniqueVaccineNames(List<VacinaVet> vaccines) {
    final names = vaccines.map((v) => v.nomeVacina).toSet().toList();
    names.sort();
    return names;
  }

  /// Filters vaccines by name (case insensitive)
  static List<VacinaVet> filterByName(List<VacinaVet> vaccines, String name) {
    if (name.isEmpty) return vaccines;
    final lowerName = name.toLowerCase();
    return vaccines.where((v) => v.nomeVacina.toLowerCase().contains(lowerName)).toList();
  }

  /// Filters vaccines by date range
  static List<VacinaVet> filterByDateRange(List<VacinaVet> vaccines, int startTimestamp, int endTimestamp) {
    return vaccines.where((v) => 
        v.dataAplicacao >= startTimestamp && v.dataAplicacao <= endTimestamp).toList();
  }

  /// Filters vaccines by animal
  static List<VacinaVet> filterByAnimal(List<VacinaVet> vaccines, String animalId) {
    return vaccines.where((v) => v.animalId == animalId).toList();
  }

  /// Filters vaccines by status
  static List<VacinaVet> filterByStatus(List<VacinaVet> vaccines, String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
      case 'atrasada':
        return vaccines.where((v) => isOverdue(v)).toList();
      case 'upcoming':
      case 'proxima':
        return vaccines.where((v) => isUpcoming(v)).toList();
      case 'uptodate':
      case 'em_dia':
        return vaccines.where((v) => isUpToDate(v)).toList();
      default:
        return vaccines;
    }
  }

  /// Gets vaccines that need attention (overdue or near expiry)
  static List<VacinaVet> getVaccinesNeedingAttention(List<VacinaVet> vaccines) {
    return vaccines.where((v) => isOverdue(v) || isUpcoming(v)).toList();
  }

  /// Calculates statistics for a list of vaccines
  static Map<String, int> calculateVaccineStats(List<VacinaVet> vaccines) {
    int overdue = 0;
    int upcoming = 0;
    int upToDate = 0;
    
    for (final vaccine in vaccines) {
      if (isOverdue(vaccine)) {
        overdue++;
      } else if (isUpcoming(vaccine)) {
        upcoming++;
      } else {
        upToDate++;
      }
    }
    
    return {
      'total': vaccines.length,
      'overdue': overdue,
      'upcoming': upcoming,
      'upToDate': upToDate,
    };
  }

  /// Generates a summary text for vaccine status
  static String generateStatusSummary(List<VacinaVet> vaccines) {
    final stats = calculateVaccineStats(vaccines);
    final total = stats['total']!;
    final overdue = stats['overdue']!;
    final upcoming = stats['upcoming']!;
    
    if (total == 0) return 'Nenhuma vacina cadastrada';
    if (overdue > 0) return '$overdue vacina(s) atrasada(s)';
    if (upcoming > 0) return '$upcoming vacina(s) próxima(s) do vencimento';
    return 'Todas as vacinas em dia';
  }

  /// Validates if a timestamp is in the past
  static bool isInPast(int timestamp) {
    return timestamp < DateTime.now().millisecondsSinceEpoch;
  }

  /// Validates if a timestamp is in the future
  static bool isInFuture(int timestamp) {
    return timestamp > DateTime.now().millisecondsSinceEpoch;
  }

  /// Validates if dose interval is appropriate
  static bool isValidDoseInterval(int applicationDate, int nextDoseDate) {
    final daysBetween = daysBetweenTimestamps(applicationDate, nextDoseDate);
    return daysBetween >= 1; // Minimum 1 day between doses
  }

  /// Creates a copy of vaccine with updated data
  static VacinaVet copyVaccineWith(VacinaVet original, {
    String? nomeVacina,
    int? dataAplicacao,
    int? proximaDose,
    String? observacoes,
  }) {
    return VacinaVet(
      id: original.id,
      createdAt: original.createdAt,
      updatedAt: original.updatedAt,
      isDeleted: original.isDeleted,
      needsSync: original.needsSync,
      version: original.version,
      lastSyncAt: original.lastSyncAt,
      animalId: original.animalId,
      nomeVacina: nomeVacina ?? original.nomeVacina,
      dataAplicacao: dataAplicacao ?? original.dataAplicacao,
      proximaDose: proximaDose ?? original.proximaDose,
      observacoes: observacoes ?? original.observacoes,
    );
  }

  /// Validates vaccine name
  static String? validateVaccineName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Nome da vacina é obrigatório';
    }
    
    if (name.trim().length < 2) {
      return 'Nome da vacina deve ter pelo menos 2 caracteres';
    }
    
    if (name.trim().length > 100) {
      return 'Nome da vacina deve ter no máximo 100 caracteres';
    }
    
    // Check for invalid characters
    if (name.contains('<') || name.contains('>') || name.contains('"') || 
        name.contains("'") || name.contains('/') || name.contains('&')) {
      return 'Nome da vacina contém caracteres inválidos';
    }
    
    return null;
  }

  /// Validates application date
  static String? validateApplicationDate(int? timestamp) {
    if (timestamp == null || timestamp <= 0) {
      return 'Data de aplicação é obrigatória';
    }
    
    final applicationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = now.add(const Duration(hours: 24)); // Allow up to tomorrow
    
    if (applicationDate.isBefore(minDate)) {
      return 'Data de aplicação muito antiga';
    }
    
    if (applicationDate.isAfter(maxDate)) {
      return 'Data de aplicação não pode ser no futuro';
    }
    
    return null;
  }

  /// Validates next dose date
  static String? validateNextDoseDate(int? timestamp, int? applicationTimestamp) {
    if (timestamp == null || timestamp <= 0) {
      return 'Data da próxima dose é obrigatória';
    }
    
    final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365 * 10)); // 10 years max
    
    if (nextDoseDate.isAfter(maxDate)) {
      return 'Data da próxima dose muito distante (máximo 10 anos)';
    }
    
    // If application date is provided, next dose must be after application
    if (applicationTimestamp != null && applicationTimestamp > 0) {
      final applicationDate = DateTime.fromMillisecondsSinceEpoch(applicationTimestamp);
      if (nextDoseDate.isBefore(applicationDate)) {
        return 'Próxima dose deve ser após a data de aplicação';
      }
      
      // Check if next dose is too soon (minimum 1 day)
      if (!isValidDoseInterval(applicationTimestamp, timestamp)) {
        return 'Próxima dose deve ser pelo menos 1 dia após a aplicação';
      }
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
      if (lower.contains('<script') || lower.contains('javascript:') || lower.contains('data:')) {
        return 'Observações contêm conteúdo inválido';
      }
    }
    
    return null;
  }

  /// Validates animal ID
  static String? validateAnimalId(String? animalId) {
    if (animalId == null || animalId.trim().isEmpty) {
      return 'ID do animal é obrigatório';
    }
    
    return null;
  }

  /// Validates complete vaccine data
  static Map<String, String> validateVaccineData({
    required String? animalId,
    required String? vaccineName,
    required int? applicationDate,
    required int? nextDoseDate,
    String? observations,
  }) {
    final errors = <String, String>{};
    
    final animalIdError = validateAnimalId(animalId);
    if (animalIdError != null) {
      errors['animalId'] = animalIdError;
    }
    
    final vaccineNameError = validateVaccineName(vaccineName);
    if (vaccineNameError != null) {
      errors['vaccineName'] = vaccineNameError;
    }
    
    final applicationDateError = validateApplicationDate(applicationDate);
    if (applicationDateError != null) {
      errors['applicationDate'] = applicationDateError;
    }
    
    final nextDoseDateError = validateNextDoseDate(nextDoseDate, applicationDate);
    if (nextDoseDateError != null) {
      errors['nextDoseDate'] = nextDoseDateError;
    }
    
    final observationsError = validateObservations(observations);
    if (observationsError != null) {
      errors['observations'] = observationsError;
    }
    
    return errors;
  }

  /// Checks if vaccine data is valid (no validation errors)
  static bool isVaccineDataValid({
    required String? animalId,
    required String? vaccineName,
    required int? applicationDate,
    required int? nextDoseDate,
    String? observations,
  }) {
    final errors = validateVaccineData(
      animalId: animalId,
      vaccineName: vaccineName,
      applicationDate: applicationDate,
      nextDoseDate: nextDoseDate,
      observations: observations,
    );
    return errors.isEmpty;
  }

  /// Sanitizes input string for vaccine name
  static String sanitizeVaccineName(String input) {
    return input.trim()
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('`', '')
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  /// Sanitizes observations text
  static String sanitizeObservations(String input) {
    var sanitized = input.trim();
    
    // Remove common dangerous patterns
    sanitized = sanitized.replaceAll('<script', '');
    sanitized = sanitized.replaceAll('javascript:', '');
    sanitized = sanitized.replaceAll('data:', '');
    
    // Replace multiple spaces with single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized;
  }

  /// Gets common vaccine intervals
  static Map<String, int> getCommonIntervals() {
    return {
      '1 semana': 7,
      '2 semanas': 14,
      '3 semanas': 21,
      '1 mês': 30,
      '2 meses': 60,
      '3 meses': 90,
      '6 meses': 180,
      '1 ano': 365,
      '2 anos': 730,
      '3 anos': 1095,
    };
  }

  /// Gets suggested next dose date based on vaccine type
  static int? getSuggestedNextDose(String vaccineName, int applicationDate) {
    final intervals = {
      'v8': 365, // 1 year
      'v10': 365,
      'v11': 365,
      'antirrábica': 365,
      'tríplice': 365,
      'quádrupla': 365,
      'quíntupla': 365,
      'gripe': 365,
      'leishmaniose': 365,
      'leucemia': 365,
      'bordetella': 180, // 6 months
      'giardia': 365,
    };
    
    final lowerName = vaccineName.toLowerCase();
    for (final entry in intervals.entries) {
      if (lowerName.contains(entry.key)) {
        return addDaysToTimestamp(applicationDate, entry.value);
      }
    }
    
    // Default to 1 year
    return addDaysToTimestamp(applicationDate, 365);
  }

  /// Export vaccine to JSON
  static Map<String, dynamic> exportToJson(VacinaVet vaccine) {
    return {
      'id': vaccine.id,
      'animalId': vaccine.animalId,
      'nomeVacina': vaccine.nomeVacina,
      'dataAplicacao': vaccine.dataAplicacao,
      'dataAplicacaoFormatada': timestampToDateString(vaccine.dataAplicacao),
      'proximaDose': vaccine.proximaDose,
      'proximaDoseFormatada': timestampToDateString(vaccine.proximaDose),
      'observacoes': vaccine.observacoes,
      'statusText': getVaccineStatusText(vaccine),
      'icon': getVaccineIcon(vaccine.nomeVacina),
      'diasAteProximaDose': getDaysUntilNextDose(vaccine),
      'idadeVacina': getVaccineAge(vaccine),
      'isOverdue': isOverdue(vaccine),
      'isUpcoming': isUpcoming(vaccine),
      'isUpToDate': isUpToDate(vaccine),
    };
  }

  /// Get vaccine suggestions based on animal type
  static List<String> getVaccineSuggestions(String? animalType) {
    switch (animalType?.toLowerCase()) {
      case 'cachorro':
      case 'dog':
        return dogVaccines;
      case 'gato':
      case 'cat':
        return catVaccines;
      default:
        return [...dogVaccines, ...catVaccines];
    }
  }

  /// Format vaccine description for display
  static String formatVaccineDescription(VacinaVet vaccine) {
    final icon = getVaccineIcon(vaccine.nomeVacina);
    final status = getVaccineStatusText(vaccine);
    final daysUntil = getDaysUntilNextDose(vaccine);
    
    if (daysUntil < 0) {
      return '$icon ${vaccine.nomeVacina} • $status (${daysUntil.abs()} dias)';
    } else if (daysUntil == 0) {
      return '$icon ${vaccine.nomeVacina} • Vence hoje';
    } else {
      return '$icon ${vaccine.nomeVacina} • $status ($daysUntil dias)';
    }
  }
}
