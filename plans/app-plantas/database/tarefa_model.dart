// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part 'tarefa_model.g.dart';

@HiveType(typeId: 84)
class TarefaModel extends BaseModel {
  @HiveField(7)
  String plantaId;

  @HiveField(8)
  String tipoCuidado;

  @HiveField(9)
  DateTime dataExecucao;

  @HiveField(10)
  bool concluida;

  @HiveField(11)
  String? observacoes;

  @HiveField(12)
  DateTime? dataConclusao;

  TarefaModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.plantaId,
    required this.tipoCuidado,
    required this.dataExecucao,
    this.concluida = false,
    this.observacoes,
    this.dataConclusao,
  });

  @override
  TarefaModel copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? plantaId,
    String? tipoCuidado,
    DateTime? dataExecucao,
    bool? concluida,
    String? observacoes,
    DateTime? dataConclusao,
  }) {
    return TarefaModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plantaId: plantaId ?? this.plantaId,
      tipoCuidado: tipoCuidado ?? this.tipoCuidado,
      dataExecucao: dataExecucao ?? this.dataExecucao,
      concluida: concluida ?? this.concluida,
      observacoes: observacoes ?? this.observacoes,
      dataConclusao: dataConclusao ?? this.dataConclusao,
    )..updateBase(
        isDeleted: isDeleted,
        needsSync: needsSync,
        lastSyncAt: lastSyncAt,
        version: version,
      );
  }

  /// Marca a tarefa como concluída
  TarefaModel marcarConcluida({String? observacoes}) {
    return copyWith(
      concluida: true,
      dataConclusao: DateTime.now(),
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Marca a tarefa como pendente
  TarefaModel marcarPendente() {
    return copyWith(
      concluida: false,
      dataConclusao: null,
    );
  }

  /// Verifica se a tarefa está atrasada
  bool get isAtrasada {
    if (concluida) return false;
    final hoje = DateTime.now();
    final dataExecucaoDate =
        DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isBefore(hojeDate);
  }

  /// Verifica se a tarefa é para hoje
  bool get isParaHoje {
    final hoje = DateTime.now();
    final dataExecucaoDate =
        DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isAtSameMomentAs(hojeDate);
  }

  /// Verifica se a tarefa é para o futuro
  bool get isParaFuturo {
    final hoje = DateTime.now();
    final dataExecucaoDate =
        DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return dataExecucaoDate.isAfter(hojeDate);
  }

  /// Calcula quantos dias está atrasada (retorna 0 se não estiver atrasada)
  int get diasAtrasada {
    if (!isAtrasada) return 0;
    final hoje = DateTime.now();
    final dataExecucaoDate =
        DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
    final hojeDate = DateTime(hoje.year, hoje.month, hoje.day);
    return hojeDate.difference(dataExecucaoDate).inDays;
  }

  /// Retorna o status em texto
  String get statusTexto {
    if (concluida) return 'Concluída';
    if (isAtrasada) return 'Atrasada';
    if (isParaHoje) return 'Para hoje';
    return 'Agendada';
  }

  /// Retorna o nome amigável do tipo de cuidado
  String get tipoCuidadoNome {
    switch (tipoCuidado) {
      case 'agua':
        return 'Regar';
      case 'adubo':
        return 'Adubar';
      case 'banho_sol':
        return 'Banho de sol';
      case 'inspecao_pragas':
        return 'Inspeção de pragas';
      case 'poda':
        return 'Podar';
      case 'replantar':
        return 'Replantar';
      default:
        return tipoCuidado;
    }
  }

  /// Lista de tipos de cuidado válidos
  static const List<String> tiposCuidadoValidos = [
    'agua',
    'adubo',
    'banho_sol',
    'inspecao_pragas',
    'poda',
    'replantar',
  ];

  /// Verifica se o tipo de cuidado é válido
  bool get tipoValido => tiposCuidadoValidos.contains(tipoCuidado);

  /// Verifica se a tarefa está pendente (não concluída)
  bool get pendente => !concluida;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'plantaId': plantaId,
      'tipoCuidado': tipoCuidado,
      'dataExecucao': dataExecucao.toIso8601String(),
      'concluida': concluida,
      'observacoes': observacoes,
      'dataConclusao': dataConclusao?.toIso8601String(),
    };
  }

  static TarefaModel fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return TarefaModel(
      id: json['id'] ?? '',
      createdAt: _extractTimestamp(json['createdAt']) ?? now,
      updatedAt: _extractTimestamp(json['updatedAt']) ?? now,
      plantaId: json['plantaId'] as String,
      tipoCuidado: json['tipoCuidado'] as String,
      dataExecucao: DateTime.parse(json['dataExecucao'] as String),
      concluida: json['concluida'] as bool,
      observacoes: json['observacoes'] as String?,
      dataConclusao: json['dataConclusao'] != null
          ? DateTime.parse(json['dataConclusao'] as String)
          : null,
    );
  }

  /// Converte Timestamp do Firestore ou int para int
  static int? _extractTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }

  @override
  String toString() {
    return 'TarefaModel(id: $id, plantaId: $plantaId, tipoCuidado: $tipoCuidado, dataExecucao: $dataExecucao, concluida: $concluida)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TarefaModel &&
        other.id == id &&
        other.plantaId == plantaId &&
        other.tipoCuidado == tipoCuidado &&
        other.dataExecucao == dataExecucao &&
        other.concluida == concluida &&
        other.observacoes == observacoes &&
        other.dataConclusao == dataConclusao;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      plantaId,
      tipoCuidado,
      dataExecucao,
      concluida,
      observacoes,
      dataConclusao,
    );
  }
}
