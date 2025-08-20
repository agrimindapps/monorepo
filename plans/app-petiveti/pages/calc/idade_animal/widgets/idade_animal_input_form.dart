// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/idade_animal_controller.dart';

class IdadeAnimalInputForm extends StatelessWidget {
  final IdadeAnimalController controller;

  const IdadeAnimalInputForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = controller.model;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildEspecieDropdown(),
                const SizedBox(height: 16),
                _buildIdadeField(),
                const SizedBox(height: 16),
                if (model.especieSelecionada == 'Cão') _buildPorteDropdown(),
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
      items: controller.model.especies
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: controller.atualizarEspecie,
      validator: (value) => value == null ? 'Selecione uma espécie' : null,
    );
  }

  Widget _buildIdadeField() {
    return TextFormField(
      controller: controller.idadeController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Idade do animal (anos)',
        border: OutlineInputBorder(),
      ),
      validator: controller.validateNumber,
    );
  }

  Widget _buildPorteDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.model.porteCanino,
      decoration: const InputDecoration(
        labelText: 'Porte do cão',
        border: OutlineInputBorder(),
      ),
      items: controller.model.portesCaes
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: controller.atualizarPorte,
      validator: (value) =>
          controller.model.especieSelecionada == 'Cão' && value == null
              ? 'Selecione o porte do cão'
              : null,
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: controller.limpar,
          child: const Text('Limpar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: controller.calcular,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Calcular'),
        ),
      ],
    );
  }
}
