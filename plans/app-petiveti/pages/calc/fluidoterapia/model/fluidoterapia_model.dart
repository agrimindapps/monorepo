class FluidoterapiaModel {
  double? peso;
  double? percentualHidratacao;
  double? periodoAdministracao;
  double? volumeTotal;
  double? gotasPorMinuto;

  FluidoterapiaModel({
    this.peso,
    this.percentualHidratacao,
    this.periodoAdministracao,
    this.volumeTotal,
    this.gotasPorMinuto,
  });

  void calcular() {
    if (peso != null &&
        percentualHidratacao != null &&
        periodoAdministracao != null) {
      // Cálculo do volume total (ml) = peso * percentual
      volumeTotal = peso! * percentualHidratacao!;

      // Cálculo de gotas por minuto = (volume total * 20) / (horas * 60)
      gotasPorMinuto = (volumeTotal! * 20) / (periodoAdministracao! * 60);
    }
  }

  void limpar() {
    peso = null;
    percentualHidratacao = null;
    periodoAdministracao = null;
    volumeTotal = null;
    gotasPorMinuto = null;
  }
}
