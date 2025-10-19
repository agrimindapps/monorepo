class Termo {
  bool status;
  String id;
  String termo;
  String descricao;
  String categoria;
  bool visible;
  bool isComment;
  bool favorito;

  Termo({
    this.status = true,
    required this.id,
    required this.termo,
    required this.descricao,
    required this.categoria,
    this.visible = false,
    this.isComment = false,
    this.favorito = false,
  });

  // Método para desserializar um objeto JSON em uma instância de Termo
  factory Termo.fromJson(Map<String, dynamic> json) {
    return Termo(
      status: json['status'],
      id: json['IdReg'],
      termo: json['termo'],
      descricao: json['descricao'],
      categoria: json['categoria'],
      visible: json['visible'],
      isComment: json['isComment'],
      favorito: json['favorito'],
    );
  }

  // Método para serializar uma instância de Termo em um objeto JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'IdReg': id,
      'termo': termo,
      'descricao': descricao,
      'categoria': categoria,
      'visible': visible,
      'isComment': isComment,
      'favorito': favorito,
    };
  }

  @override
  String toString() {
    return 'Termo{termo: $termo, descricao: $descricao, categoria: $categoria, visible: $visible, isComment: $isComment, favorito: $favorito}';
  }
}
