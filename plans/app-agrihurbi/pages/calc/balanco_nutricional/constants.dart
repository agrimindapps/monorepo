// Flutter imports:
import 'package:flutter/material.dart';

class BalancoNutricionalStrings {
  static const String tabTitleCalcario = 'Necessidade de Calcário';
  static const String tabDescCalcario =
      'Cálculo da quantidade de calcário necessária para correção da acidez do solo';
  static const String tabTitleAdubacaoOrganica = 'Adubação Orgânica';
  static const String tabDescAdubacaoOrganica =
      'Cálculo de adubação orgânica com base nos nutrientes disponíveis e necessários';
  static const String tabTitleMicronutrientes = 'Micronutrientes';
  static const String tabDescMicronutrientes =
      'Cálculo da necessidade de micronutrientes com base na análise do solo e demanda da cultura';

  static const String dialogTitle = 'Sobre o Balanço Nutricional';
  static const String dialogCloseButton = 'Fechar';

  static const String appBarTitle = 'Balanço Nutricional';
  static const String tooltipVoltar = 'Voltar';
  static const String tooltipInformacoes =
      'Informações sobre balanço nutricional';

  static const String infoTextFormCalculation =
      'Informe os valores para o cálculo';
  static const String buttonTextClear = 'Limpar';
  static const String buttonTextCalculate = 'Calcular';

  static const String formTitleCorrecaoAcidez =
      'Dados para Cálculo da Necessidade de Calcário';
  static const String formMetodoCalculo = 'Método de cálculo:';
  static const String formDadosSolo = 'Dados do solo:';
  static const String labelPHAtual = 'pH atual do solo';
  static const String labelPHDesejado = 'pH desejado';
  static const String labelTeorCTC = 'Teor de CTC (cmolc/dm³)';
  static const String labelProfundidadeSolo = 'Profundidade do solo (cm)';
  static const String labelAreaCalagem = 'Área para calagem (ha)';
  static const String labelPRNTCalcario = 'PRNT do calcário (%)';

  static const String resultTitle = 'Resultados do Cálculo';
  static const String shareButton = 'Compartilhar';
  static const String resultNecessidadeCalcario = 'Necessidade de Calcário';
  static const String resultQuantidadeTotal = 'Quantidade Total';
  static const String unitTHa = 't/ha';
  static const String unitT = 't';
  static const String recomendacoesTitle = 'Recomendações para aplicação';
  static const String recomendacao1 =
      'Aplicar o calcário de forma uniforme em toda a área';
  static const String recomendacao2 =
      'Incorporar o calcário ao solo com grade ou arado quando possível';
  static const String recomendacao3 =
      'Realizar a aplicação com 2-3 meses de antecedência do plantio';
  static const String recomendacao4 =
      'Em áreas de plantio direto, aplicar superficialmente';

  static const String formTitleAdubacaoOrganica =
      'Dados para Cálculo da Adubação Orgânica';
  static const String formFonteOrganica = 'Fonte orgânica:';
  static const String formUnidade = 'Unidade:';
  static const String labelQuantidadeAdubo = 'Quantidade de adubo';
  static const String labelTeorNitrogenio = 'Teor de nitrogênio (%)';
  static const String labelTeorFosforo = 'Teor de fósforo (% P2O5)';
  static const String labelTeorPotassio = 'Teor de potássio (% K2O)';
  static const String labelMateriaSecaAdubo = 'Matéria seca (%)';
  static const String labelAreaTratada = 'Área a ser tratada (ha)';
  static const String unitKgha = 'kg/ha';

  static const String resultNitrogenioPorHectare = 'Nitrogênio por Hectare';
  static const String resultNitrogenioTotal = 'Nitrogênio Total';
  static const String resultFosforoPorHectare = 'Fósforo por Hectare';
  static const String resultFosforoTotal = 'Fósforo Total';
  static const String resultPotassioPorHectare = 'Potássio por Hectare';
  static const String resultPotassioTotal = 'Potássio Total';
  static const String unitKg = 'kg';

  static const String recomendacaoAdubacaoOrganica1 =
      'Distribuir o adubo orgânico de forma uniforme';
  static const String recomendacaoAdubacaoOrganica2 =
      'Incorporar ao solo quando possível';
  static const String recomendacaoAdubacaoOrganica3 =
      'Evitar aplicação em dias chuvosos';
  static const String recomendacaoAdubacaoOrganica4 =
      'Considerar o tempo de decomposição do material';

  static const String dialogTitleCultura = 'Selecione a cultura';
  static const String buttonTextCancelar = 'Cancelar';
  static const String labelTeorZinco = 'Teor de Zinco no solo (mg/dm³)';
  static const String labelTeorBoro = 'Teor de Boro no solo (mg/dm³)';
  static const String labelTeorCobre = 'Teor de Cobre no solo (mg/dm³)';
  static const String labelTeorManganes = 'Teor de Manganês no solo (mg/dm³)';
  static const String labelTeorFerro = 'Teor de Ferro no solo (mg/dm³)';
  static const String labelAreaPlantada = 'Área plantada (ha)';

