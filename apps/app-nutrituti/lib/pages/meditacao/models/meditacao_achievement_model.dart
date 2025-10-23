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
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      icone: map['icone'] as String,
      conquistado: map['conquistado'] as bool,
      dataConquista: map['dataConquista'] != null
          ? DateTime.parse(map['dataConquista'] as String)
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
