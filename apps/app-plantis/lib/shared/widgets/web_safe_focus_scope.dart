import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wrapper seguro para focus management no Flutter Web
/// Resolve problemas de focus traversal quando o usuário sai e volta ao navegador
class WebSafeFocusScope extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final bool skipTraversal;
  final bool canRequestFocus;
  final VoidCallback? onFocusChange;

  const WebSafeFocusScope({
    super.key,
    required this.child,
    this.focusNode,
    this.skipTraversal = false,
    this.canRequestFocus = true,
    this.onFocusChange,
  });

  @override
  State<WebSafeFocusScope> createState() => _WebSafeFocusScopeState();
}

class _WebSafeFocusScopeState extends State<WebSafeFocusScope> {
  late FocusNode _focusNode;
  bool _isWebEnvironment = false;

  @override
  void initState() {
    super.initState();
    _isWebEnvironment = kIsWeb;
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (_isWebEnvironment && mounted) {
      _setupWebFocusHandling();
    }
  }

  void _setupWebFocusHandling() {
    // Add listener with web-specific handling
    _focusNode.addListener(_handleFocusChange);
    
    // Web-specific: Handle browser focus events
    if (kIsWeb) {
      _setupBrowserFocusListeners();
    }
  }

  void _setupBrowserFocusListeners() {
    // This helps handle when user switches tabs/windows and comes back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleWebFocusRecovery();
      }
    });
  }

  void _handleFocusChange() {
    if (!mounted) return;
    
    // Safe focus change handling with web-specific considerations
    try {
      if (_isWebEnvironment) {
        // Web: Add delay to prevent race conditions
        Future.delayed(const Duration(milliseconds: 10), () {
          if (mounted && widget.onFocusChange != null) {
            widget.onFocusChange!();
          }
        });
      } else {
        // Mobile: Direct callback
        widget.onFocusChange?.call();
      }
    } catch (e) {
      // Silently handle focus errors in web environment
      debugPrint('WebSafeFocusScope: Focus change error handled: $e');
    }
  }

  void _handleWebFocusRecovery() {
    if (!mounted || !_isWebEnvironment) return;
    
    // Web-specific: Recover from focus traversal issues
    try {
      if (_focusNode.hasFocus && !_focusNode.canRequestFocus) {
        // Reset focus node state if it's in an invalid state
        _focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
        });
      }
    } catch (e) {
      // Silently handle recovery errors
      debugPrint('WebSafeFocusScope: Focus recovery error handled: $e');
    }
  }

  @override
  void dispose() {
    // Safe disposal with web considerations
    try {
      _focusNode.removeListener(_handleFocusChange);
      if (widget.focusNode == null) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
        _focusNode.dispose();
      }
    } catch (e) {
      // Silently handle disposal errors
      debugPrint('WebSafeFocusScope: Disposal error handled: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWebEnvironment) {
      // Mobile: Use standard Focus
      return Focus(
        focusNode: _focusNode,
        skipTraversal: widget.skipTraversal,
        canRequestFocus: widget.canRequestFocus,
        child: widget.child,
      );
    }

    // Web: Enhanced focus scope with error handling
    return Focus(
      focusNode: _focusNode,
      skipTraversal: widget.skipTraversal,
      canRequestFocus: widget.canRequestFocus,
      onFocusChange: (hasFocus) => _handleFocusChange(),
      child: WebFocusTraversalWrapper(
        child: widget.child,
      ),
    );
  }
}

/// Wrapper interno para handling de focus traversal no web
class WebFocusTraversalWrapper extends StatefulWidget {
  final Widget child;

  const WebFocusTraversalWrapper({
    super.key,
    required this.child,
  });

  @override
  State<WebFocusTraversalWrapper> createState() => _WebFocusTraversalWrapperState();
}

class _WebFocusTraversalWrapperState extends State<WebFocusTraversalWrapper> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    // Web: Wrap with custom focus traversal policy
    return FocusTraversalGroup(
      policy: WebSafeFocusTraversalPolicy(),
      child: widget.child,
    );
  }
}

