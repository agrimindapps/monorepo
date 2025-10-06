class Fitossanitario {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String nomeComum;
  String nomeTecnico;
  String? classeAgronomica;
  String? fabricante;
  String? classAmbiental;
  int comercializado;
  String? corrosivo;
  String? inflamavel;
  String? formulacao;
  String? modoAcao;
  String? mapa;
  String? toxico;
  String? ingredienteAtivo;
  String? quantProduto;
  bool elegivel;

  Fitossanitario(
      {this.objectId = '',
      this.createdAt = 0,
      this.updatedAt = 0,
      this.idReg = '',
      this.status = 1,
      this.nomeComum = '',
      this.nomeTecnico = '',
      this.comercializado = 0,
      this.classeAgronomica = '',
      this.fabricante = '',
      this.classAmbiental = '',
      this.corrosivo = '',
      this.inflamavel = '',
      this.formulacao = '',
      this.modoAcao = '',
      this.mapa = '',
      this.toxico = '',
      this.ingredienteAtivo = '',
      this.quantProduto = '',
      this.elegivel = false});

  factory Fitossanitario.fromJson(Map<String, dynamic> json) {
    return Fitossanitario(
        objectId: json['objectId'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        idReg: json['IdReg'],
        status: json['Status'],
        nomeComum: json['nomeComum'],
        nomeTecnico: json['nomeTecnico'],
        classeAgronomica: json['classeAgronomica'],
        fabricante: json['fabricante'],
        classAmbiental: json['classAmbiental'],
        comercializado: json['comercializado'],
        corrosivo: json['corrosivo'],
        inflamavel: json['inflamavel'],
        formulacao: json['formulacao'],
        modoAcao: json['modoAcao'],
        mapa: json['mapa'],
        toxico: json['toxico'],
        ingredienteAtivo: json['ingredienteAtivo'],
        quantProduto: json['quantProduto'],
        elegivel: json['elegivel']);
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
      'nomeComum': nomeComum,
      'nomeTecnico': nomeTecnico,
      'classeAgronomica': classeAgronomica,
      'fabricante': fabricante,
      'classAmbiental': classAmbiental,
      'comercializado': comercializado,
      'corrosivo': corrosivo,
      'inflamavel': inflamavel,
      'formulacao': formulacao,
      'modoAcao': modoAcao,
      'mapa': mapa,
      'toxico': toxico,
      'ingredienteAtivo': ingredienteAtivo,
      'quantProduto': quantProduto,
      'elegivel': elegivel
    };
  }
}
