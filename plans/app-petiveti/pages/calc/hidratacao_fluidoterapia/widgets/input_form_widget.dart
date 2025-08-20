// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import '../controller/hidratacao_fluidoterapia_controller.dart';
import '../model/hidratacao_fluidoterapia_model.dart';

class InputFormWidget extends StatefulWidget {
  const InputFormWidget({super.key});

  @override
  State<InputFormWidget> createState() => _InputFormWidgetState();
}

class _InputFormWidgetState extends State<InputFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _percentualDesidratacaoController = TextEditingController();
  final _perdaCorrente24hController = TextEditingController();
  final _temperaturaCorporalController = TextEditingController();

  String? _especieSelecionada;
  String? _tipoSolucaoSelecionado;
  String? _viaAdministracaoSelecionada;
  String? _condicaoClinicaSelecionada;

  @override
  void dispose() {
    _pesoController.dispose();
    _percentualDesidratacaoController.dispose();
    _perdaCorrente24hController.dispose();
    _temperaturaCorporalController.dispose();
    super.dispose();
  }

  // Conversor de ponto para vírgula
  TextInputFormatter pontoPraVirgula() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final text = newValue.text.replaceAll('.', ',');
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HidratacaoFluidoterapiaController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
                  ),
                  value: _especieSelecionada,
                  items: HidratacaoFluidoterapiaModel.especies
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _especieSelecionada = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione uma espécie' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    pontoPraVirgula(),
                  ],
                  validator: controller.validateNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _percentualDesidratacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Percentual de Desidratação (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    pontoPraVirgula(),
                  ],
                  validator: controller.validateDesidratacao,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _perdaCorrente24hController,
                  decoration: const InputDecoration(
                    labelText: 'Perdas Correntes em 24h (ml) - Opcional',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    pontoPraVirgula(),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temperaturaCorporalController,
                  decoration: const InputDecoration(
                    labelText: 'Temperatura Corporal (°C) - Opcional',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    pontoPraVirgula(),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Solução',
                    border: OutlineInputBorder(),
                  ),
                  value: _tipoSolucaoSelecionado,
                  items: HidratacaoFluidoterapiaModel.tiposSolucao
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _tipoSolucaoSelecionado = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione um tipo de solução' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Via de Administração',
                    border: OutlineInputBorder(),
                  ),
                  value: _viaAdministracaoSelecionada,
                  items: HidratacaoFluidoterapiaModel.viasAdministracao
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _viaAdministracaoSelecionada = value;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Selecione uma via de administração'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Condição Clínica',
                    border: OutlineInputBorder(),
                  ),
                  value: _condicaoClinicaSelecionada,
                  items: HidratacaoFluidoterapiaModel.condicoesClinicas
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _condicaoClinicaSelecionada = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Selecione uma condição clínica' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.calcular(
                              peso: double.parse(
                                  _pesoController.text.replaceAll(',', '.')),
                              percentualDesidratacao: double.parse(
                                  _percentualDesidratacaoController.text
                                      .replaceAll(',', '.')),
                              perdaCorrente24h:
                                  _perdaCorrente24hController.text.isEmpty
                                      ? 0.0
                                      : double.parse(_perdaCorrente24hController
                                          .text
                                          .replaceAll(',', '.')),
                              temperaturaCorporal:
                                  _temperaturaCorporalController.text.isEmpty
                                      ? 38.5
                                      : double.parse(
                                          _temperaturaCorporalController.text
                                              .replaceAll(',', '.')),
                              especieSelecionada: _especieSelecionada!,
                              tipoSolucaoSelecionado: _tipoSolucaoSelecionado!,
                              viaAdministracaoSelecionada:
                                  _viaAdministracaoSelecionada!,
                              condicaoClinicaSelecionada:
                                  _condicaoClinicaSelecionada!,
                            );
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'CALCULAR',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                        _pesoController.clear();
                        _percentualDesidratacaoController.clear();
                        _perdaCorrente24hController.clear();
                        _temperaturaCorporalController.clear();
                        setState(() {
                          _especieSelecionada = null;
                          _tipoSolucaoSelecionado = null;
                          _viaAdministracaoSelecionada = null;
                          _condicaoClinicaSelecionada = null;
                        });
                        controller.limpar();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('LIMPAR'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
