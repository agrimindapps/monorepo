import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';

class PlantsFab extends StatefulWidget {
  final VoidCallback onScrollToTop;
  final ScrollController scrollController;

  const PlantsFab({
    super.key,
    required this.onScrollToTop,
    required this.scrollController,
  });

  @override
  State<PlantsFab> createState() => _PlantsFabState();
}

class _PlantsFabState extends State<PlantsFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final showScrollToTop = widget.scrollController.offset > 200;
    if (showScrollToTop != _showScrollToTop) {
      setState(() {
        _showScrollToTop = showScrollToTop;
      });
      if (showScrollToTop) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _onAddPlant() {
    context.push('/plants/add');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Botão de scroll to top
        if (_showScrollToTop)
          Positioned(
            bottom: 80,
            right: 0,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: FloatingActionButton.small(
                    onPressed: widget.onScrollToTop,
                    heroTag: 'scroll_to_top',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: PlantisColors.primary,
                    tooltip: 'Voltar ao topo',
                    elevation: 2,
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                );
              },
            ),
          ),
        
        // Botão principal (adicionar planta)
        FloatingActionButton.extended(
          onPressed: _onAddPlant,
          heroTag: 'add_plant',
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          tooltip: 'Adicionar nova planta',
          icon: const Icon(Icons.add),
          label: const Text(
            'Nova Planta',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}