class CorrecaoAcidezModel {
  double pHAtual = 0;
  double pHDesejado = 0;
  double teorCTC = 0;
  double profundidadeSolo = 0;
  double areaCalagem = 0;
  double prntCalcario = 0;
  double necessidadeCalcario = 0;
  double quantidadeTotal = 0;
  String metodoSelecionado = 'Saturação por Bases';

  static final List<String> metodos = [
    'Saturação por Bases',
    'Neutralização do Alumínio',
    'pH SMP'
  ];

  void calcular() {
    // Estimativa da saturação por bases a partir do pH (simplificação didática)
    final v1 =
        (pHAtual - 4.0) * 20; // Estimativa: cada 0.1 pH = 2% de saturação
    final v2 = (pHDesejado - 4.0) * 20;

    necessidadeCalcario = teorCTC * (v2 - v1) / 10 * (100 / prntCalcario);

    // Ajuste pela profundidade (padrão é 20cm)
    necessidadeCalcario = necessidadeCalcario * (profundidadeSolo / 20);

    // Garantir que o valor não seja negativo
    necessidadeCalcario = necessidadeCalcario < 0 ? 0 : necessidadeCalcario;

    // Cálculo da quantidade total
    quantidadeTotal = necessidadeCalcario * areaCalagem;
  }

  void limpar() {
    pHAtual = 0;
    pHDesejado = 0;
    teorCTC = 0;
    profundidadeSolo = 0;
    areaCalagem = 0;
    prntCalcario = 0;
    necessidadeCalcario = 0;
    quantidadeTotal = 0;
  }

  String gerarTextoCompartilhamento() {
    return '''
    Cálculo de Necessidade de Calcário
    
    Dados do Solo:
    pH atual: $pHAtual
    pH desejado: $pHDesejado
    Teor de CTC: $teorCTC cmolc/dm³
    Profundidade: $profundidadeSolo cm
    Área para calagem: $areaCalagem ha
    PRNT do calcário: $prntCalcario%
    
    Resultados:
    Necessidade de calcário: $necessidadeCalcario t/ha
    Quantidade total: $quantidadeTotal toneladas
    
    Método utilizado: $metodoSelecionado
    ''';
  }
}
