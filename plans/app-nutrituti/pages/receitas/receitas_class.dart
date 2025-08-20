// Project imports:
import 'receitas_ingredientes_class.dart';
import 'receitas_passos_class.dart';

// Classe para representar a receita fit
class ReceitaFit {
  final String nome;
  final String descricao;
  final List<Ingrediente> ingredientes;
  final List<Passo> modoPreparo;
  final String tempoPreparo;
  final String tempoCozinho;
  final int porcoes;
  final String dificuldade;
  final String categoria;
  final List<String> tags;
  final List<String> observacoes;
  final List<String> dicas;

  ReceitaFit({
    required this.nome,
    required this.descricao,
    required this.ingredientes,
    required this.modoPreparo,
    required this.tempoPreparo,
    required this.tempoCozinho,
    required this.porcoes,
    required this.dificuldade,
    required this.categoria,
    required this.tags,
    this.observacoes = const [],
    this.dicas = const [],
  });

  factory ReceitaFit.fromJson(Map<String, dynamic> json) {
    return ReceitaFit(
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      ingredientes: (json['ingredientes'] as List<dynamic>)
          .map((ingrediente) => Ingrediente.fromJson(ingrediente))
          .toList(),
      modoPreparo: (json['modoPreparo'] as List<dynamic>)
          .map((passo) => Passo.fromJson(passo))
          .toList(),
      tempoPreparo: json['tempoPreparo'] as String,
      tempoCozinho: json['tempoCozinho'] as String,
      porcoes: json['porcoes'] as int,
      dificuldade: json['dificuldade'] as String,
      categoria: json['categoria'] as String,
      tags: json['tags'] as List<String>,
      observacoes: json['observacoes'] as List<String>,
      dicas: json['dicas'] as List<String>,
    );
  }

  String getIngredientes() {
    return ingredientes.map((ingrediente) => ingrediente.toString()).join(', ');
  }

  String getModoPreparo() {
    return modoPreparo.map((passo) => passo.toString()).join('\n\n');
  }
}
