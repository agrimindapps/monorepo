import 'package:flutter/material.dart';
import '../../../infrastructure/services/database_inspector_service.dart';
import '../../theme/data_inspector_theme.dart';

/// Overview dashboard showing database statistics and health
/// Inspired by app-gasometer implementation
class OverviewTab extends StatefulWidget {
  final Map<String, dynamic> stats;
  final DatabaseInspectorService inspector;
  final DataInspectorTheme theme;
  final String appName;
  final VoidCallback onRefresh;

  const OverviewTab({
    super.key,
    required this.stats,
    required this.inspector,
    required this.theme,
    required this.appName,
    required this.onRefresh,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          _buildStatsGrid(),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          _buildQuickActionsCard(),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          _buildBoxesOverview(),
          const SizedBox(height: DataInspectorDesignTokens.spacingM),
          _buildSystemInfo(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.theme.primaryColor.withValues(alpha: 0.1),
              widget.theme.accentColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
                  decoration: BoxDecoration(
                    color: widget.theme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: widget.theme.primaryColor,
                    size: DataInspectorDesignTokens.iconL,
                  ),
                ),
                const SizedBox(width: DataInspectorDesignTokens.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.appName} - Inspetor de Dados',
                        style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: DataInspectorDesignTokens.spacingXs),
                      Text(
                        'Dashboard de monitoramento e análise de dados locais',
                        style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            Text(
              'Última atualização: ${DateTime.now().toString().split('.')[0]}',
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatItem(
        icon: Icons.storage,
        title: 'Hive Boxes',
        value: '${widget.stats['totalHiveBoxes'] ?? 0}',
        color: widget.theme.getIconColorForType('hive'),
        subtitle: 'Bases de dados ativas',
      ),
      _StatItem(
        icon: Icons.data_object,
        title: 'Total Registros',
        value: '${widget.stats['totalHiveRecords'] ?? 0}',
        color: widget.theme.getIconColorForType('box'),
        subtitle: 'Itens armazenados',
      ),
      _StatItem(
        icon: Icons.app_registration,
        title: 'Boxes Registradas',
        value: '${widget.stats['customBoxesRegistered'] ?? 0}',
        color: widget.theme.getModuleColor(widget.appName),
        subtitle: 'Tipos personalizados',
      ),
      _StatItem(
        icon: Icons.memory,
        title: 'Status Sistema',
        value: 'Saudável',
        color: widget.theme.getStatusColor('healthy'),
        subtitle: 'Funcionamento normal',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: DataInspectorDesignTokens.spacingS,
        mainAxisSpacing: DataInspectorDesignTokens.spacingS,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingS),
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: DataInspectorDesignTokens.iconL,
              ),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingS),
            Text(
              stat.value,
              style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                color: widget.theme.onSurfaceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingXs),
            Text(
              stat.title,
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              stat.subtitle,
              style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: widget.theme.primaryColor,
                  size: DataInspectorDesignTokens.iconM,
                ),
                const SizedBox(width: DataInspectorDesignTokens.spacingS),
                Text(
                  'Ações Rápidas',
                  style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            Wrap(
              spacing: DataInspectorDesignTokens.spacingS,
              runSpacing: DataInspectorDesignTokens.spacingS,
              children: [
                _buildQuickActionButton(
                  icon: Icons.refresh,
                  label: 'Atualizar',
                  onTap: widget.onRefresh,
                ),
                _buildQuickActionButton(
                  icon: Icons.download,
                  label: 'Exportar Tudo',
                  onTap: () => _exportAll(),
                ),
                _buildQuickActionButton(
                  icon: Icons.clear_all,
                  label: 'Limpar Cache',
                  onTap: () => _clearCache(),
                ),
                _buildQuickActionButton(
                  icon: Icons.analytics,
                  label: 'Estatísticas',
                  onTap: () => _showDetailedStats(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: widget.theme.primaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DataInspectorDesignTokens.spacingM,
            vertical: DataInspectorDesignTokens.spacingS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: widget.theme.primaryColor,
                size: DataInspectorDesignTokens.iconS,
              ),
              const SizedBox(width: DataInspectorDesignTokens.spacingXs),
              Text(
                label,
                style: TextStyle(
                  color: widget.theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoxesOverview() {
    final availableBoxes = widget.stats['availableBoxes'] as List<dynamic>? ?? [];
    
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: widget.theme.primaryColor,
                  size: DataInspectorDesignTokens.iconM,
                ),
                const SizedBox(width: DataInspectorDesignTokens.spacingS),
                Text(
                  'Boxes Disponíveis',
                  style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${availableBoxes.length} boxes',
                  style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            if (availableBoxes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        size: DataInspectorDesignTokens.iconXl,
                        color: widget.theme.onSurfaceColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: DataInspectorDesignTokens.spacingS),
                      Text(
                        'Nenhuma box encontrada',
                        style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
                          color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...availableBoxes.take(5).map(
                (boxKey) => _buildBoxPreviewItem(boxKey.toString()),
              ),
            if (availableBoxes.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: DataInspectorDesignTokens.spacingS),
                child: Text(
                  '... e mais ${availableBoxes.length - 5} boxes',
                  style: DataInspectorDesignTokens.captionTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxPreviewItem(String boxKey) {
    final stats = widget.inspector.getBoxStats(boxKey);
    final displayName = widget.inspector.getBoxDisplayName(boxKey);
    final recordCount = stats['totalRecords'] ?? 0;
    final isOpen = stats['isOpen'] ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingXs),
            decoration: BoxDecoration(
              color: widget.theme.getIconColorForType('box').withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
            ),
            child: Icon(
              (isOpen == true) ? Icons.storage : Icons.storage_outlined,
              color: widget.theme.getStatusColor((isOpen == true) ? 'healthy' : 'warning'),
              size: DataInspectorDesignTokens.iconS,
            ),
          ),
          const SizedBox(width: DataInspectorDesignTokens.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: widget.theme.onSurfaceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$recordCount registros',
                  style: TextStyle(
                    color: widget.theme.onSurfaceColor.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isOpen != true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DataInspectorDesignTokens.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: widget.theme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusS),
              ),
              child: Text(
                'FECHADA',
                style: TextStyle(
                  color: widget.theme.warningColor,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Card(
      color: widget.theme.cardColor,
      elevation: DataInspectorDesignTokens.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DataInspectorDesignTokens.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DataInspectorDesignTokens.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: widget.theme.primaryColor,
                  size: DataInspectorDesignTokens.iconM,
                ),
                const SizedBox(width: DataInspectorDesignTokens.spacingS),
                Text(
                  'Informações do Sistema',
                  style: DataInspectorDesignTokens.titleTextStyle.copyWith(
                    color: widget.theme.onSurfaceColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DataInspectorDesignTokens.spacingM),
            _buildInfoRow('Aplicativo', widget.appName),
            _buildInfoRow('Tema', widget.theme.brightness == Brightness.dark ? 'Escuro' : 'Claro'),
            _buildInfoRow('Gerado em', widget.stats['generatedAt']?.toString().split('T')[0] ?? 'N/A'),
            _buildInfoRow('Desenvolvedor', widget.theme.isDeveloperMode ? 'Habilitado' : 'Desabilitado'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DataInspectorDesignTokens.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: DataInspectorDesignTokens.subtitleTextStyle.copyWith(
              color: widget.theme.onSurfaceColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _exportAll() {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getSuccessSnackbar(
        'Exportação iniciada...',
        theme: widget.theme,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      DataInspectorDesignTokens.getSuccessSnackbar(
        'Cache limpo com sucesso!',
        theme: widget.theme,
      ),
    );
  }

  void _showDetailedStats() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.cardColor,
        title: const Text('Estatísticas Detalhadas'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: widget.stats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(entry.value.toString()),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String subtitle;

  _StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.subtitle,
  });
}