import 'package:core/core.dart';

part 'fitossanitario_hive.g.dart';

@HiveType(typeId: 102)
class FitossanitarioHive extends HiveObject {
  @HiveField(0)
  String? objectId;

  @HiveField(1)
  int? createdAt;

  @HiveField(2)
  int? updatedAt;

  @HiveField(3)
  String idReg;

  @HiveField(4)
  bool status;

  @HiveField(5)
  String nomeComum;

  @HiveField(6)
  String nomeTecnico;

  @HiveField(7)
  String? classeAgronomica;

  @HiveField(8)
  String? fabricante;

  @HiveField(9)
  String? classAmbiental;

  @HiveField(10)
  int comercializado;

  @HiveField(11)
  String? corrosivo;

  @HiveField(12)
  String? inflamavel;

  @HiveField(13)
  String? formulacao;

  @HiveField(14)
  String? modoAcao;

  @HiveField(15)
  String? mapa;

  @HiveField(16)
  String? toxico;

  @HiveField(17)
  String? ingredienteAtivo;

  @HiveField(18)
  String? quantProduto;

  @HiveField(19)
  bool elegivel;

  FitossanitarioHive({
    this.objectId,
    this.createdAt,
    this.updatedAt,
    required this.idReg,
    required this.status,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.comercializado,
    this.classeAgronomica,
    this.fabricante,
    this.classAmbiental,
    this.corrosivo,
    this.inflamavel,
    this.formulacao,
    this.modoAcao,
    this.mapa,
    this.toxico,
    this.ingredienteAtivo,
    this.quantProduto,
    required this.elegivel,
  });

  factory FitossanitarioHive.fromJson(Map<String, dynamic> json) {
    return FitossanitarioHive(
      objectId: json['objectId'] as String?,
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) : null,
      idReg: (json['idReg'] as String?) ?? '',
      status: json['status'] != null ? json['status'] as bool : false,
      nomeComum: (json['nomeComum'] as String?) ?? '',
      nomeTecnico: (json['nomeTecnico'] as String?) ?? '',
      classeAgronomica: json['classeAgronomica'] as String?,
      fabricante: json['fabricante'] as String?,
      classAmbiental: json['classAmbiental'] as String?,
      comercializado:
          json['comercializado'] != null ? int.tryParse(json['comercializado'].toString()) ?? 0 : 0,
      corrosivo: json['corrosivo'] as String?,
      inflamavel: json['inflamavel'] as String?,
      formulacao: json['formulacao'] as String?,
      modoAcao: json['modoAcao'] as String?,
      mapa: json['mapa'] as String?,
      toxico: json['toxico'] as String?,
      ingredienteAtivo: json['ingredienteAtivo'] as String?,
      quantProduto: json['quantProduto'] as String?,
      elegivel: json['elegivel'] != null ? json['elegivel'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'status': status,
      'nomeComum': nomeComum,
      'nomeTecnico': nomeTecnico,
      'classeAgronomica': classeAgronomica,
      'fabricante': fabricante,
      'classAmbiental': classAmbiental,
      'comercializado': comercializado,
      'corrosivo': corrosivo,
      'inflamavel': inflamavel,
      'formulacao': formulacao,
      'modoAcao': modoAcao,
      'mapa': mapa,
      'toxico': toxico,
      'ingredienteAtivo': ingredienteAtivo,
      'quantProduto': quantProduto,
      'elegivel': elegivel
    };
  }

  @override
  String toString() {
    return 'FitossanitarioHive{objectId: $objectId, nomeComum: $nomeComum, nomeTecnico: $nomeTecnico}';
  }
}