class BulaModel {
  String? id;
  String descricao;
  String? miniatura;
  List<String>? imagens;

  BulaModel({
    this.id,
    required this.descricao,
    this.miniatura,
    this.imagens,
  });

  factory BulaModel.empty() {
    return BulaModel(
      descricao: '',
      imagens: [],
    );
  }

  factory BulaModel.fromJson(Map<String, dynamic> json) {
    return BulaModel(
      id: json['id'] as String?,
      descricao: json['descricao'] as String,
      miniatura: json['miniatura'] as String?,
      imagens: (json['imagens'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'miniatura': miniatura,
      'imagens': imagens,
    };
  }
}
