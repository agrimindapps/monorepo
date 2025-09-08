import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/export_progress.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/entities/export_result.dart';
import '../providers/data_export_provider.dart';
import 'export_customization_dialog.dart';
import 'export_progress_dialog.dart';

/// Seção de exportação de dados para a ProfilePage
class ExportDataSection extends StatefulWidget {
  const ExportDataSection({super.key});

  @override
  State<ExportDataSection> createState() => _ExportDataSectionState();
}

class _ExportDataSectionState extends State<ExportDataSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authProvider = context.read<AuthProvider>();
    final exportProvider = context.read<DataExportProvider>();
    
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      exportProvider.checkCanExport(userId);
      exportProvider.loadExportHistory(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DataExportProvider>(
      builder: (context, authProvider, exportProvider, child) {
        final user = authProvider.currentUser;
        final isAnonymous = authProvider.isAnonymous;
        
        if (isAnonymous || user?.id == null) {
          return const SizedBox.shrink();
        }

        return _buildSection(
          context,
          title: 'Meus Dados',
          icon: Icons.download,
          children: [
            _buildExportCard(context, exportProvider, user!.id!),
            if (exportProvider.exportHistory.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHistoryCard(context, exportProvider),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusCard),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: GasometerDesignTokens.iconSizeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(
    BuildContext context, 
    DataExportProvider exportProvider, 
    String userId,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Exportação de Dados LGPD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Faça o download de todos os seus dados pessoais armazenados no aplicativo. Esta funcionalidade está em conformidade com a Lei Geral de Proteção de Dados (LGPD).',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Estado baseado no provider
          if (exportProvider.isExporting)
            _buildExportingState(context, exportProvider)
          else if (!exportProvider.canExport)
            _buildRateLimitedState(context)
          else
            _buildReadyState(context, userId, exportProvider),
          
          // Mostrar erro se houver
          if (exportProvider.hasError) ...[
            const SizedBox(height: 12),
            _buildErrorState(context, exportProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildReadyState(
    BuildContext context, 
    String userId, 
    DataExportProvider exportProvider,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showExportDialog(userId),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exportar Meus Dados'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusButton),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Você pode exportar seus dados uma vez por dia',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExportingState(
    BuildContext context, 
    DataExportProvider exportProvider,
  ) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (exportProvider.currentProgress?.percentage ?? 0) / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          exportProvider.currentProgress?.currentTask ?? 'Processando...',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _showProgressDialog(exportProvider.currentProgress),
          child: const Text('Ver Detalhes'),
        ),
      ],
    );
  }

  Widget _buildRateLimitedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: 8),
          Text(
            'Limite Atingido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Você já fez uma exportação nas últimas 24 horas. Tente novamente amanhã.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, 
    DataExportProvider exportProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exportProvider.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: exportProvider.clearError,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, 
    DataExportProvider exportProvider,
  ) {
    final history = exportProvider.exportHistory.take(3).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Exportações Recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...history.map((result) => _buildHistoryItem(context, result)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ExportResult result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.cancel,
            color: result.success ? Colors.green : Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatDate(result.completedAt),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          if (result.success && result.filePath != null)
            TextButton(
              onPressed: () => _shareFile(result.filePath!, result.metadata?.id ?? 'export'),
              child: const Text('Compartilhar'),
            ),
        ],
      ),
    );
  }

  // Métodos auxiliares

  void _showExportDialog(String userId) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (context) => ExportCustomizationDialog(
        userId: userId,
        onStartExport: (request) => _startExport(userId, request),
      ),
    );
  }

  void _showProgressDialog(ExportProgress? progress) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(
        progress: progress,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _startExport(String userId, ExportRequest request) async {
    final exportProvider = context.read<DataExportProvider>();
    
    final success = await exportProvider.startExport(
      userId: userId,
      categories: request.includedCategories,
      startDate: request.startDate,
      endDate: request.endDate,
      includeAttachments: request.includeAttachments,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Exportação concluída com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Compartilhar',
            textColor: Colors.white,
            onPressed: () {
              final result = exportProvider.lastResult;
              if (result?.filePath != null) {
                _shareFile(result!.filePath!, 'gasometer_export');
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _shareFile(String filePath, String fileName) async {
    final exportProvider = context.read<DataExportProvider>();
    await exportProvider.shareExportFile(filePath, '$fileName.json');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}