// Project imports:
import '../../../../models/15_medicamento_model.dart';

class MedicamentosFilterService {
  static List<MedicamentoVet> filterByDateRange(
    List<MedicamentoVet> medicamentos,
    int? dataInicial,
    int? dataFinal,
  ) {
    if (dataInicial == null || dataFinal == null) return medicamentos;
    
    final filterStart = DateTime.fromMillisecondsSinceEpoch(dataInicial);
    final filterEnd = DateTime.fromMillisecondsSinceEpoch(dataFinal);
    
    return medicamentos.where((medicamento) {
      final startDate = DateTime.fromMillisecondsSinceEpoch(medicamento.inicioTratamento);
      final endDate = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
      
      return startDate.isBefore(filterEnd.add(const Duration(days: 1))) &&
             endDate.isAfter(filterStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  static List<MedicamentoVet> filterByStatus(
    List<MedicamentoVet> medicamentos,
    MedicamentoStatus status,
  ) {
    final hoje = DateTime.now().millisecondsSinceEpoch;
    
    switch (status) {
      case MedicamentoStatus.ativo:
        return medicamentos.where((medicamento) {
          return medicamento.inicioTratamento <= hoje && 
                 medicamento.fimTratamento >= hoje;
        }).toList();
        
      case MedicamentoStatus.finalizado:
        return medicamentos.where((medicamento) {
          return medicamento.fimTratamento < hoje;
        }).toList();
        
      case MedicamentoStatus.futuro:
        return medicamentos.where((medicamento) {
          return medicamento.inicioTratamento > hoje;
        }).toList();
        
      default:
        return medicamentos;
    }
  }

  static List<MedicamentoVet> filterBySearchQuery(
    List<MedicamentoVet> medicamentos,
    String query,
  ) {
    if (query.isEmpty) return medicamentos;
    
    final lowercaseQuery = query.toLowerCase();
    return medicamentos.where((medicamento) {
      return medicamento.nomeMedicamento.toLowerCase().contains(lowercaseQuery) ||
             medicamento.dosagem.toLowerCase().contains(lowercaseQuery) ||
             medicamento.frequencia.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<MedicamentoVet> sortByDate(
    List<MedicamentoVet> medicamentos, {
    bool ascending = false,
  }) {
    final sorted = List<MedicamentoVet>.from(medicamentos);
    sorted.sort((a, b) {
      final comparison = a.inicioTratamento.compareTo(b.inicioTratamento);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<MedicamentoVet> sortByName(
    List<MedicamentoVet> medicamentos, {
    bool ascending = true,
  }) {
    final sorted = List<MedicamentoVet>.from(medicamentos);
    sorted.sort((a, b) {
      final comparison = a.nomeMedicamento.compareTo(b.nomeMedicamento);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<MedicamentoVet> getMedicamentosExpiringSoon(
    List<MedicamentoVet> medicamentos, {
    int daysThreshold = 7,
  }) {
    final hoje = DateTime.now();
    final limite = hoje.add(Duration(days: daysThreshold));
    
    return medicamentos.where((medicamento) {
      final endDate = DateTime.fromMillisecondsSinceEpoch(medicamento.fimTratamento);
      return endDate.isAfter(hoje) && endDate.isBefore(limite);
    }).toList();
  }
}

enum MedicamentoStatus {
  ativo,
  finalizado,
  futuro,
  todos,
}
