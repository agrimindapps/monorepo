// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/lista_medicamento_controller.dart';

class MedicamentoFilterChipsWidget extends StatelessWidget {
  final ListaMedicamentoController controller;

  const MedicamentoFilterChipsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tiposFiltro.length,
        itemBuilder: (context, index) {
          final tipo = controller.tiposFiltro[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(tipo),
              selected: controller.filterType == tipo,
              onSelected: (selected) {
                controller.updateFilterType(selected ? tipo : 'Todos');
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
            ),
          );
        },
      ),
    );
  }
}
