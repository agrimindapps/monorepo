import '../../domain/entities/diagnostico.dart';

/// DiagnosticoModel - Data layer
/// Extends Diagnostico entity with JSON serialization for Supabase
/// Represents the many-to-many relationship between Defensivo, Cultura, and Praga
class DiagnosticoModel extends Diagnostico {
  const DiagnosticoModel({
    required super.id,
    required super.defensivoId,
    required super.culturaId,
    required super.pragaId,
    super.dsMin,
    super.dsMax,
    super.um,
    super.minAplicacaoT,
    super.maxAplicacaoT,
    super.umT,
    super.minAplicacaoA,
    super.maxAplicacaoA,
    super.umA,
    super.intervalo,
    super.intervalo2,
    super.epocaAplicacao,
    super.culturaNome,
    super.pragaNomeComum,
    super.pragaNomeCientifico,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (Supabase format)
  factory DiagnosticoModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoModel(
      id: json['id']?.toString() ?? '',
      defensivoId: json['defensivo_id']?.toString() ?? json['fkiddefensivo']?.toString() ?? '',
      culturaId: json['cultura_id']?.toString() ?? json['fkidcultura']?.toString() ?? '',
      pragaId: json['praga_id']?.toString() ?? json['fkidpraga']?.toString() ?? '',
      dsMin: json['ds_min']?.toString() ?? json['dosagem']?.toString(),
      dsMax: json['ds_max']?.toString(),
      um: json['um']?.toString(),
      minAplicacaoT: json['min_aplicacao_t']?.toString() ?? json['terrestre']?.toString(),
      maxAplicacaoT: json['max_aplicacao_t']?.toString(),
      umT: json['um_t']?.toString(),
      minAplicacaoA: json['min_aplicacao_a']?.toString() ?? json['aerea']?.toString(),
      maxAplicacaoA: json['max_aplicacao_a']?.toString(),
      umA: json['um_a']?.toString(),
      intervalo: json['intervalo']?.toString(),
      intervalo2: json['intervalo2']?.toString(),
      epocaAplicacao: json['epoca_aplicacao']?.toString(),
      culturaNome: json['cultura']?.toString(),
      pragaNomeComum: json['praganomecomum']?.toString(),
      pragaNomeCientifico: json['praganomecientifico']?.toString(),
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
      'defensivo_id': defensivoId,
      'cultura_id': culturaId,
      'praga_id': pragaId,
      'ds_min': dsMin,
      'ds_max': dsMax,
      'um': um,
      'min_aplicacao_t': minAplicacaoT,
      'max_aplicacao_t': maxAplicacaoT,
      'um_t': umT,
      'min_aplicacao_a': minAplicacaoA,
      'max_aplicacao_a': maxAplicacaoA,
      'um_a': umA,
      'intervalo': intervalo,
      'intervalo2': intervalo2,
      'epoca_aplicacao': epocaAplicacao,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create model from domain entity
  factory DiagnosticoModel.fromEntity(Diagnostico entity) {
    return DiagnosticoModel(
      id: entity.id,
      defensivoId: entity.defensivoId,
      culturaId: entity.culturaId,
      pragaId: entity.pragaId,
      dsMin: entity.dsMin,
      dsMax: entity.dsMax,
      um: entity.um,
      minAplicacaoT: entity.minAplicacaoT,
      maxAplicacaoT: entity.maxAplicacaoT,
      umT: entity.umT,
      minAplicacaoA: entity.minAplicacaoA,
      maxAplicacaoA: entity.maxAplicacaoA,
      umA: entity.umA,
      intervalo: entity.intervalo,
      intervalo2: entity.intervalo2,
      epocaAplicacao: entity.epocaAplicacao,
      culturaNome: entity.culturaNome,
      pragaNomeComum: entity.pragaNomeComum,
      pragaNomeCientifico: entity.pragaNomeCientifico,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to domain entity
  Diagnostico toEntity() {
    return Diagnostico(
      id: id,
      defensivoId: defensivoId,
      culturaId: culturaId,
      pragaId: pragaId,
      dsMin: dsMin,
      dsMax: dsMax,
      um: um,
      minAplicacaoT: minAplicacaoT,
      maxAplicacaoT: maxAplicacaoT,
      umT: umT,
      minAplicacaoA: minAplicacaoA,
      maxAplicacaoA: maxAplicacaoA,
      umA: umA,
      intervalo: intervalo,
      intervalo2: intervalo2,
      epocaAplicacao: epocaAplicacao,
      culturaNome: culturaNome,
      pragaNomeComum: pragaNomeComum,
      pragaNomeCientifico: pragaNomeCientifico,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  DiagnosticoModel copyWith({
    String? id,
    String? defensivoId,
    String? culturaId,
    String? pragaId,
    String? dsMin,
    String? dsMax,
    String? um,
    String? minAplicacaoT,
    String? maxAplicacaoT,
    String? umT,
    String? minAplicacaoA,
    String? maxAplicacaoA,
    String? umA,
    String? intervalo,
    String? intervalo2,
    String? epocaAplicacao,
    String? culturaNome,
    String? pragaNomeComum,
    String? pragaNomeCientifico,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosticoModel(
      id: id ?? this.id,
      defensivoId: defensivoId ?? this.defensivoId,
      culturaId: culturaId ?? this.culturaId,
      pragaId: pragaId ?? this.pragaId,
      dsMin: dsMin ?? this.dsMin,
      dsMax: dsMax ?? this.dsMax,
      um: um ?? this.um,
      minAplicacaoT: minAplicacaoT ?? this.minAplicacaoT,
      maxAplicacaoT: maxAplicacaoT ?? this.maxAplicacaoT,
      umT: umT ?? this.umT,
      minAplicacaoA: minAplicacaoA ?? this.minAplicacaoA,
      maxAplicacaoA: maxAplicacaoA ?? this.maxAplicacaoA,
      umA: umA ?? this.umA,
      intervalo: intervalo ?? this.intervalo,
      intervalo2: intervalo2 ?? this.intervalo2,
      epocaAplicacao: epocaAplicacao ?? this.epocaAplicacao,
      culturaNome: culturaNome ?? this.culturaNome,
      pragaNomeComum: pragaNomeComum ?? this.pragaNomeComum,
      pragaNomeCientifico: pragaNomeCientifico ?? this.pragaNomeCientifico,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
