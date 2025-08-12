// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '22_despesas_model.g.dart';

@HiveType(typeId: 22)
class DespesaCar extends BaseModel {
  @HiveField(7)
  String veiculoId;

  @HiveField(8)
  String tipo;

  @HiveField(9)
  String descricao;

  @HiveField(10)
  double valor;

  @HiveField(11)
  int data;

  @HiveField(12)
  double odometro;

  DespesaCar({
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
  });

  /// Converte o objeto para um mapa
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
      });
  }

  /// Cria uma instância de `DespesaCar` a partir de um mapa
  factory DespesaCar.fromMap(Map<String, dynamic> map) {
    return DespesaCar(
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
      odometro: map['odometro'] ?? 0.0,
    );
  }

  // Metodo toJson
  Map<String, dynamic> toJson() => toMap();

  /// Calcula o valor total das despesas em uma lista de despesas
  static double calcularTotalDespesas(List<DespesaCar> despesas) {
    return despesas.fold(0.0, (total, despesa) => total + despesa.valor);
  }

  /// Retorna uma string formatada com os dados da despesa
  // String resumoDespesa() {
  //   return "Tipo: $tipo, Descrição: $descricao, Valor: R\$${valor.toStringAsFixed(2)}, Data: ${data.toIso8601String()}";
  // }

  /// Filtra despesas por tipo em uma lista
  static List<DespesaCar> filtrarPorTipo(
    List<DespesaCar> despesas,
    String tipo,
  ) {
    return despesas.where((despesa) => despesa.tipo == tipo).toList();
  }

  /// Ordena uma lista de despesas por data (mais recente primeiro)
  static List<DespesaCar> ordenarPorData(List<DespesaCar> despesas) {
    despesas.sort((a, b) => b.data.compareTo(a.data));
    return despesas;
  }

  /// Compara duas despesas para ver qual tem o maior valor
  bool possuiMaiorValor(DespesaCar outraDespesa) {
    return valor > outraDespesa.valor;
  }

  /// Verifica se a despesa pertence a uma data específica
  bool pertenceAData(DateTime dataAlvo) {
    return DateTime.fromMillisecondsSinceEpoch(data).isAtSameMomentAs(dataAlvo);
  }

  /// Clona o objeto atual
  DespesaCar clone() {
    return DespesaCar(
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
    );
  }

  /// Sobrescreve o operador de igualdade para comparar por ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DespesaCar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Verifica se o valor da despesa está dentro de um intervalo
  bool valorDentroDoIntervalo(double min, double max) {
    return valor >= min && valor <= max;
  }
}
