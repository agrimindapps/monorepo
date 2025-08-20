/// Sistema de animações padronizadas para o módulo AgriHurbi
/// 
/// Este arquivo centraliza todas as animações customizadas para garantir
/// consistência visual e melhorar a percepção de qualidade da interface.
/// 
/// Funcionalidades:
/// - Constantes de duração padronizadas
/// - Widgets animados reutilizáveis
/// - Transições suaves para navegação
/// - Efeitos visuais para feedback

library agrihurbi_animations;

import 'package:flutter/material.dart';

/// Constantes de duração para animações consistentes
class AnimationDurations {
  /// Animações rápidas - para micro-interações
  static const fast = Duration(milliseconds: 200);
  
  /// Animações normais - padrão para a maioria dos casos
  static const normal = Duration(milliseconds: 300);
  
  /// Animações lentas - para transições importantes
  static const slow = Duration(milliseconds: 500);
  
  /// Animações muito lentas - para efeitos especiais
  static const verySlow = Duration(milliseconds: 800);
}

/// Curvas de animação padronizadas
class AnimationCurves {
  /// Curva suave padrão
  static const smooth = Curves.easeInOut;
  
  /// Curva elástica para feedback
  static const elastic = Curves.elasticOut;
  
  /// Curva rápida para entrada
  static const fastIn = Curves.fastOutSlowIn;
  
  /// Curva de bounce para elementos especiais
  static const bounce = Curves.bounceOut;
}

/// Widget para animações de fade com transições suaves
class AnimatedFadeIn extends StatefulWidget {
  /// Conteúdo a ser animado
  final Widget child;
  
  /// Duração da animação
  final Duration duration;
  
  /// Delay antes de iniciar a animação
  final Duration delay;
  
  /// Curva da animação
  final Curve curve;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.curve = AnimationCurves.smooth,
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Inicia animação após delay
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Widget para animações de escala em cards e botões
class AnimatedScaleIn extends StatefulWidget {
  /// Conteúdo a ser animado
  final Widget child;
  
  /// Duração da animação
  final Duration duration;
  
  /// Delay antes de iniciar a animação
  final Duration delay;

  const AnimatedScaleIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedScaleIn> createState() => _AnimatedScaleInState();
}

class _AnimatedScaleInState extends State<AnimatedScaleIn>
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.bounce,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Widget para lista com animações escalonadas
class AnimatedListBuilder extends StatelessWidget {
  /// Lista de widgets
  final List<Widget> children;
  
  /// Duração base para cada item
  final Duration itemDuration;
  
  /// Delay entre cada item
  final Duration staggerDelay;

  const AnimatedListBuilder({
    super.key,
    required this.children,
    this.itemDuration = AnimationDurations.normal,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return AnimatedFadeIn(
          duration: itemDuration,
          delay: staggerDelay * index,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Widget para ícones com animação de rotação
class AnimatedRotatingIcon extends StatefulWidget {
  /// Ícone a ser animado
  final IconData icon;
  
  /// Tamanho do ícone
  final double size;
  
  /// Cor do ícone
  final Color? color;
  
  /// Se deve continuar rotacionando
  final bool isRotating;
  
  /// Duração de uma rotação completa
  final Duration duration;

  const AnimatedRotatingIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
    this.isRotating = false,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedRotatingIcon> createState() => _AnimatedRotatingIconState();
}

class _AnimatedRotatingIconState extends State<AnimatedRotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    if (widget.isRotating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedRotatingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRotating && !oldWidget.isRotating) {
      _controller.repeat();
    } else if (!widget.isRotating && oldWidget.isRotating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Widget para container animado com expansão
class AnimatedExpandableContainer extends StatefulWidget {
  /// Conteúdo quando expandido
  final Widget child;
  
  /// Se está expandido
  final bool isExpanded;
  
  /// Duração da animação
  final Duration duration;

  const AnimatedExpandableContainer({
    super.key,
    required this.child,
    required this.isExpanded,
    this.duration = AnimationDurations.normal,
  });

  @override
  State<AnimatedExpandableContainer> createState() =>
      _AnimatedExpandableContainerState();
}

class _AnimatedExpandableContainerState
    extends State<AnimatedExpandableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.smooth,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedExpandableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Transições customizadas para navegação
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;
  
  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.fromRight,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.fromLeft:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.fromRight:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.fromTop:
          begin = const Offset(0.0, -1.0);
          break;
        case SlideDirection.fromBottom:
          begin = const Offset(0.0, 1.0);
          break;
      }
      
      const end = Offset.zero;
      
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(
        tween.chain(CurveTween(curve: AnimationCurves.smooth))
      );
      
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: AnimationDurations.normal,
  );
}

enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Classe utilitária para criar Hero animations consistentes
class HeroHelper {
  /// Cria uma tag única para Hero animations
  static String createTag(String prefix, dynamic id) {
    return '${prefix}_$id';
  }
  
  /// Widget Hero com configurações padronizadas
  static Widget create({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final hero = Hero(
      tag: tag,
      child: child,
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: hero,
      );
    }
    
    return hero;
  }
}

/// Extension para adicionar animações facilmente aos widgets
extension AnimatedWidgetExtensions on Widget {
  /// Adiciona animação de fade in
  Widget fadeIn({
    Duration duration = AnimationDurations.normal,
    Duration delay = Duration.zero,
  }) {
    return AnimatedFadeIn(
      duration: duration,
      delay: delay,
      child: this,
    );
  }
  
  /// Adiciona animação de scale in
  Widget scaleIn({
    Duration duration = AnimationDurations.normal,
    Duration delay = Duration.zero,
  }) {
    return AnimatedScaleIn(
      duration: duration,
      delay: delay,
      child: this,
    );
  }
  
  /// Adiciona Hero animation
  Widget hero(String tag, {VoidCallback? onTap}) {
    return HeroHelper.create(
      tag: tag,
      child: this,
      onTap: onTap,
    );
  }
}