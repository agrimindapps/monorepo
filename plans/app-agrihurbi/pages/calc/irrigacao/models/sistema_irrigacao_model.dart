class SistemaIrrigacaoInfo {
  final String nome;
  final double vazaoPadrao;
  final double espacamentoPadrao;
  final double eficienciaPadrao;

  SistemaIrrigacaoInfo({
    required this.nome,
    required this.vazaoPadrao,
    required this.espacamentoPadrao,
    required this.eficienciaPadrao,
  });

  static List<SistemaIrrigacaoInfo> get sistemasDisponiveis => [
        SistemaIrrigacaoInfo(
          nome: 'Gotejamento',
          vazaoPadrao: 4.0, // L/h por gotejador
          espacamentoPadrao: 0.5, // m entre gotejadores
          eficienciaPadrao: 0.90, // 90% de eficiência
        ),
        SistemaIrrigacaoInfo(
          nome: 'Microaspersão',
          vazaoPadrao: 70.0, // L/h por microaspersor
          espacamentoPadrao: 4.0, // m entre microaspersores
          eficienciaPadrao: 0.85, // 85% de eficiência
        ),
        SistemaIrrigacaoInfo(
          nome: 'Aspersão convencional',
          vazaoPadrao: 1000.0, // L/h por aspersor
          espacamentoPadrao: 12.0, // m entre aspersores
          eficienciaPadrao: 0.75, // 75% de eficiência
        ),
        SistemaIrrigacaoInfo(
          nome: 'Pivô central',
          vazaoPadrao: 2000.0, // L/h por aspersor
          espacamentoPadrao: 6.0, // m entre aspersores
          eficienciaPadrao: 0.80, // 80% de eficiência
        ),
        SistemaIrrigacaoInfo(
          nome: 'Sulcos',
          vazaoPadrao: 3.0, // L/s por sulco
          espacamentoPadrao: 1.0, // m entre sulcos
          eficienciaPadrao: 0.60, // 60% de eficiência
        ),
        SistemaIrrigacaoInfo(
          nome: 'Inundação',
          vazaoPadrao: 5.0, // L/s por faixa
          espacamentoPadrao: 2.0, // m entre faixas
          eficienciaPadrao: 0.50, // 50% de eficiência
        ),
      ];
}
