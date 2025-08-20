
enum UnidadeCultura { sacas, arrobas, ton, unidades }

class CulturaModel {
  final String nome;
  final UnidadeCultura unidade;

  const CulturaModel({
    required this.nome,
    required this.unidade,
  });

  static const List<CulturaModel> culturas = [
    CulturaModel(nome: 'Soja', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Milho', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Feijão', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Algodão', unidade: UnidadeCultura.arrobas),
    CulturaModel(nome: 'Café', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Trigo', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Cana-de-açúcar', unidade: UnidadeCultura.ton),
    CulturaModel(nome: 'Arroz', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Sorgo', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Girassol', unidade: UnidadeCultura.sacas),
    CulturaModel(nome: 'Outra', unidade: UnidadeCultura.unidades),
  ];
}
