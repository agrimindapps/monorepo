// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../controller/dieta_caseira_controller.dart';

class DietaCaseiraInputForm extends StatefulWidget {
  final DietaCaseiraController controller;
  final VoidCallback onCalcular;
  final VoidCallback onLimpar;

  const DietaCaseiraInputForm({
    super.key,
    required this.controller,
    required this.onCalcular,
    required this.onLimpar,
  });

  @override
  State<DietaCaseiraInputForm> createState() => _DietaCaseiraInputFormState();
}

class _DietaCaseiraInputFormState extends State<DietaCaseiraInputForm> {
  final _pesoController = TextEditingController();
  final _idadeAnosController = TextEditingController();
  final _idadeMesesController = TextEditingController();

  @override
  void dispose() {
    _pesoController.dispose();
    _idadeAnosController.dispose();
    _idadeMesesController.dispose();
    super.dispose();
  }

  // Conversor de ponto para vírgula e restrição a números e separadores decimais
  TextInputFormatter pontoPraVirgula() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      // Primeiro, filtra para permitir apenas dígitos e vírgulas/pontos
      final filteredText = newValue.text.replaceAll(RegExp(r'[^0-9.,]'), '');
      // Depois, converte pontos para vírgulas
      final text = filteredText.replaceAll('.', ',');
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  // Formatador para permitir apenas dígitos (números inteiros)
  TextInputFormatter apenasDigitos() {
    return FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: widget.controller.formKey,
          child: Column(
            children: [
              _buildEspecieDropdown(),
              const SizedBox(height: 16),
              _buildEstadoFisiologicoDropdown(),
              const SizedBox(height: 16),
              _buildNivelAtividadeDropdown(),
              const SizedBox(height: 16),
              _buildTipoAlimentacaoDropdown(),
              const SizedBox(height: 16),
              _buildPesoTextField(),
              const SizedBox(height: 16),
              _buildIdadeFields(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEspecieDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Espécie',
        border: OutlineInputBorder(),
      ),
      value: widget.controller.model.especieSelecionada,
      validator: (value) => value == null ? 'Selecione a espécie' : null,
      onChanged: widget.controller.setEspecie,
      items: widget.controller.model.especies.map((especie) {
        return DropdownMenuItem<String>(
          value: especie,
          child: Text(especie),
        );
      }).toList(),
    );
  }

  Widget _buildEstadoFisiologicoDropdown() {
    final estadosFisiologicos = widget.controller.model.especieSelecionada !=
            null
        ? widget.controller.model
            .estadosFisiologicos[widget.controller.model.especieSelecionada!]!
        : <String>[];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Estado Fisiológico',
        border: OutlineInputBorder(),
      ),
      value: widget.controller.model.estadoFisiologicoSelecionado,
      validator: (value) =>
          value == null ? 'Selecione o estado fisiológico' : null,
      onChanged: widget.controller.model.especieSelecionada != null
          ? widget.controller.setEstadoFisiologico
          : null,
      items: estadosFisiologicos.map((estado) {
        return DropdownMenuItem<String>(
          value: estado,
          child: Text(estado),
        );
      }).toList(),
    );
  }

  Widget _buildNivelAtividadeDropdown() {
    final niveisAtividade = widget.controller.model.especieSelecionada != null
        ? widget.controller.model
            .niveisAtividade[widget.controller.model.especieSelecionada!]!
        : <String>[];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Nível de Atividade',
        border: OutlineInputBorder(),
      ),
      value: widget.controller.model.nivelAtividadeSelecionado,
      validator: (value) =>
          value == null ? 'Selecione o nível de atividade' : null,
      onChanged: widget.controller.model.especieSelecionada != null
          ? widget.controller.setNivelAtividade
          : null,
      items: niveisAtividade.map((nivel) {
        return DropdownMenuItem<String>(
          value: nivel,
          child: Text(nivel),
        );
      }).toList(),
    );
  }

  Widget _buildTipoAlimentacaoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Tipo de Dieta',
        border: OutlineInputBorder(),
      ),
      value: widget.controller.model.tipoAlimentacaoSelecionado,
      validator: (value) => value == null ? 'Selecione o tipo de dieta' : null,
      onChanged: widget.controller.setTipoAlimentacao,
      items: widget.controller.model.tiposAlimentacao.map((tipo) {
        return DropdownMenuItem<String>(
          value: tipo,
          child: Text(tipo),
        );
      }).toList(),
    );
  }

  Widget _buildPesoTextField() {
    return TextFormField(
      controller: _pesoController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [pontoPraVirgula()],
      decoration: const InputDecoration(
        labelText: 'Peso do Animal (kg)',
        border: OutlineInputBorder(),
      ),
      validator: (value) => widget.controller.validateNumber(value),
    );
  }

  Widget _buildIdadeFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _idadeAnosController,
            keyboardType: TextInputType.number,
            inputFormatters: [apenasDigitos()],
            decoration: const InputDecoration(
              labelText: 'Idade (Anos)',
              border: OutlineInputBorder(),
            ),
            validator: (value) => widget.controller.validateInteger(value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _idadeMesesController,
            keyboardType: TextInputType.number,
            inputFormatters: [apenasDigitos()],
            decoration: const InputDecoration(
              labelText: 'Idade (Meses)',
              border: OutlineInputBorder(),
            ),
            validator: (value) => widget.controller.validateInteger(value),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            _pesoController.clear();
            _idadeAnosController.clear();
            _idadeMesesController.clear();
            widget.onLimpar();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Limpar'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            widget.controller.calcular(
              _pesoController.text,
              _idadeAnosController.text,
              _idadeMesesController.text,
            );
            widget.onCalcular();
          },
          icon: const Icon(Icons.calculate),
          label: const Text('Calcular'),
        ),
      ],
    );
  }
}
