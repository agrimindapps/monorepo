class SugestoesHelper {
  String getSugestao(double anosParaIndependencia) {
    if (anosParaIndependencia > 15) {
      return 'O tempo para sua independência financeira está longo. Considere aumentar seus aportes mensais ou buscar investimentos com maior retorno.';
    } else if (anosParaIndependencia > 0) {
      return 'Você está no caminho certo! Mantenha a consistência nos aportes e reavalie seus investimentos periodicamente.';
    } else {
      return 'Parabéns! Você já atingiu sua independência financeira. Agora é importante manter uma estratégia de preservação de capital.';
    }
  }
}
