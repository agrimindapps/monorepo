// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/necessidades_caloricas_controller.dart';
import '../utils/necessidades_caloricas_utils.dart';

class InputFormWidget extends StatefulWidget {
  final NecessidasCaloricas_Controller controller;

  const InputFormWidget({
    super.key,
    required this.controller,
  });

  @override
  State<InputFormWidget> createState() => _InputFormWidgetState();
}

class _InputFormWidgetState extends State<InputFormWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                TextFormField(
                  controller: widget.controller.pesoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Peso do animal (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: widget.controller.validatePeso,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.controller.especieSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
                  ),
                  items: NecessidadesCaloricas_Utils.especies
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: widget.controller.atualizarEspecie,
                  validator: (value) =>
                      value == null ? 'Selecione uma espécie' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.controller.estadoFisiologicoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado Fisiológico',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.controller.especieSelecionada != null
                      ? NecessidadesCaloricas_Utils.estadosFisiologicos[
                              widget.controller.especieSelecionada!]!
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList()
                      : [],
                  onChanged: widget.controller.atualizarEstadoFisiologico,
                  validator: (value) =>
                      value == null ? 'Selecione o estado fisiológico' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.controller.nivelAtividadeSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Nível de Atividade',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.controller.especieSelecionada != null
                      ? NecessidadesCaloricas_Utils.niveisAtividade[
                              widget.controller.especieSelecionada!]!
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList()
                      : [],
                  onChanged: widget.controller.atualizarNivelAtividade,
                  validator: (value) =>
                      value == null ? 'Selecione o nível de atividade' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.controller.limpar,
                      child: const Text('Limpar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.controller.calcular();
                        }
                      },
                      child: const Text('Calcular'),
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
