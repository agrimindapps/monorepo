/// Widget para exibição de estatísticas do jogo Ping Pong
/// 
/// Fornece uma interface rica para visualizar estatísticas da sessão,
/// histórico de jogos e insights de performance do jogador.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/services/statistics_manager.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Widget principal para exibição de estatísticas
class StatisticsDisplay extends StatefulWidget {
  /// Gerenciador de estatísticas
  final StatisticsManager statisticsManager;
  
  /// Gerenciador de temas
  final ThemeManager themeManager;
  
  /// Tipo de estatísticas a exibir
  final StatisticsDisplayType displayType;
  
  /// Callback para voltar
  final VoidCallback? onBack;
  
  const StatisticsDisplay({
    super.key,
    required this.statisticsManager,
    required this.themeManager,
    this.displayType = StatisticsDisplayType.overview,
    this.onBack,
  });
  
  @override
  State<StatisticsDisplay> createState() => _StatisticsDisplayState();
}

class _StatisticsDisplayState extends State<StatisticsDisplay>
    with TickerProviderStateMixin {
  
  /// Controlador de tabs
  late TabController _tabController;
  
  /// Controlador de animação
  late AnimationController _animationController;
  
  /// Animação de fade
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 4, vsync: this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    widget.statisticsManager.addListener(_onStatsChanged);
  }
  
  @override
  void dispose() {
    widget.statisticsManager.removeListener(_onStatsChanged);
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onStatsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          title: Text(
            'Estatísticas',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.onSurface),
            onPressed: widget.onBack,
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: colors.accent,
            unselectedLabelColor: colors.onSurface.withValues(alpha: 0.6),
            indicatorColor: colors.accent,
            tabs: const [
              Tab(text: 'Visão Geral', icon: Icon(Icons.dashboard)),
              Tab(text: 'Sessão', icon: Icon(Icons.timer)),
              Tab(text: 'Histórico', icon: Icon(Icons.history)),
              Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(colors, typography, spacing),
            _buildSessionTab(colors, typography, spacing),
            _buildHistoricalTab(colors, typography, spacing),
            _buildInsightsTab(colors, typography, spacing),
          ],
        ),
      ),
    );
  }
  
  /// Constrói tab de visão geral
  Widget _buildOverviewTab(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final sessionStats = widget.statisticsManager.getCurrentSessionStats();
    final historicalStats = widget.statisticsManager.getHistoricalStats();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats cards
          _buildQuickStatsGrid(sessionStats, historicalStats, colors, typography, spacing),
          
          SizedBox(height: spacing.large),
          
          // Current game status
          if (widget.statisticsManager.currentSession.currentGame != null)
            _buildCurrentGameCard(colors, typography, spacing),
          
          SizedBox(height: spacing.large),
          
          // Performance overview
          _buildPerformanceOverview(historicalStats, colors, typography, spacing),
        ],
      ),
    );
  }
  
  /// Constrói grid de estatísticas rápidas
  Widget _buildQuickStatsGrid(
    Map<String, dynamic> sessionStats,
    Map<String, dynamic> historicalStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: spacing.medium,
      mainAxisSpacing: spacing.medium,
      children: [
        _buildStatCard(
          title: 'Jogos Hoje',
          value: sessionStats['gamesPlayed']?.toString() ?? '0',
          icon: Icons.sports_tennis,
          color: colors.accent,
          colors: colors,
          typography: typography,
          spacing: spacing,
        ),
        _buildStatCard(
          title: 'Taxa de Vitória',
          value: '${((sessionStats['winRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
          icon: Icons.emoji_events,
          color: Colors.amber,
          colors: colors,
          typography: typography,
          spacing: spacing,
        ),
        _buildStatCard(
          title: 'Total de Jogos',
          value: historicalStats['totalGames']?.toString() ?? '0',
          icon: Icons.bar_chart,
          color: colors.primary,
          colors: colors,
          typography: typography,
          spacing: spacing,
        ),
        _buildStatCard(
          title: 'Melhor Sequência',
          value: historicalStats['bestWinStreak']?.toString() ?? '0',
          icon: Icons.trending_up,
          color: Colors.green,
          colors: colors,
          typography: typography,
          spacing: spacing,
        ),
      ],
    );
  }
  
  /// Constrói card de estatística
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeColors colors,
    required ResponsiveTypography typography,
    required ResponsiveSpacing spacing,
  }) {
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          SizedBox(height: spacing.small),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.tiny),
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.7),
              fontSize: typography.captionSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Constrói card do jogo atual
  Widget _buildCurrentGameCard(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final currentGame = widget.statisticsManager.currentSession.currentGame!;
    
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_filled, color: colors.accent),
              SizedBox(width: spacing.small),
              Text(
                'Jogo em Andamento',
                style: TextStyle(
                  color: colors.accent,
                  fontSize: typography.bodySize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGameStatColumn(
                'Placar',
                '${currentGame.playerScore} x ${currentGame.aiScore}',
                colors,
                typography,
              ),
              _buildGameStatColumn(
                'Duração',
                _formatDuration(currentGame.duration),
                colors,
                typography,
              ),
              _buildGameStatColumn(
                'Hits',
                currentGame.totalHits.toString(),
                colors,
                typography,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Constrói coluna de estatística do jogo
  Widget _buildGameStatColumn(
    String label,
    String value,
    ThemeColors colors,
    ResponsiveTypography typography,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.bodySize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.7),
            fontSize: typography.captionSize,
          ),
        ),
      ],
    );
  }
  
  /// Constrói visão geral de performance
  Widget _buildPerformanceOverview(
    Map<String, dynamic> historicalStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Geral',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.bodySize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          _buildStatRow(
            'Taxa de Vitória',
            '${((historicalStats['winRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
            colors,
            typography,
          ),
          _buildStatRow(
            'Tempo Total Jogado',
            '${historicalStats['totalPlayTime']} horas',
            colors,
            typography,
          ),
          _buildStatRow(
            'Melhor Rally',
            historicalStats['bestRally']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Velocidade Máxima',
            '${historicalStats['maxBallSpeed']} m/s',
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói linha de estatística
  Widget _buildStatRow(
    String label,
    String value,
    ThemeColors colors,
    ResponsiveTypography typography,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.7),
              fontSize: typography.captionSize,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.captionSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de sessão
  Widget _buildSessionTab(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final sessionStats = widget.statisticsManager.getCurrentSessionStats();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sessão Atual',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          
          // Session summary
          _buildSessionSummary(sessionStats, colors, typography, spacing),
          
          SizedBox(height: spacing.large),
          
          // Recent games
          _buildRecentGames(colors, typography, spacing),
        ],
      ),
    );
  }
  
  /// Constrói resumo da sessão
  Widget _buildSessionSummary(
    Map<String, dynamic> sessionStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStatRow(
            'Duração da Sessão',
            '${sessionStats['duration']} minutos',
            colors,
            typography,
          ),
          _buildStatRow(
            'Jogos Completados',
            sessionStats['gamesPlayed']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Vitórias',
            sessionStats['wins']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Derrotas',
            sessionStats['losses']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Duração Média por Jogo',
            '${sessionStats['averageGameDuration']} segundos',
            colors,
            typography,
          ),
          _buildStatRow(
            'Total de Hits',
            sessionStats['totalHits']?.toString() ?? '0',
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói lista de jogos recentes
  Widget _buildRecentGames(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final recentGames = widget.statisticsManager.currentSession.completedGames.reversed.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jogos Recentes',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.bodySize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing.medium),
        if (recentGames.isEmpty)
          Text(
            'Nenhum jogo completado ainda',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.6),
              fontSize: typography.captionSize,
            ),
          )
        else
          ...recentGames.map((game) => _buildGameTile(game, colors, typography, spacing)),
      ],
    );
  }
  
  /// Constrói tile de jogo
  Widget _buildGameTile(GameStats game, ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing.small),
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: game.playerWon ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            game.playerWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: game.playerWon ? Colors.green : Colors.red,
          ),
          SizedBox(width: spacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.playerScore} x ${game.aiScore}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.captionSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${game.difficulty.name} • ${_formatDuration(game.duration)}',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: typography.captionSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab histórica
  Widget _buildHistoricalTab(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final historicalStats = widget.statisticsManager.getHistoricalStats();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas Históricas',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          
          // Overall stats
          _buildOverallStats(historicalStats, colors, typography, spacing),
          
          SizedBox(height: spacing.large),
          
          // Stats by difficulty
          _buildStatsByDifficulty(historicalStats, colors, typography, spacing),
          
          SizedBox(height: spacing.large),
          
          // Stats by game mode
          _buildStatsByGameMode(historicalStats, colors, typography, spacing),
        ],
      ),
    );
  }
  
  /// Constrói estatísticas gerais
  Widget _buildOverallStats(
    Map<String, dynamic> historicalStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geral',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.bodySize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          _buildStatRow(
            'Jogos Totais',
            historicalStats['totalGames']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Vitórias',
            historicalStats['totalWins']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Derrotas',
            historicalStats['totalLosses']?.toString() ?? '0',
            colors,
            typography,
          ),
          _buildStatRow(
            'Taxa de Vitória',
            '${((historicalStats['winRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
            colors,
            typography,
          ),
          _buildStatRow(
            'Sequência Atual',
            historicalStats['currentWinStreak']?.toString() ?? '0',
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói estatísticas por dificuldade
  Widget _buildStatsByDifficulty(
    Map<String, dynamic> historicalStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    final statsByDifficulty = historicalStats['statsByDifficulty'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Dificuldade',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.bodySize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing.medium),
        ...statsByDifficulty.entries.map((entry) {
          final difficultyName = entry.key;
          final stats = entry.value as Map<String, dynamic>;
          
          return Container(
            margin: EdgeInsets.only(bottom: spacing.small),
            padding: EdgeInsets.all(spacing.medium),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficultyName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.captionSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing.small),
                _buildStatRow(
                  'Jogos',
                  stats['gamesPlayed']?.toString() ?? '0',
                  colors,
                  typography,
                ),
                _buildStatRow(
                  'Vitórias',
                  stats['wins']?.toString() ?? '0',
                  colors,
                  typography,
                ),
                _buildStatRow(
                  'Taxa',
                  '${((stats['winRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                  colors,
                  typography,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  /// Constrói estatísticas por modo de jogo
  Widget _buildStatsByGameMode(
    Map<String, dynamic> historicalStats,
    ThemeColors colors,
    ResponsiveTypography typography,
    ResponsiveSpacing spacing,
  ) {
    final statsByGameMode = historicalStats['statsByGameMode'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Modo de Jogo',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.bodySize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: spacing.medium),
        ...statsByGameMode.entries.map((entry) {
          final modeName = entry.key;
          final stats = entry.value as Map<String, dynamic>;
          
          return Container(
            margin: EdgeInsets.only(bottom: spacing.small),
            padding: EdgeInsets.all(spacing.medium),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modeName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.captionSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing.small),
                _buildStatRow(
                  'Jogos',
                  stats['gamesPlayed']?.toString() ?? '0',
                  colors,
                  typography,
                ),
                _buildStatRow(
                  'Vitórias',
                  stats['wins']?.toString() ?? '0',
                  colors,
                  typography,
                ),
                _buildStatRow(
                  'Taxa',
                  '${((stats['winRate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                  colors,
                  typography,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  /// Constrói tab de insights
  Widget _buildInsightsTab(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final insights = widget.statisticsManager.getPerformanceInsights();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights de Performance',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.titleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          
          if (insights.isEmpty)
            Container(
              padding: EdgeInsets.all(spacing.large),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.onSurface.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: spacing.medium),
                  Text(
                    'Jogue mais para ver insights!',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.7),
                      fontSize: typography.bodySize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Complete alguns jogos para receber dicas personalizadas sobre sua performance.',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: typography.captionSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...insights.map((insight) => _buildInsightCard(insight, colors, typography, spacing)),
        ],
      ),
    );
  }
  
  /// Constrói card de insight
  Widget _buildInsightCard(PerformanceInsight insight, ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    Color insightColor;
    IconData insightIcon;
    
    switch (insight.type) {
      case InsightType.positive:
        insightColor = Colors.green;
        insightIcon = Icons.thumb_up;
        break;
      case InsightType.improvement:
        insightColor = Colors.orange;
        insightIcon = Icons.trending_up;
        break;
      case InsightType.achievement:
        insightColor = Colors.purple;
        insightIcon = Icons.emoji_events;
        break;
      case InsightType.milestone:
        insightColor = Colors.blue;
        insightIcon = Icons.flag;
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: spacing.medium),
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insightColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            insightIcon,
            size: 32,
            color: insightColor,
          ),
          SizedBox(width: spacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.bodySize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing.tiny),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    fontSize: typography.captionSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Formata duração
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Tipos de exibição de estatísticas
enum StatisticsDisplayType {
  overview,
  session,
  historical,
  insights,
}
