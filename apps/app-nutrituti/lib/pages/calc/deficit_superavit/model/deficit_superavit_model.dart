
class DeficitSuperavitModel {
  double caloriasDiarias;
  double metaPeso;
  int tempoSemanas;
  double deficitSuperavitDiario;
  double deficitSuperavitSemanal;
  double metaCaloricaDiaria;
  bool perderPeso;
  int tipoMetaSelecionado;
  bool calculado;

  // ignore: constant_identifier_names
  static const double CALORIAS_POR_KG = 7700.0;
  // ignore: constant_identifier_names
  static const double MINIMO_CALORIAS_DIARIAS = 1200.0;

  DeficitSuperavitModel({
    this.caloriasDiarias = 0,
    this.metaPeso = 0,
    this.tempoSemanas = 12,
    this.deficitSuperavitDiario = 0,
    this.deficitSuperavitSemanal = 0,
    this.metaCaloricaDiaria = 0,
    this.perderPeso = true,
    this.tipoMetaSelecionado = 1,
    this.calculado = false,
  });

  void calcular() {
    perderPeso = tipoMetaSelecionado == 1;

    // Calcular diferença total de calorias para atingir a meta
    double caloriasTotais = metaPeso * CALORIAS_POR_KG;

    // Calcular déficit/superávit diário e semanal
    deficitSuperavitDiario = caloriasTotais / (tempoSemanas * 7);
    deficitSuperavitSemanal = deficitSuperavitDiario * 7;

    // Calcular meta calórica diária
    metaCaloricaDiaria = perderPeso
        ? caloriasDiarias - deficitSuperavitDiario
        : caloriasDiarias + deficitSuperavitDiario;

    // Ajustar para o mínimo seguro
    if (perderPeso && metaCaloricaDiaria < MINIMO_CALORIAS_DIARIAS) {
      metaCaloricaDiaria = MINIMO_CALORIAS_DIARIAS;
      deficitSuperavitDiario = caloriasDiarias - metaCaloricaDiaria;
      deficitSuperavitSemanal = deficitSuperavitDiario * 7;
      tempoSemanas = (caloriasTotais / deficitSuperavitSemanal).ceil();
    }

    // Arredondar resultados
    deficitSuperavitDiario =
        double.parse(deficitSuperavitDiario.toStringAsFixed(0));
    deficitSuperavitSemanal =
        double.parse(deficitSuperavitSemanal.toStringAsFixed(0));
    metaCaloricaDiaria = double.parse(metaCaloricaDiaria.toStringAsFixed(0));

    calculado = true;
  }

  String gerarTextoCompartilhamento() {
    StringBuffer t = StringBuffer();
    String tipoCalculo = perderPeso ? 'Déficit' : 'Superávit';

    t.writeln('Cálculo de $tipoCalculo Calórico');
    t.writeln();
    t.writeln('Dados:');
    t.writeln(
        'Calorias Diárias Atuais: ${caloriasDiarias.toStringAsFixed(0)} kcal');
    t.writeln(
        'Meta de ${perderPeso ? 'Perda' : 'Ganho'} de Peso: ${metaPeso.toStringAsFixed(1)} kg');
    t.writeln('Tempo para Atingir a Meta: $tempoSemanas semanas');
    t.writeln();
    t.writeln('Resultados:');
    t.writeln(
        '$tipoCalculo Diário Necessário: ${deficitSuperavitDiario.toStringAsFixed(0)} kcal/dia');
    t.writeln(
        '$tipoCalculo Semanal: ${deficitSuperavitSemanal.toStringAsFixed(0)} kcal/semana');
    t.writeln(
        'Meta Calórica Diária: ${metaCaloricaDiaria.toStringAsFixed(0)} kcal/dia');

    if (perderPeso && metaCaloricaDiaria <= MINIMO_CALORIAS_DIARIAS) {
      t.writeln();
      t.writeln(
          'Aviso: A meta calórica foi ajustada para o mínimo seguro de ${MINIMO_CALORIAS_DIARIAS.toStringAsFixed(0)} kcal/dia.');
      t.writeln(
          'Isso pode aumentar o tempo necessário para atingir sua meta de peso.');
    }

    return t.toString();
  }

  void limpar() {
    tipoMetaSelecionado = 1;
    caloriasDiarias = 0;
    metaPeso = 0;
    tempoSemanas = 12;
    deficitSuperavitDiario = 0;
    deficitSuperavitSemanal = 0;
    metaCaloricaDiaria = 0;
    perderPeso = true;
    calculado = false;
  }
}