  static const String msgErroCampoVazio = 'Este campo não pode ser vazio.';
  static const String msgErroValorInvalido = 'Valor inválido.';
  static const String msgErroValorMinimo = 'O valor deve ser maior que zero.';
  static const String msgErroPHAtual = 'Informe o pH atual do solo';
  static const String msgErroPHDesejado = 'Informe o pH desejado';
  static const String msgErroTeorCTC = 'Informe o teor de CTC do solo';
  static const String msgErroProfundidadeSolo =
      'Informe a profundidade do solo';
  static const String msgErroAreaCalagem = 'Informe a área para calagem';
  static const String msgErroPRNTCalcario = 'Informe o PRNT do calcário';
  static const String msgSucessoCalculo = 'Cálculo realizado com sucesso!';

  static const String msgErroQuantidadeAdubo =
      'Necessário informar a quantidade de adubo orgânico';
  static const String msgErroTeorNitrogenio =
      'Necessário informar o teor de nitrogênio';
  static const String msgErroTeorFosforo =
      'Necessário informar o teor de fósforo';
  static const String msgErroTeorPotassio =
      'Necessário informar o teor de potássio';
  static const String msgErroMateriaSeca =
      'Necessário informar o teor de matéria seca';
  static const String msgErroAreaTratada =
      'Necessário informar a área a ser tratada';

  static const String msgErroCultura = 'Selecione uma cultura';
  static const String msgErroTeorZinco =
      'Necessário informar o teor de Zinco no solo';
  static const String msgErroTeorBoro =
      'Necessário informar o teor de Boro no solo';
  static const String msgErroTeorCobre =
      'Necessário informar o teor de Cobre no solo';
  static const String msgErroTeorManganes =
      'Necessário informar o teor de Manganês no solo';
  static const String msgErroTeorFerro =
      'Necessário informar o teor de Ferro no solo';
  static const String msgErroAreaPlantada =
      'Necessário informar a área plantada';
  static const String msgErroNumeroInvalido =
      'O valor informado para {campo} não é um número válido';
  static const String msgErroCampoObrigatorio = 'O campo {campo} é obrigatório';
  static const String msgErroValorMin =
      'O valor para {campo} deve ser maior que {min}';
  static const String msgErroValorMax =
      'O valor para {campo} deve ser menor que {max}';

  static const String resultZinco = 'Zinco:';
  static const String resultBoro = 'Boro:';
  static const String resultCobre = 'Cobre:';
  static const String resultManganes = 'Manganês:';
  static const String resultFerro = 'Ferro:';

  static const String resultTitleMicronutrientes =
      'Resultado da Análise de Micronutrientes para';
  static const String infoComplementares = 'Informações Complementares';
  static const String infoResultadosMicronutrientes =
      'Os valores apresentados são baseados na diferença entre a necessidade da cultura e os teores disponíveis no solo.';
  static const String infoNivelCritico = 'Níveis críticos para';
  static const String infoZinco = 'Zinco:';
  static const String infoBoro = 'Boro:';
  static const String infoCobre = 'Cobre:';
  static const String infoManganes = 'Manganês:';
  static const String infoFerro = 'Ferro:';
}

class BalancoNutricionalIcons {
  static const IconData bubbleChartOutlined = Icons.bubble_chart_outlined;
  static const IconData compostOutlined = Icons.compost_outlined;
  static const IconData scienceOutlined = Icons.science_outlined;
  static const IconData infoOutline = Icons.info_outline;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData flag = Icons.flag;
  static const IconData clear = Icons.clear;
  static const IconData calculateOutlined = Icons.calculate_outlined;
  static const IconData errorOutline = Icons.error_outline;
  static const IconData checkCircleOutline = Icons.check_circle_outline;
  static const IconData phpOutlined = Icons.php_outlined;
  static const IconData landscapeOutlined = Icons.landscape_outlined;
  static const IconData heightOutlined = Icons.height_outlined;
  static const IconData cropSquareOutlined = Icons.crop_square_outlined;
  static const IconData percentOutlined = Icons.percent_outlined;
  static const IconData shareOutlined = Icons.share_outlined;
  static const IconData scaleOutlined = Icons.scale_outlined;
  static const IconData inventory2Outlined = Icons.inventory_2_outlined;
  static const IconData tipsAndUpdatesOutlined =
      Icons.tips_and_updates_outlined;
  static const IconData gridOnOutlined = Icons.grid_on_outlined;
  static const IconData agricultureOutlined = Icons.agriculture_outlined;
  static const IconData calendarTodayOutlined = Icons.calendar_today_outlined;
  static const IconData layersOutlined = Icons.layers_outlined;
  static const IconData arrowDropDown = Icons.arrow_drop_down;
  static const IconData ecoOutlined = Icons.eco_outlined;
  static const IconData cloudOutlined = Icons.cloud_outlined;
  static const IconData timerOutlined = Icons.timer_outlined;
  static const IconData refresh = Icons.refresh;
  static const IconData calculate = Icons.calculate;
  static const IconData shareSharp = Icons.share_sharp;
}

class BalancoNutricionalColors {
  static const Color green = Colors.green;
  static const Color indigo = Colors.indigo;
  static const Color red900 = Colors.red;
  static const Color green700 = Colors.green;
  static const Color amber = Colors.amber;
  static const Color brown = Colors.brown;
  static const Color blue = Colors.blue;
  static const Color purple = Colors.purple;
  static const Color orange = Colors.orange;
}
