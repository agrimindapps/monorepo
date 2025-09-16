import '../../../diagnosticos/domain/entities/diagnostico_entity.dart' as DiagnosticsEntity;
import '../../domain/entities/diagnostico_entity.dart';

/// Modelo de dados para Diagnostico
/// 
/// Esta classe implementa a conversão entre a entidade de domínio
/// e os dados externos (Hive, API, etc), seguindo Clean Architecture
class DiagnosticoModel extends DiagnosticoEntity {
  const DiagnosticoModel({
    required super.id,
    required super.idDefensivo,
    super.nomeDefensivo,
    super.nomeCultura,
    super.nomePraga,
    required super.dosagem,
    super.unidadeDosagem,
    super.modoAplicacao,
    super.intervaloDias,
    super.observacoes,
    required super.ingredienteAtivo,
    required super.cultura,
    required super.grupo,
    super.createdAt,
    super.updatedAt,
  });

  /// Cria um DiagnosticoModel a partir de uma entidade do módulo de diagnósticos
  factory DiagnosticoModel.fromDiagnosticsEntity(DiagnosticsEntity.DiagnosticoEntity entity) {
    return DiagnosticoModel(
      id: entity.id,
      idDefensivo: entity.idDefensivo,
      nomeDefensivo: entity.nomeDefensivo,
      nomeCultura: entity.nomeCultura,
      nomePraga: entity.nomePraga,
      dosagem: entity.dosagem.displayDosagem,
      unidadeDosagem: entity.dosagem.unidadeMedida,
      modoAplicacao: entity.aplicacao.hasTerrestre ? 'Terrestre' : (entity.aplicacao.hasAerea ? 'Aérea' : null),
      intervaloDias: null, // Não disponível diretamente na nova entity
      observacoes: null, // Não disponível diretamente na nova entity
      ingredienteAtivo: entity.nomeDefensivo ?? 'Não identificado',
      cultura: entity.nomeCultura ?? 'Não especificado',
      grupo: entity.nomePraga ?? 'Não especificado', // grupo é usado como nomePraga para compatibilidade
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Cria um DiagnosticoModel a partir do modelo legacy (do código antigo)
  factory DiagnosticoModel.fromLegacyModel(Map<String, dynamic> legacyModel) {
    return DiagnosticoModel(
      id: (legacyModel['id'] as String?) ?? '',
      idDefensivo: (legacyModel['ingredienteAtivo'] as String?) ?? '',
      nomeDefensivo: legacyModel['nome'] as String?,
      nomeCultura: legacyModel['cultura'] as String?,
      nomePraga: legacyModel['grupo'] as String?,
      dosagem: (legacyModel['dosagem'] as String?) ?? '',
      ingredienteAtivo: (legacyModel['ingredienteAtivo'] as String?) ?? '',
      cultura: (legacyModel['cultura'] as String?) ?? '',
      grupo: (legacyModel['grupo'] as String?) ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Cria um DiagnosticoModel a partir de JSON (API)
  factory DiagnosticoModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoModel(
      id: json['id'] as String,
      idDefensivo: json['idDefensivo'] as String,
      nomeDefensivo: json['nomeDefensivo'] as String?,
      nomeCultura: json['nomeCultura'] as String?,
      nomePraga: json['nomePraga'] as String?,
      dosagem: json['dosagem'] as String,
      unidadeDosagem: json['unidadeDosagem'] as String?,
      modoAplicacao: json['modoAplicacao'] as String?,
      intervaloDias: json['intervaloDias'] as int?,
      observacoes: json['observacoes'] as String?,
      ingredienteAtivo: json['ingredienteAtivo'] as String,
      cultura: json['cultura'] as String,
      grupo: json['grupo'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converte para JSON (para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idDefensivo': idDefensivo,
      'nomeDefensivo': nomeDefensivo,
      'nomeCultura': nomeCultura,
      'nomePraga': nomePraga,
      'dosagem': dosagem,
      'unidadeDosagem': unidadeDosagem,
      'modoAplicacao': modoAplicacao,
      'intervaloDias': intervaloDias,
      'observacoes': observacoes,
      'ingredienteAtivo': ingredienteAtivo,
      'cultura': cultura,
      'grupo': grupo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Cria um DiagnosticoModel a partir de uma entidade
  factory DiagnosticoModel.fromEntity(DiagnosticoEntity entity) {
    return DiagnosticoModel(
      id: entity.id,
      idDefensivo: entity.idDefensivo,
      nomeDefensivo: entity.nomeDefensivo,
      nomeCultura: entity.nomeCultura,
      nomePraga: entity.nomePraga,
      dosagem: entity.dosagem,
      unidadeDosagem: entity.unidadeDosagem,
      modoAplicacao: entity.modoAplicacao,
      intervaloDias: entity.intervaloDias,
      observacoes: entity.observacoes,
      ingredienteAtivo: entity.ingredienteAtivo,
      cultura: entity.cultura,
      grupo: entity.grupo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Cria uma cópia com alguns campos alterados
  @override
  DiagnosticoModel copyWith({
    String? id,
    String? idDefensivo,
    String? nomeDefensivo,
    String? nomeCultura,
    String? nomePraga,
    String? dosagem,
    String? unidadeDosagem,
    String? modoAplicacao,
    int? intervaloDias,
    String? observacoes,
    String? ingredienteAtivo,
    String? cultura,
    String? grupo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosticoModel(
      id: id ?? this.id,
      idDefensivo: idDefensivo ?? this.idDefensivo,
      nomeDefensivo: nomeDefensivo ?? this.nomeDefensivo,
      nomeCultura: nomeCultura ?? this.nomeCultura,
      nomePraga: nomePraga ?? this.nomePraga,
      dosagem: dosagem ?? this.dosagem,
      unidadeDosagem: unidadeDosagem ?? this.unidadeDosagem,
      modoAplicacao: modoAplicacao ?? this.modoAplicacao,
      intervaloDias: intervaloDias ?? this.intervaloDias,
      observacoes: observacoes ?? this.observacoes,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      cultura: cultura ?? this.cultura,
      grupo: grupo ?? this.grupo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}