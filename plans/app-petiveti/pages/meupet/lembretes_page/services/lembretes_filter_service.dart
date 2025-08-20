// Project imports:
import '../../../../models/14_lembrete_model.dart';

class LembretesFilterService {
  static List<LembreteVet> filterByDateRange(
    List<LembreteVet> lembretes,
    DateTime? dataInicial,
    DateTime? dataFinal,
  ) {
    if (dataInicial == null || dataFinal == null) return lembretes;
    
    return lembretes.where((lembrete) {
      final lembreteDate = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
      return lembreteDate.isAfter(dataInicial.subtract(const Duration(days: 1))) &&
             lembreteDate.isBefore(dataFinal.add(const Duration(days: 1)));
    }).toList();
  }

  static List<LembreteVet> filterByStatus(
    List<LembreteVet> lembretes,
    LembreteStatus status,
  ) {
    final now = DateTime.now();
    
    switch (status) {
      case LembreteStatus.pendente:
        return lembretes.where((lembrete) => !lembrete.concluido).toList();
        
      case LembreteStatus.concluido:
        return lembretes.where((lembrete) => lembrete.concluido).toList();
        
      case LembreteStatus.atrasado:
        return lembretes.where((lembrete) {
          final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
          return !lembrete.concluido && dataHora.isBefore(now);
        }).toList();
        
      case LembreteStatus.hoje:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        return lembretes.where((lembrete) {
          final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
          return dataHora.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
                 dataHora.isBefore(tomorrow);
        }).toList();
        
      case LembreteStatus.futuro:
        return lembretes.where((lembrete) {
          final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
          return !lembrete.concluido && dataHora.isAfter(now);
        }).toList();
        
      default:
        return lembretes;
    }
  }

  static List<LembreteVet> filterByTipo(
    List<LembreteVet> lembretes,
    String tipo,
  ) {
    if (tipo.isEmpty) return lembretes;
    
    return lembretes.where((lembrete) {
      return lembrete.tipo.toLowerCase() == tipo.toLowerCase();
    }).toList();
  }

  static List<LembreteVet> filterBySearchQuery(
    List<LembreteVet> lembretes,
    String query,
  ) {
    if (query.isEmpty) return lembretes;
    
    final lowercaseQuery = query.toLowerCase();
    return lembretes.where((lembrete) {
      return lembrete.titulo.toLowerCase().contains(lowercaseQuery) ||
             lembrete.descricao.toLowerCase().contains(lowercaseQuery) ||
             lembrete.tipo.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<LembreteVet> sortByDate(
    List<LembreteVet> lembretes, {
    bool ascending = false,
  }) {
    final sorted = List<LembreteVet>.from(lembretes);
    sorted.sort((a, b) {
      final comparison = a.dataHora.compareTo(b.dataHora);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<LembreteVet> sortByTitulo(
    List<LembreteVet> lembretes, {
    bool ascending = true,
  }) {
    final sorted = List<LembreteVet>.from(lembretes);
    sorted.sort((a, b) {
      final comparison = a.titulo.compareTo(b.titulo);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<LembreteVet> sortByStatus(
    List<LembreteVet> lembretes, {
    bool concluidosFirst = false,
  }) {
    final sorted = List<LembreteVet>.from(lembretes);
    sorted.sort((a, b) {
      if (concluidosFirst) {
        if (a.concluido && !b.concluido) return -1;
        if (!a.concluido && b.concluido) return 1;
      } else {
        if (!a.concluido && b.concluido) return -1;
        if (a.concluido && !b.concluido) return 1;
      }
      return a.dataHora.compareTo(b.dataHora);
    });
    return sorted;
  }

  static List<LembreteVet> getLembretesUrgentes(
    List<LembreteVet> lembretes, {
    int hoursThreshold = 24,
  }) {
    final now = DateTime.now();
    final threshold = now.add(Duration(hours: hoursThreshold));
    
    return lembretes.where((lembrete) {
      if (lembrete.concluido) return false;
      final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
      return dataHora.isAfter(now) && dataHora.isBefore(threshold);
    }).toList();
  }

  static List<String> getUniqueTipos(List<LembreteVet> lembretes) {
    final tipos = lembretes.map((lembrete) => lembrete.tipo).toSet().toList();
    tipos.sort();
    return tipos;
  }

  static Map<String, int> getLembreteCountByTipo(List<LembreteVet> lembretes) {
    final countMap = <String, int>{};
    for (final lembrete in lembretes) {
      countMap[lembrete.tipo] = (countMap[lembrete.tipo] ?? 0) + 1;
    }
    return countMap;
  }

  static Map<String, int> getLembreteCountByStatus(List<LembreteVet> lembretes) {
    final now = DateTime.now();
    int pendentes = 0;
    int concluidos = 0;
    int atrasados = 0;
    
    for (final lembrete in lembretes) {
      if (lembrete.concluido) {
        concluidos++;
      } else {
        final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
        if (dataHora.isBefore(now)) {
          atrasados++;
        } else {
          pendentes++;
        }
      }
    }
    
    return {
      'pendentes': pendentes,
      'concluidos': concluidos,
      'atrasados': atrasados,
    };
  }
}

enum LembreteStatus {
  todos,
  pendente,
  concluido,
  atrasado,
  hoje,
  futuro,
}
