import 'package:core/core.dart' hide deviceManagementProvider, DeviceManagementState;
import 'package:flutter/material.dart';

import '../../../../core/providers/device_management_providers.dart';
import '../../data/models/device_model.dart';

/// Widget que exibe estatísticas detalhadas dos dispositivos
/// Mostra informações analíticas e recomendações para o usuário
class DeviceStatisticsWidget extends ConsumerStatefulWidget {
  const DeviceStatisticsWidget({super.key});

  @override
  ConsumerState<DeviceStatisticsWidget> createState() => _DeviceStatisticsWidgetState();
}

class _DeviceStatisticsWidgetState extends ConsumerState<DeviceStatisticsWidget> {
  @override
  void initState() {
    super.initState();
    // Load statistics on init
    Future.microtask(() => ref.read(deviceManagementProvider.notifier).loadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final deviceManagementAsync = ref.watch(deviceManagementProvider);

    return deviceManagementAsync.when(
      data: (deviceState) {
        if (deviceState.statistics == null) {
          return _buildEmptyState(context);
        }

        final stats = deviceState.statistics!;

        return RefreshIndicator(
          onRefresh: () => ref.read(deviceManagementProvider.notifier).loadStatistics(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Resumo geral
              _buildOverviewCard(context, stats),

              const SizedBox(height: 16),

              // Distribuição por plataforma
              _buildPlatformDistribution(context, stats),

              const SizedBox(height: 16),

              // Atividade recente
              _buildActivitySection(context, stats),

              const SizedBox(height: 16),

              // Recomendações (se disponível)
              _buildRecommendations(context, stats),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro ao carregar estatísticas: $error')),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Estatísticas não disponíveis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre pelo menos um dispositivo para ver estatísticas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, DeviceStatisticsModel stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Resumo Geral',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid de métricas
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total',
                    stats.totalDevices.toString(),
                    Icons.devices,
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Ativos',
                    stats.activeDevices.toString(),
                    Icons.verified,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Inativos',
                    (stats.totalDevices - stats.activeDevices).toString(),
                    Icons.block,
                    Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Limite',
                    '3',
                    Icons.security,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Barra de progresso do limite
            _buildLimitProgressBar(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitProgressBar(
    BuildContext context,
    DeviceStatisticsModel stats,
  ) {
    final int active = stats.activeDevices;
    const int limit = 3;
    final double progress = active / limit;

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = Colors.red;
    } else if (progress >= 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uso do Limite',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            Text(
              '$active/$limit dispositivos',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      ],
    );
  }

  Widget _buildPlatformDistribution(
    BuildContext context,
    DeviceStatisticsModel stats,
  ) {
    if (stats.devicesByPlatform.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Distribuição por Plataforma',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...stats.devicesByPlatform.entries.map(
              (entry) => _buildPlatformItem(
                context,
                entry.key,
                entry.value,
                stats.totalDevices,
              ),
            ),

            const SizedBox(height: 12),

            // Insight sobre diversidade de plataformas
            if (stats.plantisMetrics != null)
              _buildPlatformInsight(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformItem(
    BuildContext context,
    String platform,
    int count,
    int total,
  ) {
    final percentage = (count / total * 100).round();
    final platformIcon = _getPlatformIcon(platform);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(platformIcon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: count / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count ($percentage%)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return '🍎';
      case 'android':
        return '🤖';
      case 'web':
        return '🌐';
      case 'windows':
        return '🖥️';
      case 'macos':
        return '💻';
      default:
        return '📱';
    }
  }

  Widget _buildPlatformInsight(BuildContext context, stats) {
    final metrics = stats.plantisMetrics;
    final mostUsed = metrics['mostUsedPlatform'] as String?;
    final diversity = metrics['platformDiversity'] as int? ?? 0;

    if (mostUsed == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              diversity > 1
                  ? 'Você usa $diversity plataformas diferentes. $mostUsed é a mais usada.'
                  : 'Todos os seus dispositivos são $mostUsed.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context, stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Atividade Recente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (stats.lastActiveDevice != null) ...[
              _buildActivityItem(
                context,
                'Último Dispositivo Ativo',
                (stats.lastActiveDevice as DeviceModel).name,
                'há ${_formatTimeSince((stats.lastActiveDevice as DeviceModel).lastActiveAt)}',
                Icons.smartphone,
              ),
            ],

            if (stats.oldestDevice != null) ...[
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                'Dispositivo Mais Antigo',
                (stats.oldestDevice as DeviceModel).name,
                'desde ${DateFormat('dd/MM/yyyy').format((stats.oldestDevice as DeviceModel).firstLoginAt)}',
                Icons.history,
              ),
            ],

            if (stats.newestDevice != null) ...[
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                'Dispositivo Mais Recente',
                (stats.newestDevice as DeviceModel).name,
                'desde ${DateFormat('dd/MM/yyyy').format((stats.newestDevice as DeviceModel).firstLoginAt)}',
                Icons.new_releases,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String label,
    String deviceName,
    String timeInfo,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          timeInfo,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(BuildContext context, stats) {
    if (stats.plantisMetrics == null) return const SizedBox.shrink();

    final metrics = stats.plantisMetrics;
    final recommendations = metrics['recommendations'] as List<String>? ?? [];

    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tudo em ordem!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seus dispositivos estão bem gerenciados.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.recommend, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Recomendações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...recommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeSince(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'poucos segundos';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana' : '$weeks semanas';
    }
  }
}
