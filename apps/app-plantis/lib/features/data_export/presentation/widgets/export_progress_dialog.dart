import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/export_request.dart';
import '../notifiers/data_export_notifier.dart';

/// Dialog that shows export progress for Plantis data
class ExportProgressDialog extends ConsumerStatefulWidget {
  final ExportRequest request;

  const ExportProgressDialog({super.key, required this.request});

  @override
  ConsumerState<ExportProgressDialog> createState() => _ExportProgressDialogState();
}

class _ExportProgressDialogState extends ConsumerState<ExportProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Builder(
            builder: (context) {
              final asyncValue = ref.watch(dataExportNotifierProvider);

              return asyncValue.when(
                data: (state) {
                  final progress = state.currentProgress;
                  return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [PlantisColors.primary, PlantisColors.leaf],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              progress.isCompleted
                                  ? 'Exportação Concluída!'
                                  : progress.errorMessage != null
                                  ? 'Erro na Exportação'
                                  : 'Exportando Dados',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    progress.errorMessage != null
                                        ? Colors.red
                                        : PlantisColors.primary,
                              ),
                            ),
                            Text(
                              progress.isCompleted
                                  ? 'Seus dados estão prontos!'
                                  : progress.errorMessage != null
                                  ? 'Ocorreu um problema'
                                  : 'Aguarde enquanto processamos...',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (progress.errorMessage != null)
                    _buildErrorContent(
                      context,
                      progress.errorMessage!,
                    )
                  else if (progress.isCompleted)
                    _buildCompletedContent(context, widget.request)
                  else
                    _buildProgressContent(context, progress),

                  const SizedBox(height: 24),
                  _buildActionButtons(context, progress),
                ],
              );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Erro: $error'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContent(BuildContext context, ExportProgress progress) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress.percentage / 100,
                strokeWidth: 6,
                backgroundColor: PlantisColors.primary.withAlpha(50),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PlantisColors.primary,
                ),
              ),
            ),
            Text(
              '${progress.percentage.toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: PlantisColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PlantisColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantisColors.primary.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.task_alt, color: PlantisColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      progress.currentTask,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: PlantisColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              if (progress.estimatedTimeRemaining != null) ...[
                const SizedBox(height: 8),
                Text(
                  progress.estimatedTimeRemaining!,
                  style: TextStyle(
                    fontSize: 12,
                    color: PlantisColors.primary.withAlpha(180),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedContent(
    BuildContext context,
    ExportRequest request,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: PlantisColors.leaf.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: PlantisColors.leaf,
            size: 48,
          ),
        ),

        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PlantisColors.leaf.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantisColors.leaf.withAlpha(60)),
          ),
          child: Column(
            children: [
              const Text(
                'Exportação realizada com sucesso!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PlantisColors.leaf,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Seus dados foram compilados no formato ${request.format.displayName}.',
                style: TextStyle(
                  fontSize: 13,
                  color: PlantisColors.leaf.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                context,
                Icons.folder_outlined,
                'Formato',
                request.format.displayName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                context,
                Icons.data_usage,
                'Tipos de dados',
                '${request.dataTypes.length}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(100),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    String errorMessage,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        ),

        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withAlpha(60)),
          ),
          child: Column(
            children: [
              const Text(
                'Erro durante a exportação',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ExportProgress progress,
  ) {
    if (progress.errorMessage != null) {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ref.read(dataExportNotifierProvider.notifier).resetProgress();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ),
        ],
      );
    }

    if (progress.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await ref.read(dataExportNotifierProvider.notifier).downloadExport(
                  widget.request.id,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download iniciado com sucesso!'),
                      backgroundColor: PlantisColors.leaf,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PlantisColors.leaf,
                foregroundColor: Colors.white,
              ),
              child: const Text('Baixar'),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
    );
  }
}
