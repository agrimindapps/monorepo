import 'package:flutter/material.dart';

import '../../../infrastructure/services/data_migration_service.dart';

/// Dialog widget that displays migration progress with real-time updates
/// 
/// This widget shows the progress of data migration operations including
/// percentage completion, current operation description, and estimated
/// time remaining.
class MigrationProgressDialog extends StatefulWidget {
  const MigrationProgressDialog({
    super.key,
    required this.progressStream,
    required this.operationTitle,
    this.allowCancel = false,
    this.onCancel,
    this.onComplete,
  });

  /// Stream of migration progress updates
  final Stream<MigrationProgress> progressStream;
  
  /// Title for the operation being performed
  final String operationTitle;
  
  /// Whether to allow canceling the operation
  final bool allowCancel;
  
  /// Callback when user requests cancellation
  final VoidCallback? onCancel;
  
  /// Callback when operation is complete
  final VoidCallback? onComplete;

  @override
  State<MigrationProgressDialog> createState() => _MigrationProgressDialogState();

  /// Static method to show the progress dialog
  static Future<void> show({
    required BuildContext context,
    required Stream<MigrationProgress> progressStream,
    required String operationTitle,
    bool allowCancel = false,
    VoidCallback? onCancel,
    VoidCallback? onComplete,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MigrationProgressDialog(
        progressStream: progressStream,
        operationTitle: operationTitle,
        allowCancel: allowCancel,
        onCancel: onCancel,
        onComplete: onComplete,
      ),
    );
  }
}

class _MigrationProgressDialogState extends State<MigrationProgressDialog> {
  MigrationProgress? _currentProgress;
  bool _isCompleted = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _listenToProgress();
  }

  void _listenToProgress() {
    widget.progressStream.listen(
      (progress) {
        if (mounted) {
          setState(() {
            _currentProgress = progress;
            if (progress.isComplete) {
              _isCompleted = true;
              // Auto-close after a brief delay when complete
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  widget.onComplete?.call();
                  Navigator.of(context).pop();
                }
              });
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.operationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasError) ...[
            _buildErrorContent(),
          ] else if (_isCompleted) ...[
            _buildCompletedContent(),
          ] else ...[
            _buildProgressContent(),
          ],
        ],
      ),
      actions: [
        if (_hasError)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          )
        else if (_isCompleted)
          ElevatedButton(
            onPressed: () {
              widget.onComplete?.call();
              Navigator.of(context).pop();
            },
            child: const Text('Concluído'),
          )
        else if (widget.allowCancel)
          TextButton(
            onPressed: () {
              widget.onCancel?.call();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
      ],
    );
  }

  Widget _buildProgressContent() {
    final progress = _currentProgress;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: progress?.percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // Progress percentage
        Text(
          '${progress?.percentageInt ?? 0}%',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Current operation
        Text(
          progress?.currentOperation ?? 'Inicializando...',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        
        // Additional details if available
        if (progress?.details != null) ...[
          const SizedBox(height: 8),
          Text(
            progress!.details!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        
        // Estimated time remaining if available
        if (progress?.estimatedTimeRemaining != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 4),
              Text(
                'Tempo estimado: ${_formatDuration(progress!.estimatedTimeRemaining!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Spinning indicator
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildCompletedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Operação Concluída!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          _currentProgress?.currentOperation ?? 'Migração concluída com sucesso.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Erro na Operação',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          _errorMessage ?? 'Ocorreu um erro durante a migração.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Simple progress indicator widget for inline usage
class MigrationProgressIndicator extends StatelessWidget {
  const MigrationProgressIndicator({
    super.key,
    required this.progress,
    this.showPercentage = true,
    this.showOperation = true,
    this.height = 6.0,
  });

  /// Current migration progress
  final MigrationProgress progress;
  
  /// Whether to show percentage text
  final bool showPercentage;
  
  /// Whether to show operation description
  final bool showOperation;
  
  /// Height of the progress bar
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showOperation) ...[
          Text(
            progress.currentOperation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],
        
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress.percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: height,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 12),
              Text(
                '${progress.percentageInt}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        
        if (progress.details != null) ...[
          const SizedBox(height: 4),
          Text(
            progress.details!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}