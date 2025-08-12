// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '16_vacina_model.g.dart';

@HiveType(typeId: 16)
class VacinaVet extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  String nomeVacina;

  @HiveField(9)
  int dataAplicacao;

  @HiveField(10)
  int proximaDose;

  @HiveField(11)
  String? observacoes;

  VacinaVet({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.nomeVacina,
    required this.dataAplicacao,
    required this.proximaDose,
    this.observacoes,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'animalId': animalId,
        'nomeVacina': nomeVacina,
        'dataAplicacao': dataAplicacao,
        'proximaDose': proximaDose,
        'observacoes': observacoes,
      });
  }

  /// Cria uma instância de `VacinaVet` a partir de um mapa
  factory VacinaVet.fromMap(Map<String, dynamic> map) {
    return VacinaVet(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      nomeVacina: map['nomeVacina'] ?? '',
      dataAplicacao: map['dataAplicacao'] ?? 0,
      proximaDose: map['proximaDose'] ?? 0,
      observacoes: map['observacoes'],
    );
  }

  /// Verifica se a próxima dose está atrasada
  // bool isDoseAtrasada() {
  //   return DateTime.now().isAfter(proximaDose);
  // }

  /// Calcula os dias restantes para a próxima dose
  // int diasParaProximaDose() {
  //   final hoje = DateTime.now();
  //   return proximaDose
  //       .difference(hoje)
  //       .inDays
  //       .clamp(0, proximaDose.difference(dataAplicacao).inDays);
  // }

  /// Retorna se a vacina foi aplicada recentemente (nos últimos 7 dias)
  // bool foiAplicadaRecentemente() {
  //   final hoje = DateTime.now();
  //   return hoje.difference(dataAplicacao).inDays <= 7;
  // }

  /// Retorna uma string formatada com as informações principais da vacina
  // String resumoVacina() {
  //   return "Vacina: $nomeVacina, Aplicação: ${dataAplicacao.day}/${dataAplicacao.month}/${dataAplicacao.year}, "
  //       "Próxima Dose: ${proximaDose.day}/${proximaDose.month}/${proximaDose.year}";
  // }

  /// Atualiza a data da próxima dose
  // void atualizarProximaDose(DateTime novaProximaDose) {
  //   if (novaProximaDose.isAfter(dataAplicacao)) {
  //     proximaDose = novaProximaDose;
  //     updatedAt = DateTime.now().millisecondsSinceEpoch;
  //   } else {
  //     throw ArgumentError(
  //         "A data da próxima dose deve ser posterior à data de aplicação.");
  //   }
  // }

  /// Valida os dados do registro de vacina
  // bool validarDados() {
  //   return nomeVacina.isNotEmpty &&
  //       animalId.isNotEmpty &&
  //       dataAplicacao.isBefore(proximaDose);
  // }

  /// Clona o objeto atual
  @override
  VacinaVet copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    String? nomeVacina,
    int? dataAplicacao,
    int? proximaDose,
    String? observacoes,
  }) {
    return VacinaVet(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      nomeVacina: nomeVacina ?? this.nomeVacina,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
      proximaDose: proximaDose ?? this.proximaDose,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Sobrescreve o operador de igualdade para comparar IDs
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VacinaVet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
