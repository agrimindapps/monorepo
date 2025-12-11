import 'package:flutter/material.dart';
import 'haptic_service.dart';

/// Serviço de toast messages contextuais e não intrusivas
/// Complementa o FeedbackSystem para mensagens rápidas
class ToastService {
  final HapticService _hapticService;

  OverlayEntry? _currentToast;
  final List<ToastController> _toastQueue = [];
  bool _isShowingToast = false;

  ToastService(this._hapticService);

  /// Mostra toast de sucesso
  void showSuccess({
    required BuildContext context,
    required String message,
    String? description,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 3),
    bool includeHaptic = true,
    VoidCallback? onTap,
  }) {
    if (includeHaptic) {
      _hapticService.buttonTap();
    }

    final controller = ToastController(
      type: ToastType.success,
      message: message,
      description: description,
      icon: icon,
      duration: duration,
      onTap: onTap,
    );

    _showToast(context, controller);
  }

  /// Mostra toast de erro
  void showError({
    required BuildContext context,
    required String message,
    String? description,
    IconData icon = Icons.error,
    Duration duration = const Duration(seconds: 4),
    bool includeHaptic = true,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (includeHaptic) {
      _hapticService.warning();
    }

    final controller = ToastController(
      type: ToastType.error,
      message: message,
      description: description,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    _showToast(context, controller);
  }

  /// Mostra toast de informação
  void showInfo({
    required BuildContext context,
    required String message,
    String? description,
    IconData icon = Icons.info,
    Duration duration = const Duration(seconds: 3),
    bool includeHaptic = false,
    VoidCallback? onTap,
  }) {
    if (includeHaptic) {
      _hapticService.light();
    }

    final controller = ToastController(
      type: ToastType.info,
      message: message,
      description: description,
      icon: icon,
      duration: duration,
      onTap: onTap,
    );

    _showToast(context, controller);
  }

  /// Mostra toast de warning
  void showWarning({
    required BuildContext context,
    required String message,
    String? description,
    IconData icon = Icons.warning,
    Duration duration = const Duration(seconds: 4),
    bool includeHaptic = true,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (includeHaptic) {
      _hapticService.warning();
    }

    final controller = ToastController(
      type: ToastType.warning,
      message: message,
      description: description,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    _showToast(context, controller);
  }

  /// Mostra toast customizado
  void showCustom({
    required BuildContext context,
    required String message,
    String? description,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool includeHaptic = false,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (includeHaptic) {
      _hapticService.light();
    }

    final controller = ToastController(
      type: ToastType.custom,
      message: message,
      description: description,
      icon: icon,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
      onAction: onAction,
      customBackgroundColor: backgroundColor,
      customTextColor: textColor,
    );

    _showToast(context, controller);
  }

  /// Remove o toast atual
  void dismiss() {
    if (_currentToast != null) {
      _currentToast!.remove();
      _currentToast = null;
      _isShowingToast = false;
      _processQueue();
    }
  }

  /// Remove todos os toasts
  void dismissAll() {
    dismiss();
    _toastQueue.clear();
  }

  void _showToast(BuildContext context, ToastController controller) {
    if (_isShowingToast) {
      _toastQueue.add(controller);
      return;
    }

    _displayToast(context, controller);
  }

  void _displayToast(BuildContext context, ToastController controller) {
    _isShowingToast = true;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ToastWidget(
        controller: controller,
        onDismiss: () {
          dismiss();
        },
      ),
    );

    _currentToast = overlayEntry;
    overlay.insert(overlayEntry);
    Future.delayed(controller.duration, () {
      if (_currentToast == overlayEntry) {
        dismiss();
      }
    });
  }

  void _processQueue() {
    if (_toastQueue.isNotEmpty && !_isShowingToast) {
      _toastQueue.removeAt(0);
    }
  }
}

/// Controller para um toast específico
class ToastController {
  final ToastType type;
  final String message;
  final String? description;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? customBackgroundColor;
  final Color? customTextColor;

  const ToastController({
    required this.type,
    required this.message,
    this.description,
    this.icon,
    required this.duration,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.customBackgroundColor,
    this.customTextColor,
  });
}

/// Widget visual do toast
class ToastWidget extends StatefulWidget {
  final ToastController controller;
  final VoidCallback onDismiss;

  const ToastWidget({
    super.key,
    required this.controller,
    required this.onDismiss,
  });

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: _buildToastCard(theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToastCard(ThemeData theme) {
    final colors = _getToastColors(theme);

    return Material(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: widget.controller.onTap ?? _dismiss,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (widget.controller.icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.controller.icon,
                    color: colors.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.controller.message,
                      style: TextStyle(
                        color: colors.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.controller.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.controller.description!,
                        style: TextStyle(
                          color: colors.textColor.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.controller.actionLabel != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    widget.controller.onAction?.call();
                    _dismiss();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colors.actionColor,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    widget.controller.actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: colors.textColor.withValues(alpha: 0.6),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ToastColors _getToastColors(ThemeData theme) {
    switch (widget.controller.type) {
      case ToastType.success:
        return ToastColors(
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          actionColor: Colors.white,
        );
      case ToastType.error:
        return ToastColors(
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          actionColor: Colors.white,
        );
      case ToastType.warning:
        return ToastColors(
          backgroundColor: Colors.orange.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          actionColor: Colors.white,
        );
      case ToastType.info:
        return ToastColors(
          backgroundColor: Colors.blue.shade600,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withValues(alpha: 0.2),
          actionColor: Colors.white,
        );
      case ToastType.custom:
        return ToastColors(
          backgroundColor: widget.controller.customBackgroundColor!,
          textColor: widget.controller.customTextColor!,
          iconColor: widget.controller.customTextColor!,
          iconBackgroundColor: widget.controller.customTextColor!.withValues(
            alpha: 0.2,
          ),
          actionColor: widget.controller.customTextColor!,
        );
    }
  }
}

/// Cores do toast
class ToastColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color actionColor;

  const ToastColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.actionColor,
  });
}

/// Tipos de toast
enum ToastType { success, error, warning, info, custom }

/// Contextos pré-definidos para toasts
class ToastContexts {}
