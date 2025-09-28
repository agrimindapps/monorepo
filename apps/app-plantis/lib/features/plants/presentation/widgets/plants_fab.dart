import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/riverpod_providers/solid_providers.dart';
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
    // Inicializar o formulário para adição de nova planta
    final formManager = ref.read(solidPlantFormStateManagerProvider.notifier);
    formManager.initializeForNewPlant();

    // Mostrar dialog
    await PlantFormDialog.show(context);

    // O cleanup é automático com Riverpod
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
