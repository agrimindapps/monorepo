// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '14_lembrete_model.g.dart';

@HiveType(typeId: 14)
class LembreteVet extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  String titulo;

  @HiveField(9)
  String descricao;

  @HiveField(10)
  int dataHora;

  @HiveField(11)
  String tipo; // Consulta, Vacina, Medicamento, etc.

  @HiveField(12)
  String repetir; // Sem repetição, Diário, Semanal, etc.

  @HiveField(13)
  bool concluido; // Pendente, Concluído

  LembreteVet({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.repetir,
    required this.concluido,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'animalId': animalId,
        'titulo': titulo,
        'descricao': descricao,
        'dataHora': dataHora,
        'tipo': tipo,
        'repetir': repetir,
        'concluido': concluido,
      });
  }

  /// Cria uma instância de `LembreteVet` a partir de um mapa
  factory LembreteVet.fromMap(Map<String, dynamic> map) {
    return LembreteVet(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      dataHora: map['dataHora'] ?? 0,
      tipo: map['tipo'] ?? '',
      repetir: map['repetir'] ?? 'Sem repetição',
      concluido: map['concluido'] ?? false,
    );
  }

  /// Atualiza o status do lembrete (concluído ou pendente)
  void atualizarStatus(bool status) {
    concluido = status;
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Retorna se o lembrete é para hoje
  // bool isHoje() {
  //   final hoje = DateTime.now();
  //   return dataHora.year == hoje.year &&
  //       dataHora.month == hoje.month &&
  //       dataHora.day == hoje.day;
  // }

  /// Verifica se o lembrete já passou
  // bool isAtrasado() {
  //   return !concluido && dataHora.isBefore(DateTime.now());
  // }

  /// Formata a data e hora do lembrete no padrão amigável
  // String formatarDataHora() {
  //   return "${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year} ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}";
  // }

  /// Retorna a descrição da repetição em português
  String descricaoRepeticao() {
    switch (repetir.toLowerCase()) {
      case 'diário':
        return 'Todos os dias';
      case 'semanal':
        return 'Semanalmente';
      case 'mensal':
        return 'Mensalmente';
      default:
        return 'Sem repetição';
    }
  }

  /// Clona o objeto atual
  @override
  LembreteVet copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    String? titulo,
    String? descricao,
    int? dataHora,
    String? tipo,
    String? repetir,
    bool? concluido,
  }) {
    return LembreteVet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataHora: dataHora ?? this.dataHora,
      tipo: tipo ?? this.tipo,
      repetir: repetir ?? this.repetir,
      concluido: concluido ?? this.concluido,
    );
  }

  /// Retorna um resumo do lembrete
  // String resumo() {
  //   return "Lembrete: $titulo, Data: ${formatarDataHora()}, Concluído: ${concluido ? 'Sim' : 'Não'}";
  // }

  /// Valida se os dados do lembrete estão preenchidos corretamente
  bool validarDados() {
    return titulo.isNotEmpty && descricao.isNotEmpty && tipo.isNotEmpty;
  }

  /// Compara dois objetos `LembreteVet` pelo ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LembreteVet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
