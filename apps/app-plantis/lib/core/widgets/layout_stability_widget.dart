import 'dart:async';

import 'package:flutter/material.dart';

/// Widget para gerenciar estabilidade de layout durante redimensionamento
/// e operações que podem causar race conditions como "RenderBox was not laid out"
class LayoutStabilityWidget extends StatefulWidget {
  const LayoutStabilityWidget({
    super.key,
    required this.child,
    this.onLayoutStable,
    this.onLayoutChanged,
    this.stabilityDelay = const Duration(milliseconds: 100),
    this.enableRepaintBoundary = true,
    this.enableResizeThrottling = true,
    this.debugLabel,
  });

  final Widget child;
  final VoidCallback? onLayoutStable;
  final VoidCallback? onLayoutChanged;
  final Duration stabilityDelay;
  final bool enableRepaintBoundary;
  final bool enableResizeThrottling;
  final String? debugLabel;

  @override
  State<LayoutStabilityWidget> createState() => _LayoutStabilityWidgetState();
}

class _LayoutStabilityWidgetState extends State<LayoutStabilityWidget>
    with WidgetsBindingObserver {
  Timer? _stabilityTimer;
  Size? _lastSize;
  bool _isLayoutStable = false;
  bool _isResizing = false;

  // Throttling for resize events
  Timer? _resizeThrottleTimer;
  static const Duration _resizeThrottleDuration = Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial stability check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLayoutStability();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stabilityTimer?.cancel();
    _resizeThrottleTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _handleResize();
  }

  void _handleResize() {
    if (!widget.enableResizeThrottling) {
      _onResizeEvent();
      return;
    }

    // Throttle resize events to prevent excessive rebuilds
    _resizeThrottleTimer?.cancel();
    _resizeThrottleTimer = Timer(_resizeThrottleDuration, () {
      if (mounted) {
        _onResizeEvent();
      }
    });
  }

  void _onResizeEvent() {
    setState(() {
      _isResizing = true;
      _isLayoutStable = false;
    });

    widget.onLayoutChanged?.call();

    // Reset stability after resize
    _stabilityTimer?.cancel();
    _stabilityTimer = Timer(widget.stabilityDelay, () {
      if (mounted) {
        setState(() {
          _isResizing = false;
        });
        _checkLayoutStability();
      }
    });
  }

  void _checkLayoutStability() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) return;

      final currentSize = renderObject.hasSize ? renderObject.size : Size.zero;

      // Check if size has stabilized
      if (_lastSize != null &&
          _lastSize == currentSize &&
          renderObject.attached &&
          !renderObject.debugNeedsLayout) {
        if (!_isLayoutStable) {
          setState(() {
            _isLayoutStable = true;
          });
          widget.onLayoutStable?.call();

          if (widget.debugLabel != null) {
            debugPrint('Layout stable for ${widget.debugLabel}: $currentSize');
          }
        }
      } else {
        if (_isLayoutStable) {
          setState(() {
            _isLayoutStable = false;
          });
        }

        _lastSize = currentSize;

        // Recheck after next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkLayoutStability();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Add layout detection
    child = LayoutBuilder(
      builder: (context, constraints) {
        // Trigger layout change detection when constraints change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkLayoutStability();
          }
        });

        return child;
      },
    );

    // Add RepaintBoundary for isolation during resize
    if (widget.enableRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }

    // Add resize indicator for debugging
    if (widget.debugLabel != null && _isResizing) {
      child = Stack(
        children: [
          child,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Resizing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}

/// Enhanced RepaintBoundary widget com isolamento para operações críticas
class IsolatedRepaintBoundary extends StatelessWidget {
  const IsolatedRepaintBoundary({
    super.key,
    required this.child,
    this.isActive = true,
    this.debugLabel,
  });

  final Widget child;
  final bool isActive;
  final String? debugLabel;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return child;
    }

    return RepaintBoundary(child: child);
  }
}

/// Mixin para componentes que precisam de estabilidade de layout
mixin LayoutStabilityMixin<T extends StatefulWidget> on State<T> {
  bool _layoutStable = false;
  Size? _lastKnownSize;
  Timer? _stabilityCheckTimer;

  bool get isLayoutStable => _layoutStable;
  Size? get lastKnownSize => _lastKnownSize;

  /// Verifica se o layout está estável antes de executar operação crítica
  Future<bool> waitForLayoutStability({
    Duration timeout = const Duration(milliseconds: 500),
    int maxChecks = 5,
  }) async {
    if (_layoutStable) return true;

    int checks = 0;
    final completer = Completer<bool>();

    void checkStability() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          if (!completer.isCompleted) completer.complete(false);
          return;
        }

        final renderObject = context.findRenderObject() as RenderBox?;
        if (renderObject == null) {
          if (checks < maxChecks) {
            checks++;
            Timer(const Duration(milliseconds: 16), checkStability);
          } else {
            if (!completer.isCompleted) completer.complete(false);
          }
          return;
        }

        if (renderObject.hasSize &&
            renderObject.attached &&
            !renderObject.debugNeedsLayout) {
          final currentSize = renderObject.size;
          if (_lastKnownSize == null || _lastKnownSize == currentSize) {
            _layoutStable = true;
            _lastKnownSize = currentSize;
            if (!completer.isCompleted) completer.complete(true);
            return;
          }

          _lastKnownSize = currentSize;
        }

        if (checks < maxChecks) {
          checks++;
          Timer(const Duration(milliseconds: 16), checkStability);
        } else {
          // Fallback: assume stable after max checks
          _layoutStable = true;
          if (!completer.isCompleted) completer.complete(true);
        }
      });
    }

    checkStability();

    // Timeout fallback
    Timer(timeout, () {
      if (!completer.isCompleted) {
        _layoutStable = true; // Assume stable on timeout
        completer.complete(true);
      }
    });

    return completer.future;
  }

  /// Marca layout como instável (chamado durante resize)
  void markLayoutUnstable() {
    _layoutStable = false;
    _stabilityCheckTimer?.cancel();

    _stabilityCheckTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        waitForLayoutStability();
      }
    });
  }

  @override
  void dispose() {
    _stabilityCheckTimer?.cancel();
    super.dispose();
  }
}

/// Widget que detecta mudanças de tamanho e notifica sobre instabilidade
class SizeChangeNotifier extends StatefulWidget {
  const SizeChangeNotifier({
    super.key,
    required this.child,
    required this.onSizeChange,
    this.onStabilityChange,
    this.debounceDelay = const Duration(milliseconds: 100),
  });

  final Widget child;
  final void Function(Size size) onSizeChange;
  final void Function(bool isStable)? onStabilityChange;
  final Duration debounceDelay;

  @override
  State<SizeChangeNotifier> createState() => _SizeChangeNotifierState();
}

class _SizeChangeNotifierState extends State<SizeChangeNotifier> {
  Size? _lastSize;
  Timer? _debounceTimer;

  void _handleSizeChange(Size newSize) {
    if (_lastSize == newSize) return;

    _lastSize = newSize;

    widget.onSizeChange(newSize);
    widget.onStabilityChange?.call(false);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      if (mounted) {
        widget.onStabilityChange?.call(true);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderObject = context.findRenderObject() as RenderBox?;
          if (renderObject != null && renderObject.hasSize) {
            _handleSizeChange(renderObject.size);
          }
        });

        return widget.child;
      },
    );
  }
}
