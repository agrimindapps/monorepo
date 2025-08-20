class MeditacaoAchievementModel {
  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final bool conquistado;
  final DateTime? dataConquista;

  MeditacaoAchievementModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.conquistado,
    this.dataConquista,
  });

  // Converter para Map para salvar no SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'icone': icone,
      'conquistado': conquistado,
      'dataConquista': dataConquista?.toIso8601String(),
    };
  }

  // Construir a partir de um Map (do SharedPreferences)
  factory MeditacaoAchievementModel.fromMap(Map<String, dynamic> map) {
    return MeditacaoAchievementModel(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      icone: map['icone'],
      conquistado: map['conquistado'],
      dataConquista: map['dataConquista'] != null
          ? DateTime.parse(map['dataConquista'])
          : null,
    );
  }

  // Marcar como conquistado
  MeditacaoAchievementModel comoConcluido() {
    return MeditacaoAchievementModel(
      id: id,
      titulo: titulo,
      descricao: descricao,
      icone: icone,
      conquistado: true,
      dataConquista: DateTime.now(),
    );
  }
}
