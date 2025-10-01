class FavoritoDiagnosticoModel {
  final int id;
  final String idReg;
  final String nome;
  final String? descricao;
  final String? cultura;
  final String? categoria;
  final String? recomendacoes;
  final String? imagem;
  final DateTime dataCriacao;

  const FavoritoDiagnosticoModel({
    required this.id,
    required this.idReg,
    required this.nome,
    this.descricao,
    this.cultura,
    this.categoria,
    this.recomendacoes,
    this.imagem,
    required this.dataCriacao,
  });

  factory FavoritoDiagnosticoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoDiagnosticoModel(
      id: map['id'] as int? ?? 0,
      idReg: map['idReg']?.toString() ?? '',
      nome: map['nome']?.toString() ?? 'Diagnóstico desconhecido',
      descricao: map['descricao']?.toString(),
      cultura: map['cultura']?.toString(),
      categoria: map['categoria']?.toString(),
      recomendacoes: map['recomendacoes']?.toString(),
      imagem: map['imagem']?.toString(),
      dataCriacao: DateTime.tryParse(map['dataCriacao']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get displayName => nome;
  String get displayDescription => descricao ?? 'Sem descrição disponível';
  String get displayCultura => cultura ?? 'Cultura não especificada';
  String get displayCategoria => categoria ?? 'Categoria não informada';
  String get displayRecomendacoes => recomendacoes ?? 'Recomendações não disponíveis';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritoDiagnosticoModel &&
        other.id == id &&
        other.idReg == idReg;
  }

  @override
  int get hashCode => id.hashCode ^ idReg.hashCode;

  @override
  String toString() {
    return 'FavoritoDiagnosticoModel(id: $id, idReg: $idReg, nome: $nome)';
  }
}