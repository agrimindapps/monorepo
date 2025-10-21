// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/widgets/appbar_widget.dart';
import 'package:app_minigames/models/game_statistics.dart';
import 'package:app_minigames/services/snake_persistence_service.dart';

/// Página que exibe estatísticas detalhadas do jogo da cobra
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  GameStatistics? _statistics;
  bool _isLoading = true;
  late SnakePersistenceService _persistenceService;

  @override
  void initState() {
    super.initState();
    _persistenceService = SharedPreferencesSnakePersistenceService();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _persistenceService.getDetailedGameStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statistics = GameStatistics.empty();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearStatistics() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Estatísticas'),
        content: const Text(
          'Tem certeza que deseja limpar todas as estatísticas? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _persistenceService.saveDetailedGameStatistics(GameStatistics.empty());
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header da página
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PageHeaderWidget(
              title: 'Estatísticas',
              subtitle: 'Acompanhe seu desempenho no Snake',
              icon: Icons.bar_chart,
              showBackButton: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadStatistics,
                  tooltip: 'Atualizar',
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearStatistics,
                  tooltip: 'Limpar Estatísticas',
                ),
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _statistics == null
                    ? _buildErrorState()
                    : _buildStatisticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar estatísticas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente novamente ou verifique sua conexão',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadStatistics,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final stats = _statistics!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSection(stats),
          const SizedBox(height: 24),
          _buildPerformanceSection(stats),
          const SizedBox(height: 24),
          _buildFoodStatsSection(stats),
          const SizedBox(height: 24),
          _buildTimeSection(stats),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(GameStatistics stats) {
    return _buildSection(
      title: 'Visão Geral',
      icon: Icons.dashboard,
      children: [
        _buildStatCard(
          'Jogos Jogados',
          stats.totalGamesPlayed.toString(),
          Icons.gamepad,
          Colors.blue,
        ),
        _buildStatCard(
          'Melhor Pontuação',
          stats.bestScore.toString(),
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildStatCard(
          'Pontuação Média',
          stats.averageScore.toStringAsFixed(1),
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatCard(
          'Cobra Mais Longa',
          stats.longestSnake.toString(),
          Icons.straighten,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(GameStatistics stats) {
    return _buildSection(
      title: 'Performance',
      icon: Icons.analytics,
      children: [
        _buildStatCard(
          'Comidas Consumidas',
          stats.totalFoodEaten.toString(),
          Icons.restaurant,
          Colors.red,
        ),
        _buildStatCard(
          'Eficiência',
          '${stats.efficiency.toStringAsFixed(1)}/jogo',
          Icons.speed,
          Colors.orange,
        ),
        _buildStatCard(
          'Comida Favorita',
          stats.favoriteFoodType,
          Icons.favorite,
          Colors.pink,
        ),
        _buildStatCard(
          'Sessões Hoje',
          stats.totalSessionsToday.toString(),
          Icons.today,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildFoodStatsSection(GameStatistics stats) {
    if (stats.foodTypeStats.isEmpty) {
      return _buildSection(
        title: 'Estatísticas por Tipo de Comida',
        icon: Icons.pie_chart,
        children: [
          Center(
            child: Text(
              'Nenhuma comida consumida ainda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final sortedFoodStats = stats.foodTypeStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _buildSection(
      title: 'Estatísticas por Tipo de Comida',
      icon: Icons.pie_chart,
      children: sortedFoodStats.map((entry) {
        final percentage = (entry.value / stats.totalFoodEaten * 100);
        return _buildFoodStatRow(
          entry.key,
          entry.value,
          percentage,
        );
      }).toList(),
    );
  }

  Widget _buildTimeSection(GameStatistics stats) {
    return _buildSection(
      title: 'Tempo de Jogo',
      icon: Icons.access_time,
      children: [
        _buildStatCard(
          'Tempo Total',
          stats.formattedTotalTime,
          Icons.timer,
          Colors.indigo,
        ),
        _buildStatCard(
          'Tempo Médio/Jogo',
          stats.averageGameDuration,
          Icons.hourglass_empty,
          Colors.cyan,
        ),
        _buildStatCard(
          'Última Partida',
          _formatLastPlayed(stats.lastPlayedDate),
          Icons.history,
          Colors.brown,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodStatRow(String foodType, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              foodType,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastPlayed(DateTime lastPlayed) {
    final now = DateTime.now();
    final difference = now.difference(lastPlayed);

    if (difference.inDays > 0) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
