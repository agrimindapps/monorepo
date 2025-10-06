import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../infrastructure/services/sync_service.dart';

/// Widget de loading para sincronização do Task Manager
/// Baseado no SimpleSyncLoading do app-plantis, mas adaptado para Task Manager
class TaskSyncLoading extends StatefulWidget {
  final Stream<SyncProgress>? progressStream;
  final Stream<String>? messageStream;
  final VoidCallback? onComplete;
  final VoidCallback? onError;
  final String title;
  final Color? primaryColor;

  const TaskSyncLoading({
    super.key,
    this.progressStream,
    this.messageStream,
    this.onComplete,
    this.onError,
    this.title = 'Sincronizando...',
    this.primaryColor,
  });

  @override
  State<TaskSyncLoading> createState() => _TaskSyncLoadingState();
}

class _TaskSyncLoadingState extends State<TaskSyncLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  SyncProgress? _currentProgress;
  String _currentMessage = 'Iniciando sincronização...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenToStreams();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
  }

  void _listenToStreams() {
    widget.progressStream?.listen(
      (progress) {
        if (mounted) {
          setState(() {
            _currentProgress = progress;
          });

          if (progress.isCompleted) {
            _handleCompletion();
          } else if (progress.isError) {
            _handleError();
          }
        }
      },
      onError: (error) {
        if (mounted) {
          _handleError();
        }
      },
    );
    widget.messageStream?.listen(
      (message) {
        if (mounted) {
          setState(() {
            _currentMessage = message;
          });
        }
      },
    );
  }

  void _handleCompletion() {
    _rotationController.stop();
    _pulseController.stop();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      widget.onComplete?.call();
    });
  }

  void _handleError() {
    setState(() {
      _hasError = true;
    });
    
    _rotationController.stop();
    _pulseController.stop();
    
    widget.onError?.call();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;
    
    return Material(
      color: Colors.black.withAlpha(179), // 70% opacity
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedIcon(primaryColor),
                
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _hasError ? Colors.red[600] : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                if (_currentProgress != null && !_hasError) ...[
                  _buildProgressBar(primaryColor),
                  const SizedBox(height: 16),
                ],
                Text(
                  _currentMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _hasError 
                        ? Colors.red[600] 
                        : theme.textTheme.bodyMedium?.color?.withAlpha(179),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                if (_currentProgress != null && !_hasError) ...[
                  _buildStepsIndicator(primaryColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(Color primaryColor) {
    if (_hasError) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.red[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline,
          size: 40,
          color: Colors.red,
        ),
      );
    }

    if (_currentProgress?.isCompleted == true) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_outline,
          size: 40,
          color: Colors.green,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withAlpha(179),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(102),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sync,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Color primaryColor) {
    final progress = _currentProgress!.progress;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: primaryColor.withAlpha(51),
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildStepsIndicator(Color primaryColor) {
    final progress = _currentProgress!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(progress.totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber <= progress.currentStep;
        final isCurrent = stepNumber == progress.currentStep;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? primaryColor
                  : primaryColor.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: isCurrent && !progress.isCompleted
                ? AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }),
    );
  }
}

/// Widget simples para mostrar loading de sync sem streams
class SimpleTaskSyncLoading extends StatelessWidget {
  final String message;
  final Color? primaryColor;

  const SimpleTaskSyncLoading({
    super.key,
    this.message = 'Sincronizando dados...',
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.primaryColor;
    
    return Material(
      color: Colors.black.withAlpha(128),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
