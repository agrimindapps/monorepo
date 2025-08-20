// Project imports:
import '../../core/models/base_model.dart';

class BovinoClass extends BaseModel {
  bool status;
  String idReg;
  String nomeComum;
  String paisOrigem;
  List<String>? imagens;
  String? miniatura;
  String tipoAnimal;
  String origem;
  String caracteristicas;

  // Novos campos para categorização
  String raca;
  String aptidao;
  List<String> tags;
  String sistemaCriacao;
  String finalidade;

  BovinoClass({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    this.status = false,
    this.idReg = '',
    this.nomeComum = '',
    this.paisOrigem = '',
    this.imagens = const [],
    this.miniatura = '',
    this.tipoAnimal = '',
    this.origem = '',
    this.caracteristicas = '',
    this.raca = '',
    this.aptidao = '',
    this.tags = const [],
    this.sistemaCriacao = '',
    this.finalidade = '',
  });

  //Converter para json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['idReg'] = idReg;
    data['nomeComum'] = nomeComum;
    data['paisOrigem'] = paisOrigem;
    data['imagens'] = imagens;
    data['miniatura'] = miniatura;
    data['tipoAnimal'] = tipoAnimal;
    data['origem'] = origem;
    data['caracteristicas'] = caracteristicas;
    data['raca'] = raca;
    data['aptidao'] = aptidao;
    data['tags'] = tags;
    data['sistemaCriacao'] = sistemaCriacao;
    data['finalidade'] = finalidade;
    return data;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['id_reg'] = idReg;
    data['nome_comum'] = nomeComum;
    data['pais_origem'] = paisOrigem;
    data['imagens'] = imagens;
    data['miniatura'] = miniatura;
    data['tipo_animal'] = tipoAnimal;
    data['origem'] = origem;
    data['caracteristicas'] = caracteristicas;
    data['raca'] = raca;
    data['aptidao'] = aptidao;
    data['tags'] = tags;
    data['sistema_criacao'] = sistemaCriacao;
    data['finalidade'] = finalidade;
    return data;
  }

  //factory empty
  factory BovinoClass.empty() {
    return BovinoClass(
      id: '',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      status: false,
      idReg: '',
      nomeComum: '',
      paisOrigem: '',
      imagens: [],
      miniatura: '',
      tipoAnimal: '',
      origem: '',
      caracteristicas: '',
      raca: '',
      aptidao: '',
      tags: [],
      sistemaCriacao: '',
      finalidade: '',
    );
  }

  //fromMap
  factory BovinoClass.fromMap(Map<String, dynamic> map) {
    return BovinoClass(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ??
          map['created_at'] ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAt: map['updatedAt'] ??
          map['updated_at'] ??
          DateTime.now().millisecondsSinceEpoch,
      status: map['status'] ?? false,
      idReg: map['idReg'] ?? map['id_reg'] ?? '',
      nomeComum: map['nomeComum'] ?? map['nome_comum'] ?? '',
      paisOrigem: map['paisOrigem'] ?? map['pais_origem'] ?? '',
      imagens: List<String>.from(map['imagens'] ?? []),
      miniatura: map['miniatura'] ?? '',
      tipoAnimal: map['tipoAnimal'] ?? map['tipo_animal'] ?? '',
      origem: map['origem'] ?? '',
      caracteristicas: map['caracteristicas'] ?? '',
      raca: map['raca'] ?? '',
      aptidao: map['aptidao'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      sistemaCriacao: map['sistemaCriacao'] ?? map['sistema_criacao'] ?? '',
      finalidade: map['finalidade'] ?? '',
    );
  }
}
