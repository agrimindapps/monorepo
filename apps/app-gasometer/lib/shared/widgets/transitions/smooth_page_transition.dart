import 'package:flutter/material.dart';
import '../../../core/theme/loading_design_tokens.dart';

/// Widget para transições suaves entre páginas
/// Fornece animações personalizadas e profissionais para navegação
class SmoothPageTransition extends StatefulWidget {
  const SmoothPageTransition({
    super.key,
    required this.child,
    this.transitionType = SmoothTransitionType.fadeSlide,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.onComplete,
    this.reverse = false,
  });
  final Widget child;
  final SmoothTransitionType transitionType;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final VoidCallback? onComplete;
  final bool reverse;

  /// Factory para transição de fade simples
  static SmoothPageTransition fade({
    Key? key,
    required Widget child,
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    return SmoothPageTransition(
      key: key,
      transitionType: SmoothTransitionType.fade,
      duration: duration ?? LoadingDesignTokens.normalDuration,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Factory para transição de slide
  static SmoothPageTransition slide({
    Key? key,
    required Widget child,
    SlideDirection direction = SlideDirection.fromRight,
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    return SmoothPageTransition(
      key: key,
      transitionType: _getSlideType(direction),
      duration: duration ?? LoadingDesignTokens.normalDuration,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Factory para transição de escala
  static SmoothPageTransition scale({
    Key? key,
    required Widget child,
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    return SmoothPageTransition(
      key: key,
      transitionType: SmoothTransitionType.scale,
      duration: duration ?? LoadingDesignTokens.normalDuration,
      onComplete: onComplete,
      child: child,
    );
  }

  /// Factory para transição combinada (mais suave)
  static SmoothPageTransition fadeSlide({
    Key? key,
    required Widget child,
    SlideDirection direction = SlideDirection.fromBottom,
    Duration? duration,
    VoidCallback? onComplete,
  }) {
    return SmoothPageTransition(
      key: key,
      transitionType:
          direction == SlideDirection.fromBottom
              ? SmoothTransitionType.fadeSlide
              : _getFadeSlideType(direction),
      duration: duration ?? LoadingDesignTokens.normalDuration,
      onComplete: onComplete,
      child: child,
    );
  }

  static SmoothTransitionType _getSlideType(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return SmoothTransitionType.slideFromLeft;
      case SlideDirection.fromRight:
        return SmoothTransitionType.slideFromRight;
      case SlideDirection.fromTop:
        return SmoothTransitionType.slideFromTop;
      case SlideDirection.fromBottom:
        return SmoothTransitionType.slideFromBottom;
    }
  }

  static SmoothTransitionType _getFadeSlideType(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return SmoothTransitionType.fadeSlideFromLeft;
      case SlideDirection.fromRight:
        return SmoothTransitionType.fadeSlideFromRight;
      case SlideDirection.fromTop:
        return SmoothTransitionType.fadeSlideFromTop;
      case SlideDirection.fromBottom:
        return SmoothTransitionType.fadeSlide;
    }
  }

  @override
  State<SmoothPageTransition> createState() => _SmoothPageTransitionState();
}

class _SmoothPageTransitionState extends State<SmoothPageTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _primaryAnimation = Tween<double>(
      begin: widget.reverse ? 1.0 : 0.0,
      end: widget.reverse ? 0.0 : 1.0,
    ).animate(curvedAnimation);

    _secondaryAnimation = Tween<double>(
      begin: widget.reverse ? 1.0 : 0.8,
      end: widget.reverse ? 0.8 : 1.0,
    ).animate(curvedAnimation);
    _slideAnimation = _getSlideAnimation(curvedAnimation);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !widget.reverse) {
        widget.onComplete?.call();
      } else if (status == AnimationStatus.dismissed && widget.reverse) {
        widget.onComplete?.call();
      }
    });
  }

  Animation<Offset> _getSlideAnimation(Animation<double> animation) {
    Offset begin;
    const end = Offset.zero;

    switch (widget.transitionType) {
      case SmoothTransitionType.slideFromLeft:
      case SmoothTransitionType.fadeSlideFromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case SmoothTransitionType.slideFromRight:
      case SmoothTransitionType.fadeSlideFromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case SmoothTransitionType.slideFromTop:
      case SmoothTransitionType.fadeSlideFromTop:
        begin = const Offset(0.0, -1.0);
        break;
      case SmoothTransitionType.slideFromBottom:
      case SmoothTransitionType.fadeSlide:
        begin = const Offset(0.0, 0.3);
        break;
      default:
        begin = Offset.zero;
    }

    if (widget.reverse) {
      return Tween<Offset>(begin: end, end: begin).animate(animation);
    } else {
      return Tween<Offset>(begin: begin, end: end).animate(animation);
    }
  }

