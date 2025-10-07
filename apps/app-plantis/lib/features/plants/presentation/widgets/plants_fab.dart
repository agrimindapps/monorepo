import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'plant_form_dialog.dart';

class PlantsFab extends ConsumerWidget {
  const PlantsFab({super.key});

  Future<void> _onAddPlant(BuildContext context) async {
    await PlantFormDialog.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () => _onAddPlant(context),
      backgroundColor: theme.colorScheme.secondary,
      child: Icon(
        Icons.add,
        color: theme.colorScheme.onSecondary,
        size: 28,
      ),
    );
  }
}
