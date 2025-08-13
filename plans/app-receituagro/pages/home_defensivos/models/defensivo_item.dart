class DefensivoItem {
  final String idReg;
  final String nomeComum;
  final String? ingredienteAtivo;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;

  DefensivoItem({
    required this.idReg,
    required this.nomeComum,
    this.ingredienteAtivo,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
  });

  factory DefensivoItem.fromMap(Map<String, dynamic> map) {
    return DefensivoItem(
      idReg: map['idReg']?.toString() ?? '',
      nomeComum: map['nomeComum']?.toString() ?? '',
      ingredienteAtivo: map['ingredienteAtivo']?.toString(),
      classeAgronomica: map['classeAgronomica']?.toString(),
      fabricante: map['fabricante']?.toString(),
      modoAcao: map['modoAcao']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idReg': idReg,
      'nomeComum': nomeComum,
      'ingredienteAtivo': ingredienteAtivo,
      'classeAgronomica': classeAgronomica,
      'fabricante': fabricante,
      'modoAcao': modoAcao,
    };
  }
}