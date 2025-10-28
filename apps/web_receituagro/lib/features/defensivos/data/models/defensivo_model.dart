import '../../domain/entities/defensivo.dart';

/// Defensivo data model (DTO)
/// Extends domain entity and adds serialization logic
class DefensivoModel extends Defensivo {
  const DefensivoModel({
    required super.id,
    required super.nomeComum,
    super.nomeTecnico,
    required super.fabricante,
    required super.ingredienteAtivo,
    super.quantProduto,
    super.mapa,
    super.formulacao,
    super.modoAcao,
    super.classeAgronomica,
    super.toxico,
    super.classAmbiental,
    super.inflamavel,
    super.corrosivo,
    super.comercializado,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (Supabase format)
  factory DefensivoModel.fromJson(Map<String, dynamic> json) {
    return DefensivoModel(
      id: json['id']?.toString() ?? '',
      nomeComum: json['nome_comum']?.toString() ?? '',
      nomeTecnico: json['nome_tecnico']?.toString(),
      fabricante: json['fabricante']?.toString() ?? '',
      ingredienteAtivo: json['ingrediente_ativo']?.toString() ?? '',
      quantProduto: json['quant_produto']?.toString(),
      mapa: json['mapa']?.toString(),
      formulacao: json['formulacao']?.toString(),
      modoAcao: json['modo_acao']?.toString(),
      classeAgronomica: json['classe_agronomica']?.toString(),
      toxico: json['toxico']?.toString(),
      classAmbiental: json['class_ambiental']?.toString(),
      inflamavel: json['inflamavel']?.toString(),
      corrosivo: json['corrosivo']?.toString(),
      comercializado: json['comercializado']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert model to JSON (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_comum': nomeComum,
      'nome_tecnico': nomeTecnico,
      'fabricante': fabricante,
      'ingrediente_ativo': ingredienteAtivo,
      'quant_produto': quantProduto,
      'mapa': mapa,
      'formulacao': formulacao,
      'modo_acao': modoAcao,
      'classe_agronomica': classeAgronomica,
      'toxico': toxico,
      'class_ambiental': classAmbiental,
      'inflamavel': inflamavel,
      'corrosivo': corrosivo,
      'comercializado': comercializado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory DefensivoModel.fromEntity(Defensivo entity) {
    return DefensivoModel(
      id: entity.id,
      nomeComum: entity.nomeComum,
      nomeTecnico: entity.nomeTecnico,
      fabricante: entity.fabricante,
      ingredienteAtivo: entity.ingredienteAtivo,
      quantProduto: entity.quantProduto,
      mapa: entity.mapa,
      formulacao: entity.formulacao,
      modoAcao: entity.modoAcao,
      classeAgronomica: entity.classeAgronomica,
      toxico: entity.toxico,
      classAmbiental: entity.classAmbiental,
      inflamavel: entity.inflamavel,
      corrosivo: entity.corrosivo,
      comercializado: entity.comercializado,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  Defensivo toEntity() {
    return Defensivo(
      id: id,
      nomeComum: nomeComum,
      nomeTecnico: nomeTecnico,
      fabricante: fabricante,
      ingredienteAtivo: ingredienteAtivo,
      quantProduto: quantProduto,
      mapa: mapa,
      formulacao: formulacao,
      modoAcao: modoAcao,
      classeAgronomica: classeAgronomica,
      toxico: toxico,
      classAmbiental: classAmbiental,
      inflamavel: inflamavel,
      corrosivo: corrosivo,
      comercializado: comercializado,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  DefensivoModel copyWith({
    String? id,
    String? nomeComum,
    String? nomeTecnico,
    String? fabricante,
    String? ingredienteAtivo,
    String? quantProduto,
    String? mapa,
    String? formulacao,
    String? modoAcao,
    String? classeAgronomica,
    String? toxico,
    String? classAmbiental,
    String? inflamavel,
    String? corrosivo,
    String? comercializado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoModel(
      id: id ?? this.id,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      fabricante: fabricante ?? this.fabricante,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      quantProduto: quantProduto ?? this.quantProduto,
      mapa: mapa ?? this.mapa,
      formulacao: formulacao ?? this.formulacao,
      modoAcao: modoAcao ?? this.modoAcao,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      toxico: toxico ?? this.toxico,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      inflamavel: inflamavel ?? this.inflamavel,
      corrosivo: corrosivo ?? this.corrosivo,
      comercializado: comercializado ?? this.comercializado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
