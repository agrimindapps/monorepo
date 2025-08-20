// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/design_tokens.dart';

/// Animation utilities for consistent animations across the app
class AnimationUtils {
  AnimationUtils._();

  /// Fade in animation for widgets
  static Widget fadeIn({
    required Widget child,
    Duration duration = DesignTokens.animationNormal,
    Curve curve = DesignTokens.curveStandard,
    double? delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in from bottom animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = DesignTokens.animationNormal,
    Curve curve = DesignTokens.curveDecelerate,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: 0.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offset * value),
          child: Opacity(
            opacity: 1.0 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Scale in animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = DesignTokens.animationNormal,
    Curve curve = DesignTokens.curveBounce,
    double beginScale = 0.0,
    double endScale = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: beginScale, end: endScale),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Staggered list animation
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = DesignTokens.animationNormal,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration + (delay * index),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: DesignTokens.curveDecelerate,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide out animation (for dismissible items)
  static Widget slideOut({
    required Widget child,
    required Animation<double> animation,
    DismissDirection direction = DismissDirection.endToStart,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: direction == DismissDirection.endToStart
            ? const Offset(1.0, 0.0)
            : const Offset(-1.0, 0.0),
      ).animate(CurvedAnimation(
        parent: animation,
        curve: DesignTokens.curveStandard,
      )),
      child: child,
    );
  }

  /// Pulse animation for attention-grabbing elements
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minScale, end: maxScale),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // Reverse animation would be implemented with AnimationController in practice
      },
      child: child,
    );
  }
}

/// Animated loading indicator
class AnimatedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const AnimatedLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (_animation.value * 0.5),
          child: Opacity(
            opacity: 1.0 - _animation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bounce animation for buttons
class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  const BounceButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = DesignTokens.animationFast,
  });

  @override
  State<BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveStandard,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Shake animation for error feedback
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.offset = 10.0,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward().then((_) => _controller.reset());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        final offset = widget.offset * _offsetAnimation.value;
        return Transform.translate(
          offset: Offset(offset * (1 - 2 * (_offsetAnimation.value % 0.5) / 0.5), 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Page transition animations
class CustomPageTransitions {
  static Route<T> slideFromRight<T extends Object?>(
    Widget page, {
    Duration duration = DesignTokens.animationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = DesignTokens.curveDecelerate;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeTransition<T extends Object?>(
    Widget page, {
    Duration duration = DesignTokens.animationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
