enum DefensivosCategory {
  defensivos('defensivos'),
  fabricantes('fabricantes'),
  classeAgronomica('classeAgronomica'),
  ingredienteAtivo('ingredienteAtivo'),
  modoAcao('modoAcao');

  const DefensivosCategory(this.value);
  final String value;

  static DefensivosCategory fromString(String value) {
    return DefensivosCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => DefensivosCategory.defensivos,
    );
  }

  String get title {
    switch (this) {
      case DefensivosCategory.defensivos:
        return 'Defensivos';
      case DefensivosCategory.fabricantes:
        return 'Fabricantes';
      case DefensivosCategory.classeAgronomica:
        return 'Classe Agronômica';
      case DefensivosCategory.ingredienteAtivo:
        return 'Ingrediente Ativo';
      case DefensivosCategory.modoAcao:
        return 'Modo de Ação';
    }
  }

  String get label {
    switch (this) {
      case DefensivosCategory.fabricantes:
        return 'Fabricante';
      case DefensivosCategory.classeAgronomica:
        return 'Classe';
      case DefensivosCategory.ingredienteAtivo:
        return 'Ingrediente';
      case DefensivosCategory.modoAcao:
        return 'Modo de Ação';
      default:
        return '';
    }
  }
}