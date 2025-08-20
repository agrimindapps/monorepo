// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '17_peso_model.g.dart';

@HiveType(typeId: 17)
class PesoAnimal extends BaseModel {
  @HiveField(7)
  String animalId;

  @HiveField(8)
  double peso;

  @HiveField(9)
  int dataPesagem;

  @HiveField(10)
  String? observacoes;

  PesoAnimal({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.animalId,
    required this.peso,
    required this.dataPesagem,
    this.observacoes,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'animalId': animalId,
      'peso': peso,
      'dataPesagem': dataPesagem,
      'observacoes': observacoes,
    });
    return map;
  }

  factory PesoAnimal.fromMap(Map<String, dynamic> map) {
    return PesoAnimal(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      animalId: map['animalId'] ?? '',
      peso: map['peso']?.toDouble() ?? 0.0,
      dataPesagem: map['dataPesagem'] ?? 0,
      observacoes: map['observacoes'],
    );
  }

  @override
  PesoAnimal copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? animalId,
    double? peso,
    int? dataPesagem,
    String? observacoes,
  }) {
    return PesoAnimal(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      animalId: animalId ?? this.animalId,
      peso: peso ?? this.peso,
      dataPesagem: dataPesagem ?? this.dataPesagem,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  bool validarDados() {
    if (animalId.isEmpty) return false;
    if (peso <= 0) return false;
    return true;
  }
}
