// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '15_medicamento_model.g.dart';

@HiveType(typeId: 15)
class MedicamentoVet extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  String nomeMedicamento;

  @HiveField(9)
  String dosagem;

  @HiveField(10)
  String frequencia; // Exemplo: "2x ao dia"

  @HiveField(11)
  String duracao; // Exemplo: "7 dias"

  @HiveField(12)
  int inicioTratamento;

  @HiveField(13)
  int fimTratamento;

  @HiveField(14)
  String? observacoes;

  MedicamentoVet({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.nomeMedicamento,
    required this.dosagem,
    required this.frequencia,
    required this.duracao,
    required this.inicioTratamento,
    required this.fimTratamento,
    this.observacoes,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'animalId': animalId,
        'nomeMedicamento': nomeMedicamento,
        'dosagem': dosagem,
        'frequencia': frequencia,
        'duracao': duracao,
        'inicioTratamento': inicioTratamento,
        'fimTratamento': fimTratamento,
        'observacoes': observacoes,
      });
  }

  /// Cria uma instância de `MedicamentoVet` a partir de um mapa
  factory MedicamentoVet.fromMap(Map<String, dynamic> map) {
    return MedicamentoVet(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      nomeMedicamento: map['nomeMedicamento'] ?? '',
      dosagem: map['dosagem'] ?? '',
      frequencia: map['frequencia'] ?? '',
      duracao: map['duracao'] ?? '',
      inicioTratamento: map['inicioTratamento'],
      fimTratamento: map['fimTratamento'],
      observacoes: map['observacoes'],
    );
  }

  /// Verifica se o tratamento ainda está em andamento
  // bool isTratamentoAtivo() {
  //   final hoje = DateTime.now();
  //   return hoje.isAfter(inicioTratamento) && hoje.isBefore(fimTratamento);
  // }

  /// Calcula a duração total do tratamento em dias
  // int duracaoTotalDias() {
  //   return fimTratamento.difference(inicioTratamento).inDays + 1;
  // }

  /// Retorna os dias restantes para o fim do tratamento
  // int diasRestantes() {
  //   final hoje = DateTime.now();
  //   return fimTratamento.difference(hoje).inDays.clamp(0, duracaoTotalDias());
  // }

  /// Formata o intervalo de tratamento como string amigável
  // String intervaloTratamento() {
  //   return "${inicioTratamento.day}/${inicioTratamento.month}/${inicioTratamento.year} - "
  //          "${fimTratamento.day}/${fimTratamento.month}/${fimTratamento.year}";
  // }

  /// Retorna um resumo amigável do medicamento
  // String resumo() {
  //   return "Medicamento: $nomeMedicamento, Dosagem: $dosagem, Frequência: $frequencia, "
  //          "Duração: $duracao, Intervalo: ${intervaloTratamento()}";
  // }

  /// Valida os dados do medicamento
  // bool validarDados() {
  //   return nomeMedicamento.isNotEmpty &&
  //       dosagem.isNotEmpty &&
  //       frequencia.isNotEmpty &&
  //       inicioTratamento.isBefore(fimTratamento);
  // }

  /// Atualiza o período do tratamento
  // void atualizarPeriodo(DateTime novoInicio, DateTime novoFim) {
  //   if (novoInicio.isBefore(novoFim)) {
  //     inicioTratamento = novoInicio;
  //     fimTratamento = novoFim;
  //     updatedAt = DateTime.now().millisecondsSinceEpoch;
  //   } else {
  //     throw ArgumentError("A data de início deve ser antes da data de término.");
  //   }
  // }

  /// Clona o objeto atual
  @override
  MedicamentoVet copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    String? nomeMedicamento,
    String? dosagem,
    String? frequencia,
    String? duracao,
    int? inicioTratamento,
    int? fimTratamento,
    String? observacoes,
  }) {
    return MedicamentoVet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      nomeMedicamento: nomeMedicamento ?? this.nomeMedicamento,
      dosagem: dosagem ?? this.dosagem,
      frequencia: frequencia ?? this.frequencia,
      duracao: duracao ?? this.duracao,
      inicioTratamento: inicioTratamento ?? this.inicioTratamento,
      fimTratamento: fimTratamento ?? this.fimTratamento,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Sobrescreve o operador de igualdade para comparar IDs
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicamentoVet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
