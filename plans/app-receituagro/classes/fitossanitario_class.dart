class Fitossanitario {
  String? objectId;
  int? createdAt;
  int? updatedAt;
  String idReg;
  bool status;
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

  Fitossanitario({
    this.objectId,
    this.createdAt,
    this.updatedAt,
    required this.idReg,
    required this.status,
    required this.nomeComum,
    required this.nomeTecnico,
    required this.comercializado,
    this.classeAgronomica,
    this.fabricante,
    this.classAmbiental,
    this.corrosivo,
    this.inflamavel,
    this.formulacao,
    this.modoAcao,
    this.mapa,
    this.toxico,
    this.ingredienteAtivo,
    this.quantProduto,
    required this.elegivel,
  });

  factory Fitossanitario.fromJson(Map<String, dynamic> json) {
    return Fitossanitario(
      objectId: json['objectId'],
      createdAt: json['createdAt'] != null ? int.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? int.tryParse(json['updatedAt'].toString()) : null,
      idReg: json['idReg'] ?? '',
      status: json['status'] != null ? json['status'] as bool : false,
      nomeComum: json['nomeComum'] ?? '',
      nomeTecnico: json['nomeTecnico'] ?? '',
      classeAgronomica: json['classeAgronomica'],
      fabricante: json['fabricante'],
      classAmbiental: json['classAmbiental'],
      comercializado:
          json['comercializado'] != null ? int.tryParse(json['comercializado'].toString()) ?? 0 : 0,
      corrosivo: json['corrosivo'],
      inflamavel: json['inflamavel'],
      formulacao: json['formulacao'],
      modoAcao: json['modoAcao'],
      mapa: json['mapa'],
      toxico: json['toxico'],
      ingredienteAtivo: json['ingredienteAtivo'],
      quantProduto: json['quantProduto'],
      elegivel: json['elegivel'] != null ? json['elegivel'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'idReg': idReg,
      'status': status,
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
