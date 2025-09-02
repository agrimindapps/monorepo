import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../providers/plant_form_provider.dart';
import 'plant_form_dialog.dart';

class PlantsFab extends StatelessWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  Future<void> _onAddPlant(BuildContext context) async {
    // Criar um novo provider para a dialog
    final plantFormProvider = di.sl<PlantFormProvider>();
    
    // Mostrar dialog com o provider
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: plantFormProvider,
        child: const PlantFormDialog(),
      ),
    );
    
    // Limpar o provider após fechar a dialog
    plantFormProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () => _onAddPlant(context),
          borderRadius: BorderRadius.circular(28),
          child: const Icon(Icons.add, color: Colors.black, size: 28),
        ),
      ),
    );
  }
}
