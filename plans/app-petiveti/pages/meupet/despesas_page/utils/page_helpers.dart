// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../utils/despesas_utils.dart';

class DespesasPageHelpers {
  static String formatarData(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DespesasUtils.formatData(date);
  }

  static String formatarDataAtual() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  static List<String> gerarListaMesesDisponiveis(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return [formatarDataAtual()];
    }

    final sortedDespesas = List<DespesaVet>.from(despesas)
      ..sort((a, b) => a.dataDespesa.compareTo(b.dataDespesa));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.first.dataDespesa);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.last.dataDespesa);

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

  static String formatarPeriodoDespesas(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return formatarDataAtual();
    }

    final sortedDespesas = List<DespesaVet>.from(despesas)
      ..sort((a, b) => a.dataDespesa.compareTo(b.dataDespesa));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.first.dataDespesa);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.last.dataDespesa);

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

  static List<DespesaVet> filtrarDespesasPorPeriodo(
    List<DespesaVet> despesas,
    String periodo,
  ) {
    if (periodo == 'Todos') return despesas;

    final now = DateTime.now();
    final startOfPeriod = _getStartOfPeriod(periodo, now);
    final endOfPeriod = _getEndOfPeriod(periodo, now);

    return despesas.where((despesa) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      return data.isAfter(startOfPeriod.subtract(const Duration(days: 1))) &&
             data.isBefore(endOfPeriod.add(const Duration(days: 1)));
    }).toList();
  }

  static DateTime _getStartOfPeriod(String periodo, DateTime referenceDate) {
    switch (periodo) {
      case 'Hoje':
        return DespesasUtils.getStartOfDay(referenceDate);
      case 'Esta semana':
        return DespesasDateUtils.getStartOfWeek(referenceDate);
      case 'Este mês':
        return DespesasUtils.getStartOfMonth(referenceDate);
      case 'Este ano':
        return DespesasDateUtils.getStartOfYear(referenceDate);
      default:
        return DespesasUtils.getStartOfDay(referenceDate);
    }
  }

  static DateTime _getEndOfPeriod(String periodo, DateTime referenceDate) {
    switch (periodo) {
      case 'Hoje':
        return DespesasUtils.getEndOfDay(referenceDate);
      case 'Esta semana':
        return DespesasDateUtils.getEndOfWeek(referenceDate);
      case 'Este mês':
        return DespesasUtils.getEndOfMonth(referenceDate);
      case 'Este ano':
        return DespesasDateUtils.getEndOfYear(referenceDate);
      default:
        return DespesasUtils.getEndOfDay(referenceDate);
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

  static List<DespesaVet> ordenarDespesas(
    List<DespesaVet> despesas,
    String ordenacao,
  ) {
    final List<DespesaVet> sorted = List.from(despesas);

    switch (ordenacao) {
      case 'Data (mais recente)':
        sorted.sort((a, b) => b.dataDespesa.compareTo(a.dataDespesa));
        break;
      case 'Data (mais antiga)':
        sorted.sort((a, b) => a.dataDespesa.compareTo(b.dataDespesa));
        break;
      case 'Valor (maior)':
        sorted.sort((a, b) => b.valor.compareTo(a.valor));
        break;
      case 'Valor (menor)':
        sorted.sort((a, b) => a.valor.compareTo(b.valor));
        break;
      case 'Tipo (A-Z)':
        sorted.sort((a, b) => a.tipo.compareTo(b.tipo));
        break;
      case 'Tipo (Z-A)':
        sorted.sort((a, b) => b.tipo.compareTo(a.tipo));
        break;
      default:
        sorted.sort((a, b) => b.dataDespesa.compareTo(a.dataDespesa));
    }

    return sorted;
  }

  static List<String> getOpcoesOrdenacao() {
    return [
      'Data (mais recente)',
      'Data (mais antiga)',
      'Valor (maior)',
      'Valor (menor)',
      'Tipo (A-Z)',
      'Tipo (Z-A)',
    ];
  }

  static Map<String, dynamic> calcularEstatisticas(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return {
        'total': 0.0,
        'media': 0.0,
        'maior': 0.0,
        'menor': 0.0,
        'quantidade': 0,
        'porTipo': <String, double>{},
        'porMes': <String, double>{},
      };
    }

    final valores = despesas.map((d) => d.valor).toList();
    final total = valores.reduce((a, b) => a + b);
    final media = total / valores.length;
    final maior = valores.reduce((a, b) => a > b ? a : b);
    final menor = valores.reduce((a, b) => a < b ? a : b);

    // Agrupar por tipo
    final porTipo = <String, double>{};
    for (final despesa in despesas) {
      porTipo[despesa.tipo] = (porTipo[despesa.tipo] ?? 0) + despesa.valor;
    }

    // Agrupar por mês
    final porMes = <String, double>{};
    for (final despesa in despesas) {
      final data = DateTime.fromMillisecondsSinceEpoch(despesa.dataDespesa);
      final mesChave = _getFormattedMonth(data);
      porMes[mesChave] = (porMes[mesChave] ?? 0) + despesa.valor;
    }

    return {
      'total': total,
      'media': media,
      'maior': maior,
      'menor': menor,
      'quantidade': despesas.length,
      'porTipo': porTipo,
      'porMes': porMes,
    };
  }

  static String formatarEstatistica(String tipo, dynamic valor) {
    switch (tipo) {
      case 'total':
      case 'media':
      case 'maior':
      case 'menor':
        return DespesasDisplayUtils.formatValor(valor as double);
      case 'quantidade':
        return '${valor as int} despesa${valor > 1 ? 's' : ''}';
      default:
        return valor.toString();
    }
  }

  static List<DespesaVet> buscarDespesas(
    List<DespesaVet> despesas,
    String termoBusca,
  ) {
    if (termoBusca.trim().isEmpty) return despesas;

    final termo = termoBusca.toLowerCase().trim();
    
    return despesas.where((despesa) {
      return despesa.descricao.toLowerCase().contains(termo) ||
             despesa.tipo.toLowerCase().contains(termo);
    }).toList();
  }

  static List<DespesaVet> filtrarPorTipo(
    List<DespesaVet> despesas,
    String? tipoFiltro,
  ) {
    if (tipoFiltro == null || tipoFiltro == 'Todos') return despesas;
    
    return despesas.where((despesa) => despesa.tipo == tipoFiltro).toList();
  }

  static List<DespesaVet> filtrarPorValor(
    List<DespesaVet> despesas,
    double? valorMinimo,
    double? valorMaximo,
  ) {
    return despesas.where((despesa) {
      final valor = despesa.valor;
      
      if (valorMinimo != null && valor < valorMinimo) return false;
      if (valorMaximo != null && valor > valorMaximo) return false;
      
      return true;
    }).toList();
  }

  static List<String> getTiposDisponiveis(List<DespesaVet> despesas) {
    final tipos = despesas.map((d) => d.tipo).toSet().toList();
    tipos.sort();
    return ['Todos', ...tipos];
  }
}
