class PragasInf {
  String objectId;
  int createdAt;
  int updatedAt;
  String idReg;
  int status;
  String? descrisao;
  String? sintomas;
  String? bioecologia;
  String? controle;
  String fkIdPraga;

  PragasInf({
    required this.objectId,
    required this.createdAt,
    required this.updatedAt,
    required this.idReg,
    required this.status,
    this.descrisao,
    this.sintomas,
    this.bioecologia,
    this.controle,
    required this.fkIdPraga,
  });

  factory PragasInf.fromJson(Map<String, dynamic> json) {
    return PragasInf(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      idReg: json['IdReg'],
      status: json['Status'],
      descrisao: json['descrisao'],
      sintomas: json['sintomas'],
      bioecologia: json['bioecologia'],
      controle: json['controle'],
      fkIdPraga: json['fkIdPraga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'IdReg': idReg,
      'Status': status,
      'descrisao': descrisao,
      'sintomas': sintomas,
      'bioecologia': bioecologia,
      'controle': controle,
      'fkIdPraga': fkIdPraga,
    };
  }
}

// "objectId": "-MrK_AUcRssfsX_4t-g8",
// "createdAt": 1642590241940,
// "updatedAt": 1642732301575,
// "IdReg": "iPZQLcukkWxtE",
// "Status": 1,
// "descrisao": "É uma espécie que tem grande ocorrência em algumas leguminosas, em especial na cultura do amendoim. Seus maiores prejuízos são provocados pela transmissão de viroses. Outras culturas em que a espécie tem ocorrência são: alface, amendoim, arroz, batata, batata-doce, café, ervilha, feijão, feijão-vagem, milho, soja.",
// "sintomas": "Atacam as folhas da planta, sendo comumente encontrados na face superior das mesmas. São insetos que têm o hábito de raspar as folhas para sugar a seiva, provocando inicialmente uma descoloração e, posteriormente, pontuações escuras nos locais de ataque. Em condições de ataques intensos, as folhas podem cair.",
// "bioecologia": "São insetos que medem um pouco mais de 1 mm de comprimento. As fêmeas ovipositam nas folhas. A fase jovem tem coloração amarelada, e a fase adulta é mais escura, vivendo abrigados nos folíolos. São facilmente carregados pelas chuvas, daí não causarem sérios prejuízos no campo.",
// "controle": "CONTROLE QUÍMICO: Fazer uso de inseticidas específicos, conforme recomendação do fabricante.",
// "fkIdPraga": "iPZQLcukkWxtE"
