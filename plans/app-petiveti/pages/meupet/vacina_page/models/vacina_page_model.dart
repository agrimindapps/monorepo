// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../utils/string_utils.dart';
import '../views/styles/vacina_constants.dart';

/// Business logic model for VacinaPage containing all vaccine-related calculations.
/// 
/// This class provides static methods for vaccine status analysis, date formatting,
/// sorting, filtering, and other business logic operations. It serves as the core
/// business logic layer, keeping calculations separate from UI components.
/// 
/// Key responsibilities:
/// - Vaccine status determination (overdue, near expiry, up-to-date)
/// - Date formatting and calculations
/// - Vaccine categorization and sorting
/// - Search and filtering operations
/// - Data validation helpers
/// 
/// All methods are static to ensure they are pure functions without side effects.
/// This design makes the class easily testable and reusable across different
/// contexts within the application.
/// 
/// Example usage:
/// ```dart
/// final isOverdue = VacinaPageModel.isVacinaAtrasada(vaccine);
/// final sortedVaccines = VacinaPageModel.sortVacinasByPriority(vaccines);
/// final daysUntilDue = VacinaPageModel.getDiasParaVencimento(vaccine);
/// ```
class VacinaPageModel {
  /// Determines if a vaccine is overdue based on its next dose date.
  /// 
  /// A vaccine is considered overdue if its next dose date ([VacinaVet.proximaDose])
  /// is before the current date.
  /// 
  /// Parameters:
  /// - [vacina]: The vaccine to check
  /// 
  /// Returns:
  /// - `true` if the vaccine is overdue
  /// - `false` if the vaccine is not overdue
  static bool isVacinaAtrasada(VacinaVet vacina) {
    final hoje = DateTime.now();
    final proximaDose = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
    return proximaDose.isBefore(hoje);
  }

  /// Determines if a vaccine is near expiration (due soon).
  /// 
  /// A vaccine is considered near expiration if its next dose is due within
  /// the warning period defined by [VacinaConstants.diasAvisoVencimento]
  /// and is not yet overdue.
  /// 
  /// Parameters:
  /// - [vacina]: The vaccine to check
  /// 
  /// Returns:
  /// - `true` if the vaccine is due within the warning period
  /// - `false` otherwise
  static bool isVacinaProximaDoVencimento(VacinaVet vacina) {
    final hoje = DateTime.now();
    final proximaDose = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
    final diasParaVencimento = proximaDose.difference(hoje).inDays;
    return diasParaVencimento <= VacinaConstants.diasAvisoVencimento && diasParaVencimento > 0;
  }

  /// Calculates the number of days until a vaccine is due.
  /// 
  /// Returns positive numbers for future dates and negative numbers
  /// for overdue vaccines.
  /// 
  /// Parameters:
  /// - [vacina]: The vaccine to calculate days for
  /// 
  /// Returns:
  /// - Positive integer: days until due
  /// - Negative integer: days overdue
  /// - Zero: due today
  static int getDiasParaVencimento(VacinaVet vacina) {
    final hoje = DateTime.now();
    final proximaDose = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
    return proximaDose.difference(hoje).inDays;
  }

  // Date formatting helpers
  static String formatDateToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String getFormattedCurrentMonth() {
    final now = DateTime.now();
    return StringUtils.capitalize(DateFormat('MMM yy', 'pt_BR').format(now));
  }

