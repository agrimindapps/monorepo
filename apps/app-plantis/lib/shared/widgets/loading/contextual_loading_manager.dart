import 'package:flutter/material.dart';

/// Sistema centralizado para gerenciar estados de loading contextuais
/// Este widget resolve os problemas de loading inconsistentes identificados na análise UX
class ContextualLoadingManager {
  static final Map<String, LoadingState> _activeLoadings = {};
  static final List<VoidCallback> _listeners = [];

  /// Registra um loading contextual
  static void startLoading(
    String context, {
    required String message,
    String? semanticLabel,
    LoadingType type = LoadingType.standard,
    Duration? timeout,
  }) {
    _activeLoadings[context] = LoadingState(
      message: message,
      semanticLabel: semanticLabel,
      type: type,
      startTime: DateTime.now(),
    );
    if (timeout != null) {
      Future.delayed(timeout, () => stopLoading(context));
    }

    _notifyListeners();
  }

  /// Para um loading específico
  static void stopLoading(String context) {
    _activeLoadings.remove(context);
    _notifyListeners();
  }

  /// Para todos os loadings
  static void stopAllLoadings() {
    _activeLoadings.clear();
    _notifyListeners();
  }

  /// Verifica se existe loading ativo
  static bool hasActiveLoading([String? context]) {
    if (context != null) {
      return _activeLoadings.containsKey(context);
    }
    return _activeLoadings.isNotEmpty;
  }

  /// Obtém estado de loading específico
  static LoadingState? getLoadingState(String context) {
    return _activeLoadings[context];
  }

  /// Obtém todos os loadings ativos
  static Map<String, LoadingState> get activeLoadings =>
      Map.unmodifiable(_activeLoadings);

  /// Adiciona listener para mudanças
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Limpa todos os recursos
  static void dispose() {
    _activeLoadings.clear();
    _listeners.clear();
  }
}

/// Widget que escuta mudanças no gerenciador de loading
class ContextualLoadingListener extends StatefulWidget {
  final Widget child;
  final String? context;
  final Widget Function(BuildContext, LoadingState?)? loadingBuilder;

  const ContextualLoadingListener({
    super.key,
    required this.child,
    this.context,
    this.loadingBuilder,
  });

  @override
  State<ContextualLoadingListener> createState() =>
      _ContextualLoadingListenerState();
}

class _ContextualLoadingListenerState extends State<ContextualLoadingListener> {
  @override
  void initState() {
    super.initState();
    ContextualLoadingManager.addListener(_onLoadingChanged);
  }

  @override
  void dispose() {
    ContextualLoadingManager.removeListener(_onLoadingChanged);
    super.dispose();
  }

  void _onLoadingChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = widget.context != null
        ? ContextualLoadingManager.getLoadingState(widget.context!)
        : null;

    if (widget.loadingBuilder != null && loadingState != null) {
      return widget.loadingBuilder!(context, loadingState);
    }

    return Stack(
      children: [
        widget.child,
        if (loadingState != null) _buildDefaultLoadingOverlay(loadingState),
      ],
    );
  }

  Widget _buildDefaultLoadingOverlay(LoadingState state) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoadingIndicator(state.type),
                const SizedBox(height: 16),
                Semantics(
                  label: state.semanticLabel ?? state.message,
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(LoadingType type) {
    switch (type) {
      case LoadingType.standard:
        return const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        );
      case LoadingType.purchase:
        return Icon(
          Icons.credit_card,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        );
      case LoadingType.save:
        return Icon(
          Icons.save,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        );
      case LoadingType.sync:
        return Icon(
          Icons.sync,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        );
      case LoadingType.auth:
        return Icon(
          Icons.person,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        );
    }
  }
}

/// Estado de loading com contexto
class LoadingState {
  final String message;
  final String? semanticLabel;
  final LoadingType type;
  final DateTime startTime;

  const LoadingState({
    required this.message,
    this.semanticLabel,
    required this.type,
    required this.startTime,
  });

  /// Duração desde o início
  Duration get duration => DateTime.now().difference(startTime);

  /// Se passou do timeout recomendado (10 segundos)
  bool get isTimeout => duration.inSeconds > 10;
}

/// Tipos de loading contextuais
enum LoadingType { standard, purchase, save, sync, auth }

/// Contextos pré-definidos para consistência
class LoadingContexts {
  static const String premium = 'premium';
  static const String auth = 'auth';
  static const String plantSave = 'plant_save';
  static const String taskComplete = 'task_complete';
  static const String sync = 'sync';
  static const String settings = 'settings';
  static const String profile = 'profile';
}

/// Mixin para simplificar uso em páginas
mixin ContextualLoadingMixin {
  void startContextualLoading(
    String context, {
    required String message,
    String? semanticLabel,
    LoadingType type = LoadingType.standard,
    Duration? timeout = const Duration(seconds: 30),
  }) {
    ContextualLoadingManager.startLoading(
      context,
      message: message,
      semanticLabel: semanticLabel,
      type: type,
      timeout: timeout,
    );
  }

  void stopContextualLoading(String context) {
    ContextualLoadingManager.stopLoading(context);
  }

  bool hasContextualLoading(String context) {
    return ContextualLoadingManager.hasActiveLoading(context);
  }
}
