import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'plant_form_dialog.dart';

class PlantsFab extends ConsumerWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  Future<void> _onAddPlant(BuildContext context, WidgetRef ref) async {
    // Mostrar dialog modal para cadastro de planta
    await PlantFormDialog.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onAddPlant(context, ref),
          borderRadius: BorderRadius.circular(28),
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}
