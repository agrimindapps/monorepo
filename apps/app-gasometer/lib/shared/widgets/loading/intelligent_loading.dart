import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/loading_design_tokens.dart';

/// Widget de loading inteligente com múltiplas etapas
/// Fornece feedback visual detalhado durante processos longos
class IntelligentLoading extends StatefulWidget {

  const IntelligentLoading({
    super.key,
    required this.steps,
    this.onComplete,
    this.autoAdvance = true,
    this.customStepDuration,
    this.primaryColor,
    this.backgroundColor,
    this.showProgress = true,
    this.expandedView = true,
  });
  final List<LoadingStepConfig> steps;
  final VoidCallback? onComplete;
  final bool autoAdvance;
  final Duration? customStepDuration;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool showProgress;
  final bool expandedView;

  /// Factory para login flow padrão
  static IntelligentLoading loginFlow({
    Key? key,
    VoidCallback? onComplete,
    Color? primaryColor,
  }) {
    return IntelligentLoading(
      key: key,
      steps: LoadingDesignTokens.loginSteps,
      onComplete: onComplete,
      primaryColor: primaryColor,
    );
  }

  /// Factory para versão compacta
  static IntelligentLoading compact({
    Key? key,
    required List<LoadingStepConfig> steps,
    VoidCallback? onComplete,
    Color? primaryColor,
  }) {
    return IntelligentLoading(
      key: key,
      steps: steps,
      onComplete: onComplete,
      expandedView: false,
      showProgress: false,
      primaryColor: primaryColor,
    );
  }

  @override
  State<IntelligentLoading> createState() => _IntelligentLoadingState();
}

