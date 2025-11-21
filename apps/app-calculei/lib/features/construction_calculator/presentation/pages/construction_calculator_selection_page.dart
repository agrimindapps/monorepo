import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/construction_calc_type.dart';

/// Selection page for construction calculator types
///
/// Allows users to choose which type of construction calculation to perform
class ConstructionCalculatorSelectionPage extends StatefulWidget {
  const ConstructionCalculatorSelectionPage({super.key});

  @override
  State<ConstructionCalculatorSelectionPage> createState() =>
      _ConstructionCalculatorSelectionPageState();
}

class _ConstructionCalculatorSelectionPageState
    extends State<ConstructionCalculatorSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Cálculos de Construção'),
          ],
        ),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  -1.0 + (_gradientAnimation.value * 0.5),
                  -1.0 + (_gradientAnimation.value * 0.3),
                ),
                end: Alignment(
                  1.0 - (_gradientAnimation.value * 0.5),
                  1.0 - (_gradientAnimation.value * 0.3),
                ),
                colors: [
                  Colors.orange.shade50,
                  Colors.amber.shade50,
                  Colors.yellow.shade50,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Escolha o tipo de cálculo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione o cálculo que você deseja realizar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),
                ..._buildCalculatorCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCalculatorCards() {
    final calcTypes = ConstructionCalcType.values;
    return List.generate(
      calcTypes.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _ConstructionTypeCard(
          index: index,
          calcType: calcTypes[index],
          onTap: () => context.go(calcTypes[index].route),
        ),
      ),
    );
  }
}

class _ConstructionTypeCard extends StatefulWidget {
  const _ConstructionTypeCard({
    required this.index,
    required this.calcType,
    required this.onTap,
  });

  final int index;
  final ConstructionCalcType calcType;
  final VoidCallback onTap;

  @override
  State<_ConstructionTypeCard> createState() => _ConstructionTypeCardState();
}

class _ConstructionTypeCardState extends State<_ConstructionTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovering = false;

  static const Color _materialsColor = Color(0xFF8B4513); // Brown
  static const Color _costColor = Color(0xFF2E7D32); // Green
  static const Color _paintColor = Color(0xFF1565C0); // Blue
  static const Color _flooringColor = Color(0xFF795548); // Brown Grey
  static const Color _concreteColor = Color(0xFF424242); // Dark Grey

  late Color _cardColor;

  @override
  void initState() {
    super.initState();

    _cardColor = _getColorForType(widget.calcType);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.15,
          0.5 + (widget.index * 0.15),
          curve: Curves.easeOut,
        ),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.15,
          0.5 + (widget.index * 0.15),
          curve: Curves.elasticOut,
        ),
      ),
    );

    _controller.forward();
  }

  Color _getColorForType(ConstructionCalcType type) {
    switch (type) {
      case ConstructionCalcType.materialsQuantity:
        return _materialsColor;
      case ConstructionCalcType.costPerSquareMeter:
        return _costColor;
      case ConstructionCalcType.paintConsumption:
        return _paintColor;
      case ConstructionCalcType.flooring:
        return _flooringColor;
      case ConstructionCalcType.concrete:
        return _concreteColor;
    }
  }

  IconData _getIconForType(ConstructionCalcType type) {
    switch (type) {
      case ConstructionCalcType.materialsQuantity:
        return Icons.layers;
      case ConstructionCalcType.costPerSquareMeter:
        return Icons.trending_up;
      case ConstructionCalcType.paintConsumption:
        return Icons.format_paint;
      case ConstructionCalcType.flooring:
        return Icons.grid_on;
      case ConstructionCalcType.concrete:
        return Icons.foundation;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _cardColor.withOpacity(
                      _isHovering ? 0.4 : 0.15,
                    ),
                    blurRadius: _isHovering ? 24 : 12,
                    offset: Offset(0, _isHovering ? 12 : 6),
                    spreadRadius: _isHovering ? 2 : 0,
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isHovering
                          ? [
                              _cardColor.withOpacity(0.1),
                              _cardColor.withOpacity(0.05),
                            ]
                          : [
                              Colors.white,
                              Colors.white.withOpacity(0.8),
                            ],
                    ),
                    border: Border.all(
                      color: _cardColor.withOpacity(_isHovering ? 0.3 : 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Transform.scale(
                      scale: _isHovering ? 1.02 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _cardColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedScale(
                                  scale: _isHovering ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    _getIconForType(widget.calcType),
                                    size: 32,
                                    color: _cardColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.calcType.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _isHovering
                                                ? _cardColor
                                                : Colors.grey[800],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.calcType.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: _cardColor.withOpacity(0.5),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
