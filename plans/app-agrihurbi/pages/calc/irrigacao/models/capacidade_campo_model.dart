class CapacidadeCampoModel {
  // Parâmetros de entrada
  double? soloPesoUmido;
  double? soloPesoSeco;
  double capacidadeCampo;
  double pontoMurcha;
  double densidadeSolo;
  double profundidadeRaiz;
  double areaIrrigada;
  bool calculoUmidadeAtual;

  // Resultados calculados
  double umidadeGravimetrica = 0;
  double umidadeVolumetrica = 0;
  double aguaDisponivel = 0;
  double aguaFacilmenteDisponivel = 0;
  double volumeTotalAgua = 0;
  double eficienciaArmazenamento = 0;

  CapacidadeCampoModel({
    this.soloPesoUmido,
    this.soloPesoSeco,
    required this.capacidadeCampo,
    required this.pontoMurcha,
    required this.densidadeSolo,
    required this.profundidadeRaiz,
    required this.areaIrrigada,
    this.calculoUmidadeAtual = false,
  });

  void calcular() {
    if (calculoUmidadeAtual && soloPesoUmido != null && soloPesoSeco != null) {
      // Calcular umidade gravimétrica a partir dos pesos
      umidadeGravimetrica =
          ((soloPesoUmido! - soloPesoSeco!) / soloPesoSeco!) * 100;
    } else {
      umidadeGravimetrica = capacidadeCampo;
    }

    // Converter umidade gravimétrica para volumétrica
    umidadeVolumetrica = umidadeGravimetrica * densidadeSolo;

    // Calcular água disponível total
    aguaDisponivel = (capacidadeCampo - pontoMurcha) *
        densidadeSolo *
        (profundidadeRaiz / 10);

    // Calcular água facilmente disponível (50% da água disponível)
    aguaFacilmenteDisponivel = aguaDisponivel * 0.5;

    // Calcular volume total de água disponível em m³
    volumeTotalAgua = aguaDisponivel * areaIrrigada * 10;

    // Calcular eficiência de armazenamento
    if (calculoUmidadeAtual) {
      eficienciaArmazenamento = ((umidadeGravimetrica - pontoMurcha) /
              (capacidadeCampo - pontoMurcha)) *
          100;

      // Limitar entre 0 e 100%
      eficienciaArmazenamento = eficienciaArmazenamento.clamp(0, 100);
    } else {
      eficienciaArmazenamento = 100;
    }
  }
}
