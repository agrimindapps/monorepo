// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/implementos_cadastro_controller.dart';

class FormFieldsWidget extends StatelessWidget {
  final ImplementosCadastroController controller;

  const FormFieldsWidget({
    super.key,
    required this.controller,
  });

  Widget _buildFormField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: isRequired
            ? const Icon(Icons.star, size: 10, color: Colors.red)
            : null,
      ),
      validator: isRequired
          ? (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null
          : null,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildFormField(
                label: 'Descrição',
                initialValue: controller.implemento.descricao,
                onChanged: (value) =>
                    controller.updateImplemento(descricao: value),
                isRequired: true,
              ),
              _buildFormField(
                label: 'Marca',
                initialValue: controller.implemento.marca,
                onChanged: (value) => controller.updateImplemento(marca: value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Disponível'),
                value: controller.implemento.status,
                onChanged: (value) =>
                    controller.updateImplemento(status: value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
