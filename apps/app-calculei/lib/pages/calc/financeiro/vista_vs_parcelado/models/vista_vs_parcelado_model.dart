// Package imports:
import 'package:intl/intl.dart';

class VistaVsParceladoModel {
  double? valorVista;
  double? valorParcelado;
  int numeroParcelas;
  double taxaJuros;
  bool resultadoVisivel;
  String melhorOpcao;
  double economiaOuCustoAdicional;
  double taxaImplicita;
  String detalhesCalculo;

  static final formatadorMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final formatadorPercentual = NumberFormat.percentPattern('pt_BR');

  VistaVsParceladoModel({
    this.valorVista,
    this.valorParcelado,
    this.numeroParcelas = 12,
    this.taxaJuros = 0.8,
    this.resultadoVisivel = false,
    this.melhorOpcao = '',
    this.economiaOuCustoAdicional = 0.0,
    this.taxaImplicita = 0.0,
    this.detalhesCalculo = '',
  });

  bool validarCampos() {
    return valorVista != null &&
        valorVista! > 0 &&
        valorParcelado != null &&
        valorParcelado! > 0 &&
        numeroParcelas > 0 &&
        taxaJuros >= 0 &&
        taxaJuros <= 20;
  }

  Map<String, String> getValoresFormatados() {
    return {
      'valorVista': formatadorMoeda.format(valorVista ?? 0),
      'valorParcelado': formatadorMoeda.format(valorParcelado ?? 0),
      'numeroParcelas': numeroParcelas.toString(),
      'taxaJuros': '${(taxaJuros).toString().replaceAll('.', ',')}%',
      'economiaOuCustoAdicional':
          formatadorMoeda.format(economiaOuCustoAdicional),
      'taxaImplicita':
          '${formatadorPercentual.format(taxaImplicita.abs())}${taxaImplicita < 0 ? ' (desconto)' : ''}/mês',
    };
  }
}
