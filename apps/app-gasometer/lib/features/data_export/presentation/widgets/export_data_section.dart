import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/providers/auth_provider.dart';
import '../providers/data_export_provider.dart';

/// Seção de exportação de dados para a ProfilePage
class ExportDataSection extends ConsumerStatefulWidget {
  const ExportDataSection({super.key});

  @override
  ConsumerState<ExportDataSection> createState() => _ExportDataSectionState();
}

class _ExportDataSectionState extends ConsumerState<ExportDataSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authState = ref.read(authNotifierProvider);
    final exportProvider = provider.Provider.of<DataExportProvider>(context, listen: false);

    final userId = authState.currentUser?.id;
    if (userId != null) {
      exportProvider.checkCanExport(userId);
      exportProvider.loadExportHistory(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return provider.Consumer<DataExportProvider>(
      builder: (context, exportProvider, child) {
        final user = authState.currentUser;
        final isAnonymous = authState.isAnonymous;

        if (isAnonymous || user == null) {
          return const SizedBox.shrink();
        }

        return _buildSection(
          context,
          title: 'Meus Dados',
          icon: Icons.download,
          children: [
            _buildDataActionsContainer(context, exportProvider, user.id),
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

  Widget _buildDataActionsContainer(
    BuildContext context, 
    DataExportProvider exportProvider, 
    String userId,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          _buildDataActionItem(
            context,
            icon: Icons.code,
            title: 'Exportar JSON',
            subtitle: 'Baixar dados em formato JSON',
            onTap: () => _handleExportJson(context, userId, exportProvider),
            isFirst: true,
          ),
          _buildDataActionItem(
            context,
            icon: Icons.table_chart,
            title: 'Exportar CSV',
            subtitle: 'Baixar dados em formato CSV',
            onTap: () => _handleExportCsv(context, userId, exportProvider),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDataActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isFirst
            ? const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )
            : isLast
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  )
                : BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Métodos de ação

  Future<void> _handleExportJson(
    BuildContext context, 
    String userId, 
    DataExportProvider exportProvider,
  ) async {
    HapticFeedback.lightImpact();
    
    if (!exportProvider.canExport) {
      _showLimitMessage(context);
      return;
    }

    try {
      final success = await exportProvider.startExport(
        userId: userId,
        categories: ['all'], // Exportar todas as categorias
        startDate: null,
        endDate: null,
        includeAttachments: false,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Arquivo JSON exportado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Compartilhar',
              textColor: Colors.white,
              onPressed: () {
                final result = exportProvider.lastResult;
                if (result?.filePath != null) {
                  _shareFile(result!.filePath!, 'dados_json');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleExportCsv(
    BuildContext context, 
    String userId, 
    DataExportProvider exportProvider,
  ) async {
    HapticFeedback.lightImpact();
    
    if (!exportProvider.canExport) {
      _showLimitMessage(context);
      return;
    }

    // Por enquanto mostrar mensagem de funcionalidade em desenvolvimento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exportação CSV em desenvolvimento'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLimitMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você já fez uma exportação nas últimas 24 horas'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareFile(String filePath, String fileName) async {
    final exportProvider = provider.Provider.of<DataExportProvider>(context, listen: false);
    await exportProvider.shareExportFile(filePath, '$fileName.json');
  }
}