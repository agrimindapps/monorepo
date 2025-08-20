// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_lista_controller.dart';
import '../../utils/racas_lista_constants.dart';
import '../../utils/racas_lista_helpers.dart';

class QuickFiltersWidget extends StatelessWidget {
  final RacasListaController controller;

  const QuickFiltersWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: RacasListaConstants.quickFiltersHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: RacasListaConstants.quickFilterOptions.length,
        itemBuilder: (context, index) {
          final filter = RacasListaConstants.quickFilterOptions[index];
          final isSelected = controller.quickFilters.contains(filter);

          return Padding(
            padding: RacasListaConstants.filterChipMargin,
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => controller.toggleQuickFilter(filter),
              backgroundColor: RacasListaHelpers.getFilterChipColor(false),
              selectedColor: RacasListaHelpers.getFilterChipSelectedColor(),
              checkmarkColor: RacasListaHelpers.getFilterChipCheckmarkColor(),
            ),
          );
        },
      ),
    );
  }
}
