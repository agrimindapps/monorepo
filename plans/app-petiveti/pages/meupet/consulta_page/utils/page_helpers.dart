// Project imports:
import '../../../../utils/consulta/consulta_core.dart';
import '../../../../utils/consulta/consulta_date_utils.dart';

// Placeholder for ConsultaVet model - update this import when the model is available
class ConsultaVet {
  final int dataConsulta;
  final String veterinario;
  final String motivo;
  final String diagnostico;
  final String? observacoes;
  
  ConsultaVet({
    required this.dataConsulta,
    required this.veterinario,
    required this.motivo,
    required this.diagnostico,
    this.observacoes,
  });
}

class ConsultaPageHelpers {
  static String formatarData(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return ConsultaDateUtils.formatData(date);
  }

  static String formatarDataAtual() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  static List<String> gerarListaMesesDisponiveis(List<ConsultaVet> consultas) {
    if (consultas.isEmpty) {
      return [formatarDataAtual()];
    }

    final sortedConsultas = List<ConsultaVet>.from(consultas)
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.first.dataConsulta);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.last.dataConsulta);

    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = '${months[currentDate.month - 1]} ${currentDate.year.toString().substring(2)}';
      meses.add(mesFormatado);
      
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    final mesAtual = formatarDataAtual();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList();
  }

  static String formatarPeriodoConsultas(List<ConsultaVet> consultas) {
    if (consultas.isEmpty) {
      return formatarDataAtual();
    }

    final sortedConsultas = List<ConsultaVet>.from(consultas)
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.first.dataConsulta);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.last.dataConsulta);

    final mesInicial = _getFormattedMonth(dataInicial);
    final mesFinal = _getFormattedMonth(dataFinal);

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  static String _getFormattedMonth(DateTime date) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[date.month - 1]} ${date.year.toString().substring(2)}';
  }

  static List<ConsultaVet> filtrarConsultasPorPeriodo(
    List<ConsultaVet> consultas,
    String periodo,
  ) {
    if (periodo == 'Todos') return consultas;

    final now = DateTime.now();
    final startOfPeriod = _getStartOfPeriod(periodo, now);
    final endOfPeriod = _getEndOfPeriod(periodo, now);

    return consultas.where((consulta) {
      final data = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return data.isAfter(startOfPeriod.subtract(const Duration(days: 1))) &&
             data.isBefore(endOfPeriod.add(const Duration(days: 1)));
    }).toList();
  }

  static DateTime _getStartOfPeriod(String periodo, DateTime referenceDate) {
    switch (periodo) {
      case 'Hoje':
        return ConsultaDateUtils.getStartOfDay(referenceDate);
      case 'Esta semana':
        return ConsultaDateUtils.getStartOfWeek(referenceDate);
      case 'Este mês':
        return ConsultaDateUtils.getStartOfMonth(referenceDate);
      case 'Este ano':
        return ConsultaDateUtils.getStartOfYear(referenceDate);
      default:
        return ConsultaDateUtils.getStartOfDay(referenceDate);
    }
  }

  static DateTime _getEndOfPeriod(String periodo, DateTime referenceDate) {
    switch (periodo) {
      case 'Hoje':
        return ConsultaDateUtils.getEndOfDay(referenceDate);
      case 'Esta semana':
        return ConsultaDateUtils.getEndOfWeek(referenceDate);
      case 'Este mês':
        return ConsultaDateUtils.getEndOfMonth(referenceDate);
      case 'Este ano':
        return ConsultaDateUtils.getEndOfYear(referenceDate);
      default:
        return ConsultaDateUtils.getEndOfDay(referenceDate);
    }
  }

  static List<String> getOpcoesFiltroPeriodo() {
    return [
      'Todos',
      'Hoje',
      'Esta semana',
      'Este mês',
      'Este ano',
    ];
  }

  static List<ConsultaVet> ordenarConsultas(
    List<ConsultaVet> consultas,
    String ordenacao,
  ) {
    final List<ConsultaVet> sorted = List.from(consultas);

    switch (ordenacao) {
      case 'Data (mais recente)':
        sorted.sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));
        break;
      case 'Data (mais antiga)':
        sorted.sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));
        break;
      case 'Veterinário (A-Z)':
        sorted.sort((a, b) => a.veterinario.compareTo(b.veterinario));
        break;
      case 'Veterinário (Z-A)':
        sorted.sort((a, b) => b.veterinario.compareTo(a.veterinario));
        break;
      case 'Motivo (A-Z)':
        sorted.sort((a, b) => a.motivo.compareTo(b.motivo));
        break;
      case 'Motivo (Z-A)':
        sorted.sort((a, b) => b.motivo.compareTo(a.motivo));
        break;
      case 'Prioridade':
        sorted.sort((a, b) {
          final priorityA = ConsultaCore.calculatePriority(a.motivo);
          final priorityB = ConsultaCore.calculatePriority(b.motivo);
          return priorityB.compareTo(priorityA); // Maior prioridade primeiro
        });
        break;
      default:
        sorted.sort((a, b) => b.dataConsulta.compareTo(a.dataConsulta));
    }

    return sorted;
  }

  static List<String> getOpcoesOrdenacao() {
    return [
      'Data (mais recente)',
      'Data (mais antiga)',
      'Veterinário (A-Z)',
      'Veterinário (Z-A)',
      'Motivo (A-Z)',
      'Motivo (Z-A)',
      'Prioridade',
    ];
  }

  static Map<String, dynamic> calcularEstatisticas(List<ConsultaVet> consultas) {
    if (consultas.isEmpty) {
      return {
        'total': 0,
        'porMotivo': <String, int>{},
        'porVeterinario': <String, int>{},
        'porMes': <String, int>{},
        'porPrioridade': <String, int>{},
        'seguimentoNecessario': 0,
      };
    }

    // Agrupar por motivo
    final porMotivo = <String, int>{};
    for (final consulta in consultas) {
      porMotivo[consulta.motivo] = (porMotivo[consulta.motivo] ?? 0) + 1;
    }

    // Agrupar por veterinário
    final porVeterinario = <String, int>{};
    for (final consulta in consultas) {
      porVeterinario[consulta.veterinario] = (porVeterinario[consulta.veterinario] ?? 0) + 1;
    }

    // Agrupar por mês
    final porMes = <String, int>{};
    for (final consulta in consultas) {
      final data = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      final mesChave = _getFormattedMonth(data);
      porMes[mesChave] = (porMes[mesChave] ?? 0) + 1;
    }

    // Agrupar por prioridade
    final porPrioridade = <String, int>{};
    int seguimentoNecessario = 0;
    
    for (final consulta in consultas) {
      final priority = ConsultaCore.calculatePriority(consulta.motivo);
      final priorityText = ConsultaCore.getPriorityText(priority);
      porPrioridade[priorityText] = (porPrioridade[priorityText] ?? 0) + 1;
      
      if (ConsultaCore.requiresFollowUp(consulta.motivo)) {
        seguimentoNecessario++;
      }
    }

    return {
      'total': consultas.length,
      'porMotivo': porMotivo,
      'porVeterinario': porVeterinario,
      'porMes': porMes,
      'porPrioridade': porPrioridade,
      'seguimentoNecessario': seguimentoNecessario,
    };
  }

  static String formatarEstatistica(String tipo, dynamic valor) {
    switch (tipo) {
      case 'total':
      case 'seguimentoNecessario':
        return '${valor as int} consulta${valor > 1 ? 's' : ''}';
      default:
        return valor.toString();
    }
  }

  static List<ConsultaVet> buscarConsultas(
    List<ConsultaVet> consultas,
    String termoBusca,
  ) {
    if (termoBusca.trim().isEmpty) return consultas;

    final termo = termoBusca.toLowerCase().trim();
    
    return consultas.where((consulta) {
      return consulta.motivo.toLowerCase().contains(termo) ||
             consulta.veterinario.toLowerCase().contains(termo) ||
             consulta.diagnostico.toLowerCase().contains(termo) ||
             (consulta.observacoes?.toLowerCase().contains(termo) ?? false);
    }).toList();
  }

  static List<ConsultaVet> filtrarPorMotivo(
    List<ConsultaVet> consultas,
    String? motivoFiltro,
  ) {
    if (motivoFiltro == null || motivoFiltro == 'Todos') return consultas;
    
    return consultas.where((consulta) => consulta.motivo == motivoFiltro).toList();
  }

  static List<ConsultaVet> filtrarPorVeterinario(
    List<ConsultaVet> consultas,
    String? veterinarioFiltro,
  ) {
    if (veterinarioFiltro == null || veterinarioFiltro == 'Todos') return consultas;
    
    return consultas.where((consulta) => consulta.veterinario == veterinarioFiltro).toList();
  }

  static List<ConsultaVet> filtrarPorPrioridade(
    List<ConsultaVet> consultas,
    int? prioridadeMinima,
  ) {
    if (prioridadeMinima == null) return consultas;
    
    return consultas.where((consulta) {
      final priority = ConsultaCore.calculatePriority(consulta.motivo);
      return priority >= prioridadeMinima;
    }).toList();
  }

  static List<String> getMotivosDisponiveis(List<ConsultaVet> consultas) {
    final motivos = consultas.map((c) => c.motivo).toSet().toList();
    motivos.sort();
    return ['Todos', ...motivos];
  }

  static List<String> getVeterinariosDisponiveis(List<ConsultaVet> consultas) {
    final veterinarios = consultas.map((c) => c.veterinario).toSet().toList();
    veterinarios.sort();
    return ['Todos', ...veterinarios];
  }

  static List<ConsultaVet> getConsultasRecentes(List<ConsultaVet> consultas, {int dias = 30}) {
    final agora = DateTime.now();
    final limiteData = agora.subtract(Duration(days: dias));
    
    return consultas.where((consulta) {
      final dataConsulta = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return dataConsulta.isAfter(limiteData);
    }).toList();
  }

  static List<ConsultaVet> getConsultasQueRequeremSeguimento(List<ConsultaVet> consultas) {
    return consultas.where((consulta) {
      return ConsultaCore.requiresFollowUp(consulta.motivo);
    }).toList();
  }

  static Map<String, List<ConsultaVet>> agruparPorVeterinario(List<ConsultaVet> consultas) {
    final grupos = <String, List<ConsultaVet>>{};
    
    for (final consulta in consultas) {
      if (!grupos.containsKey(consulta.veterinario)) {
        grupos[consulta.veterinario] = [];
      }
      grupos[consulta.veterinario]!.add(consulta);
    }
    
    return grupos;
  }

  static Map<String, List<ConsultaVet>> agruparPorMotivo(List<ConsultaVet> consultas) {
    final grupos = <String, List<ConsultaVet>>{};
    
    for (final consulta in consultas) {
      if (!grupos.containsKey(consulta.motivo)) {
        grupos[consulta.motivo] = [];
      }
      grupos[consulta.motivo]!.add(consulta);
    }
    
    return grupos;
  }
}
