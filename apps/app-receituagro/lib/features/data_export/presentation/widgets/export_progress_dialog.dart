import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/export_request.dart';
import '../providers/data_export_notifier.dart';

/// Dialog that shows export progress with proper Future typing
class ExportProgressDialog extends ConsumerStatefulWidget {
  final String userId;
  final Set<DataType> dataTypes;
  final ExportFormat format;

  const ExportProgressDialog({
    super.key,
    required this.userId,
    required this.dataTypes,
    required this.format,
  });

  /// Shows the export progress dialog and returns the export request when completed
  static Future<ExportRequest?> show(
    BuildContext context, {
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    return showDialog<ExportRequest?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => ExportProgressDialog(
        userId: userId,
        dataTypes: dataTypes,
        format: format,
      ),
    );
  }

  @override
  ConsumerState<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends ConsumerState<ExportProgressDialog> {
  ExportRequest? _completedRequest;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExport();
    });
  }

  Future<void> _startExport() async {
    if (_hasStarted) return;
    _hasStarted = true;

    final request = await ref.read(dataExportProvider.notifier).requestExport(
      userId: widget.userId,
      dataTypes: widget.dataTypes,
      format: widget.format,
    );

    if (request != null) {
      setState(() {
        _completedRequest = request;
      });
    }
  }

  void _closeDialog() {
    Navigator.of(context).pop(_completedRequest);
  }

  @override
  Widget build(BuildContext context) {
    final exportStateAsync = ref.watch(dataExportProvider);

    return exportStateAsync.when(
      data: (exportState) {
        final progress = exportState.currentProgress;

        return PopScope(
          canPop: progress.isCompleted || progress.errorMessage != null,
          child: AlertDialog(
            title: const Text('Exportando dados'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProgressIndicator(progress),
                  const SizedBox(height: 16),
                  _buildCurrentTask(context, progress),
                  if (progress.estimatedTimeRemaining != null) ...[
                    const SizedBox(height: 8),
                    _buildTimeRemaining(context, progress),
                  ],
                  if (progress.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(context, progress),
                  ],
                ],
              ),
            ),
            actions: _buildActions(context, progress),
          ),
        );
      },
      loading: () => const AlertDialog(
        title: Text('Exportando dados'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando exportação...'),
            ],
          ),
        ),
      ),
      error: (error, _) => AlertDialog(
        title: const Text('Erro'),
        content: Text('Erro ao exportar: $error'),
        actions: [
          TextButton(
            onPressed: _closeDialog,
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ExportProgress progress) {
    if (progress.errorMessage != null) {
      return const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 64,
      );
    }

    if (progress.isCompleted) {
      return const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 64,
      );
    }

    return Column(
      children: [
        CircularProgressIndicator(
          value: progress.percentage / 100,
          strokeWidth: 6,
        ),
        const SizedBox(height: 8),
        Text(
          '${progress.percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTask(BuildContext context, ExportProgress progress) {
    return Text(
      progress.currentTask,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTimeRemaining(BuildContext context, ExportProgress progress) {
    return Text(
      progress.estimatedTimeRemaining!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(BuildContext context, ExportProgress progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Erro na exportação',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            progress.errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ExportProgress progress) {
    if (progress.errorMessage != null) {
      return [
        TextButton(
          onPressed: _closeDialog,
          child: const Text('Fechar'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(dataExportProvider.notifier).resetProgress();
            _hasStarted = false;
            _completedRequest = null;
            _startExport();
          },
          child: const Text('Tentar novamente'),
        ),
      ];
    }

    if (progress.isCompleted) {
      return [
        if (_completedRequest?.downloadUrl != null)
          TextButton(
            onPressed: () async {
              final success = await ref.read(dataExportProvider.notifier).downloadExport(_completedRequest!.id);

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao baixar arquivo'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Baixar'),
          ),
        ElevatedButton(
          onPressed: _closeDialog,
          child: const Text('Concluir'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () {
          _showCancelConfirmation(context);
        },
        child: const Text('Cancelar'),
      ),
    ];
  }

  Future<void> _showCancelConfirmation(BuildContext context) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cancelar exportação'),
        content: const Text(
          'Tem certeza que deseja cancelar a exportação? '
          'O progresso atual será perdido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && context.mounted) {
      ref.read(dataExportProvider.notifier).resetProgress();
      _closeDialog();
    }
  }
}

/// Simplified version for showing quick progress updates
/// Note: This is a Consumer widget wrapper for snackbar
class ExportProgressSnackBar extends ConsumerWidget {
  final String userId;
  final Set<DataType> dataTypes;
  final ExportFormat format;

  const ExportProgressSnackBar({
    super.key,
    required this.userId,
    required this.dataTypes,
    required this.format,
  });

  /// Shows a progress snackbar that updates automatically
  static void show(
    BuildContext context, {
    required String userId,
    required Set<DataType> dataTypes,
    required ExportFormat format,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ExportProgressSnackBar(
          userId: userId,
          dataTypes: dataTypes,
          format: format,
        ),
        duration: const Duration(seconds: 30), // Long duration for ongoing process
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportStateAsync = ref.watch(dataExportProvider);

    return exportStateAsync.when(
      data: (exportState) {
        final progress = exportState.currentProgress;

        if (progress.errorMessage != null) {
          return Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Erro: ${progress.errorMessage}'),
              ),
            ],
          );
        }

        if (progress.isCompleted) {
          return const Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Exportação concluída!'),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: progress.percentage / 100,
                strokeWidth: 2,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    progress.currentTask,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${progress.percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 16),
          Text('Inicializando...'),
        ],
      ),
      error: (error, _) => Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Erro: $error'),
          ),
        ],
      ),
    );
  }
}
