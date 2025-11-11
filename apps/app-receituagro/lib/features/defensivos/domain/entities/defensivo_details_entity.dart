import '../../../../core/data/models/fitossanitario_legacy.dart';
import '../../../../database/receituagro_database.dart';

/// Entity que representa os detalhes de um defensivo
/// Encapsula dados vindos do FitossanitarioHive mantendo clean architecture
class DefensivoDetailsEntity {
  final String id;
  final String nomeComum;
  final String nomeTecnico;
  final String fabricante;
  final String ingredienteAtivo;
  final String? toxico;
  final String? inflamavel;
  final String? corrosivo;
  final String? modoAcao;
  final String? classeAgronomica;
  final String? classAmbiental;
  final String? formulacao;
  final String? idReg;
  final String? mapa;

  const DefensivoDetailsEntity({
    required this.id,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.fabricante,
    required this.ingredienteAtivo,
    this.toxico,
    this.inflamavel,
    this.corrosivo,
    this.modoAcao,
    this.classeAgronomica,
    this.classAmbiental,
    this.formulacao,
    this.idReg,
    this.mapa,
  });

  /// Cria entity a partir do modelo Hive
  factory DefensivoDetailsEntity.fromHive(FitossanitarioHive hive) {
    return DefensivoDetailsEntity(
      id: hive.idReg,
      nomeComum: hive.nomeComum,
      nomeTecnico: hive.nomeTecnico,
      fabricante: hive.fabricante ?? 'Não informado',
      ingredienteAtivo: hive.ingredienteAtivo ?? 'Não informado',
      toxico: hive.toxico,
      inflamavel: hive.inflamavel,
      corrosivo: hive.corrosivo,
      modoAcao: hive.modoAcao,
      classeAgronomica: hive.classeAgronomica,
      classAmbiental: hive.classAmbiental,
      formulacao: hive.formulacao,
      idReg: hive.idReg,
      mapa: hive.mapa,
    );
  }

  /// Cria entity a partir do modelo Drift
  factory DefensivoDetailsEntity.fromDrift(Fitossanitario drift) {
    return DefensivoDetailsEntity(
      id: drift.idDefensivo,
      nomeComum: drift.nomeComum ?? drift.nome,
      nomeTecnico: drift.nome,
      fabricante: drift.fabricante ?? 'Não informado',
      ingredienteAtivo: drift.ingredienteAtivo ?? 'Não informado',
      toxico: null, // Não disponível no Drift
      inflamavel: null, // Não disponível no Drift
      corrosivo: null, // Não disponível no Drift
      modoAcao: null, // Não disponível no Drift
      classeAgronomica: drift.classeAgronomica,
      classAmbiental: null, // Não disponível no Drift
      formulacao: null, // Não disponível no Drift
      idReg: drift.registroMapa,
      mapa: drift.registroMapa,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefensivoDetailsEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DefensivoDetailsEntity(id: $id, nomeComum: $nomeComum, nomeTecnico: $nomeTecnico, fabricante: $fabricante)';
  }

  DefensivoDetailsEntity copyWith({
    String? id,
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
    String? idReg,
    String? mapa,
  }) {
    return DefensivoDetailsEntity(
      id: id ?? this.id,
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
      idReg: idReg ?? this.idReg,
      mapa: mapa ?? this.mapa,
    );
  }
}
