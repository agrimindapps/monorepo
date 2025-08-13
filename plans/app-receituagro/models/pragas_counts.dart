class PragasCounts {
  // Contadores para cada tipo de praga
  int insetos = 0;
  int doencas = 0;
  int plantas = 0;

  // Construtor padrão
  PragasCounts({
    this.insetos = 0,
    this.doencas = 0,
    this.plantas = 0,
  });

  // Construtor que inicializa a partir de um Map
  PragasCounts.fromMap(Map<String, dynamic> map) {
    insetos = map['insetos'] as int? ?? 0;
    doencas = map['doencas'] as int? ?? 0;
    plantas = map['plantas'] as int? ?? 0;
  }

  // Método para converter para Map
  Map<String, dynamic> toMap() {
    return {
      'insetos': insetos,
      'doencas': doencas,
      'plantas': plantas,
    };
  }

  // Método para incrementar contadores a partir dos tipos
  void incrementByType(String tipoPraga) {
    switch (tipoPraga) {
      case '1':
        insetos++;
        break;
      case '2':
        doencas++;
        break;
      case '3':
        plantas++;
        break;
    }
  }

  // Reset dos contadores
  void reset() {
    insetos = 0;
    doencas = 0;
    plantas = 0;
  }

  // Total de pragas
  int get total => insetos + doencas + plantas;
}
