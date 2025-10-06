import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

/// Sistema centralizado de feedback visual para operações async
/// Trabalha em conjunto com ContextualLoadingManager para feedback completo
class FeedbackSystem {
  static final Map<String, FeedbackController> _activeControllers = {};
  static final List<VoidCallback> _listeners = [];

  /// Mostra feedback de sucesso com animação
  static void showSuccess({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 3),
    SuccessAnimationType animation = SuccessAnimationType.checkmark,
    bool includeHaptic = true,
    VoidCallback? onComplete,
  }) {
    if (includeHaptic) {
      HapticFeedback.mediumImpact();
    }

    final controller = FeedbackController(
      type: FeedbackType.success,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      duration: duration,
      animation: animation,
      onComplete: onComplete,
    );

    _showFeedback(context, controller);
  }

  /// Mostra feedback de erro com opções de recovery
  static void showError({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData icon = Icons.error,
    Duration duration = const Duration(seconds: 5),
    ErrorAnimationType animation = ErrorAnimationType.shake,
    bool includeHaptic = true,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onComplete,
  }) {
    if (includeHaptic) {
      HapticFeedback.heavyImpact();
    }

    final controller = FeedbackController(
      type: FeedbackType.error,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      duration: duration,
      animation: animation,
      actionLabel: actionLabel,
      onAction: onAction,
      onComplete: onComplete,
    );

    _showFeedback(context, controller);
  }

  /// Mostra feedback de progresso com barra ou porcentagem
  static FeedbackController showProgress({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData? icon,
    ProgressType progressType = ProgressType.determinate,
    double progress = 0.0,
    bool includeHaptic = false,
  }) {
    if (includeHaptic) {
      HapticFeedback.lightImpact();
    }

    final controller = FeedbackController(
      type: FeedbackType.progress,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      progressType: progressType,
      progress: progress,
    );

    _showFeedback(context, controller);
    return controller;
  }

  /// Atualiza progresso de um feedback ativo
  static void updateProgress(
    String key, {
    required double progress,
    String? message,
  }) {
    final controller = _activeControllers[key];
    if (controller != null) {
      controller.updateProgress(progress, message: message);
    }
  }

  /// Completa progresso com sucesso
  static void completeProgress(
    String key, {
    String? successMessage,
    bool includeHaptic = true,
  }) {
    final controller = _activeControllers[key];
    if (controller != null) {
      if (includeHaptic) {
        HapticFeedback.mediumImpact();
      }
      controller.completeWithSuccess(successMessage);
    }
  }

  /// Falha progresso com erro
  static void failProgress(
    String key, {
    String? errorMessage,
    bool includeHaptic = true,
  }) {
    final controller = _activeControllers[key];
    if (controller != null) {
      if (includeHaptic) {
        HapticFeedback.heavyImpact();
      }
      controller.completeWithError(errorMessage);
    }
  }

  /// Remove feedback específico
  static void dismiss(String key) {
    final controller = _activeControllers[key];
    if (controller != null) {
      controller.dismiss();
      _activeControllers.remove(key);
      _notifyListeners();
    }
  }

  /// Remove todos os feedbacks
  static void dismissAll() {
    for (final controller in _activeControllers.values) {
      controller.dismiss();
    }
    _activeControllers.clear();
    _notifyListeners();
  }

  static void _showFeedback(
    BuildContext context,
    FeedbackController controller,
  ) {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    _activeControllers[key] = controller;
    if (controller.duration != null) {
      Future.delayed(controller.duration!, () {
        dismiss(key);
      });
    }

    _notifyListeners();
    if (controller.semanticLabel != null || controller.message.isNotEmpty) {
      SemanticsService.announce(
        controller.semanticLabel ?? controller.message,
        TextDirection.ltr,
      );
    }
  }

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

  /// Obtém feedbacks ativos
  static Map<String, FeedbackController> get activeFeedbacks =>
      Map.unmodifiable(_activeControllers);

  /// Limpa recursos
  static void dispose() {
    for (final controller in _activeControllers.values) {
      controller.dispose();
    }
    _activeControllers.clear();
    _listeners.clear();
  }
}

/// Controller para um feedback específico
class FeedbackController extends ChangeNotifier {
  final FeedbackType type;
  final String? semanticLabel;
  final IconData? icon;
  final Duration? duration;
  final dynamic animation; // SuccessAnimationType ou ErrorAnimationType
  final ProgressType? progressType;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onComplete;

  String _message;
  double _progress;
  FeedbackState _state;

  FeedbackController({
    required this.type,
    required String message,
    this.semanticLabel,
    this.icon,
    this.duration,
    this.animation,
    this.progressType,
    this.actionLabel,
    this.onAction,
    this.onComplete,
    double progress = 0.0,
  }) :
       _message = message,
       _progress = progress,
       _state = FeedbackState.active;

