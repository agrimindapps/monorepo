class Infassinatura {
  String inicioAssinatura;
  String fimAssinatura;
  String descAssinatura;
  String daysRemaning;
  double percent;
  bool ativo;

  Infassinatura(
      {this.inicioAssinatura = '',
      this.fimAssinatura = '',
      this.descAssinatura = '',
      this.daysRemaning = '0 Dias Restantes',
      this.percent = 0.0,
      this.ativo = false});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inicioAssinatura'] = inicioAssinatura;
    data['fimAssinatura'] = fimAssinatura;
    data['descAssinatura'] = descAssinatura;
    data['daysRemaning'] = daysRemaning;
    data['percent'] = percent;
    data['ativo'] = ativo;
    return data;
  }

  factory Infassinatura.fromJson(Map<String, dynamic> json) {
    return Infassinatura(
      inicioAssinatura: json['inicioAssinatura'],
      fimAssinatura: json['fimAssinatura'],
      descAssinatura: json['descAssinatura'],
      daysRemaning: json['daysRemaning'],
      percent: json['percent'],
      ativo: json['ativo'],
    );
  }

  @override
  String toString() {
    return 'InfAssinatura{inicioAssinatura: $inicioAssinatura, fimAssinatura: $fimAssinatura, descAssinatura: $descAssinatura, daysRemaning: $daysRemaning, percent: $percent, ativo: $ativo}';
  }
}
