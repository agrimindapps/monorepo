// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';
import '../../../../../core/utils/formatters/decimal_input_formatter.dart'
    as formatters;
import '../../../../../core/widgets/textfield_widget.dart';

class RentabilidadeAgricolaWidget extends StatefulWidget {
  const RentabilidadeAgricolaWidget({super.key});

  @override
  RentabilidadeAgricolaWidgetState createState() =>
      RentabilidadeAgricolaWidgetState();
}

class RentabilidadeAgricolaWidgetState
    extends State<RentabilidadeAgricolaWidget> {
  // Controllers
  final _culturaController = TextEditingController();
  final _areaPlantada = TextEditingController();
  final _valorInvestimentoTotal = TextEditingController();
  final _custoInsumos = TextEditingController();
  final _custoMaquinario = TextEditingController();
  final _custoMaoObra = TextEditingController();
  final _custoArrendamento = TextEditingController();
  final _produtividadePrevista = TextEditingController();
  final _precoVendaProduto = TextEditingController();
  final _impostosTaxas = TextEditingController();
  final _outrosCustos = TextEditingController();

  // Focus Nodes
  final _focus1 = FocusNode();
  final _focus2 = FocusNode();
  final _focus3 = FocusNode();
  final _focus4 = FocusNode();
  final _focus5 = FocusNode();
  final _focus6 = FocusNode();
  final _focus7 = FocusNode();
  final _focus8 = FocusNode();
  final _focus9 = FocusNode();
  final _focus10 = FocusNode();
  final _focus11 = FocusNode();

  // State Variables
  String _cultura = 'Soja';
  num _vl1 = 0; // Área plantada (ha)
  num _vl2 = 0; // Valor do investimento total (R$)
  num _vl3 = 0; // Custo de insumos (R$/ha)
  num _vl4 = 0; // Custo de maquinário (R$/ha)
  num _vl5 = 0; // Custo de mão de obra (R$/ha)
  num _vl6 = 0; // Custo de arrendamento (R$/ha)
  num _vl7 = 0; // Produtividade prevista (sacas/ha ou ton/ha)
  num _vl8 = 0; // Preço de venda do produto (R$/saca ou R$/ton)
  num _vl9 = 0; // Impostos e taxas (%)
  num _vl10 = 0; // Outros custos (R$/ha)

  // Resultados calculados
  num _custoTotalPorHectare = 0;
  num _custoTotalProducao = 0;
  num _receitaBrutaPorHectare = 0;
  num _receitaBrutaTotal = 0;
  num _custoUnitario = 0;
  num _margemBrutaPorHectare = 0;
  num _margemBrutaTotal = 0;
  num _lucroLiquidoPorHectare = 0;
  num _lucroLiquidoTotal = 0;
  num _pontoEquilibrio = 0;
  num _retornoInvestimento = 0;
  num _relacaoBeneficioCusto = 0;

  bool _calculado = false;

  // Formatters
  final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');
  final _percentFormat = NumberFormat('#,##0.00', 'pt_BR');

  // Lista de culturas e unidades
  final List<String> _culturas = [
    'Soja',
    'Milho',
    'Feijão',
    'Algodão',
    'Café',
    'Trigo',
    'Cana-de-açúcar',
    'Arroz',
    'Sorgo',
    'Girassol',
    'Outra'
  ];

  final Map<String, String> _unidadesPorCultura = {
    'Soja': 'sacas',
    'Milho': 'sacas',
    'Feijão': 'sacas',
    'Algodão': 'arrobas',
    'Café': 'sacas',
    'Trigo': 'sacas',
    'Cana-de-açúcar': 'ton',
    'Arroz': 'sacas',
    'Sorgo': 'sacas',
    'Girassol': 'sacas',
    'Outra': 'unidades'
  };

  @override
  void initState() {
    super.initState();
    _culturaController.text = _cultura;
  }

  @override
  void dispose() {
    // Dispose controllers
    _culturaController.dispose();
    _areaPlantada.dispose();
    _valorInvestimentoTotal.dispose();
    _custoInsumos.dispose();
    _custoMaquinario.dispose();
    _custoMaoObra.dispose();
    _custoArrendamento.dispose();
    _produtividadePrevista.dispose();
    _precoVendaProduto.dispose();
    _impostosTaxas.dispose();
    _outrosCustos.dispose();

    // Dispose focus nodes
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    _focus5.dispose();
    _focus6.dispose();
    _focus7.dispose();
    _focus8.dispose();
    _focus9.dispose();
    _focus10.dispose();
    _focus11.dispose();

    super.dispose();
  }

  void _exibirMensagem(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.red.shade900,
      ));
  }

  bool _validarCampos() {
    if (_areaPlantada.text.isEmpty) {
      _focus2.requestFocus();
      _exibirMensagem('Necessário informar a área plantada');
      return false;
    }

    if (_valorInvestimentoTotal.text.isEmpty) {
      _focus3.requestFocus();
      _exibirMensagem('Necessário informar o valor do investimento total');
      return false;
    }

    if (_produtividadePrevista.text.isEmpty) {
      _focus8.requestFocus();
      _exibirMensagem('Necessário informar a produtividade prevista');
      return false;
    }

    if (_precoVendaProduto.text.isEmpty) {
      _focus9.requestFocus();
      _exibirMensagem('Necessário informar o preço de venda do produto');
      return false;
    }

    return true;
  }

  void _calcular() {
    if (!_validarCampos()) return;

    setState(() {
      // Parse input values
      _vl1 = num.parse(_areaPlantada.text.replaceAll(',', '.'));
      _vl2 = num.parse(_valorInvestimentoTotal.text.replaceAll(',', '.'));
      _vl3 = _custoInsumos.text.isEmpty
          ? 0
          : num.parse(_custoInsumos.text.replaceAll(',', '.'));
      _vl4 = _custoMaquinario.text.isEmpty
          ? 0
          : num.parse(_custoMaquinario.text.replaceAll(',', '.'));
      _vl5 = _custoMaoObra.text.isEmpty
          ? 0
          : num.parse(_custoMaoObra.text.replaceAll(',', '.'));
      _vl6 = _custoArrendamento.text.isEmpty
          ? 0
          : num.parse(_custoArrendamento.text.replaceAll(',', '.'));
      _vl7 = num.parse(_produtividadePrevista.text.replaceAll(',', '.'));
      _vl8 = num.parse(_precoVendaProduto.text.replaceAll(',', '.'));
      _vl9 = _impostosTaxas.text.isEmpty
          ? 0
          : num.parse(_impostosTaxas.text.replaceAll(',', '.'));
      _vl10 = _outrosCustos.text.isEmpty
          ? 0
          : num.parse(_outrosCustos.text.replaceAll(',', '.'));

      // Calculate results
      _custoTotalPorHectare = _vl3 + _vl4 + _vl5 + _vl6 + _vl10;
      if (_custoTotalPorHectare == 0) {
        _custoTotalPorHectare = _vl2 / _vl1;
      }

      _custoTotalProducao = _custoTotalPorHectare * _vl1;
      _receitaBrutaPorHectare = _vl7 * _vl8;
      _receitaBrutaTotal = _receitaBrutaPorHectare * _vl1;
      _custoUnitario = _custoTotalPorHectare / _vl7;
      _margemBrutaPorHectare = _receitaBrutaPorHectare - _custoTotalPorHectare;
      _margemBrutaTotal = _margemBrutaPorHectare * _vl1;
      _lucroLiquidoPorHectare = _margemBrutaPorHectare * (1 - (_vl9 / 100));
      _lucroLiquidoTotal = _lucroLiquidoPorHectare * _vl1;
      _pontoEquilibrio = _custoTotalPorHectare / _vl8;
      _retornoInvestimento = (_lucroLiquidoTotal / _vl2) * 100;
      _relacaoBeneficioCusto = _receitaBrutaTotal / _custoTotalProducao;

      _calculado = true;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void _limpar() {
    setState(() {
      _calculado = false;
      _areaPlantada.clear();
      _valorInvestimentoTotal.clear();
      _custoInsumos.clear();
      _custoMaquinario.clear();
      _custoMaoObra.clear();
      _custoArrendamento.clear();
      _produtividadePrevista.clear();
      _precoVendaProduto.clear();
      _impostosTaxas.clear();
      _outrosCustos.clear();
    });
  }

  void _compartilhar() {
    final unidade = _unidadesPorCultura[_cultura]!;
    final shareText = '''
    Análise de Rentabilidade Agrícola

    Cultura: $_cultura
    Área plantada: ${_numberFormat.format(_vl1)} ha
    
    Entradas:
    Investimento total: R\$ ${_numberFormat.format(_vl2)}
    Custos de insumos: R\$ ${_numberFormat.format(_vl3)}/ha
    Custos de maquinário: R\$ ${_numberFormat.format(_vl4)}/ha
    Custos de mão de obra: R\$ ${_numberFormat.format(_vl5)}/ha
    Custos de arrendamento: R\$ ${_numberFormat.format(_vl6)}/ha
    Outros custos: R\$ ${_numberFormat.format(_vl10)}/ha
    Produtividade prevista: ${_numberFormat.format(_vl7)} $unidade/ha
    Preço de venda: R\$ ${_numberFormat.format(_vl8)}/$unidade
    Impostos e taxas: ${_numberFormat.format(_vl9)}%

    Resultados:
    Custo total por hectare: R\$ ${_numberFormat.format(_custoTotalPorHectare)}/ha
    Custo total de produção: R\$ ${_numberFormat.format(_custoTotalProducao)}
    Receita bruta por hectare: R\$ ${_numberFormat.format(_receitaBrutaPorHectare)}/ha
    Receita bruta total: R\$ ${_numberFormat.format(_receitaBrutaTotal)}
    Custo unitário: R\$ ${_numberFormat.format(_custoUnitario)}/$unidade
    Margem bruta por hectare: R\$ ${_numberFormat.format(_margemBrutaPorHectare)}/ha
    Margem bruta total: R\$ ${_numberFormat.format(_margemBrutaTotal)}
    Lucro líquido por hectare: R\$ ${_numberFormat.format(_lucroLiquidoPorHectare)}/ha
    Lucro líquido total: R\$ ${_numberFormat.format(_lucroLiquidoTotal)}
    Ponto de equilíbrio: ${_numberFormat.format(_pontoEquilibrio)} $unidade/ha
    Retorno sobre investimento: ${_percentFormat.format(_retornoInvestimento)}%
    Relação benefício/custo: ${_numberFormat.format(_relacaoBeneficioCusto)}
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  void _selecionarCultura() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a Cultura'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _culturas
                  .map((cultura) => ListTile(
                        title: Text(cultura),
                        onTap: () {
                          setState(() {
                            _cultura = cultura;
                            _culturaController.text = cultura;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputFields() {
    final unidade = _unidadesPorCultura[_cultura]!;
    final isDark = ThemeManager().isDark.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: ShadcnStyle.borderColor),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados da Produção',
              style: TextStyle(
                color: ShadcnStyle.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Cultura selector
            GestureDetector(
              onTap: _selecionarCultura,
              child: VTextField(
                labelText: 'Cultura',
                readOnly: true,
                txEditController: _culturaController,
                focusNode: _focus1,
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Basic info fields
            VTextField(
              labelText: 'Área plantada (ha)',
              focusNode: _focus2,
              txEditController: _areaPlantada,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 100',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Valor do investimento total (R\$)',
              focusNode: _focus3,
              txEditController: _valorInvestimentoTotal,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 50000',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Custos por Hectare',
                style: TextStyle(
                  color: ShadcnStyle.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            VTextField(
              labelText: 'Custo de insumos (R\$/ha)',
              focusNode: _focus4,
              txEditController: _custoInsumos,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 2000',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Custo de maquinário (R\$/ha)',
              focusNode: _focus5,
              txEditController: _custoMaquinario,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 1500',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Custo de mão de obra (R\$/ha)',
              focusNode: _focus6,
              txEditController: _custoMaoObra,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 500',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Custo de arrendamento (R\$/ha)',
              focusNode: _focus7,
              txEditController: _custoArrendamento,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 1000',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Projeções',
                style: TextStyle(
                  color: ShadcnStyle.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            VTextField(
              labelText: 'Produtividade prevista ($unidade/ha)',
              focusNode: _focus8,
              txEditController: _produtividadePrevista,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 60',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Preço de venda (R\$/$unidade)',
              focusNode: _focus9,
              txEditController: _precoVendaProduto,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 100',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Impostos e taxas (%)',
              focusNode: _focus10,
              txEditController: _impostosTaxas,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 5.5',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Outros custos (R\$/ha)',
              focusNode: _focus11,
              txEditController: _outrosCustos,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              hintText: 'Ex: 200',
              inputFormatters: [
                formatters.DecimalInputFormatter(decimalPlaces: 2)
              ],
              showClearButton: true,
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _limpar,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Limpar'),
                  style: ShadcnStyle.textButtonStyle,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _calcular,
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Calcular'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                if (_calculado) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _compartilhar,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Compartilhar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ShadcnStyle.textColor,
          ),
        ),
        const SizedBox(height: 5),
        ...children,
        const SizedBox(height: 5),
        Divider(color: ShadcnStyle.borderColor, thickness: 1),
      ],
    );
  }

  Widget _buildResultItem(String label, num value, [String unit = 'R\$']) {
    String valueText;
    if (unit == '%') {
      valueText = '${_percentFormat.format(value)}$unit';
    } else if (unit.isEmpty) {
      valueText = _numberFormat.format(value);
    } else {
      valueText = '$unit ${_numberFormat.format(value)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ShadcnStyle.textColor)),
          Text(valueText, style: TextStyle(color: ShadcnStyle.textColor)),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final unidade = _unidadesPorCultura[_cultura]!;

    return Visibility(
      visible: _calculado,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: ShadcnStyle.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados da Análise',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildResultSection(
                'Custos',
                [
                  _buildResultItem('Custo total por hectare',
                      _custoTotalPorHectare, 'R\$/ha'),
                  _buildResultItem(
                      'Custo total de produção', _custoTotalProducao),
                  _buildResultItem(
                      'Custo unitário', _custoUnitario, 'R\$/$unidade'),
                ],
              ),
              _buildResultSection(
                'Receitas',
                [
                  _buildResultItem('Receita bruta por hectare',
                      _receitaBrutaPorHectare, 'R\$/ha'),
                  _buildResultItem('Receita bruta total', _receitaBrutaTotal),
                ],
              ),
              _buildResultSection(
                'Margens e Lucros',
                [
                  _buildResultItem('Margem bruta por hectare',
                      _margemBrutaPorHectare, 'R\$/ha'),
                  _buildResultItem('Margem bruta total', _margemBrutaTotal),
                  _buildResultItem('Lucro líquido por hectare',
                      _lucroLiquidoPorHectare, 'R\$/ha'),
                  _buildResultItem('Lucro líquido total', _lucroLiquidoTotal),
                ],
              ),
              _buildResultSection(
                'Indicadores',
                [
                  _buildResultItem(
                      'Ponto de equilíbrio', _pontoEquilibrio, '$unidade/ha'),
                  _buildResultItem(
                      'Retorno sobre investimento', _retornoInvestimento, '%'),
                  _buildResultItem(
                      'Relação benefício/custo', _relacaoBeneficioCusto, ''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterpretationCard() {
    if (!_calculado) return const SizedBox.shrink();

    final isDark = ThemeManager().isDark.value;
    final positiveColor = isDark ? Colors.green.shade300 : Colors.green;
    final negativeColor = isDark ? Colors.red.shade300 : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: ShadcnStyle.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interpretação dos Resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                _relacaoBeneficioCusto > 1 ? Icons.check_circle : Icons.warning,
                color:
                    _relacaoBeneficioCusto > 1 ? positiveColor : negativeColor,
              ),
              title: Text(
                'Viabilidade do Projeto',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              subtitle: Text(
                _relacaoBeneficioCusto > 1
                    ? 'O projeto é viável, com retorno positivo sobre o investimento'
                    : 'O projeto apresenta riscos, com possível retorno negativo',
                style: TextStyle(color: ShadcnStyle.textColor.withValues(alpha: 0.7)),
              ),
            ),
            ListTile(
              leading: Icon(
                _retornoInvestimento > 15
                    ? Icons.trending_up
                    : Icons.trending_down,
                color:
                    _retornoInvestimento > 15 ? positiveColor : negativeColor,
              ),
              title: Text(
                'Retorno do Investimento',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              subtitle: Text(
                _retornoInvestimento > 15
                    ? 'Retorno acima da média do mercado'
                    : 'Retorno abaixo da média do mercado',
                style: TextStyle(color: ShadcnStyle.textColor.withValues(alpha: 0.7)),
              ),
            ),
            ListTile(
              leading: Icon(
                _lucroLiquidoPorHectare > 0
                    ? Icons.attach_money
                    : Icons.money_off,
                color:
                    _lucroLiquidoPorHectare > 0 ? positiveColor : negativeColor,
              ),
              title: Text(
                'Lucratividade',
                style: TextStyle(color: ShadcnStyle.textColor),
              ),
              subtitle: Text(
                _lucroLiquidoPorHectare > 0
                    ? 'Projeto apresenta lucro líquido positivo'
                    : 'Projeto apresenta prejuízo',
                style: TextStyle(color: ShadcnStyle.textColor.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildInputFields(),
          ),
          const SizedBox(height: 10),
          _buildResultCard(),
          const SizedBox(height: 10),
          _buildInterpretationCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
