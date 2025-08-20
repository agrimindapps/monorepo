class MedicamentoConstants {
  static const String tipoAntibiotico = 'Antibiótico';
  static const String tipoAnalgesico = 'Analgésico';
  static const String tipoAntiInflamatorio = 'Anti-inflamatório';

  static const String recomendacoesGerais =
      'Siga as recomendações do médico veterinário quanto à dosagem e frequência de administração.';

  static const String avisoImportante =
      'Consulte um médico veterinário antes de administrar qualquer medicamento ao seu animal. Esta página contém apenas informações gerais e não substitui a orientação profissional.';

  static const List<String> tiposComCalculadora = [
    tipoAntibiotico,
    tipoAnalgesico,
    tipoAntiInflamatorio,
  ];

  static const Map<String, String> administracaoTipica = {
    tipoAntibiotico:
        'Antibióticos geralmente devem ser administrados até o fim do tratamento, mesmo se os sintomas desaparecerem antes.',
    tipoAnalgesico:
        'Analgésicos devem ser administrados conforme necessidade e prescrição veterinária para controle da dor.',
    tipoAntiInflamatorio:
        'Anti-inflamatórios geralmente são administrados com alimento para reduzir irritação gástrica.',
  };

  static const Map<String, double> dosagensBase = {
    tipoAntibiotico: 10.0, // 10mg/kg
    tipoAnalgesico: 5.0,   // 5mg/kg
    tipoAntiInflamatorio: 2.0, // 2mg/kg
  };

  static const double textScaleFactorMin = 0.8;
  static const double textScaleFactorMax = 1.5;
  static const double textScaleFactorIncrement = 0.1;
}