  void _startAnimation() {
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          if (widget.reverse) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        }
      });
    } else {
      if (widget.reverse) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildTransition();
      },
    );
  }

  Widget _buildTransition() {
    switch (widget.transitionType) {
      case SmoothTransitionType.fade:
        return FadeTransition(opacity: _primaryAnimation, child: widget.child);

      case SmoothTransitionType.scale:
        return ScaleTransition(
          scale: _secondaryAnimation,
          child: FadeTransition(
            opacity: _primaryAnimation,
            child: widget.child,
          ),
        );

      case SmoothTransitionType.slideFromLeft:
      case SmoothTransitionType.slideFromRight:
      case SmoothTransitionType.slideFromTop:
      case SmoothTransitionType.slideFromBottom:
        return SlideTransition(position: _slideAnimation, child: widget.child);

      case SmoothTransitionType.fadeSlide:
      case SmoothTransitionType.fadeSlideFromLeft:
      case SmoothTransitionType.fadeSlideFromRight:
      case SmoothTransitionType.fadeSlideFromTop:
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _primaryAnimation,
            child: widget.child,
          ),
        );

      case SmoothTransitionType.slideScale:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _secondaryAnimation,
            child: widget.child,
          ),
        );

      case SmoothTransitionType.fadeSlideScale:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _secondaryAnimation,
            child: FadeTransition(
              opacity: _primaryAnimation,
              child: widget.child,
            ),
          ),
        );
    }
  }

  void forward() => _controller.forward();
  void reverse() => _controller.reverse();
  void reset() => _controller.reset();
  void stop() => _controller.stop();
}

/// Widget para transição entre múltiplas páginas com sequência
class SmoothPageSequence extends StatefulWidget {
  const SmoothPageSequence({
    super.key,
    required this.pages,
    this.pageDuration = const Duration(seconds: 2),
    this.transitionDuration = const Duration(milliseconds: 600),
    this.transitionType = SmoothTransitionType.fadeSlide,
    this.autoAdvance = true,
    this.onComplete,
    this.loop = false,
  });
  final List<Widget> pages;
  final Duration pageDuration;
  final Duration transitionDuration;
  final SmoothTransitionType transitionType;
  final bool autoAdvance;
  final VoidCallback? onComplete;
  final bool loop;

  @override
  State<SmoothPageSequence> createState() => _SmoothPageSequenceState();
}

class _SmoothPageSequenceState extends State<SmoothPageSequence> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoAdvance) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    Future.delayed(widget.pageDuration, () {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _nextPage() {
    if (!mounted) return;
    if (_currentIndex < widget.pages.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: widget.transitionDuration,
        curve: Curves.easeInOut,
      );
      if (widget.autoAdvance) {
        _startAutoAdvance();
      }
    } else if (widget.loop) {
      setState(() {
        _currentIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: widget.transitionDuration,
        curve: Curves.easeInOut,
      );
      if (widget.autoAdvance) {
        _startAutoAdvance();
      }
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.pages.length,
      itemBuilder: (context, index) {
        return SmoothPageTransition(
          transitionType: widget.transitionType,
          duration: widget.transitionDuration,
          child: widget.pages[index],
        );
      },
    );
  }

  /// Controle manual
  void nextPage() => _nextPage();
  void previousPage() {
    if (!mounted) return;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: widget.transitionDuration,
        curve: Curves.easeInOut,
      );
    }
  }
}

/// Utilitário para criar transições personalizadas de rota
class SmoothPageRoute<T> extends PageRoute<T> {
  SmoothPageRoute({
    required this.child,
    this.transitionType = SmoothTransitionType.fadeSlide,
    this.customTransitionDuration = const Duration(milliseconds: 600),
    this.customReverseTransitionDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.settings,
  });
  final Widget child;
  final SmoothTransitionType transitionType;
  final Duration customTransitionDuration;
  final Duration customReverseTransitionDuration;
  final Curve curve;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => customTransitionDuration;

  @override
  Duration get reverseTransitionDuration => customReverseTransitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SmoothPageTransition(
      transitionType: transitionType,
      duration: customTransitionDuration,
      curve: curve,
      child: this.child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }
}

/// Tipos de transição disponíveis
enum SmoothTransitionType {
  fade,
  scale,
  slideFromLeft,
  slideFromRight,
  slideFromTop,
  slideFromBottom,
  fadeSlide,
  fadeSlideFromLeft,
  fadeSlideFromRight,
  fadeSlideFromTop,
  slideScale,
  fadeSlideScale,
}

/// Direções de slide
enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }
