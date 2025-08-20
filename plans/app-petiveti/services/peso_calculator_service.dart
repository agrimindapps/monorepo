// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/17_peso_model.dart';
import '../utils/string_utils.dart' as string_utils;

/// Service centralizado para cálculos estatísticos de peso
/// Responsável por toda lógica de cálculo, análise e formatação de dados de peso
class PesoCalculatorService {
  static final PesoCalculatorService _instance = PesoCalculatorService._internal();
  factory PesoCalculatorService() => _instance;
  PesoCalculatorService._internal();

  /// Calcula a variação absoluta de peso entre o primeiro e último registro
  double calcularVariacaoPeso(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return 0.0;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final pesoInicial = sortedPesos.first.peso;
    final pesoFinal = sortedPesos.last.peso;
    
    return pesoFinal - pesoInicial;
  }

  /// Calcula a variação percentual de peso
  double calcularPercentualVariacao(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return 0.0;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final pesoInicial = sortedPesos.first.peso;
    final pesoFinal = sortedPesos.last.peso;
    
    if (pesoInicial == 0) return 0.0;
    
    return ((pesoFinal - pesoInicial) / pesoInicial) * 100;
  }

  /// Calcula o peso atual (mais recente)
  double calcularPesoAtual(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0.0;
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    return sortedPesos.first.peso;
  }

  /// Calcula a média de todos os pesos
  double calcularMediaPesos(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0.0;
    final total = pesos.fold<double>(0.0, (sum, peso) => sum + peso.peso);
    return total / pesos.length;
  }

  /// Encontra o peso mínimo
  double calcularPesoMinimo(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0;
    return pesos.map((p) => p.peso).reduce((a, b) => a < b ? a : b);
  }

  /// Encontra o peso máximo
  double calcularPesoMaximo(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return 0;
    return pesos.map((p) => p.peso).reduce((a, b) => a > b ? a : b);
  }

  /// Determina se o peso está aumentando
  bool isPesoAumentando(List<PesoAnimal> pesos) {
    return calcularVariacaoPeso(pesos) > 0;
  }

  /// Determina se o peso está diminuindo
  bool isPesoDiminuindo(List<PesoAnimal> pesos) {
    return calcularVariacaoPeso(pesos) < 0;
  }

  /// Determina se o peso está estável
  bool isPesoEstavel(List<PesoAnimal> pesos) {
    return calcularVariacaoPeso(pesos) == 0;
  }

  /// Gera dados formatados para gráfico
  List<Map<String, dynamic>> gerarDadosGrafico(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return [];
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    return sortedPesos.map((peso) => {
      'data': peso.dataPesagem,
      'peso': peso.peso,
    }).toList();
  }

  /// Filtra pesos por intervalo de datas
  List<PesoAnimal> filtrarPorData(
    List<PesoAnimal> pesos, 
    int? dataInicial, 
    int? dataFinal
  ) {
    if (dataInicial == null || dataFinal == null) return pesos;
    
    return pesos.where((peso) {
      final pesoDate = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      final filterStart = DateTime.fromMillisecondsSinceEpoch(dataInicial);
      final filterEnd = DateTime.fromMillisecondsSinceEpoch(dataFinal);
      
      return pesoDate.isAfter(filterStart.subtract(const Duration(days: 1))) &&
             pesoDate.isBefore(filterEnd.add(const Duration(days: 1)));
    }).toList();
  }

  /// Formata data para string no padrão brasileiro
  String formatarDataParaString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formata mês atual para exibição
  String formatarMesAtual() {
    final now = DateTime.now();
    return string_utils.StringExtension(DateFormat('MMM yy', 'pt_BR').format(now)).capitalize();
  }

  /// Gera lista de meses baseada nos registros de peso existentes
  List<String> gerarListaMesesDisponiveis(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      // Se não há registros, retorna o mês atual
      return [formatarMesAtual()];
    }

