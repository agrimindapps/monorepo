// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../constants.dart';

class AplicacaoModel {
  final numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  num volumePulverizar = 0;
  num velocidadeAplicacao = 0;
  num espacamentoBicos = 0;
  num resultado = 0;
  bool calculado = false;

  // Volume Calculation
  void calcularVolume() {
    resultado =
        ((volumePulverizar * velocidadeAplicacao * espacamentoBicos) / 600);
    calculado = true;
  }

  // Vazão Calculation
  void calcularVazao() {
    resultado = ((600 * volumePulverizar) /
        (velocidadeAplicacao * (espacamentoBicos / 100)));
    calculado = true;
  }

  // Quantidade Calculation
  void calcularQuantidade() {
    resultado = ((volumePulverizar * velocidadeAplicacao) / espacamentoBicos);
    calculado = true;
  }

  void limpar() {
    volumePulverizar = 0;
    velocidadeAplicacao = 0;
    espacamentoBicos = 0;
    resultado = 0;
    calculado = false;
  }

  String formatarCompartilhamento(String tipo) {
    return '''
    $tipo

    ${AplicacaoStrings.shareTitle}
    ${AplicacaoStrings.shareVolumePulverizacao}: ${numberFormat.format(volumePulverizar)} ${AplicacaoStrings.shareLtHa}
    ${AplicacaoStrings.shareVelocidadeDeslocamento}: ${numberFormat.format(velocidadeAplicacao)} ${AplicacaoStrings.shareKmH}
    ${AplicacaoStrings.shareEspacamentoBicos}: ${numberFormat.format(espacamentoBicos)} ${AplicacaoStrings.shareCm}

    ${AplicacaoStrings.shareResultado}
    ${numberFormat.format(resultado)} ${AplicacaoStrings.shareLtHa}
    ''';
  }
}
