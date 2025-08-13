import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlantsFab extends StatelessWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  void _onAddPlant(BuildContext context) {
    context.push('/plants/add');
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