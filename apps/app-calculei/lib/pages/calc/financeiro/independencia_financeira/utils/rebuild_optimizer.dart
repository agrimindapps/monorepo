// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilitário para otimizar rebuilds na interface
class RebuildOptimizer {
  /// Cria um ValueListenableBuilder otimizado que só rebuilda quando necessário
  static Widget buildOptimizedListener<T>({
    required ValueNotifier<T> listenable,
    required Widget Function(BuildContext context, T value, Widget? child) builder,
    Widget? child,
    bool Function(T previous, T current)? shouldRebuild,
  }) {
    return ValueListenableBuilder<T>(
      valueListenable: listenable,
      builder: (context, value, child) {
        return builder(context, value, child);
      },
      child: child,
    );
  }

  /// Cria um ListenableBuilder otimizado com controle granular
  static Widget buildGranularListener({
    required Listenable listenable,
    required Widget Function(BuildContext context, Widget? child) builder,
    Widget? child,
    bool Function()? shouldRebuild,
  }) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, child) {
        if (shouldRebuild != null && !shouldRebuild()) {
          return child ?? const SizedBox.shrink();
        }
        return builder(context, child);
      },
      child: child,
    );
  }
}

/// Mixin para otimizar rebuilds em StatefulWidgets
mixin RebuildOptimizationMixin<T extends StatefulWidget> on State<T> {
  bool _shouldRebuild = true;
  
  /// Controla se o widget deve ser reconstruído
  void setShouldRebuild(bool should) {
    if (_shouldRebuild != should) {
      _shouldRebuild = should;
      if (should && mounted) {
        setState(() {});
      }
    }
  }
  
  /// Verifica se deve reconstruir
  bool get shouldRebuild => _shouldRebuild;
  
  /// Override do setState para controlar rebuilds
  @override
  void setState(VoidCallback fn) {
    if (_shouldRebuild && mounted) {
      super.setState(fn);
    }
  }
}

/// Widget otimizado que evita rebuilds desnecessários
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Listenable> listenables;
  final bool Function()? shouldRebuild;

  const OptimizedBuilder({
    super.key,
    required this.builder,
    required this.listenables,
    this.shouldRebuild,
  });

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> 
    with RebuildOptimizationMixin {
  
  @override
  void initState() {
    super.initState();
    _attachListeners();
  }

  @override
  void dispose() {
    _detachListeners();
    super.dispose();
  }

  void _attachListeners() {
    for (final listenable in widget.listenables) {
      listenable.addListener(_onListenableChanged);
    }
  }

  void _detachListeners() {
    for (final listenable in widget.listenables) {
      listenable.removeListener(_onListenableChanged);
    }
  }

  void _onListenableChanged() {
    if (widget.shouldRebuild?.call() ?? true) {
      setShouldRebuild(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// Widget que usa RepaintBoundary para isolar rebuilds
class IsolatedWidget extends StatelessWidget {
  final Widget child;
  final bool shouldIsolate;

  const IsolatedWidget({
    super.key,
    required this.child,
    this.shouldIsolate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldIsolate) {
      return RepaintBoundary(
        child: child,
      );
    }
    return child;
  }
}

/// Widget que cacheia seu conteúdo para evitar rebuilds
class CachedWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Object?> dependencies;

  const CachedWidget({
    super.key,
    required this.builder,
    required this.dependencies,
  });

  @override
  State<CachedWidget> createState() => _CachedWidgetState();
}

class _CachedWidgetState extends State<CachedWidget> {
  Widget? _cachedWidget;
  List<Object?> _lastDependencies = [];

  @override
  Widget build(BuildContext context) {
    // Verifica se as dependências mudaram
    if (_cachedWidget == null || 
        !_dependenciesEqual(_lastDependencies, widget.dependencies)) {
      _cachedWidget = widget.builder(context);
      _lastDependencies = List.from(widget.dependencies);
    }
    
    return _cachedWidget!;
  }

  bool _dependenciesEqual(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    
    return true;
  }
}

/// Wrapper para TextField que otimiza rebuilds
class OptimizedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool enabled;

  const OptimizedTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.enabled = true,
  });

  @override
  State<OptimizedTextField> createState() => _OptimizedTextFieldState();
}

class _OptimizedTextFieldState extends State<OptimizedTextField> 
    with RebuildOptimizationMixin {
  
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Só rebuilda se necessário (pode ser customizado)
    setShouldRebuild(true);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: widget.suffixIcon,
          border: const OutlineInputBorder(),
        ),
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
      ),
    );
  }
}

/// Manager para controlar rebuilds globalmente
class RebuildManager {
  static final RebuildManager _instance = RebuildManager._internal();
  factory RebuildManager() => _instance;
  RebuildManager._internal();

  final Map<String, bool> _rebuildFlags = {};
  final Map<String, List<VoidCallback>> _listeners = {};

  /// Define se uma área deve ser reconstruída
  void setRebuildFlag(String area, bool should) {
    if (_rebuildFlags[area] != should) {
      _rebuildFlags[area] = should;
      _notifyListeners(area);
    }
  }

  /// Verifica se uma área deve ser reconstruída
  bool shouldRebuild(String area) {
    return _rebuildFlags[area] ?? true;
  }

  /// Adiciona listener para uma área
  void addListener(String area, VoidCallback callback) {
    _listeners[area] ??= [];
    _listeners[area]!.add(callback);
  }

  /// Remove listener de uma área
  void removeListener(String area, VoidCallback callback) {
    _listeners[area]?.remove(callback);
  }

  /// Notifica listeners de uma área
  void _notifyListeners(String area) {
    final callbacks = _listeners[area];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback();
      }
    }
  }

  /// Limpa todas as flags
  void clearAll() {
    _rebuildFlags.clear();
    _listeners.clear();
  }
}
