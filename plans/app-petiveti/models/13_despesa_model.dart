// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '13_despesa_model.g.dart';

@HiveType(typeId: 13)
class DespesaVet extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  int dataDespesa;

  @HiveField(9)
  String tipo; // Consulta, Medicamento, etc.

  @HiveField(10)
  String descricao;

  @HiveField(11)
  double valor;

  DespesaVet({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.dataDespesa,
    required this.tipo,
    required this.descricao,
    required this.valor,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'animalId': animalId,
        'dataDespesa': dataDespesa,
        'tipo': tipo,
        'descricao': descricao,
        'valor': valor,
      });
  }

  /// Cria uma instância de `DespesaVet` a partir de um mapa
  factory DespesaVet.fromMap(Map<String, dynamic> map) {
    return DespesaVet(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      dataDespesa: map['dataDespesa'] ?? 0,
      tipo: map['tipo'] ?? '',
      descricao: map['descricao'] ?? '',
      valor: map['valor']?.toDouble() ?? 0.0,
    );
  }

  /// Atualiza informações da despesa
  void atualizarDespesa({
    String? tipo,
    String? descricao,
    double? valor,
  }) {
    if (tipo != null) this.tipo = tipo;
    if (descricao != null) this.descricao = descricao;
    if (valor != null) this.valor = valor;

    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Verifica se a despesa foi realizada no mês atual
  // bool isDespesaAtual() {
  //   final hoje = DateTime.now();
  //   return dataDespesa.year == hoje.year && dataDespesa.month == hoje.month;
  // }

  /// Formata a data da despesa no padrão amigável
  // String formatarDataDespesa() {
  //   return "${dataDespesa.day.toString().padLeft(2, '0')}/${dataDespesa.month.toString().padLeft(2, '0')}/${dataDespesa.year}";
  // }

  /// Formata o valor da despesa para exibição
  // String formatarValor() {
  //   return "R\$ ${valor.toStringAsFixed(2)}";
  // }

  /// Retorna um resumo da despesa
  // String resumo() {
  //   return "Tipo: $tipo, Valor: ${formatarValor()}, Data: ${formatarDataDespesa()}";
  // }

  /// Clona o objeto atual
  @override
  DespesaVet copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    int? dataDespesa,
    String? tipo,
    String? descricao,
    double? valor,
  }) {
    return DespesaVet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      dataDespesa: dataDespesa ?? this.dataDespesa,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
    );
  }

  /// Compara dois objetos `DespesaVet` pelo campo ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DespesaVet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Valida os dados obrigatórios da despesa
  bool validarDados() {
    return animalId.isNotEmpty && tipo.isNotEmpty && valor > 0;
  }
}
