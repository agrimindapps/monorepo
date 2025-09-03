import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/plantis_colors.dart';

/// Estados do overlay de progresso de sincronização
enum SyncProgressState {
  preparing,
  syncing,
  completing,
  completed,
  error,
}

/// Etapa individual de sincronização
class SyncStep {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool hasError;
  final double progress; // 0.0 to 1.0

  const SyncStep({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.hasError = false,
    this.progress = 0.0,
  });

  SyncStep copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? hasError,
    double? progress,
  }) {
    return SyncStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      hasError: hasError ?? this.hasError,
      progress: progress ?? this.progress,
    );
  }
}

/// Controlador para gerenciar estado do overlay
class SyncProgressController {
  final _stateController = StreamController<SyncProgressState>.broadcast();
  final _stepsController = StreamController<List<SyncStep>>.broadcast();
  final _progressController = StreamController<double>.broadcast();
  final _messageController = StreamController<String?>.broadcast();
  
  SyncProgressState _currentState = SyncProgressState.preparing;
  List<SyncStep> _steps = [];
  double _overallProgress = 0.0;
  String? _currentMessage;
  Timer? _autoHideTimer;

  // Getters
  Stream<SyncProgressState> get stateStream => _stateController.stream;
  Stream<List<SyncStep>> get stepsStream => _stepsController.stream;
  Stream<double> get progressStream => _progressController.stream;
  Stream<String?> get messageStream => _messageController.stream;
  
  SyncProgressState get currentState => _currentState;
  List<SyncStep> get steps => List.unmodifiable(_steps);
  double get overallProgress => _overallProgress;
  String? get currentMessage => _currentMessage;

  /// Inicializa as etapas de sincronização
  void initializeSteps(List<SyncStep> initialSteps) {
    _steps = initialSteps;
    _stepsController.add(_steps);
    _updateOverallProgress();
  }

  /// Atualiza o estado geral
  void updateState(SyncProgressState newState, {String? message}) {
    _currentState = newState;
    _stateController.add(newState);
    
    if (message != null) {
      updateMessage(message);
    }

    // Auto-hide logic
    if (newState == SyncProgressState.completed) {
      _scheduleAutoHide();
    }
  }

  /// Atualiza uma etapa específica
  void updateStep(String stepId, {
    String? title,
    String? description,
    bool? isCompleted,
    bool? hasError,
    double? progress,
  }) {
    final stepIndex = _steps.indexWhere((step) => step.id == stepId);
    if (stepIndex == -1) return;

    _steps[stepIndex] = _steps[stepIndex].copyWith(
      title: title,
      description: description,
      isCompleted: isCompleted,
      hasError: hasError,
      progress: progress,
    );

    _stepsController.add(_steps);
    _updateOverallProgress();
  }

  /// Marca etapa como iniciada
  void startStep(String stepId, {String? message}) {
    updateStep(stepId, progress: 0.1);
    if (message != null) {
      updateMessage(message);
    }
  }

  /// Marca etapa como completada
  void completeStep(String stepId, {String? message}) {
    updateStep(stepId, isCompleted: true, progress: 1.0);
    if (message != null) {
      updateMessage(message);
    }
    
    // Verificar se todas as etapas foram completadas
    if (_steps.every((step) => step.isCompleted)) {
      updateState(SyncProgressState.completed, message: 'Sincronização concluída!');
    }
  }

  /// Marca etapa com erro
  void errorStep(String stepId, {String? message}) {
    updateStep(stepId, hasError: true);
    updateState(SyncProgressState.error, message: message ?? 'Erro na sincronização');
  }

  /// Atualiza progresso de uma etapa
  void updateStepProgress(String stepId, double progress, {String? message}) {
    updateStep(stepId, progress: progress.clamp(0.0, 1.0));
    if (message != null) {
      updateMessage(message);
    }
  }

  /// Atualiza mensagem atual
  void updateMessage(String message) {
    _currentMessage = message;
    _messageController.add(message);
  }

  /// Calcula progresso geral
  void _updateOverallProgress() {
    if (_steps.isEmpty) {
      _overallProgress = 0.0;
    } else {
      final totalProgress = _steps.fold<double>(
        0.0, 
        (sum, step) => sum + step.progress,
      );
      _overallProgress = totalProgress / _steps.length;
    }
    
    _progressController.add(_overallProgress);
  }

  /// Agenda auto-hide após completar
  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      // O overlay deve se esconder automaticamente
    });
  }

  /// Dispose dos recursos
  void dispose() {
    _autoHideTimer?.cancel();
    _stateController.close();
    _stepsController.close();
    _progressController.close();
    _messageController.close();
  }
}

/// Overlay não-bloqueante de progresso de sincronização
class SyncProgressOverlay extends StatefulWidget {
  final SyncProgressController controller;
  final VoidCallback? onContinueInBackground;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showContinueOption;
  final bool showCloseButton;
  final Duration autoHideDuration;

