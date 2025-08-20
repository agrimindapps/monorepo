// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '12_consulta_model.g.dart';

@HiveType(typeId: 12)
class Consulta extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  int dataConsulta;

  @HiveField(9)
  String veterinario;

  @HiveField(10)
  String motivo;

  @HiveField(11)
  String diagnostico;

  @HiveField(12)
  double valor;

  @HiveField(13)
  String? observacoes;

  Consulta({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.dataConsulta,
    required this.veterinario,
    required this.motivo,
    required this.diagnostico,
    required this.valor,
    this.observacoes,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'animalId': animalId,
        'dataConsulta': dataConsulta,
        'veterinario': veterinario,
        'motivo': motivo,
        'diagnostico': diagnostico,
        'valor': valor,
        'observacoes': observacoes,
      });
  }

  /// Converte um mapa para o objeto Consulta
  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      dataConsulta: map['dataConsulta'],
      veterinario: map['veterinario'] ?? '',
      motivo: map['motivo'] ?? '',
      diagnostico: map['diagnostico'] ?? '',
      valor: map['valor']?.toDouble() ?? 0.0,
      observacoes: map['observacoes'],
    );
  }

  /// Atualiza informações da consulta
  void updateConsulta({
    String? veterinario,
    String? motivo,
    String? diagnostico,
    double? valor,
    String? observacoes,
  }) {
    if (veterinario != null) this.veterinario = veterinario;
    if (motivo != null) this.motivo = motivo;
    if (diagnostico != null) this.diagnostico = diagnostico;
    if (valor != null) this.valor = valor;
    if (observacoes != null) this.observacoes = observacoes;

    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Verifica se a consulta é recente (realizada nos últimos 30 dias)
  // bool isRecente() {
  //   final hoje = DateTime.now();
  //   return dataConsulta.isAfter(hoje.subtract(Duration(days: 30)));
  // }

  /// Formata a data da consulta em um padrão amigável
  // String formatarDataConsulta() {
  //   return "${dataConsulta.day.toString().padLeft(2, '0')}/${dataConsulta.month.toString().padLeft(2, '0')}/${dataConsulta.year}";
  // }

  /// Formata o valor da consulta para exibição
  String formatarValor() {
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  /// Retorna se o diagnóstico possui observações adicionais
  bool possuiObservacoes() {
    return observacoes != null && observacoes!.isNotEmpty;
  }

  /// Clona o objeto atual
  @override
  Consulta copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    int? dataConsulta,
    String? veterinario,
    String? motivo,
    String? diagnostico,
    double? valor,
    String? observacoes,
  }) {
    return Consulta(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      dataConsulta: dataConsulta ?? this.dataConsulta,
      veterinario: veterinario ?? this.veterinario,
      motivo: motivo ?? this.motivo,
      diagnostico: diagnostico ?? this.diagnostico,
      valor: valor ?? this.valor,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Compara objetos Consulta pelo ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Consulta && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
