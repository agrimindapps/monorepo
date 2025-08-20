// Flutter imports:
import 'package:flutter/foundation.dart';

class ImplementoModel extends ChangeNotifier {
  String id;
  String descricao;
  String marca;
  bool status;
  String miniatura;
  List<String> imagens;

  ImplementoModel({
    this.id = '',
    this.descricao = '',
    this.marca = '',
    this.status = true,
    this.miniatura = '',
    this.imagens = const [],
  });

  factory ImplementoModel.fromJson(Map<String, dynamic> json) {
    return ImplementoModel(
      id: json['id'] ?? '',
      descricao: json['descricao'] ?? '',
      marca: json['marca'] ?? '',
      status: json['status'] ?? true,
      miniatura: json['miniatura'] ?? '',
      imagens: List<String>.from(json['imagens'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'marca': marca,
      'status': status,
      'miniatura': miniatura,
      'imagens': imagens,
    };
  }

  void updateFrom(ImplementoModel other) {
    id = other.id;
    descricao = other.descricao;
    marca = other.marca;
    status = other.status;
    miniatura = other.miniatura;
    imagens = List.from(other.imagens);
    notifyListeners();
  }
}
