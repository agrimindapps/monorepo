// Project imports:
import '../../../../models/11_animal_model.dart';

class AnimalFormModel {
  String nome;
  String especie;
  String raca;
  int dataNascimento;
  String sexo;
  String cor;
  double pesoAtual;
  String? foto;
  String? observacoes;

  AnimalFormModel({
    this.nome = '',
    this.especie = 'Cachorro',
    this.raca = '',
    int? dataNascimento,
    this.sexo = 'Macho',
    this.cor = '',
    this.pesoAtual = 0.0,
    this.foto,
    this.observacoes = '',
  }) : dataNascimento = dataNascimento ?? DateTime.now().millisecondsSinceEpoch;

  factory AnimalFormModel.fromAnimal(Animal animal) {
    return AnimalFormModel(
      nome: animal.nome,
      especie: animal.especie,
      raca: animal.raca,
      dataNascimento: animal.dataNascimento,
      sexo: animal.sexo,
      cor: animal.cor,
      pesoAtual: animal.pesoAtual,
      foto: animal.foto,
      observacoes: animal.observacoes,
    );
  }

  Animal toAnimal({String? id, int? createdAt}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Animal(
      id: id ?? '',
      createdAt: createdAt ?? now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      nome: nome,
      especie: especie,
      raca: raca,
      dataNascimento: dataNascimento,
      sexo: sexo,
      cor: cor,
      pesoAtual: pesoAtual,
      foto: foto,
      observacoes: observacoes,
    );
  }

  void updateFromAnimal(Animal animal) {
    nome = animal.nome;
    especie = animal.especie;
    raca = animal.raca;
    dataNascimento = animal.dataNascimento;
    sexo = animal.sexo;
    cor = animal.cor;
    pesoAtual = animal.pesoAtual;
    foto = animal.foto;
    observacoes = animal.observacoes;
  }

  void reset() {
    nome = '';
    especie = 'Cachorro';
    raca = '';
    dataNascimento = DateTime.now().millisecondsSinceEpoch;
    sexo = 'Macho';
    cor = '';
    pesoAtual = 0.0;
    foto = null;
    observacoes = '';
  }
}
