// Flutter imports:
import 'package:flutter/material.dart';

class AplicacaoStrings {
  static const String volumeAplicacaoTitle = 'Volume Aplicação';
  static const String vazaoBicoTitle = 'Vazão Bico';
  static const String quantidadeTitle = 'Quantidade';

  static const String labelVolumeCalda = 'Volume da Calda (Lt/Min)';
  static const String labelVazaoBico = 'Vazão por Bico (Lt/Min)';
  static const String labelCapacidadeTanque = 'Capacidade do Tanque (Lt)';

  static const String dialogTitle = 'Sobre os Cálculos de Aplicação';
  static const String dialogSubtitle1 = 'Os cálculos permitem determinar:';
  static const String dialogItem1 =
      '1. Volume de Aplicação - Calcule o volume necessário baseado na velocidade, vazão e espaçamento.';
  static const String dialogItem2 =
      '2. Vazão do Bico - Determine a vazão necessária para cada bico do pulverizador.';
  static const String dialogItem3 =
      '3. Quantidade - Calcule a quantidade de produto a ser aplicada por área.';
  static const String dialogSubtitle2 = 'Fórmulas aplicadas:';
  static const String dialogFormulas =
      'Volume (L/ha) = (600 × Vazão) ÷ (Velocidade × Espaçamento)\nVazão (L/min) = (Volume × Velocidade × Espaçamento) ÷ 600\nQuantidade = Volume × Concentração';
  static const String dialogCloseButton = 'Fechar';

  static const String appBarTitle = 'Cálculos de Aplicação';
  static const String tooltipVoltar = 'Voltar';
  static const String tooltipInformacoes = 'Informações';

  static const String msgErroVolumePulverizacao =
      'Necessário informar o volume de pulverização';
  static const String msgErroVelocidadeDeslocamento =
      'Necessário informar a velocidade de deslocamento';
  static const String msgErroEspacamentoBico =
      'Necessário informar o espaçamento entre bico';
  static const String msgSucessoCalculo = 'Cálculo realizado com sucesso!';

  static const String shareTitle = 'Valores';
  static const String shareVolumePulverizacao = 'Vol. de Pulverização';
  static const String shareVelocidadeDeslocamento = 'Vel. de Deslocamento';
  static const String shareEspacamentoBicos = 'Espaçamento entre bicos';
  static const String shareResultado = 'Resultado';
  static const String shareLtHa = 'Lt/Ha';
  static const String shareKmH = 'Km/H';
  static const String shareCm = 'Cm';

  static const String msgErroCampoVazio = 'Este campo não pode ser vazio.';
  static const String msgErroValorInvalido = 'Valor inválido.';
  static const String msgErroValorMinimo = 'O valor deve ser maior que zero.';
}

class AplicacaoIcons {
  static const IconData waterDropOutlined = Icons.water_drop_outlined;
  static const IconData water = Icons.water;
  static const IconData waterDrop = Icons.water_drop;
  static const IconData infoOutline = Icons.info_outline;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData errorOutline = Icons.error_outline;
  static const IconData checkCircleOutline = Icons.check_circle_outline;
}

class AplicacaoColors {
  static const Color blue = Colors.blue;
  static const Color green = Colors.green;
  static const Color purple = Colors.purple;
}
