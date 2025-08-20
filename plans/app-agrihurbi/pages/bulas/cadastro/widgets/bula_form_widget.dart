// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/bulas_cadastro_controller.dart';
import 'image_selector_widget.dart';

class BulaFormWidget extends StatelessWidget {
  final BulasCadastroController controller;

  const BulaFormWidget({
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
      child: Obx(() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ImageSelectorWidget(
                isMiniatura: false,
                onTap: controller.selecionarImagens,
                label: 'Imagens',
                displayImage:
                    controller.images.isNotEmpty ? controller.images[0] : null,
                hasImage: controller.images.isNotEmpty,
              ),
              ImageSelectorWidget(
                isMiniatura: true,
                onTap: controller.selecionarMiniatura,
                label: 'Miniatura',
                displayImage: controller.imageMiniatura.value,
                hasImage: controller.imageMiniatura.value != null,
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildFormField(
                    label: 'Medicamento',
                    initialValue: controller.bula.descricao,
                    onChanged: controller.updateBulaDescricao,
                    isRequired: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
