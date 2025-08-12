// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '21_veiculos_model.g.dart';

@HiveType(typeId: 21)
class VeiculoCar extends BaseModel {
  @HiveField(7)
  String marca;

  @HiveField(8)
  String modelo;

  @HiveField(9)
  int ano;

  @HiveField(10)
  String placa;

  @HiveField(11)
  double odometroInicial;

  @HiveField(12)
  int combustivel;

  @HiveField(13)
  String renavan;

  @HiveField(14)
  String chassi;

  @HiveField(15)
  String cor;

  @HiveField(16)
  bool vendido;

  @HiveField(17)
  double valorVenda;

  @HiveField(18)
  double odometroAtual;

  @HiveField(19)
  String? foto;

  VeiculoCar({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.odometroInicial,
    this.combustivel = 0,
    this.renavan = '',
    this.chassi = '',
    this.cor = '',
    this.vendido = false,
    this.valorVenda = 0.0,
    this.odometroAtual = 0.0,
    this.foto,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'placa': placa,
        'odometroInicial': odometroInicial,
        'combustivel': combustivel,
        'renavan': renavan,
        'chassi': chassi,
        'cor': cor,
        'vendido': vendido,
        'valorVenda': valorVenda,
        'odometroAtual': odometroAtual,
        'foto': foto,
      });
  }

  /// Cria uma instância de `VeiculoCar` a partir de um mapa
  factory VeiculoCar.fromMap(Map<String, dynamic> map) {
    return VeiculoCar(
      id: map['id']?.toString(),
      createdAt: map['createdAt']?.toInt(),
      updatedAt: map['updatedAt']?.toInt(),
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      marca: map['marca']?.toString() ?? '',
      modelo: map['modelo']?.toString() ?? '',
      ano: map['ano']?.toInt() ?? 0,
      placa: map['placa']?.toString() ?? '',
      odometroInicial: (map['odometroInicial'] ?? 0.0).toDouble(),
      combustivel: map['combustivel']?.toInt() ?? 0,
      renavan: map['renavan']?.toString() ?? '',
      chassi: map['chassi']?.toString() ?? '',
      cor: map['cor']?.toString() ?? '',
      vendido: map['vendido'] ?? false,
      valorVenda: (map['valorVenda'] ?? 0.0).toDouble(),
      odometroAtual: (map['odometroAtual'] ?? 0.0).toDouble(),
      foto: map['foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
