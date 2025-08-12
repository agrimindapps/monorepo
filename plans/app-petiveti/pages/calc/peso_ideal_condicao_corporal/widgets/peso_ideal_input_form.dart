// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../controller/peso_ideal_controller.dart';
import '../utils/peso_ideal_utils.dart';

/// Componente de formulário para entrada de dados da calculadora de peso ideal
class PesoIdealInputForm extends StatelessWidget {
  final PesoIdealController controller;

  const PesoIdealInputForm({
    super.key,
    required this.controller,
  });

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildEspecieDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRacaDropdown()),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSexoDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildIdadeEsterilizacaoRow()),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPesoAtualField(),
                const SizedBox(height: 16),
                _buildEscalaECC(),
                const SizedBox(height: 16),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEspecieDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.model.especieSelecionada,
      decoration: const InputDecoration(
        labelText: 'Espécie',
        border: OutlineInputBorder(),
      ),
      items: ['Cão', 'Gato']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: controller.atualizarEspecie,
      validator: (value) => value == null ? 'Selecione uma espécie' : null,
    );
  }

  Widget _buildRacaDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.model.racaSelecionada,
      decoration: const InputDecoration(
        labelText: 'Raça',
        border: OutlineInputBorder(),
      ),
      items: (controller
                  .model.racasPorEspecie[controller.model.especieSelecionada] ??
              [])
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: controller.atualizarRaca,
      validator: (value) => value == null ? 'Selecione uma raça' : null,
    );
  }

  Widget _buildSexoDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.model.sexoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Sexo',
        border: OutlineInputBorder(),
      ),
      items: ['macho', 'fêmea']
          .map((e) => DropdownMenuItem(
              value: e, child: Text(e[0].toUpperCase() + e.substring(1))))
          .toList(),
      onChanged: controller.atualizarSexo,
      validator: (value) => value == null ? 'Selecione o sexo' : null,
    );
  }

  Widget _buildIdadeEsterilizacaoRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Idade (anos)',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.atualizarIdade,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CheckboxListTile(
            title: const Text('Esterilizado'),
            value: controller.model.esterilizado,
            onChanged: controller.atualizarEsterilizado,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildPesoAtualField() {
    return TextFormField(
      controller: controller.pesoAtualController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [pontoPraVirgula()],
      decoration: const InputDecoration(
        labelText: 'Peso atual (kg)',
        border: OutlineInputBorder(),
      ),
      validator: PesoIdealUtils.validateNumber,
    );
  }

  Widget _buildEscalaECC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escala de Condição Corporal (ECC)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Slider(
          value: controller.model.escalaECCSelecionada ?? 5.0,
          min: 1,
          max: 9,
          divisions: 8,
          label: controller.model.escalaECCSelecionada?.toString() ?? '5',
          onChanged: controller.atualizarEscalaECC,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1\nCaquético'),
            Text('3\nMagro'),
            Text('5\nIdeal'),
            Text('7\nAcima'),
            Text('9\nObeso'),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Builder(
      builder: (BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: controller.limpar,
            child: const Text('Limpar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.calcular(context),
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }
}
