// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/page_header_widget.dart';
import '../../controllers/racas_lista_controller.dart';
import '../../models/especie_model.dart';

class RacasAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final RacasListaController controller;
  final Especie? especie;
  final VoidCallback onFilterPressed;

  const RacasAppBarWidget({
    super.key,
    required this.controller,
    required this.especie,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: PageHeaderWidget(
          title: 'Raças de ${especie?.nome ?? "Animais"}',
          subtitle: 'Explore todas as raças disponíveis',
          icon: Icons.pets,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filtrar',
              onPressed: onFilterPressed,
            ),
            IconButton(
              icon: Icon(
                controller.isGridView ? Icons.view_list : Icons.view_module,
              ),
              tooltip: 'Alterar visualização',
              onPressed: controller.toggleViewMode,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
