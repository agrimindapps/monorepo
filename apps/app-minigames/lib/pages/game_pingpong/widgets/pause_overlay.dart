/// Widget de overlay de pausa para o jogo Ping Pong
/// 
/// Fornece uma interface rica para o estado de pausa,
/// mostrando informações do jogo e opções de controle.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/services/pause_manager.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Widget de overlay de pausa
class PauseOverlay extends StatefulWidget {
  /// Gerenciador de pausa
  final PauseManager pauseManager;
  
  /// Gerenciador de temas
  final ThemeManager themeManager;
  
  /// Callback para retomar jogo
  final VoidCallback? onResume;
  
  /// Callback para reiniciar jogo
  final VoidCallback? onRestart;
  
  /// Callback para ir ao menu
  final VoidCallback? onMainMenu;
  
  /// Callback para configurações
  final VoidCallback? onSettings;
  
  const PauseOverlay({
    super.key,
    required this.pauseManager,
    required this.themeManager,
    this.onResume,
    this.onRestart,
    this.onMainMenu,
    this.onSettings,
  });
  
  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay>
    with TickerProviderStateMixin {
  
  /// Controlador de animação
  late AnimationController _animationController;
  
  /// Controlador de pulsação para ícone de pausa
  late AnimationController _pulseController;
  
  /// Animações
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Animação principal
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Animação de pulsação
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Inicia animações
    _animationController.forward();
    _pulseController.repeat(reverse: true);
    
    widget.pauseManager.addListener(_onPauseManagerChanged);
  }
  
  @override
  void dispose() {
    widget.pauseManager.removeListener(_onPauseManagerChanged);
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _onPauseManagerChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final pauseInfo = widget.pauseManager.getPauseInfo();
    final statistics = widget.pauseManager.getStatistics();
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  margin: EdgeInsets.all(spacing.large),
                  padding: EdgeInsets.all(spacing.large),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cabeçalho com ícone de pausa
                      _buildHeader(colors, typography, spacing),
                      
                      SizedBox(height: spacing.large),
                      
                      // Informações da pausa
                      _buildPauseInfo(pauseInfo, colors, typography, spacing),
                      
                      SizedBox(height: spacing.large),
                      
                      // Estatísticas da sessão
                      _buildSessionStats(statistics, colors, typography, spacing),
                      
                      SizedBox(height: spacing.large),
                      
                      // Botões de ação
                      _buildActionButtons(colors, typography, spacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Constrói cabeçalho do overlay
  Widget _buildHeader(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Icon(
                Icons.pause_circle_filled,
                size: 64,
                color: colors.accent,
              ),
            );
          },
        ),
        SizedBox(height: spacing.medium),
        Text(
          'Jogo Pausado',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Constrói informações da pausa
  Widget _buildPauseInfo(Map<String, dynamic> pauseInfo, ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    final pauseReason = widget.pauseManager.pauseReason;
    
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                pauseReason.icon,
                color: colors.accent,
                size: 20,
              ),
              SizedBox(width: spacing.small),
              Expanded(
                child: Text(
                  pauseReason.name,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.bodySize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.small),
          Text(
            pauseReason.description,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.7),
              fontSize: typography.captionSize,
            ),
            textAlign: TextAlign.center,
          ),
          if (pauseInfo['activePauses'] > 1) ...[
            SizedBox(height: spacing.small),
            Text(
              '${pauseInfo['activePauses']} pausas ativas',
              style: TextStyle(
                color: colors.accent,
                fontSize: typography.captionSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Constrói estatísticas da sessão
  Widget _buildSessionStats(PauseStatistics statistics, ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Estatísticas da Sessão',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: typography.bodySize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Tempo Total',
                _formatDuration(statistics.totalGameTime),
                Icons.timer,
                colors,
                typography,
              ),
              _buildStatColumn(
                'Tempo Jogando',
                _formatDuration(statistics.activePlayTime),
                Icons.play_arrow,
                colors,
                typography,
              ),
              _buildStatColumn(
                'Tempo Pausado',
                _formatDuration(statistics.totalPausedTime),
                Icons.pause,
                colors,
                typography,
              ),
            ],
          ),
          if (statistics.pausePercentage > 0) ...[
            SizedBox(height: spacing.medium),
            _buildProgressBar(
              'Tempo Ativo',
              statistics.activePercentage / 100,
              colors,
              typography,
            ),
          ],
        ],
      ),
    );
  }
  
  /// Constrói coluna de estatística
  Widget _buildStatColumn(String label, String value, IconData icon, ThemeColors colors, ResponsiveTypography typography) {
    return Column(
      children: [
        Icon(
          icon,
          color: colors.accent,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.captionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.7),
            fontSize: typography.captionSize * 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Constrói barra de progresso
  Widget _buildProgressBar(String label, double progress, ThemeColors colors, ResponsiveTypography typography) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (${(progress * 100).toStringAsFixed(1)}%)',
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.8),
            fontSize: typography.captionSize,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colors.onSurface.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
        ),
      ],
    );
  }
  
  /// Constrói botões de ação
  Widget _buildActionButtons(ThemeColors colors, ResponsiveTypography typography, ResponsiveSpacing spacing) {
    return Column(
      children: [
        // Botão principal - Continuar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onResume,
            icon: const Icon(Icons.play_arrow),
            label: Text(
              'Continuar Jogo',
              style: TextStyle(fontSize: typography.buttonSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onSurface,
              padding: EdgeInsets.symmetric(vertical: spacing.medium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        SizedBox(height: spacing.medium),
        
        // Botões secundários
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onRestart,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(color: colors.onSurface.withValues(alpha: 0.3)),
                  padding: EdgeInsets.symmetric(vertical: spacing.small),
                ),
              ),
            ),
            SizedBox(width: spacing.small),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Config'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(color: colors.onSurface.withValues(alpha: 0.3)),
                  padding: EdgeInsets.symmetric(vertical: spacing.small),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: spacing.small),
        
        // Botão de menu principal
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: widget.onMainMenu,
            icon: const Icon(Icons.home),
            label: const Text('Menu Principal'),
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurface.withValues(alpha: 0.7),
              padding: EdgeInsets.symmetric(vertical: spacing.small),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Formata duração para exibição
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