  /// Gera lista de meses baseada nos registros de vacina existentes
  static List<String> gerarListaMesesDisponiveis(List<VacinaVet> vacinas) {
    if (vacinas.isEmpty) {
      // Se não há registros, retorna o mês atual
      return [getFormattedCurrentMonth()];
    }

    // Ordena vacinas por data de aplicação
    final sortedVacinas = List<VacinaVet>.from(vacinas)
      ..sort((a, b) => a.dataAplicacao.compareTo(b.dataAplicacao));

    // Obtém data mais antiga e mais recente
    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedVacinas.first.dataAplicacao);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedVacinas.last.dataAplicacao);

    // Gera lista de meses entre as datas
    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = StringUtils.capitalize(
        DateFormat('MMM yy', 'pt_BR').format(currentDate)
      );
      meses.add(mesFormatado);
      
      // Avança para o próximo mês
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Se o mês atual não está na lista, adiciona
    final mesAtual = getFormattedCurrentMonth();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList(); // Mais recente primeiro
  }

  /// Obtém o período de registros (mês mais antigo ao mais recente)
  static String formatarPeriodoVacinas(List<VacinaVet> vacinas) {
    if (vacinas.isEmpty) {
      return getFormattedCurrentMonth();
    }

    final sortedVacinas = List<VacinaVet>.from(vacinas)
      ..sort((a, b) => a.dataAplicacao.compareTo(b.dataAplicacao));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedVacinas.first.dataAplicacao);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedVacinas.last.dataAplicacao);

    final mesInicial = StringUtils.capitalize(
      DateFormat('MMM yy', 'pt_BR').format(dataInicial)
    );
    
    final mesFinal = StringUtils.capitalize(
      DateFormat('MMM yy', 'pt_BR').format(dataFinal)
    );

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  // Statistics and categorization
  static List<VacinaVet> getVacinasAtrasadas(List<VacinaVet> vacinas) {
    return vacinas.where((vacina) => isVacinaAtrasada(vacina)).toList();
  }

  static List<VacinaVet> getVacinasProximasDoVencimento(List<VacinaVet> vacinas) {
    return vacinas.where((vacina) => isVacinaProximaDoVencimento(vacina)).toList();
  }

  static List<VacinaVet> getVacinasEmDia(List<VacinaVet> vacinas) {
    return vacinas.where((vacina) => 
      !isVacinaAtrasada(vacina) && !isVacinaProximaDoVencimento(vacina)
    ).toList();
  }

  // Status text helpers
  static String getVacinaStatusColor(VacinaVet vacina) {
    if (isVacinaAtrasada(vacina)) return 'red';
    if (isVacinaProximaDoVencimento(vacina)) return 'orange';
    return 'green';
  }

  static String getVacinaStatusText(VacinaVet vacina) {
    if (isVacinaAtrasada(vacina)) {
      final dias = -getDiasParaVencimento(vacina);
      return 'Atrasada há $dias dias';
    }
    if (isVacinaProximaDoVencimento(vacina)) {
      final dias = getDiasParaVencimento(vacina);
      return 'Vence em $dias dias';
    }
    return 'Em dia';
  }

  // Sorting and filtering
  static List<VacinaVet> sortVacinasByPriority(List<VacinaVet> vacinas) {
    final sortedVacinas = List<VacinaVet>.from(vacinas);
    
    sortedVacinas.sort((a, b) {
      final isAAtrasada = isVacinaAtrasada(a);
      final isBAtrasada = isVacinaAtrasada(b);
      final isAProxima = isVacinaProximaDoVencimento(a);
      final isBProxima = isVacinaProximaDoVencimento(b);
      
      // Overdue vaccines first
      if (isAAtrasada && !isBAtrasada) return -1;
      if (!isAAtrasada && isBAtrasada) return 1;
      
      // Near expiry vaccines next
      if (isAProxima && !isBProxima && !isBAtrasada) return -1;
      if (!isAProxima && isBProxima && !isAAtrasada) return 1;
      
      // Sort by next dose date within same category
      return a.proximaDose.compareTo(b.proximaDose);
    });
    
    return sortedVacinas;
  }

  static List<VacinaVet> filterVacinasByDateRange(
    List<VacinaVet> vacinas,
    int? dataInicial,
    int? dataFinal,
  ) {
    if (dataInicial == null || dataFinal == null) return vacinas;
    
    return vacinas.where((vacina) {
      final applicationDate = DateTime.fromMillisecondsSinceEpoch(vacina.dataAplicacao);
      final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(vacina.proximaDose);
      final filterStart = DateTime.fromMillisecondsSinceEpoch(dataInicial);
      final filterEnd = DateTime.fromMillisecondsSinceEpoch(dataFinal);
      
      // Check if vaccine period overlaps with filter period
      return applicationDate.isBefore(filterEnd.add(const Duration(days: 1))) ||
             nextDoseDate.isAfter(filterStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  static List<VacinaVet> searchVacinas(List<VacinaVet> vacinas, String query) {
    if (query.isEmpty) return vacinas;
    final lowercaseQuery = query.toLowerCase();
    return vacinas.where((vacina) {
      return vacina.nomeVacina.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper methods for UI state
  static String getSubtitle(int vacinaCount) {
    return '$vacinaCount registros';
  }

  /// Validates minimum interval between application and next dose
  /// Returns true if interval is valid (at least 1 day)
  static bool isValidDoseInterval(int applicationTimestamp, int nextDoseTimestamp) {
    final applicationDate = DateTime.fromMillisecondsSinceEpoch(applicationTimestamp);
    final nextDoseDate = DateTime.fromMillisecondsSinceEpoch(nextDoseTimestamp);
    return nextDoseDate.difference(applicationDate).inDays >= 1;
  }
}
