// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '20_odometro_model.g.dart';

@HiveType(typeId: 20)
class OdometroCar extends BaseModel {
  @HiveField(7)
  String idVeiculo;

  @HiveField(8)
  int data;

  @HiveField(9)
  double odometro;

  @HiveField(10)
  String descricao;

  @HiveField(11)
  String? tipoRegistro;

  OdometroCar({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.idVeiculo,
    required this.data,
    required this.odometro,
    required this.descricao,
    required this.tipoRegistro,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'idVeiculo': idVeiculo,
        'data': data,
        'odometro': odometro,
        'descricao': descricao,
        'tipoRegistro': tipoRegistro,
      });
  }

  /// Cria uma instância de `OdometroCar` a partir de um mapa
  factory OdometroCar.fromMap(Map<String, dynamic> map) {
    return OdometroCar(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      idVeiculo: map['idVeiculo'] ?? '',
      data: map['data'] ?? 0,
      odometro: map['odometro'] ?? 0.0,
      descricao: map['descricao'] ?? '',
      tipoRegistro: map['tipoRegistro'] ?? '',
    );
  }

  // Metodo toJson
  Map<String, dynamic> toJson() => toMap();
}
