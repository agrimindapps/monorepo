class ImplementosClass {
  String idReg;
  bool status;
  String descricao;
  String marca;
  List<String> imagens;
  String miniatura;

  ImplementosClass({
    this.idReg = '',
    this.status = false,
    this.descricao = '',
    this.marca = '',
    this.imagens = const [],
    this.miniatura = '',
  });

  // Método para converter um documento em um objeto da classe
  ImplementosClass documentToClass(doc) {
    return ImplementosClass(
      idReg: doc.id,
      status: doc['status'],
      descricao: doc['descricao'],
      marca: doc['marca'],
      imagens: List<String>.from(doc['imagens']),
      miniatura: doc['miniatura'],
    );
  }

  // Método para converter um objeto da classe em um documento
  Map<String, dynamic> toMap(ImplementosClass equino) {
    return {
      'idReg': equino.idReg,
      'status': equino.status,
      'descricao': equino.descricao,
      'marca': equino.marca,
      'imagens': equino.imagens,
      'miniatura': equino.miniatura,
    };
  }

  // Método para serialização JSON
  Map<String, dynamic> toJson() {
    return {
      'idReg': idReg,
      'status': status,
      'descricao': descricao,
      'marca': marca,
      'imagens': imagens,
      'miniatura': miniatura,
    };
  }
}
