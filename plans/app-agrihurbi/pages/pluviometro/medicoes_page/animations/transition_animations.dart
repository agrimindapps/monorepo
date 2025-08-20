// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/medicoes_theme.dart';

/// Service responsável por animações de transição padronizadas - Issue #22
class TransitionAnimations {
  /// Animação de fade in/out
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration duration = MedicoesTheme.animationNormal,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Animação de slide horizontal
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }

  /// Animação de scale (crescimento/encolhimento)
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }

  /// Animação combinada: fade + slide
  static Widget fadeSlideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset slideBegin = const Offset(0.3, 0.0),
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: slideBegin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Animação de loading com rotação
  static Widget loadingRotation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return RotationTransition(
      turns: animation,
      child: child,
    );
  }

  /// Page transition customizada para mudanças de mês
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    Duration duration = MedicoesTheme.animationNormal,
    RouteTransitionsBuilder? transitionsBuilder,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: transitionsBuilder ??
          (context, animation, secondaryAnimation, child) {
            return fadeSlideTransition(
              animation: animation,
              child: child,
            );
          },
    );
  }

  /// Widget com animação de entrada automática
  static Widget animatedEntry({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = MedicoesTheme.animationNormal,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animação de mudança de dados (para quando valores mudam)
  static Widget dataChangeTransition({
    required Widget child,
    required String dataKey,
    Duration duration = MedicoesTheme.animationFast,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(dataKey),
        child: child,
      ),
    );
  }

  /// Micro-interação para cards (hover/tap)
  static Widget cardMicroInteraction({
    required Widget child,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return AnimatedContainer(
      duration: MedicoesTheme.animationFast,
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.02 : 1.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MedicoesTheme.radiusMedium,
          child: AnimatedContainer(
            duration: MedicoesTheme.animationFast,
            decoration: BoxDecoration(
              borderRadius: MedicoesTheme.radiusMedium,
              boxShadow: isSelected
                  ? MedicoesTheme.shadowMedium
                  : MedicoesTheme.shadowSmall,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Animação de pulsação para loading states
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    double minOpacity = 0.3,
    double maxOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minOpacity, end: maxOpacity),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      onEnd: () {
        // A animação irá se repetir automaticamente
      },
      child: child,
    );
  }

  /// Animação de lista (entrada sequencial de itens)
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 50),
    Duration duration = MedicoesTheme.animationNormal,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Mixin para widgets que precisam de animações
mixin AnimatedWidgetMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: MedicoesTheme.animationNormal,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Inicia animação
  void startAnimation() {
    _animationController.forward();
  }

  /// Reverte animação
  void reverseAnimation() {
    _animationController.reverse();
  }

  /// Reinicia animação
  void resetAnimation() {
    _animationController.reset();
  }

  /// Acesso ao controller de animação
  AnimationController get animationController => _animationController;

  /// Acesso à animação
  Animation<double> get animation => _animation;
}

/// Curves customizadas para o tema
class MedicoesAnimationCurves {
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve smoothTransition = Curves.easeInOutCubic;
  static const Curve quickFade = Curves.easeOut;
  static const Curve slowFade = Curves.easeInOut;
  static const Curve dataChange = Curves.easeInOut;
}
