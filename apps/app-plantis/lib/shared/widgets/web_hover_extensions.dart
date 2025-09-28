import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Extension para adicionar hover states automaticamente aos widgets interativos
extension WebHoverExtension on Widget {
  /// Aplica hover effect com cursor pointer em widgets interativos
  Widget withHoverPointer({bool enabled = true}) {
    if (!enabled || !kIsWeb) return this;

    return MouseRegion(cursor: SystemMouseCursors.click, child: this);
  }

  /// Aplica hover effect com escala e elevação
  Widget withHoverScale({
    double scale = 1.05,
    Duration duration = const Duration(milliseconds: 150),
    bool enabled = true,
  }) {
    if (!enabled || !kIsWeb) return this;

    return _HoverScaleWidget(scale: scale, duration: duration, child: this);
  }

  /// Aplica hover effect com mudança de opacidade
  Widget withHoverOpacity({
    double opacity = 0.8,
    Duration duration = const Duration(milliseconds: 150),
    bool enabled = true,
  }) {
    if (!enabled || !kIsWeb) return this;

    return _HoverOpacityWidget(
      opacity: opacity,
      duration: duration,
      child: this,
    );
  }

  /// Aplica hover effect com mudança de cor
  Widget withHoverColor({
    Color? hoverColor,
    Duration duration = const Duration(milliseconds: 150),
    bool enabled = true,
  }) {
    if (!enabled || !kIsWeb) return this;

    return _HoverColorWidget(
      hoverColor: hoverColor,
      duration: duration,
      child: this,
    );
  }

  /// Combinação completa: cursor + escala + feedback visual
  Widget withWebHoverFeedback({
    double scale = 1.02,
    double opacity = 0.9,
    Duration duration = const Duration(milliseconds: 150),
    bool enabled = true,
  }) {
    if (!enabled || !kIsWeb) return this;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: _HoverFeedbackWidget(
        scale: scale,
        opacity: opacity,
        duration: duration,
        child: this,
      ),
    );
  }
}

/// Widget interno para hover scale
class _HoverScaleWidget extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;

  const _HoverScaleWidget({
    required this.child,
    required this.scale,
    required this.duration,
  });

  @override
  State<_HoverScaleWidget> createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<_HoverScaleWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

/// Widget interno para hover opacity
class _HoverOpacityWidget extends StatefulWidget {
  final Widget child;
  final double opacity;
  final Duration duration;

  const _HoverOpacityWidget({
    required this.child,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_HoverOpacityWidget> createState() => _HoverOpacityWidgetState();
}

class _HoverOpacityWidgetState extends State<_HoverOpacityWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? widget.opacity : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}

/// Widget interno para hover color
class _HoverColorWidget extends StatefulWidget {
  final Widget child;
  final Color? hoverColor;
  final Duration duration;

  const _HoverColorWidget({
    required this.child,
    required this.hoverColor,
    required this.duration,
  });

  @override
  State<_HoverColorWidget> createState() => _HoverColorWidgetState();
}

class _HoverColorWidgetState extends State<_HoverColorWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        color: _isHovered ? widget.hoverColor : null,
        child: widget.child,
      ),
    );
  }
}

/// Widget interno para feedback completo
class _HoverFeedbackWidget extends StatefulWidget {
  final Widget child;
  final double scale;
  final double opacity;
  final Duration duration;

  const _HoverFeedbackWidget({
    required this.child,
    required this.scale,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_HoverFeedbackWidget> createState() => _HoverFeedbackWidgetState();
}

class _HoverFeedbackWidgetState extends State<_HoverFeedbackWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        child: AnimatedOpacity(
          opacity: _isHovered ? widget.opacity : 1.0,
          duration: widget.duration,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Widget para botões com hover state otimizado
class WebOptimizedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? hoverColor;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final double hoverElevation;

  const WebOptimizedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.hoverColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.elevation = 2,
    this.hoverElevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _HoverButtonWidget(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      hoverColor:
          hoverColor ?? theme.colorScheme.primary.withValues(alpha: 0.8),
      padding: padding,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      elevation: elevation,
      hoverElevation: hoverElevation,
      child: child,
    );
  }
}

/// Widget interno para botão com hover
class _HoverButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color hoverColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double elevation;
  final double hoverElevation;

  const _HoverButtonWidget({
    required this.child,
    required this.onPressed,
    required this.backgroundColor,
    required this.hoverColor,
    required this.padding,
    required this.borderRadius,
    required this.elevation,
    required this.hoverElevation,
  });

  @override
  State<_HoverButtonWidget> createState() => _HoverButtonWidgetState();
}

class _HoverButtonWidgetState extends State<_HoverButtonWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.backgroundColor,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius:
                    _isHovered ? widget.hoverElevation : widget.elevation,
                offset: Offset(
                  0,
                  _isHovered ? widget.hoverElevation / 2 : widget.elevation / 2,
                ),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
