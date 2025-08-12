enum TipoCombustivel {
  gasolina('Gasolina', 'L'),
  etanol('Etanol', 'L'),
  diesel('Diesel', 'L'),
  dieselS10('Diesel S-10', 'L'),
  gnv('GNV', 'm³'),
  eletrico('Energia Elétrica', 'kWh'),
  biCombustivel('Flex (Gasolina/Etanol)', 'L');

  final String descricao;
  final String unidade;

  const TipoCombustivel(this.descricao, this.unidade);

  static TipoCombustivel fromString(String value) {
    return TipoCombustivel.values.firstWhere(
      (tipo) => tipo.name == value,
      orElse: () => TipoCombustivel.biCombustivel,
    );
  }

  static List<String> getDescricoes() {
    return TipoCombustivel.values.map((tipo) => tipo.descricao).toList();
  }

  static String getUnidade(String tipo) {
    return TipoCombustivel.values
        .firstWhere(
          (t) => t.name == tipo,
          orElse: () => TipoCombustivel.biCombustivel,
        )
        .unidade;
  }
}
