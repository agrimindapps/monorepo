/// Modelo simples para representar um diagnóstico
class Diagnostico {
  final String id;
  final String titulo;
  final String descricao;
  final String sintomas;
  final String recomendacoes;
  final String severidade;
  final double confianca;

  const Diagnostico({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.sintomas,
    required this.recomendacoes,
    required this.severidade,
    required this.confianca,
  });

  factory Diagnostico.fromMap(Map<String, dynamic> map) {
    return Diagnostico(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      sintomas: map['sintomas']?.toString() ?? '',
      recomendacoes: map['recomendacoes']?.toString() ?? '',
      severidade: map['severidade']?.toString() ?? 'baixa',
      confianca: double.tryParse(map['confianca']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'sintomas': sintomas,
      'recomendacoes': recomendacoes,
      'severidade': severidade,
      'confianca': confianca,
    };
  }
}
