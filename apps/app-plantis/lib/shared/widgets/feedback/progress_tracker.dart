import 'dart:async';

import 'package:flutter/material.dart';

import 'feedback_system.dart';
import 'haptic_service.dart';
import 'toast_service.dart';

/// Sistema de tracking de progresso para operações de longa duração
/// Especializado em uploads, downloads e processamento de dados
class ProgressTracker {
  static final Map<String, ProgressOperation> _activeOperations = {};
  static final List<VoidCallback> _listeners = [];

  /// Inicia uma nova operação de progresso
  static ProgressOperation startOperation({
    required String key,
    required String title,
    String? description,
    ProgressType type = ProgressType.determinate,
    bool showToast = true,
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      // getIt<HapticService>().uploadStart();
    }

    final operation = ProgressOperation(
      key: key,
      title: title,
      description: description,
      type: type,
      showToast: showToast,
    );

    _activeOperations[key] = operation;
    _notifyListeners();

    return operation;
  }

  /// Atualiza progresso de uma operação
  static void updateProgress(
    String key, {
    required double progress,
    String? message,
    String? description,
    bool includeHaptic = false,
  }) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._updateProgress(
        progress: progress,
        message: message,
        description: description,
      );

      if (includeHaptic) {
        // getIt<HapticService>().uploadProgress();
      }

      _notifyListeners();
    }
  }

  /// Completa operação com sucesso
  static void completeOperation(
    String key, {
    String? successMessage,
    bool showToast = true,
    bool includeHaptic = true,
  }) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._complete(successMessage);

      if (includeHaptic) {
        // getIt<HapticService>().uploadComplete();
      }

      if (showToast && operation.context != null) {
        // getIt<ToastService>().showSuccess(
        //   context: operation.context!,
        //   message: successMessage ?? 'Operação concluída!',
        //   icon: Icons.check_circle,
        // );
      }
      Future.delayed(const Duration(seconds: 2), () {
        _activeOperations.remove(key);
        _notifyListeners();
      });
    }
  }

  /// Falha operação com erro
  static void failOperation(
    String key, {
    required String errorMessage,
    bool showToast = true,
    bool includeHaptic = true,
    VoidCallback? onRetry,
  }) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._fail(errorMessage);

      if (includeHaptic) {
        // getIt<HapticService>().uploadError();
      }

      if (showToast && operation.context != null) {
        // getIt<ToastService>().showError(
        //   context: operation.context!,
        //   message: errorMessage,
        //   actionLabel: onRetry != null ? 'Tentar novamente' : null,
        //   onAction: onRetry,
        // );
      }

      _notifyListeners();
    }
  }

  /// Pausa operação
  static void pauseOperation(String key) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._pause();
      _notifyListeners();
    }
  }

  /// Retoma operação
  static void resumeOperation(String key) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._resume();
      _notifyListeners();
    }
  }

  /// Cancela operação
  static void cancelOperation(
    String key, {
    bool showToast = true,
    bool includeHaptic = true,
  }) {
    final operation = _activeOperations[key];
    if (operation != null) {
      operation._cancel();

      if (includeHaptic) {
        // getIt<HapticService>().selection();
      }

      if (showToast && operation.context != null) {
        // getIt<ToastService>().showInfo(
        //   context: operation.context!,
        //   message: 'Operação cancelada',
        //   icon: Icons.cancel,
        // );
      }

      _activeOperations.remove(key);
      _notifyListeners();
    }
  }

  /// Obtém operação específica
  static ProgressOperation? getOperation(String key) {
    return _activeOperations[key];
  }

  /// Obtém todas as operações ativas
  static Map<String, ProgressOperation> get activeOperations =>
      Map.unmodifiable(_activeOperations);

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

  /// Limpa todas as operações
  static void clearAll() {
    _activeOperations.clear();
    _notifyListeners();
  }
}

/// Representa uma operação de progresso
class ProgressOperation extends ChangeNotifier {
  final String key;
  final String title;
  final ProgressType type;
  final bool showToast;

