import 'package:flutter/material.dart';

/// Animation wrapper for expense list items
///
/// **SRP**: Gerencia animações de entrada de lista
/// Extraído de ExpenseEnhancedList para separar lógica de animação
class ExpenseListAnimations extends StatelessWidget {
  final int index;
  final Widget child;
  final bool enableAnimations;

  const ExpenseListAnimations({
    super.key,
    required this.index,
    required this.child,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableAnimations) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}

/// Fade animation controller for entire list
class ExpenseListFadeAnimation extends StatefulWidget {
  final Widget child;
  final bool enableAnimations;

  const ExpenseListFadeAnimation({
    super.key,
    required this.child,
    this.enableAnimations = true,
  });

  @override
  State<ExpenseListFadeAnimation> createState() =>
      _ExpenseListFadeAnimationState();
}

class _ExpenseListFadeAnimationState extends State<ExpenseListFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.enableAnimations) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}