  String get message => _message;
  double get progress => _progress;
  FeedbackState get state => _state;

  void updateProgress(double progress, {String? message}) {
    _progress = progress.clamp(0.0, 1.0);
    if (message != null) {
      _message = message;
    }
    notifyListeners();
  }

  void completeWithSuccess(String? successMessage) {
    _state = FeedbackState.success;
    if (successMessage != null) {
      _message = successMessage;
    }
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      dismiss();
    });
  }

  void completeWithError(String? errorMessage) {
    _state = FeedbackState.error;
    if (errorMessage != null) {
      _message = errorMessage;
    }
    notifyListeners();
  }

  void dismiss() {
    _state = FeedbackState.dismissed;
    notifyListeners();
    onComplete?.call();
  }

  @override
  void dispose() {
    dismiss();
    super.dispose();
  }
}

/// Widget que escuta e exibe feedbacks
class FeedbackListener extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final Alignment alignment;
  final EdgeInsets padding;

  const FeedbackListener({
    super.key,
    required this.child,
    this.showOverlay = true,
    this.alignment = Alignment.topCenter,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<FeedbackListener> createState() => _FeedbackListenerState();
}

class _FeedbackListenerState extends State<FeedbackListener> {
  @override
  void initState() {
    super.initState();
    FeedbackSystem.addListener(_onFeedbackChanged);
  }

  @override
  void dispose() {
    FeedbackSystem.removeListener(_onFeedbackChanged);
    super.dispose();
  }

  void _onFeedbackChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        ...FeedbackSystem.activeFeedbacks.entries.map(
          (entry) => Positioned.fill(
            child: Align(
              alignment: widget.alignment,
              child: Padding(
                padding: widget.padding,
                child: FeedbackWidget(
                  controller: entry.value,
                  onDismiss: () => FeedbackSystem.dismiss(entry.key),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget visual para exibir feedback
class FeedbackWidget extends StatefulWidget {
  final FeedbackController controller;
  final VoidCallback? onDismiss;

  const FeedbackWidget({super.key, required this.controller, this.onDismiss});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _scaleController.forward();

    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.controller.state == FeedbackState.dismissed) {
      _animateOut();
    } else {
      setState(() {});
    }
  }

  void _animateOut() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildFeedbackCard(theme),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackCard(ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    switch (widget.controller.type) {
      case FeedbackType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case FeedbackType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        iconColor = Colors.white;
        break;
      case FeedbackType.progress:
        backgroundColor = theme.colorScheme.surface;
        textColor = theme.colorScheme.onSurface;
        iconColor = theme.colorScheme.primary;
        break;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60, maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(iconColor),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(textColor)),
            if (widget.controller.actionLabel != null) ...[
              const SizedBox(width: 12),
              _buildAction(textColor),
            ],
            if (widget.controller.type != FeedbackType.progress) ...[
              const SizedBox(width: 8),
              _buildDismissButton(textColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (widget.controller.type == FeedbackType.progress) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value:
              widget.controller.progressType == ProgressType.determinate
                  ? widget.controller.progress
                  : null,
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Icon(widget.controller.icon, color: color, size: 24);
  }

  Widget _buildContent(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.controller.message,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.controller.type == FeedbackType.progress &&
            widget.controller.progressType == ProgressType.determinate) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: widget.controller.progress,
            backgroundColor: textColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
          const SizedBox(height: 2),
          Text(
            '${(widget.controller.progress * 100).round()}%',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAction(Color textColor) {
    return TextButton(
      onPressed: widget.controller.onAction,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        widget.controller.actionLabel!,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildDismissButton(Color textColor) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.close,
          color: textColor.withValues(alpha: 0.8),
          size: 18,
        ),
      ),
    );
  }
}

/// Tipos de feedback
enum FeedbackType { success, error, progress }

/// Estados do feedback
enum FeedbackState { active, success, error, dismissed }

/// Tipos de animação de sucesso
enum SuccessAnimationType { checkmark, confetti, bounce, fade }

/// Tipos de animação de erro
enum ErrorAnimationType { shake, pulse, fade }

/// Tipos de progresso
enum ProgressType { determinate, indeterminate }

/// Contextos pré-definidos de feedback
class FeedbackContexts {
  static const String plantSave = 'plant_save';
  static const String taskComplete = 'task_complete';
  static const String premium = 'premium';
  static const String auth = 'auth';
  static const String backup = 'backup';
  static const String sync = 'sync';
  static const String imageUpload = 'image_upload';
  static const String settings = 'settings';
}
