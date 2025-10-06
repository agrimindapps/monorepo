import 'package:core/core.dart';

/// Entidade de domínio que representa um defensivo
///
/// Esta entidade segue os princípios de Clean Architecture,
/// sendo independente de frameworks e implementações específicas
class DefensivoEntity extends Equatable {
  final String idReg;
  final String nomeComum;
  final String nomeTecnico;
  final String fabricante;
  final String ingredienteAtivo;
  final String toxico;
  final String inflamavel;
  final String corrosivo;
  final String modoAcao;
  final String classeAgronomica;
  final String classAmbiental;
  final String formulacao;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DefensivoEntity({
    required this.idReg,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.fabricante,
    required this.ingredienteAtivo,
    required this.toxico,
    required this.inflamavel,
    required this.corrosivo,
    required this.modoAcao,
    required this.classeAgronomica,
    required this.classAmbiental,
    required this.formulacao,
    this.createdAt,
    this.updatedAt,
  });

  /// Getters computados para facilitar uso na UI
  bool get isToxico => !toxico.toLowerCase().contains('não');
  bool get isInflamavel => !inflamavel.toLowerCase().contains('não');
  bool get isCorrosivo => !corrosivo.toLowerCase().contains('não');

  String get toxicidadeLevel {
    if (toxico.toLowerCase().contains('classe i')) return 'Extremamente tóxico';
    if (toxico.toLowerCase().contains('classe ii')) return 'Altamente tóxico';
    if (toxico.toLowerCase().contains('classe iii'))
      return 'Medianamente tóxico';
    if (toxico.toLowerCase().contains('classe iv')) return 'Pouco tóxico';
    return 'Não classificado';
  }

  DefensivoEntity copyWith({
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
    return DefensivoEntity(
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

  @override
  List<Object?> get props => [
    idReg,
    nomeComum,
    nomeTecnico,
    fabricante,
    ingredienteAtivo,
    toxico,
    inflamavel,
    corrosivo,
    modoAcao,
    classeAgronomica,
    classAmbiental,
    formulacao,
    createdAt,
    updatedAt,
  ];
}
