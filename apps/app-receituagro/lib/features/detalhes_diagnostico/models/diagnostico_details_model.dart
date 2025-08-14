/// Immutable model for diagnostic details data
/// Following Single Responsibility Principle (SOLID)
class DiagnosticoDetailsModel {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;
  final DateTime dataCreacao;
  final DateTime? dataAtualizacao;
  final String autor;
  final List<String> tags;
  final Map<String, dynamic> dadosTecnicos;
  final List<DiagnosticStep> etapas;
  final bool isPremium;
  final double? confiabilidade;
  final String? imagemUrl;
  final List<String> referencias;
  final Map<String, String> metadados;

  const DiagnosticoDetailsModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.dataCreacao,
    this.dataAtualizacao,
    required this.autor,
    required this.tags,
    required this.dadosTecnicos,
    required this.etapas,
    this.isPremium = false,
    this.confiabilidade,
    this.imagemUrl,
    required this.referencias,
    required this.metadados,
  });

  /// Create from JSON
  factory DiagnosticoDetailsModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoDetailsModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      categoria: json['categoria'] as String,
      dataCreacao: DateTime.parse(json['dataCreacao'] as String),
      dataAtualizacao: json['dataAtualizacao'] != null 
          ? DateTime.parse(json['dataAtualizacao'] as String)
          : null,
      autor: json['autor'] as String,
      tags: List<String>.from(json['tags'] as List),
      dadosTecnicos: Map<String, dynamic>.from(json['dadosTecnicos'] as Map),
      etapas: (json['etapas'] as List)
          .map((e) => DiagnosticStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPremium: json['isPremium'] as bool? ?? false,
      confiabilidade: (json['confiabilidade'] as num?)?.toDouble(),
      imagemUrl: json['imagemUrl'] as String?,
      referencias: List<String>.from(json['referencias'] as List),
      metadados: Map<String, String>.from(json['metadados'] as Map),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'dataCreacao': dataCreacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'autor': autor,
      'tags': tags,
      'dadosTecnicos': dadosTecnicos,
      'etapas': etapas.map((e) => e.toJson()).toList(),
      'isPremium': isPremium,
      'confiabilidade': confiabilidade,
      'imagemUrl': imagemUrl,
      'referencias': referencias,
      'metadados': metadados,
    };
  }

  /// Create copy with modifications
  DiagnosticoDetailsModel copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? categoria,
    DateTime? dataCreacao,
    DateTime? dataAtualizacao,
    String? autor,
    List<String>? tags,
    Map<String, dynamic>? dadosTecnicos,
    List<DiagnosticStep>? etapas,
    bool? isPremium,
    double? confiabilidade,
    String? imagemUrl,
    List<String>? referencias,
    Map<String, String>? metadados,
  }) {
    return DiagnosticoDetailsModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      dataCreacao: dataCreacao ?? this.dataCreacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      autor: autor ?? this.autor,
      tags: tags ?? this.tags,
      dadosTecnicos: dadosTecnicos ?? this.dadosTecnicos,
      etapas: etapas ?? this.etapas,
      isPremium: isPremium ?? this.isPremium,
      confiabilidade: confiabilidade ?? this.confiabilidade,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      referencias: referencias ?? this.referencias,
      metadados: metadados ?? this.metadados,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticoDetailsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DiagnosticoDetailsModel(id: $id, titulo: $titulo)';
}

/// Model for diagnostic step
class DiagnosticStep {
  final String id;
  final String titulo;
  final String descricao;
  final int ordem;
  final bool isCompleted;
  final String? imagemUrl;
  final Map<String, dynamic>? dadosAdicionais;

  const DiagnosticStep({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.ordem,
    this.isCompleted = false,
    this.imagemUrl,
    this.dadosAdicionais,
  });

  factory DiagnosticStep.fromJson(Map<String, dynamic> json) {
    return DiagnosticStep(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      ordem: json['ordem'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      imagemUrl: json['imagemUrl'] as String?,
      dadosAdicionais: json['dadosAdicionais'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'ordem': ordem,
      'isCompleted': isCompleted,
      'imagemUrl': imagemUrl,
      'dadosAdicionais': dadosAdicionais,
    };
  }

  DiagnosticStep copyWith({
    String? id,
    String? titulo,
    String? descricao,
    int? ordem,
    bool? isCompleted,
    String? imagemUrl,
    Map<String, dynamic>? dadosAdicionais,
  }) {
    return DiagnosticStep(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      ordem: ordem ?? this.ordem,
      isCompleted: isCompleted ?? this.isCompleted,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      dadosAdicionais: dadosAdicionais ?? this.dadosAdicionais,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticStep && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}