// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'normalize.dart';

class EquinosClass {
  int createdAt;
  int updatedAt;
  bool status;
  String idReg;
  String nomeComum;
  String paisOrigem;
  List<String>? imagens;
  String miniatura;
  String historico;
  String temperamento;
  String pelagem;
  String uso;
  String influencias;
  String altura;
  String peso;

  EquinosClass({
    this.createdAt = 0,
    this.updatedAt = 0,
    this.status = false,
    this.idReg = '',
    this.nomeComum = '',
    this.paisOrigem = '',
    this.imagens = const [],
    this.miniatura = '',
    this.historico = '',
    this.temperamento = '',
    this.pelagem = '',
    this.uso = '',
    this.influencias = '',
    this.altura = '',
    this.peso = '',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['status'] = status;
    data['idReg'] = idReg;
    data['nomeComum'] = nomeComum;
    data['paisOrigem'] = paisOrigem;
    data['imagens'] = imagens;
    data['miniatura'] = miniatura;
    data['historico'] = historico;
    data['temperamento'] = temperamento;
    data['pelagem'] = pelagem;
    data['uso'] = uso;
    data['influencias'] = influencias;
    data['altura'] = altura;
    data['peso'] = peso;
    return data;
  }

  Map<String, dynamic> toMap(EquinosClass reg) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = reg.createdAt;
    data['updatedAt'] = reg.updatedAt;
    data['status'] = reg.status;
    data['idReg'] = reg.idReg;
    data['nomeComum'] = reg.nomeComum;
    data['paisOrigem'] = reg.paisOrigem;
    data['imagens'] = reg.imagens;
    data['miniatura'] = reg.miniatura;
    data['historico'] = reg.historico;
    data['temperamento'] = reg.temperamento;
    data['pelagem'] = reg.pelagem;
    data['uso'] = reg.uso;
    data['influencias'] = reg.influencias;
    data['altura'] = reg.altura;
    data['peso'] = reg.peso;
    return data;
  }

  // Função para converter um documento em um objeto CachorrosClass
  EquinosClass documentToClass(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EquinosClass(
      idReg: doc.id,
      createdAt: normalize(data, 'createdAt'),
      updatedAt: normalize(data, 'updatedAt'),
      status: normalize(data, 'status'),
      nomeComum: normalize(data, 'nomeComum'),
      paisOrigem: normalize(data, 'paisOrigem'),
      imagens: List<String>.from(normalize(data, 'imagens')),
      miniatura: normalize(data, 'miniatura'),
      historico: normalize(data, 'historico'),
      temperamento: normalize(data, 'temperamento'),
      pelagem: normalize(data, 'pelagem'),
      uso: normalize(data, 'uso'),
      influencias: normalize(data, 'influencias'),
      altura: normalize(data, 'altura'),
      peso: normalize(data, 'peso'),
    );
  }
}
