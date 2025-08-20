// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/widgets/textfield_widget.dart';
import '../../controller/previsao_simples_controller.dart';

class PrevisaoSimplesInputFields extends StatefulWidget {
  final PrevisaoSimplesController controller;

  const PrevisaoSimplesInputFields({
    super.key,
    required this.controller,
  });

  @override
  State<PrevisaoSimplesInputFields> createState() =>
      _PrevisaoSimplesInputFieldsState();
}

class _PrevisaoSimplesInputFieldsState
    extends State<PrevisaoSimplesInputFields> {
  final _areaPlantada = TextEditingController();
  final _custoPrevistoHectare = TextEditingController();
  final _sacasPrevistas = TextEditingController();
  final _valorSaca = TextEditingController();

  final _focus1 = FocusNode();
  final _focus2 = FocusNode();
  final _focus3 = FocusNode();
  final _focus4 = FocusNode();

  @override
  void initState() {
    super.initState();
    _initControllers();
    widget.controller.addListener(_updateControllers);
  }

  void _initControllers() {
    _areaPlantada.text = widget.controller.model.areaPlantada > 0
        ? widget.controller.model.areaPlantada.toString()
        : '';
    _custoPrevistoHectare.text =
        widget.controller.model.custoPrevistoHectare > 0
            ? widget.controller.model.custoPrevistoHectare.toString()
            : '';
    _sacasPrevistas.text = widget.controller.model.sacasPrevistas > 0
        ? widget.controller.model.sacasPrevistas.toString()
        : '';
    _valorSaca.text = widget.controller.model.valorSaca > 0
        ? widget.controller.model.valorSaca.toString()
        : '';
  }

  void _updateControllers() {
    setState(() {
      _initControllers();
    });
  }

  @override
  void dispose() {
    _areaPlantada.dispose();
    _custoPrevistoHectare.dispose();
    _sacasPrevistas.dispose();
    _valorSaca.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    widget.controller.removeListener(_updateControllers);
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
      _focus1.requestFocus();
      _exibirMensagem('Informe a área plantada');
      return false;
    }

    if (_custoPrevistoHectare.text.isEmpty) {
      _focus2.requestFocus();
      _exibirMensagem('Informe o custo previsto por hectare');
      return false;
    }

    if (_sacasPrevistas.text.isEmpty) {
      _focus3.requestFocus();
      _exibirMensagem('Informe a quantidade de sacas previstas por hectare');
      return false;
    }

    if (_valorSaca.text.isEmpty) {
      _focus4.requestFocus();
      _exibirMensagem('Informe o valor da saca');
      return false;
    }

    return true;
  }

  void _calcular() {
    if (!_validarCampos()) return;

    widget.controller.calcular(
      areaPlantada: double.parse(_areaPlantada.text.replaceAll(',', '.')),
      custoPrevistoHectare:
          double.parse(_custoPrevistoHectare.text.replaceAll(',', '.')),
      sacasPrevistas: double.parse(_sacasPrevistas.text.replaceAll(',', '.')),
      valorSaca: double.parse(_valorSaca.text.replaceAll(',', '.')),
    );
  }

  void _limpar() {
    setState(() {
      _areaPlantada.clear();
      _custoPrevistoHectare.clear();
      _sacasPrevistas.clear();
      _valorSaca.clear();
    });
    widget.controller.limpar();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
            VTextField(
              labelText: 'Área Plantada (ha)',
              hintText: 'Ex: 100',
              focusNode: _focus1,
              txEditController: _areaPlantada,
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Custo Previsto por Hectare',
              hintText: 'Ex: 5000',
              focusNode: _focus2,
              txEditController: _custoPrevistoHectare,
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Sacas Previstas por Hectare',
              hintText: 'Ex: 60',
              focusNode: _focus3,
              txEditController: _sacasPrevistas,
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            VTextField(
              labelText: 'Valor da Saca',
              hintText: 'Ex: 80',
              focusNode: _focus4,
              txEditController: _valorSaca,
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalInputFormatter(decimalPlaces: 2)],
              showClearButton: true,
            ),
            const SizedBox(height: 24),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
