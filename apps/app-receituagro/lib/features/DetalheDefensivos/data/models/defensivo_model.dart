import '../../../../core/models/fitossanitario_hive.dart';
import '../../domain/entities/defensivo_entity.dart';

/// Modelo de dados para Defensivo
/// 
/// Esta classe implementa a conversão entre a entidade de domínio
/// e os dados externos (Hive, API, etc), seguindo Clean Architecture
class DefensivoModel extends DefensivoEntity {
  const DefensivoModel({
    required super.idReg,
    required super.nomeComum,
    required super.nomeTecnico,
    required super.fabricante,
    required super.ingredienteAtivo,
    required super.toxico,
    required super.inflamavel,
    required super.corrosivo,
    required super.modoAcao,
    required super.classeAgronomica,
    required super.classAmbiental,
    required super.formulacao,
    super.createdAt,
    super.updatedAt,
  });

  /// Cria um DefensivoModel a partir de um FitossanitarioHive (Hive)
  factory DefensivoModel.fromHive(FitossanitarioHive hive) {
    return DefensivoModel(
      idReg: hive.idReg,
      nomeComum: hive.nomeComum,
      nomeTecnico: hive.nomeTecnico,
      fabricante: hive.fabricante ?? 'Não informado',
      ingredienteAtivo: hive.ingredienteAtivo ?? 'Não informado',
      toxico: hive.toxico ?? 'Não informado',
      inflamavel: hive.inflamavel ?? 'Não informado',
      corrosivo: hive.corrosivo ?? 'Não informado',
      modoAcao: hive.modoAcao ?? 'Não informado',
      classeAgronomica: hive.classeAgronomica ?? 'Não informado',
      classAmbiental: hive.classAmbiental ?? 'Não informado',
      formulacao: hive.formulacao ?? 'Não informado',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Cria um DefensivoModel a partir de JSON (API)
  factory DefensivoModel.fromJson(Map<String, dynamic> json) {
    return DefensivoModel(
      idReg: json['idReg'] as String,
      nomeComum: json['nomeComum'] as String,
      nomeTecnico: json['nomeTecnico'] as String,
      fabricante: json['fabricante'] as String,
      ingredienteAtivo: json['ingredienteAtivo'] as String,
      toxico: json['toxico'] as String,
      inflamavel: json['inflamavel'] as String,
      corrosivo: json['corrosivo'] as String,
      modoAcao: json['modoAcao'] as String,
      classeAgronomica: json['classeAgronomica'] as String,
      classAmbiental: json['classAmbiental'] as String,
      formulacao: json['formulacao'] as String,
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
      'idReg': idReg,
      'nomeComum': nomeComum,
      'nomeTecnico': nomeTecnico,
      'fabricante': fabricante,
      'ingredienteAtivo': ingredienteAtivo,
      'toxico': toxico,
      'inflamavel': inflamavel,
      'corrosivo': corrosivo,
      'modoAcao': modoAcao,
      'classeAgronomica': classeAgronomica,
      'classAmbiental': classAmbiental,
      'formulacao': formulacao,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Converte para FitossanitarioHive (para salvar no Hive)
  FitossanitarioHive toHive() {
    return FitossanitarioHive(
      idReg: idReg,
      status: true, // Assume ativo por padrão
      nomeComum: nomeComum,
      nomeTecnico: nomeTecnico,
      comercializado: 1, // Assume comercializado por padrão
      elegivel: true, // Assume elegível por padrão
      fabricante: fabricante,
      ingredienteAtivo: ingredienteAtivo,
      toxico: toxico,
      inflamavel: inflamavel,
      corrosivo: corrosivo,
      modoAcao: modoAcao,
      classeAgronomica: classeAgronomica,
      classAmbiental: classAmbiental,
      formulacao: formulacao,
    );
  }

  /// Cria um DefensivoModel a partir de uma entidade
  factory DefensivoModel.fromEntity(DefensivoEntity entity) {
    return DefensivoModel(
      idReg: entity.idReg,
      nomeComum: entity.nomeComum,
      nomeTecnico: entity.nomeTecnico,
      fabricante: entity.fabricante,
      ingredienteAtivo: entity.ingredienteAtivo,
      toxico: entity.toxico,
      inflamavel: entity.inflamavel,
      corrosivo: entity.corrosivo,
      modoAcao: entity.modoAcao,
      classeAgronomica: entity.classeAgronomica,
      classAmbiental: entity.classAmbiental,
      formulacao: entity.formulacao,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Cria uma cópia com alguns campos alterados
  @override
  DefensivoModel copyWith({
    String? idReg,
    String? nomeComum,
    String? nomeTecnico,
    String? fabricante,
    String? ingredienteAtivo,
    String? toxico,
    String? inflamavel,
    String? corrosivo,
    String? modoAcao,
    String? classeAgronomica,
    String? classAmbiental,
    String? formulacao,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DefensivoModel(
      idReg: idReg ?? this.idReg,
      nomeComum: nomeComum ?? this.nomeComum,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      fabricante: fabricante ?? this.fabricante,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      toxico: toxico ?? this.toxico,
      inflamavel: inflamavel ?? this.inflamavel,
      corrosivo: corrosivo ?? this.corrosivo,
      modoAcao: modoAcao ?? this.modoAcao,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      classAmbiental: classAmbiental ?? this.classAmbiental,
      formulacao: formulacao ?? this.formulacao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}