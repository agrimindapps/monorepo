class BulaDetalhes {
  final String descricao;
  final String? fabricante;
  final List<String>? imagens;

  BulaDetalhes({
    required this.descricao,
    this.fabricante,
    this.imagens,
  });

  factory BulaDetalhes.fromJson(Map<String, dynamic> json) {
    return BulaDetalhes(
      descricao: json['descricao'] ?? '',
      fabricante: json['fabricante'],
      imagens: List<String>.from(json['imagens'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'fabricante': fabricante,
      'imagens': imagens,
    };
  }
}
