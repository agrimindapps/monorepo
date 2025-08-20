// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/lista_medicamento_controller.dart';

class MedicamentoSearchBarWidget extends StatelessWidget {
  final ListaMedicamentoController controller;

  const MedicamentoSearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          labelText: 'Pesquisar medicamento',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Colors.grey[100],
          filled: true,
        ),
        onChanged: controller.updateSearchText,
      ),
    );
  }
}
