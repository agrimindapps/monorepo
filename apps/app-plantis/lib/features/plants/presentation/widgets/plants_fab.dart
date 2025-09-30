import 'package:core/core.dart';
import 'package:flutter/material.dart';

class PlantsFab extends ConsumerWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  Future<void> _onAddPlant(BuildContext context, WidgetRef ref) async {
    // Navegar para página de formulário ao invés de mostrar dialog
    await context.push('/plants/add');
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
