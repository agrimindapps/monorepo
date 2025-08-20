// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../utils/vacina_utils.dart';

/// Page-specific UI helpers for vaccination listing
class PageHelpers {
  
  /// Gets formatted title for vaccine with icon
  static String getVaccineTitle(VacinaVet vaccine) {
    final icon = VacinaUtils.getVaccineIcon(vaccine.nomeVacina);
    return '$icon ${vaccine.nomeVacina}';
  }
  
  /// Gets formatted subtitle for vaccine display
  static String getVaccineSubtitle(VacinaVet vaccine) {
    final dateStr = VacinaUtils.timestampToDateString(vaccine.dataAplicacao);
    final status = VacinaUtils.getVaccineStatusText(vaccine);
    return 'Aplicada em $dateStr • $status';
  }
  
  /// Gets detailed info for vaccine card
  static String getVaccineDetailedInfo(VacinaVet vaccine) {
    final daysUntil = VacinaUtils.getDaysUntilNextDose(vaccine);
    final nextDoseDate = VacinaUtils.timestampToDateString(vaccine.proximaDose);
    
    if (daysUntil < 0) {
      return 'Próxima dose vencida há ${daysUntil.abs()} dias';
    } else if (daysUntil == 0) {
      return 'Próxima dose vence hoje';
    } else {
      return 'Próxima dose em $daysUntil dias ($nextDoseDate)';
    }
  }
  
  /// Formats search results count
  static String formatSearchResults(int total, int filtered, String query) {
    if (query.isEmpty) {
      return 'Total: $total ${total == 1 ? 'vacina' : 'vacinas'}';
    }
    return '$filtered de $total vacinas encontradas para "$query"';
  }
  
  /// Gets status color for vaccine
  static String getStatusColor(VacinaVet vaccine) {
    final color = VacinaUtils.getVaccineStatusColor(vaccine);
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
  }
  
  /// Gets formatted age of vaccine record
  static String getVaccineAgeText(VacinaVet vaccine) {
    final age = VacinaUtils.getVaccineAge(vaccine);
    if (age == 0) return 'Hoje';
    if (age == 1) return 'Ontem';
    if (age < 7) return 'Há $age dias';
    if (age < 30) return 'Há ${(age / 7).floor()} semanas';
    if (age < 365) return 'Há ${(age / 30).floor()} meses';
    return 'Há ${(age / 365).floor()} anos';
  }
  
  /// Gets summary text for vaccine statistics
  static String getVaccineStatsSummary(List<VacinaVet> vaccines) {
    if (vaccines.isEmpty) return 'Nenhuma vacina registrada';
    
    final stats = VacinaUtils.calculateVaccineStats(vaccines);
    final upToDate = stats['upToDate'] ?? 0;
    final overdue = stats['overdue'] ?? 0;
    final upcoming = stats['upcoming'] ?? 0;
    
    String summary = '${vaccines.length} vacinas';
    if (upToDate > 0) summary += ' • $upToDate em dia';
    if (overdue > 0) summary += ' • $overdue vencidas';
    if (upcoming > 0) summary += ' • $upcoming próximas';
    
    return summary;
  }
  
  /// Gets display text for vaccine filter
  static String getFilterText(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return 'Todas';
      case 'up_to_date':
        return 'Em dia';
      case 'overdue':
        return 'Vencidas';
      case 'upcoming':
        return 'Próximas';
      default:
        return 'Filtro';
    }
  }
  
  /// Gets display text for vaccine sort option
  static String getSortText(String sort) {
    switch (sort.toLowerCase()) {
      case 'name':
        return 'Nome';
      case 'date':
        return 'Data';
      case 'next_dose':
        return 'Próxima dose';
      case 'status':
        return 'Status';
      default:
        return 'Ordenar';
    }
  }
}
