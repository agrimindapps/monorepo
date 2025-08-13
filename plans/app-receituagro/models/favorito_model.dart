/// Classe base para modelos de favoritos
abstract class FavoritoModel {
  final String id;
  final String tipo;

  FavoritoModel({
    required this.id,
    required this.tipo,
  });

  /// Converte o modelo para um Map
  Map<String, dynamic> toMap();

  /// Retorna o título principal do favorito para exibição
  String get titulo;

  /// Retorna o subtítulo ou descrição do favorito
  String get descricao;

  /// Rota para navegação ao clicar no favorito
  String get rota;

  /// Argumentos para passagem na navegação
  Map<String, dynamic> get argumentos => {'id': id};

  /// Ícone associado ao favorito
  String get icone;
}

/// Modelo específico para favoritos do tipo defensivo
class FavoritoDefensivoModel extends FavoritoModel {
  final String nomeComum;
  final String ingredienteAtivo;

  FavoritoDefensivoModel({
    required super.id,
    required this.nomeComum,
    required this.ingredienteAtivo,
  }) : super(tipo: 'defensivo');

  @override
  String get titulo => nomeComum;

  @override
  String get descricao => ingredienteAtivo;

  @override
  String get icone => 'assets/imagens/icons/defensivo.png';

  @override
  String get rota => '/defensivos/detalhes';

  @override
  Map<String, dynamic> toMap() {
    return {
      'idReg': id,
      'tipo': tipo,
      'nomeComum': nomeComum,
      'ingredienteAtivo': ingredienteAtivo,
    };
  }

  /// Cria um modelo a partir de um Map
  factory FavoritoDefensivoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoDefensivoModel(
      id: map['idReg'] ?? 0,
      nomeComum: map['nomeComum'] ?? 'Sem nome',
      ingredienteAtivo: map['ingredienteAtivo'] ?? '',
    );
  }
}

/// Modelo específico para favoritos do tipo praga
class FavoritoPragaModel extends FavoritoModel {
  final String nomeComum;
  final String nomeCientifico;

  FavoritoPragaModel({
    required super.id,
    required this.nomeComum,
    required this.nomeCientifico,
  }) : super(tipo: 'praga');

  @override
  String get titulo => nomeComum;

  @override
  String get descricao => nomeCientifico;

  @override
  String get icone => 'assets/imagens/icons/praga.png';

  @override
  String get rota => '/pragas/detalhes';

  @override
  Map<String, dynamic> toMap() {
    return {
      'idReg': id,
      'tipo': tipo,
      'nomeComum': nomeComum,
      'nomeCientifico': nomeCientifico,
    };
  }

  /// Cria um modelo a partir de um Map
  factory FavoritoPragaModel.fromMap(Map<String, dynamic> map) {
    return FavoritoPragaModel(
      id: map['idReg'] ?? 0,
      nomeComum: map['nomeComum'] ?? 'Sem nome',
      nomeCientifico: map['nomeCientifico'] ?? '',
    );
  }
}

/// Modelo específico para favoritos do tipo diagnóstico
class FavoritoDiagnosticoModel extends FavoritoModel {
  final String priNome;
  final String nomeComum;
  final String nomeCientifico;
  final String? cultura;

  FavoritoDiagnosticoModel({
    required super.id,
    required this.priNome,
    required this.nomeComum,
    required this.nomeCientifico,
    this.cultura,
  }) : super(tipo: 'diagnostico');

  @override
  String get titulo =>
      '$priNome ${nomeCientifico.isNotEmpty ? '- $nomeCientifico' : ''}';

  @override
  String get descricao =>
      '$nomeComum ${cultura != null && cultura!.isNotEmpty ? '- $cultura' : ''}';

  @override
  String get icone => 'assets/imagens/icons/diagnostico.png';

  @override
  String get rota => '/diagnostico';

  @override
  Map<String, dynamic> toMap() {
    return {
      'idReg': id,
      'tipo': tipo,
      'priNome': priNome,
      'nomeComum': nomeComum,
      'nomeCientifico': nomeCientifico,
      'cultura': cultura,
    };
  }

  /// Cria um modelo a partir de um Map
  factory FavoritoDiagnosticoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoDiagnosticoModel(
      id: map['idReg'] ?? 0,
      priNome: map['priNome'] ?? '',
      nomeComum: map['nomeComum'] ?? 'Sem nome',
      nomeCientifico: map['nomeCientifico'] ?? '',
      cultura: map['cultura'],
    );
  }
}