  String? _description;
  String? _currentMessage;
  double _progress;
  OperationState _state;
  final DateTime _startTime;
  Duration? _estimatedTime;
  BuildContext? context;

  ProgressOperation({
    required this.key,
    required this.title,
    String? description,
    required this.type,
    required this.showToast,
  }) : _description = description,
       _currentMessage = description,
       _progress = 0.0,
       _state = OperationState.running,
       _startTime = DateTime.now();
  String? get description => _description;
  String? get currentMessage => _currentMessage;
  double get progress => _progress;
  OperationState get state => _state;
  DateTime get startTime => _startTime;
  Duration? get estimatedTime => _estimatedTime;
  Duration get elapsedTime => DateTime.now().difference(_startTime);

  /// Define contexto para toasts
  void setContext(BuildContext context) {
    this.context = context;
  }

  void _updateProgress({
    required double progress,
    String? message,
    String? description,
  }) {
    _progress = progress.clamp(0.0, 1.0);

    if (message != null) {
      _currentMessage = message;
    }

    if (description != null) {
      _description = description;
    }
    if (_progress > 0.1) {
      final elapsed = elapsedTime;
      final estimatedTotal = elapsed.inMilliseconds / _progress;
      _estimatedTime = Duration(
        milliseconds: (estimatedTotal - elapsed.inMilliseconds).round(),
      );
    }

    notifyListeners();
  }

  void _complete(String? successMessage) {
    _state = OperationState.completed;
    _progress = 1.0;
    if (successMessage != null) {
      _currentMessage = successMessage;
    }
    notifyListeners();
  }

  void _fail(String errorMessage) {
    _state = OperationState.failed;
    _currentMessage = errorMessage;
    notifyListeners();
  }

  void _pause() {
    if (_state == OperationState.running) {
      _state = OperationState.paused;
      notifyListeners();
    }
  }

  void _resume() {
    if (_state == OperationState.paused) {
      _state = OperationState.running;
      notifyListeners();
    }
  }

  void _cancel() {
    _state = OperationState.cancelled;
    notifyListeners();
  }

