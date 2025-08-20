// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'normalize.dart';

class BulasClass {
  int createdAt;
  int updatedAt;
  bool status;
  String idReg;
  String descricao;
  String? fabricante;
  List<String>? imagens;
  String miniatura;
  String bula;
  List<String>? animais;

  BulasClass({
    this.createdAt = 0,
    this.updatedAt = 0,
    this.status = false,
    this.idReg = '',
    this.descricao = '',
    this.fabricante,
    this.imagens,
    this.miniatura = '',
    this.bula = '',
    this.animais,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['status'] = status;
    data['idReg'] = idReg;
    data['descricao'] = descricao;
    data['fabricante'] = fabricante;
    data['imagens'] = imagens;
    data['miniatura'] = miniatura;
    data['bula'] = bula;
    data['animais'] = animais;
    return data;
  }

  Map<String, dynamic> toMap(BulasClass reg) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = reg.createdAt;
    data['updatedAt'] = reg.updatedAt;
    data['status'] = reg.status;
    data['idReg'] = reg.idReg;
    data['descricao'] = reg.descricao;
    data['fabricante'] = reg.fabricante;
    data['imagens'] = reg.imagens;
    data['miniatura'] = reg.miniatura;
    data['bula'] = reg.bula;
    data['animais'] = reg.animais;
    return data;
  }

  BulasClass documentToClass(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BulasClass(
      idReg: doc.id,
      createdAt: normalize(data, 'createdAt'),
      updatedAt: normalize(data, 'updatedAt'),
      status: normalize(data, 'status'),
      descricao: normalize(data, 'descricao'),
      fabricante: normalize(data, 'fabricante'),
      // imagens: normalize(data, 'imagens'),
      miniatura: normalize(data, 'miniatura'),
      bula: normalize(data, 'bula'),
      // animais: normalize(data, 'animais'),
    );
  }
}
