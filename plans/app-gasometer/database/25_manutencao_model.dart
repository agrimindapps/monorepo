// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '25_manutencao_model.g.dart';

@HiveType(typeId: 25)
class ManutencaoCar extends BaseModel {
  @HiveField(7)
  String veiculoId;

  @HiveField(8)
  String tipo; // Preventiva, Corretiva, Revisão

  @HiveField(9)
  String descricao;

  @HiveField(10)
  double valor;

  @HiveField(11)
  int data;

  @HiveField(12)
  int odometro;

  @HiveField(13)
  int? proximaRevisao;

  @HiveField(14)
  bool concluida;

  ManutencaoCar({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.veiculoId,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.odometro,
    this.proximaRevisao,
    this.concluida = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'veiculoId': veiculoId,
        'tipo': tipo,
        'descricao': descricao,
        'valor': valor,
        'data': data,
        'odometro': odometro,
        'proximaRevisao': proximaRevisao,
        'concluida': concluida,
      });
  }

  factory ManutencaoCar.fromMap(Map<String, dynamic> map) {
    return ManutencaoCar(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      veiculoId: map['veiculoId'] ?? '',
      tipo: map['tipo'] ?? '',
      descricao: map['descricao'] ?? '',
      valor: map['valor'] ?? 0.0,
      data: map['data'] ?? 0,
      odometro: map['odometro'] ?? 0,
      proximaRevisao: map['proximaRevisao'],
      concluida: map['concluida'] ?? false,
    );
  }

  // Metodo toJson
  Map<String, dynamic> toJson() => toMap();

  static double calcularTotalManutencoes(List<ManutencaoCar> manutencoes) {
    return manutencoes.fold(
      0.0,
      (total, manutencao) => total + manutencao.valor,
    );
  }

  // String resumoManutencao() {
  //   return "Tipo: $tipo, Descrição: $descricao, Valor: R\$${valor.toStringAsFixed(2)}, Data: ${data.toIso8601String()}, KM: $odometro";
  // }

  static List<ManutencaoCar> filtrarPorTipo(
    List<ManutencaoCar> manutencoes,
    String tipo,
  ) {
    return manutencoes.where((manutencao) => manutencao.tipo == tipo).toList();
  }

  static List<ManutencaoCar> ordenarPorData(List<ManutencaoCar> manutencoes) {
    manutencoes.sort((a, b) => b.data.compareTo(a.data));
    return manutencoes;
  }

  bool possuiMaiorValor(ManutencaoCar outraManutencao) {
    return valor > outraManutencao.valor;
  }

  bool pertenceAData(DateTime dataAlvo) {
    return DateTime.fromMillisecondsSinceEpoch(data).isAtSameMomentAs(dataAlvo);
  }

  bool estaVencida() {
    if (proximaRevisao == null) return false;
    return DateTime.now().millisecondsSinceEpoch > proximaRevisao!;
  }

  bool precisaRevisao(int odometroAtual) {
    const int intervaloRevisao = 10000; // 10.000 km
    return (odometroAtual - odometro) >= intervaloRevisao;
  }

  ManutencaoCar clone() {
    return ManutencaoCar(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      needsSync: needsSync,
      lastSyncAt: lastSyncAt,
      version: version,
      veiculoId: veiculoId,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      data: data,
      odometro: odometro,
      proximaRevisao: proximaRevisao,
      concluida: concluida,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ManutencaoCar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool valorDentroDoIntervalo(double min, double max) {
    return valor >= min && valor <= max;
  }
}
