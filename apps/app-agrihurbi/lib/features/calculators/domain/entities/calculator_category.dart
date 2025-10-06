enum CalculatorCategory {
  irrigation('Irrigação', 'Calculadoras para manejo de irrigação e recursos hídricos'),
  nutrition('Nutrição', 'Calculadoras para adubação e correção do solo'),
  livestock('Pecuária', 'Calculadoras para manejo pecuário'),
  yield('Rendimento', 'Calculadoras para estimativa de produtividade'),
  machinery('Maquinário', 'Calculadoras para operações mecanizadas'),
  crops('Culturas', 'Calculadoras para manejo de culturas'),
  management('Manejo', 'Calculadoras para controle fitossanitário');

  const CalculatorCategory(this.displayName, this.description);

  final String displayName;
  final String description;

  static CalculatorCategory fromString(String value) {
    return CalculatorCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => CalculatorCategory.management,
    );
  }
}
