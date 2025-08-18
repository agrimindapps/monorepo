import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_form_provider.dart';
import 'plant_form_modal.dart';
import '../../../../core/di/injection_container.dart' as di;

class PlantsFab extends StatelessWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  void _onAddPlant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => di.sl<PlantFormProvider>(),
        child: const PlantFormModal(),
      ),
    );
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
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }
}