import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget para sincronização e exportação de dados
/// Responsabilidade: Display e ações de sync/export
class ProfileDataSyncSection extends ConsumerWidget {
  const ProfileDataSyncSection({
    required this.authData,
    required this.onExportDataJson,
    required this.onExportDataCsv,
    required this.onSyncData,
    super.key,
  });

  final dynamic authData;
  final VoidCallback onExportDataJson;
  final VoidCallback onExportDataCsv;
  final VoidCallback onSyncData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Dados e Sincronização',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Dados Sincronizados'),
                subtitle: const Text('Todos os dados estão atualizados'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onSyncData,
                ),
                onTap: onSyncData,
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.data_object,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar como JSON'),
                subtitle: const Text(
                  'Baixar dados em formato estruturado JSON',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: onExportDataJson,
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar como CSV'),
                subtitle: const Text('Baixar dados em formato planilha CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onExportDataCsv,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