class _IntelligentLoadingState extends State<IntelligentLoading>
    with TickerProviderStateMixin {
  int currentStepIndex = 0;
  late AnimationController _iconController;
  late AnimationController _progressController;
  late Animation<double> _iconAnimation;
  Timer? _stepTimer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.autoAdvance) {
      _startAutoAdvance();
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _progressController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    // Animação do ícone (bounce entrance)
    _iconController = AnimationController(
      duration: LoadingDesignTokens.normalDuration,
      vsync: this,
    );
    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: LoadingDesignTokens.bounceCurve,
    );

    // Animação do progresso
    _progressController = AnimationController(
      duration: LoadingDesignTokens.slowDuration,
      vsync: this,
    );

    // Iniciar primeira etapa
    _iconController.forward();
  }

  void _startAutoAdvance() {
    if (currentStepIndex < widget.steps.length) {
      final currentStep = widget.steps[currentStepIndex];
      final duration = widget.customStepDuration ?? currentStep.duration;

      _stepTimer = Timer(duration, () {
        if (mounted) {
          _advanceToNextStep();
        }
      });

      // Animação do progresso para esta etapa
      _progressController.forward();
    }
  }

  void _advanceToNextStep() {
    if (currentStepIndex < widget.steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });
      
      // Resetar e iniciar animações para próxima etapa
      _iconController.reset();
      _progressController.reset();
      
      _iconController.forward();
      _startAutoAdvance();
    } else {
      // Última etapa concluída
      _completeLoading();
    }
  }

  void _completeLoading() {
    if (_completed) return;
    
    setState(() {
      _completed = true;
    });

    // Delay before calling onComplete to show final step
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = LoadingDesignTokens.getColorScheme(context);
    final currentStep = widget.steps[currentStepIndex];

    return Container(
      padding: EdgeInsets.all(widget.expandedView 
        ? LoadingDesignTokens.spacingXl 
        : LoadingDesignTokens.spacingLg),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de progresso
          if (widget.showProgress && widget.expandedView) ...[
            _buildProgressIndicator(colors),
            const SizedBox(height: LoadingDesignTokens.spacingLg),
          ],

          // Ícone animado
          _buildAnimatedIcon(currentStep, colors),
          
          const SizedBox(height: LoadingDesignTokens.spacingMd),

          // Título
          AnimatedSwitcher(
            duration: LoadingDesignTokens.fastDuration,
            child: Text(
              currentStep.title,
              key: ValueKey('title_$currentStepIndex'),
              style: LoadingDesignTokens.titleTextStyle.copyWith(
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (widget.expandedView) ...[
            const SizedBox(height: LoadingDesignTokens.spacingSm),

            // Subtítulo
            AnimatedSwitcher(
              duration: LoadingDesignTokens.fastDuration,
              child: Text(
                currentStep.subtitle,
                key: ValueKey('subtitle_$currentStepIndex'),
                style: LoadingDesignTokens.bodyTextStyle.copyWith(
                  color: colors.onSurfaceLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: LoadingDesignTokens.spacingLg),

            // Indicador de loading circular
            _buildCircularIndicator(colors),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(LoadingColorScheme colors) {
    return Column(
      children: [
        // Barra de progresso
        ClipRRect(
          borderRadius: BorderRadius.circular(LoadingDesignTokens.borderRadiusSm),
          child: LinearProgressIndicator(
            value: (currentStepIndex + 1) / widget.steps.length,
            backgroundColor: colors.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(
              widget.primaryColor ?? colors.primary,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: LoadingDesignTokens.spacingSm),
        
        // Texto do progresso
        Text(
          'Etapa ${currentStepIndex + 1} de ${widget.steps.length}',
          style: LoadingDesignTokens.captionTextStyle.copyWith(
            color: colors.onSurfaceLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon(LoadingStepConfig step, LoadingColorScheme colors) {
    return ScaleTransition(
      scale: _iconAnimation,
      child: Container(
        width: LoadingDesignTokens.largeIconSize + 16,
        height: LoadingDesignTokens.largeIconSize + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (widget.primaryColor ?? colors.primary).withValues(alpha: 0.1),
          border: Border.all(
            color: widget.primaryColor ?? colors.primary,
            width: 2,
          ),
        ),
        child: Icon(
          step.icon,
          size: LoadingDesignTokens.largeIconSize,
          color: widget.primaryColor ?? colors.primary,
        ),
      ),
    );
  }

  Widget _buildCircularIndicator(LoadingColorScheme colors) {
    return SizedBox(
      width: LoadingDesignTokens.loadingIndicatorSize,
      height: LoadingDesignTokens.loadingIndicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: LoadingDesignTokens.loadingIndicatorStrokeWidth,
        valueColor: AlwaysStoppedAnimation(
          widget.primaryColor ?? colors.primary,
        ),
      ),
    );
  }

  /// Método público para avançar manualmente
  void nextStep() {
    if (!widget.autoAdvance && currentStepIndex < widget.steps.length - 1) {
      _advanceToNextStep();
    }
  }

  /// Método público para pular para etapa específica
  void jumpToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < widget.steps.length && !widget.autoAdvance) {
      setState(() {
        currentStepIndex = stepIndex;
      });
      _iconController.reset();
      _iconController.forward();
    }
  }

  /// Método público para finalizar manualmente
  void complete() {
    _stepTimer?.cancel();
    _completeLoading();
  }
}

/// Widget para exibir loading inteligente como overlay/modal
class IntelligentLoadingOverlay {
  /// Mostra loading inteligente como modal
  static Future<void> show(
    BuildContext context, {
    required List<LoadingStepConfig> steps,
    bool dismissible = false,
    Color? primaryColor,
    VoidCallback? onComplete,
  }) async {
    final completer = Completer<void>();
    
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: IntelligentLoading(
            steps: steps,
            primaryColor: primaryColor,
            onComplete: () {
              overlayEntry.remove();
              onComplete?.call();
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    
    // Handle dismissible
    if (dismissible) {
      // Auto-remove after total duration
      final totalDuration = steps.fold<Duration>(
        Duration.zero,
        (total, step) => total + step.duration,
      );
      
      Timer(totalDuration + const Duration(seconds: 1), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });
    }

    return completer.future;
  }

  /// Mostra loading inteligente para login flow
  static Future<void> showLoginFlow(
    BuildContext context, {
    bool dismissible = false,
    Color? primaryColor,
    VoidCallback? onComplete,
  }) {
    return show(
      context,
      steps: LoadingDesignTokens.loginSteps,
      dismissible: dismissible,
      primaryColor: primaryColor,
      onComplete: onComplete,
    );
  }
}