    // Ordena pesos por data
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    // Obtém data mais antiga e mais recente
    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedPesos.first.dataPesagem);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedPesos.last.dataPesagem);

    // Gera lista de meses entre as datas
    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = string_utils.StringExtension(
        DateFormat('MMM yy', 'pt_BR').format(currentDate)
      ).capitalize();
      meses.add(mesFormatado);
      
      // Avança para o próximo mês
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Se o mês atual não está na lista, adiciona
    final mesAtual = formatarMesAtual();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList(); // Mais recente primeiro
  }

  /// Obtém o período de registros (mês mais antigo ao mais recente)
  String formatarPeriodoRegistros(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      return formatarMesAtual();
    }

    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedPesos.first.dataPesagem);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedPesos.last.dataPesagem);

    final mesInicial = string_utils.StringExtension(
      DateFormat('MMM yy', 'pt_BR').format(dataInicial)
    ).capitalize();
    
    final mesFinal = string_utils.StringExtension(
      DateFormat('MMM yy', 'pt_BR').format(dataFinal)
    ).capitalize();

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  /// Gera dados CSV para exportação
  String gerarDadosCSV(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) return '';
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    const csvHeader = 'Data,Peso (kg),Observações\n';
    final csvRows = sortedPesos.map((peso) {
      final formattedDate = formatarDataParaString(peso.dataPesagem);
      final observacoes = _escapeCsvField(peso.observacoes ?? '');
      return '$formattedDate,${peso.peso},$observacoes';
    }).join('\n');
    
    return csvHeader + csvRows;
  }

  /// Escapa caracteres especiais para CSV
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Gera subtítulo com contagem de registros
  String gerarSubtitulo(List<PesoAnimal> pesos) {
    return '${pesos.length} registros';
  }

  /// Calcula tendência de peso com base nos últimos registros
  TendenciaPeso calcularTendencia(List<PesoAnimal> pesos, {int ultimosRegistros = 5}) {
    if (pesos.length < 2) return TendenciaPeso.insuficiente;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    
    final pesosRecentes = sortedPesos.take(ultimosRegistros).toList();
    if (pesosRecentes.length < 2) return TendenciaPeso.insuficiente;
    
    final pesoInicial = pesosRecentes.last.peso;
    final pesoFinal = pesosRecentes.first.peso;
    final diferenca = pesoFinal - pesoInicial;
    
    const limiteEstabilidade = 0.1; // 100g de tolerância
    
    if (diferenca > limiteEstabilidade) {
      return TendenciaPeso.crescendo;
    } else if (diferenca < -limiteEstabilidade) {
      return TendenciaPeso.decrescendo;
    } else {
      return TendenciaPeso.estavel;
    }
  }

  /// Detecta outliers nos dados de peso
  List<PesoAnimal> detectarOutliers(List<PesoAnimal> pesos) {
    if (pesos.length < 4) return [];
    
    final pesosValores = pesos.map((p) => p.peso).toList()..sort();
    final q1Index = (pesosValores.length * 0.25).floor();
    final q3Index = (pesosValores.length * 0.75).floor();
    
    final q1 = pesosValores[q1Index];
    final q3 = pesosValores[q3Index];
    final iqr = q3 - q1;
    
    final lowerBound = q1 - (1.5 * iqr);
    final upperBound = q3 + (1.5 * iqr);
    
    return pesos.where((peso) => 
      peso.peso < lowerBound || peso.peso > upperBound
    ).toList();
  }

  /// Calcula taxa de variação semanal média
  double calcularTaxaVariacaoSemanal(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return 0.0;
    
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));
    
    final primeiroRegistro = sortedPesos.first;
    final ultimoRegistro = sortedPesos.last;
    
    final diferencaPeso = ultimoRegistro.peso - primeiroRegistro.peso;
    final diferencaTempo = DateTime.fromMillisecondsSinceEpoch(ultimoRegistro.dataPesagem)
      .difference(DateTime.fromMillisecondsSinceEpoch(primeiroRegistro.dataPesagem));
    
    final semanas = diferencaTempo.inDays / 7.0;
    
    return semanas > 0 ? diferencaPeso / semanas : 0.0;
  }
}

/// Enum para tendências de peso
enum TendenciaPeso {
  crescendo,
  decrescendo,
  estavel,
  insuficiente
}

extension TendenciaPesoExtension on TendenciaPeso {
  String get descricao {
    switch (this) {
      case TendenciaPeso.crescendo:
        return 'Crescendo';
      case TendenciaPeso.decrescendo:
        return 'Decrescendo';
      case TendenciaPeso.estavel:
        return 'Estável';
      case TendenciaPeso.insuficiente:
        return 'Dados insuficientes';
    }
  }
  
  String get emoji {
    switch (this) {
      case TendenciaPeso.crescendo:
        return '📈';
      case TendenciaPeso.decrescendo:
        return '📉';
      case TendenciaPeso.estavel:
        return '➡️';
      case TendenciaPeso.insuficiente:
        return '❓';
    }
  }
}
