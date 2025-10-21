class Ingrediente {
  final String quantidade;
  final String unidade;
  final String nome;
  final bool opcional;

  Ingrediente({
    required this.quantidade,
    required this.unidade,
    required this.nome,
    this.opcional = false,
  });

  Ingrediente.fromJson(Map<String, dynamic> json)
      : quantidade = json['quantidade'] as String,
        unidade = json['unidade'] as String,
        nome = json['nome'] as String,
        opcional = json['opcional'] as bool;

  @override
  String toString() {
    return '$quantidade $unidade de $nome ${opcional ? '(opcional)' : ''}';
  }
}