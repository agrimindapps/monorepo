// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../styles/form_colors.dart';
import '../styles/form_constants.dart';
import '../styles/form_styles.dart';

/// Loading overlay widget with customizable message
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final double? opacity;

  const LoadingOverlay({
    super.key,
    this.message,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: FormStyles.getLoadingOverlayDecoration().copyWith(
        color: FormColors.loadingBackground.withValues(
          alpha: opacity ?? FormConstants.loadingOverlayOpacity,
        ),
      ),
      child: Center(
        child: Card(
          elevation: FormConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(FormConstants.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: FormConstants.loadingIndicatorSize,
                  height: FormConstants.loadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FormColors.loadingIndicator,
                    ),
                  ),
                ),
                
                if (message != null) ...[
                  const SizedBox(height: FormConstants.spacingMedium),
                  Text(
                    message!,
                    style: FormStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated loading overlay with fade in/out animation
class AnimatedLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final double? opacity;
  final Widget child;

  const AnimatedLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.child,
    this.message,
    this.opacity,
  });

  @override
  State<AnimatedLoadingOverlay> createState() => _AnimatedLoadingOverlayState();
}

class _AnimatedLoadingOverlayState extends State<AnimatedLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: FormConstants.animationDurationMedium,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _animation.value == 0.0
                ? const SizedBox.shrink()
                : Opacity(
                    opacity: _animation.value,
                    child: LoadingOverlay(
                      message: widget.message,
                      opacity: widget.opacity,
                    ),
                  );
          },
        ),
      ],
    );
  }
}
