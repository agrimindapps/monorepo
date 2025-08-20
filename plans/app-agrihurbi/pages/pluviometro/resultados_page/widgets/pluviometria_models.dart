// Modelos de dados para visualização de pluviometria

/// Representa um dado de pluviometria para visualização em gráficos
class DadoPluviometrico {
  final String label;
  final double valor;

  DadoPluviometrico(this.label, this.valor);
}

/// Representa dados comparativos para visualização em gráficos
class DadoComparativo {
  final String label;
  final double valorAtual;
  final double valorAnterior;

  DadoComparativo(this.label, this.valorAtual, this.valorAnterior);
}

/// Estatísticas calculadas para pluviometria
class EstatisticasPluviometria {
  final double total;
  final double media;
  final double maximo;
  final int diasComChuva;

  EstatisticasPluviometria({
    this.total = 0.0,
    this.media = 0.0,
    this.maximo = 0.0,
    this.diasComChuva = 0,
  });

  /// Formata o valor para exibição
  Map<String, dynamic> toDisplayMap() {
    return {
      'total': total,
      'media': media,
      'maximo': maximo,
      'diasChuva': diasComChuva,
    };
  }
}

/// Lista de meses abreviados
const List<String> mesesAbreviados = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez'
];

/// Lista de meses completos
const List<String> mesesCompletos = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro'
];

/// Obtém o nome do mês a partir do número (1-12)
String obterNomeMes(int mes) {
  if (mes < 1 || mes > 12) return '';
  return mesesCompletos[mes - 1];
}
