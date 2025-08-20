// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '11_animal_model.g.dart';

@HiveType(typeId: 11)
class Animal extends BaseModel {
  @HiveField(7)
  String nome;

  @HiveField(8)
  String especie; // Gato ou Cachorro

  @HiveField(9)
  String raca;

  @HiveField(10)
  int dataNascimento;

  @HiveField(11)
  String sexo; // Macho ou Fêmea

  @HiveField(12)
  String cor;

  @HiveField(13)
  double pesoAtual;

  @HiveField(14)
  String? foto;

  @HiveField(15)
  String? observacoes;

  Animal({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.dataNascimento,
    required this.sexo,
    required this.cor,
    required this.pesoAtual,
    this.foto,
    this.observacoes,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'nome': nome,
        'especie': especie,
        'raca': raca,
        'dataNascimento': dataNascimento,
        'sexo': sexo,
        'cor': cor,
        'pesoAtual': pesoAtual,
        'foto': foto,
        'observacoes': observacoes,
      });
  }

  /// Converte um mapa para o objeto Animal
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      nome: map['nome'] ?? '',
      especie: map['especie'] ?? '',
      raca: map['raca'] ?? '',
      dataNascimento: map['dataNascimento'] ?? 0,
      sexo: map['sexo'] ?? '',
      cor: map['cor'] ?? '',
      pesoAtual: map['pesoAtual']?.toDouble() ?? 0.0,
      foto: map['foto'],
      observacoes: map['observacoes'],
    );
  }

  /// Atualiza informações do Animal
  void updateAnimal({
    String? nome,
    String? especie,
    String? raca,
    int? dataNascimento,
    String? sexo,
    String? cor,
    double? pesoAtual,
    String? foto,
    String? observacoes,
  }) {
    if (nome != null) this.nome = nome;
    if (especie != null) this.especie = especie;
    if (raca != null) this.raca = raca;
    if (dataNascimento != null) this.dataNascimento = dataNascimento;
    if (sexo != null) this.sexo = sexo;
    if (cor != null) this.cor = cor;
    if (pesoAtual != null) this.pesoAtual = pesoAtual;
    if (foto != null) this.foto = foto;
    if (observacoes != null) this.observacoes = observacoes;

    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Calcula a idade do animal em anos
  // int calcularIdade() {
  //   final now = DateTime.now();
  //   return now.year -
  //       dataNascimento.year -
  //       ((now.month < dataNascimento.month ||
  //               (now.month == dataNascimento.month &&
  //                   now.day < dataNascimento.day))
  //           ? 1
  //           : 0);
  // }

  /// Verifica se o animal é um filhote
  // bool isFilhote() {
  //   return calcularIdade() < 1;
  // }

  /// Formata o peso do animal com unidade
  // String formatarPeso() {
  //   return "${pesoAtual.toStringAsFixed(1)} kg";
  // }

  /// Clona o objeto atual
  @override
  Animal copyWith({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
    String? nome,
    String? especie,
    String? raca,
    int? dataNascimento,
    String? sexo,
    String? cor,
    double? pesoAtual,
    String? foto,
    String? observacoes,
  }) {
    return Animal(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      version: version ?? this.version,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      raca: raca ?? this.raca,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      sexo: sexo ?? this.sexo,
      cor: cor ?? this.cor,
      pesoAtual: pesoAtual ?? this.pesoAtual,
      foto: foto ?? this.foto,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  /// Compara objetos Animal pelo ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Animal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