  /// Formata tempo estimado
  String get formattedEstimatedTime {
    if (_estimatedTime == null) return '--';

    final minutes = _estimatedTime!.inMinutes;
    final seconds = _estimatedTime!.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formata tempo decorrido
  String get formattedElapsedTime {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Estados de uma operação
enum OperationState { running, paused, completed, failed, cancelled }

/// Widget que exibe o progresso de uma operação
class ProgressTrackerWidget extends StatefulWidget {
  final String operationKey;
  final bool showDetails;
  final bool showActions;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const ProgressTrackerWidget({
    super.key,
    required this.operationKey,
    this.showDetails = true,
    this.showActions = true,
    this.onCancel,
    this.onRetry,
  });

  @override
  State<ProgressTrackerWidget> createState() => _ProgressTrackerWidgetState();
}

class _ProgressTrackerWidgetState extends State<ProgressTrackerWidget> {
  ProgressOperation? _operation;

  @override
  void initState() {
    super.initState();
    _operation = ProgressTracker.getOperation(widget.operationKey);
    ProgressTracker.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    ProgressTracker.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {
        _operation = ProgressTracker.getOperation(widget.operationKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_operation == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 12),
          _buildProgressBar(theme),
          if (widget.showDetails) ...[
            const SizedBox(height: 8),
            _buildDetails(theme),
          ],
          if (widget.showActions &&
              (_operation!.state == OperationState.running ||
                  _operation!.state == OperationState.paused ||
                  _operation!.state == OperationState.failed)) ...[
            const SizedBox(height: 16),
            _buildActions(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildStateIcon(theme),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _operation!.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_operation!.currentMessage != null) ...[
                const SizedBox(height: 2),
                Text(
                  _operation!.currentMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          '${(_operation!.progress * 100).round()}%',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStateIcon(ThemeData theme) {
    switch (_operation!.state) {
      case OperationState.running:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value:
                _operation!.type == ProgressType.determinate
                    ? _operation!.progress
                    : null,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        );
      case OperationState.paused:
        return Icon(
          Icons.pause_circle,
          color: theme.colorScheme.secondary,
          size: 24,
        );
      case OperationState.completed:
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case OperationState.failed:
        return const Icon(Icons.error, color: Colors.red, size: 24);
      case OperationState.cancelled:
        return Icon(Icons.cancel, color: theme.colorScheme.outline, size: 24);
    }
  }

  Widget _buildProgressBar(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value:
            _operation!.type == ProgressType.determinate
                ? _operation!.progress
                : null,
        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(theme)),
        minHeight: 6,
      ),
    );
  }

  Color _getProgressColor(ThemeData theme) {
    switch (_operation!.state) {
      case OperationState.running:
        return theme.colorScheme.primary;
      case OperationState.paused:
        return theme.colorScheme.secondary;
      case OperationState.completed:
        return Colors.green;
      case OperationState.failed:
        return Colors.red;
      case OperationState.cancelled:
        return theme.colorScheme.outline;
    }
  }

  Widget _buildDetails(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Decorrido: ${_operation!.formattedElapsedTime}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (_operation!.state == OperationState.running &&
            _operation!.estimatedTime != null)
          Text(
            'Restante: ${_operation!.formattedEstimatedTime}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_operation!.state == OperationState.failed &&
            widget.onRetry != null) ...[
          TextButton.icon(
            onPressed: widget.onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (_operation!.state == OperationState.running) ...[
          TextButton.icon(
            onPressed: () => ProgressTracker.pauseOperation(_operation!.key),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pausar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (_operation!.state == OperationState.paused) ...[
          TextButton.icon(
            onPressed: () => ProgressTracker.resumeOperation(_operation!.key),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Retomar'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (_operation!.state != OperationState.completed &&
            _operation!.state != OperationState.cancelled)
          TextButton.icon(
            onPressed: () {
              widget.onCancel?.call();
              ProgressTracker.cancelOperation(_operation!.key);
            },
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancelar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
      ],
    );
  }
}

/// Widget que mostra todas as operações ativas
class ProgressTrackerPanel extends StatefulWidget {
  final bool showOnlyActive;

  const ProgressTrackerPanel({super.key, this.showOnlyActive = true});

  @override
  State<ProgressTrackerPanel> createState() => _ProgressTrackerPanelState();
}

class _ProgressTrackerPanelState extends State<ProgressTrackerPanel> {
  @override
  void initState() {
    super.initState();
    ProgressTracker.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    ProgressTracker.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final operations =
        ProgressTracker.activeOperations.values.where((op) {
          if (widget.showOnlyActive) {
            return op.state == OperationState.running ||
                op.state == OperationState.paused;
          }
          return true;
        }).toList();

    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children:
          operations
              .map(
                (operation) => ProgressTrackerWidget(
                  operationKey: operation.key,
                  showDetails: true,
                  showActions: true,
                ),
              )
              .toList(),
    );
  }
}

/// Contextos pré-definidos para operações de progresso
class ProgressContexts {
  static String uploadImage(String imageName) {
    return ProgressTracker.startOperation(
      key: 'upload_image_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Enviando imagem',
      description: 'Fazendo upload de $imageName',
      type: ProgressType.determinate,
    ).key;
  }
  static String backupData() {
    return ProgressTracker.startOperation(
      key: 'backup_data_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Fazendo backup',
      description: 'Salvando seus dados na nuvem',
      type: ProgressType.determinate,
    ).key;
  }
  static String restoreData() {
    return ProgressTracker.startOperation(
      key: 'restore_data_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Restaurando dados',
      description: 'Recuperando backup da nuvem',
      type: ProgressType.determinate,
    ).key;
  }
  static String syncData() {
    return ProgressTracker.startOperation(
      key: 'sync_data_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Sincronizando',
      description: 'Atualizando dados com a nuvem',
      type: ProgressType.indeterminate,
    ).key;
  }
  static String processData(String operation) {
    return ProgressTracker.startOperation(
      key: 'process_${operation}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Processando',
      description: 'Executando operação: $operation',
      type: ProgressType.indeterminate,
    ).key;
  }
}