  const SyncProgressOverlay({
    super.key,
    required this.controller,
    this.onContinueInBackground,
    this.onCancel,
    this.onRetry,
    this.onClose,
    this.showContinueOption = true,
    this.showCloseButton = false,
    this.autoHideDuration = const Duration(seconds: 3),
  });

  @override
  State<SyncProgressOverlay> createState() => _SyncProgressOverlayState();
}

class _SyncProgressOverlayState extends State<SyncProgressOverlay>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  Timer? _autoHideTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAutoHide();
    _slideController.forward();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  void _setupAutoHide() {
    widget.controller.stateStream.listen((state) {
      if (state == SyncProgressState.completed && _isVisible) {
        _autoHideTimer?.cancel();
        _autoHideTimer = Timer(widget.autoHideDuration, _hideOverlay);
      }
    });
  }

  void _hideOverlay() async {
    if (!_isVisible) return;
    
    setState(() => _isVisible = false);
    
    await _slideController.reverse();
    await _fadeController.reverse();
    
    if (mounted && widget.onClose != null) {
      widget.onClose!();
    }
  }

  void _continueInBackground() {
    widget.onContinueInBackground?.call();
    _hideOverlay();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background semi-transparente
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          
          // Overlay content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildOverlayContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildProgressSection(),
          _buildStepsSection(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<SyncProgressState>(
      stream: widget.controller.stateStream,
      initialData: widget.controller.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getStateColor(state).withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              _buildStateIcon(state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStateTitle(state),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getStateColor(state),
                      ),
                    ),
                    const SizedBox(height: 4),
                    StreamBuilder<String?>(
                      stream: widget.controller.messageStream,
                      builder: (context, messageSnapshot) {
                        final message = messageSnapshot.data;
                        if (message == null) return const SizedBox.shrink();
                        
                        return Text(
                          message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (widget.showCloseButton)
                IconButton(
                  onPressed: _hideOverlay,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          StreamBuilder<double>(
            stream: widget.controller.progressStream,
            initialData: widget.controller.overallProgress,
            builder: (context, snapshot) {
              final progress = snapshot.data!;
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso Geral',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: PlantisColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        PlantisColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return StreamBuilder<List<SyncStep>>(
      stream: widget.controller.stepsStream,
      initialData: widget.controller.steps,
      builder: (context, snapshot) {
        final steps = snapshot.data!;
        if (steps.isEmpty) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Etapas de Sincronização',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ...steps.map((step) => _buildStepItem(step)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepItem(SyncStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _buildStepIndicator(step),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: step.hasError ? Colors.red : null,
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (!step.isCompleted && !step.hasError && step.progress > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: step.progress,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        PlantisColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(SyncStep step) {
    if (step.hasError) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 20,
      );
    }
    
    if (step.isCompleted) {
      return const Icon(
        Icons.check_circle,
        color: PlantisColors.primary,
        size: 20,
      );
    }
    
    if (step.progress > 0) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(PlantisColors.primary),
        ),
      );
    }
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildActions() {
    return StreamBuilder<SyncProgressState>(
      stream: widget.controller.stateStream,
      initialData: widget.controller.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (widget.showContinueOption && 
                  (state == SyncProgressState.syncing || state == SyncProgressState.preparing)) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _continueInBackground,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Continuar em Background'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlantisColors.primary,
                      side: const BorderSide(color: PlantisColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              if (state == SyncProgressState.error && widget.onRetry != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlantisColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              if (state == SyncProgressState.completed) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hideOverlay,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Concluído'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlantisColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              
              if (state != SyncProgressState.completed && widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateIcon(SyncProgressState state) {
    switch (state) {
      case SyncProgressState.preparing:
        return const Icon(Icons.settings, color: Colors.blue, size: 24);
      case SyncProgressState.syncing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(PlantisColors.primary),
          ),
        );
      case SyncProgressState.completing:
        return const Icon(Icons.sync, color: PlantisColors.primary, size: 24);
      case SyncProgressState.completed:
        return const Icon(Icons.check_circle, color: PlantisColors.success, size: 24);
      case SyncProgressState.error:
        return const Icon(Icons.error, color: Colors.red, size: 24);
    }
  }

  String _getStateTitle(SyncProgressState state) {
    switch (state) {
      case SyncProgressState.preparing:
        return 'Preparando Sincronização';
      case SyncProgressState.syncing:
        return 'Sincronizando Dados';
      case SyncProgressState.completing:
        return 'Finalizando';
      case SyncProgressState.completed:
        return 'Sincronização Concluída';
      case SyncProgressState.error:
        return 'Erro na Sincronização';
    }
  }

  Color _getStateColor(SyncProgressState state) {
    switch (state) {
      case SyncProgressState.preparing:
        return Colors.blue;
      case SyncProgressState.syncing:
        return PlantisColors.primary;
      case SyncProgressState.completing:
        return PlantisColors.primary;
      case SyncProgressState.completed:
        return PlantisColors.success;
      case SyncProgressState.error:
        return Colors.red;
    }
  }
}