/// Política de focus traversal segura para web
class WebSafeFocusTraversalPolicy extends WidgetOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    try {
      return super.inDirection(currentNode, direction);
    } catch (e) {
      // Web: Handle focus traversal errors gracefully
      debugPrint('WebSafeFocusTraversalPolicy: Traversal error handled: $e');
      return false;
    }
  }

  @override
  FocusNode? findFirstFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    try {
      return super.findFirstFocus(currentNode, ignoreCurrentFocus: ignoreCurrentFocus);
    } catch (e) {
      debugPrint('WebSafeFocusTraversalPolicy: findFirstFocus error handled: $e');
      return null;
    }
  }

  @override
  FocusNode findLastFocus(FocusNode currentNode, {bool ignoreCurrentFocus = false}) {
    try {
      return super.findLastFocus(currentNode, ignoreCurrentFocus: ignoreCurrentFocus);
    } catch (e) {
      debugPrint('WebSafeFocusTraversalPolicy: findLastFocus error handled: $e');
      return currentNode; // Fallback to current node
    }
  }

  @override
  Iterable<FocusNode> sortDescendants(Iterable<FocusNode> descendants, FocusNode currentNode) {
    try {
      return super.sortDescendants(descendants, currentNode);
    } catch (e) {
      debugPrint('WebSafeFocusTraversalPolicy: sortDescendants error handled: $e');
      return descendants;
    }
  }
}

/// Extension para facilitar o uso do WebSafeFocusScope
extension WebSafeFocusExtension on Widget {
  /// Envolve o widget em um WebSafeFocusScope para handling seguro de focus
  Widget withWebSafeFocus({
    FocusNode? focusNode,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    VoidCallback? onFocusChange,
  }) {
    return WebSafeFocusScope(
      focusNode: focusNode,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      child: this,
    );
  }
}

/// Mixin para páginas que precisam de focus management seguro no web
mixin WebSafeFocusMixin<T extends StatefulWidget> on State<T> {
  final Map<String, FocusNode> _webSafeFocusNodes = {};

  /// Obtém um FocusNode seguro para web
  FocusNode getWebSafeFocusNode(String key) {
    return _webSafeFocusNodes.putIfAbsent(key, () {
      return FocusNode(
        debugLabel: 'WebSafe_$key',
        canRequestFocus: true,
        descendantsAreFocusable: true,
        descendantsAreTraversable: true,
      );
    });
  }

  /// Request focus de forma segura para web
  void requestWebSafeFocus(String key) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final node = _webSafeFocusNodes[key];
        if (node != null && mounted) {
          try {
            if (kIsWeb) {
              // Web: Add small delay to prevent race conditions
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted && node.canRequestFocus) {
                  node.requestFocus();
                }
              });
            } else {
              // Mobile: Direct focus
              if (node.canRequestFocus) {
                node.requestFocus();
              }
            }
          } catch (e) {
            debugPrint('WebSafeFocusMixin: Focus request error handled: $e');
          }
        }
      }
    });
  }

  /// Unfocus de forma segura
  void unfocusWebSafe(String key) {
    if (!mounted) return;

    final node = _webSafeFocusNodes[key];
    if (node != null && mounted) {
      try {
        if (node.hasFocus) {
          node.unfocus();
        }
      } catch (e) {
        debugPrint('WebSafeFocusMixin: Unfocus error handled: $e');
      }
    }
  }

  @override
  void dispose() {
    // Safe disposal of all focus nodes
    for (final node in _webSafeFocusNodes.values) {
      try {
        if (node.hasFocus) {
          node.unfocus();
        }
        node.dispose();
      } catch (e) {
        debugPrint('WebSafeFocusMixin: Disposal error handled: $e');
      }
    }
    _webSafeFocusNodes.clear();
    super.dispose();
  }
}