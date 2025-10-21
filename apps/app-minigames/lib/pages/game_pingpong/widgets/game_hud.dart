/// HUD (Heads-Up Display) do jogo Ping Pong
/// 
/// Exibe informações do jogo como pontuação, tempo, estatísticas
/// e controles de interface durante o jogo.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';

/// Widget HUD principal do jogo
class GameHUD extends StatefulWidget {
  /// Estado do jogo
  final PingPongGameState gameState;
  
  /// Callbacks para ações
  final VoidCallback? onPause;
  final VoidCallback? onStop;
  final VoidCallback? onSettings;
  
  /// Configurações de exibição
  final HUDConfig config;
  
  const GameHUD({
    super.key,
    required this.gameState,
    this.onPause,
    this.onStop,
    this.onSettings,
    this.config = const HUDConfig(),
  });
  
  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  /// Timer para atualizar informações em tempo real
  Timer? _updateTimer;
  
  /// Controladores de animação
  late AnimationController _scoreAnimationController;
  late AnimationController _pulseController;
  
  /// Animações
  late Animation<double> _scoreScale;
  late Animation<double> _pulseAnimation;
  
  /// Estado de animação da pontuação
  int _lastPlayerScore = 0;
  int _lastAiScore = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Controlador para animação de pontuação
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scoreScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Controlador para animações de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Timer para atualizações
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _checkForUpdates(),
    );
    
    // Estado inicial
    _lastPlayerScore = widget.gameState.playerScore;
    _lastAiScore = widget.gameState.aiScore;
    
    widget.gameState.addListener(_onGameStateChanged);
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    _scoreAnimationController.dispose();
    _pulseController.dispose();
    widget.gameState.removeListener(_onGameStateChanged);
    super.dispose();
  }
  
  /// Callback quando estado do jogo muda
  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  /// Verifica mudanças para animações
  void _checkForUpdates() {
    if (!mounted) return;
    
    final currentPlayerScore = widget.gameState.playerScore;
    final currentAiScore = widget.gameState.aiScore;
    
    // Anima mudança de pontuação
    if (currentPlayerScore != _lastPlayerScore || currentAiScore != _lastAiScore) {
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reverse();
      });
      
      _lastPlayerScore = currentPlayerScore;
      _lastAiScore = currentAiScore;
    }
    
    // Anima indicadores baseados no estado
    if (widget.gameState.isPlaying) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pontuação principal
        if (widget.config.showScore)
          _buildScoreDisplay(),
        
        // Informações do jogo
        if (widget.config.showGameInfo)
          _buildGameInfo(),
        
        // Controles do jogo
        if (widget.config.showControls)
          _buildGameControls(),
        
        // Estatísticas em tempo real
        if (widget.config.showStats)
          _buildLiveStats(),
        
        // Indicadores de estado
        if (widget.config.showStateIndicators)
          _buildStateIndicators(),
        
        // Overlay de pausa
        if (widget.gameState.isPaused)
          _buildPauseOverlay(),
      ],
    );
  }
  
  /// Constrói display de pontuação
  Widget _buildScoreDisplay() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _scoreScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scoreScale.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pontuação do jogador
                _buildScoreNumber(
                  widget.gameState.playerScore,
                  isPlayer: true,
                ),
                
                // Separador
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    ':',
                    style: TextStyle(
                      color: widget.config.textColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Pontuação da IA
                _buildScoreNumber(
                  widget.gameState.aiScore,
                  isPlayer: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Constrói número da pontuação
  Widget _buildScoreNumber(int score, {required bool isPlayer}) {
    final isWinning = isPlayer ? 
        (widget.gameState.playerScore > widget.gameState.aiScore) :
        (widget.gameState.aiScore > widget.gameState.playerScore);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isWinning ? 
            widget.config.winningScoreColor.withValues(alpha: 0.3) :
            widget.config.scoreBackgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinning ? 
              widget.config.winningScoreColor :
              widget.config.textColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: isWinning ? 
              widget.config.winningScoreColor :
              widget.config.textColor,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
  
  /// Constrói informações do jogo
  Widget _buildGameInfo() {
    return Positioned(
      top: 120,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.config.panelBackgroundColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tempo de jogo
            _buildInfoRow(
              'Tempo',
              _formatDuration(widget.gameState.gameDuration),
              Icons.timer,
            ),
            
            const SizedBox(height: 4),
            
            // Dificuldade
            _buildInfoRow(
              'Dificuldade',
              widget.gameState.difficulty.label,
              Icons.speed,
            ),
            
            const SizedBox(height: 4),
            
            // Rally atual
            _buildInfoRow(
              'Rally',
              widget.gameState.currentRally.toString(),
              Icons.repeat,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói linha de informação
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: widget.config.textColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: widget.config.textColor.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: widget.config.textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Constrói controles do jogo
  Widget _buildGameControls() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão de pausa
          if (widget.gameState.isPlaying)
            _buildControlButton(
              icon: widget.gameState.isPaused ? Icons.play_arrow : Icons.pause,
              onPressed: widget.onPause,
              tooltip: widget.gameState.isPaused ? 'Continuar' : 'Pausar',
            ),
          
          const SizedBox(width: 10),
          
          // Botão de parar
          _buildControlButton(
            icon: Icons.stop,
            onPressed: widget.onStop,
            tooltip: 'Parar jogo',
            color: Colors.red,
          ),
          
          const SizedBox(width: 10),
          
          // Botão de configurações
          _buildControlButton(
            icon: Icons.settings,
            onPressed: widget.onSettings,
            tooltip: 'Configurações',
          ),
        ],
      ),
    );
  }
  
  /// Constrói botão de controle
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color ?? widget.config.controlButtonColor,
        onPressed: onPressed,
        child: Icon(
          icon,
          color: widget.config.textColor,
          size: 20,
        ),
      ),
    );
  }
  
  /// Constrói estatísticas em tempo real
  Widget _buildLiveStats() {
    return Positioned(
      bottom: 120,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.config.panelBackgroundColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: TextStyle(
                color: widget.config.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildStatRow('Hits', widget.gameState.totalHits.toString()),
            _buildStatRow('Max Rally', widget.gameState.maxRally.toString()),
            _buildStatRow('Velocidade', '${widget.gameState.ball.currentSpeed.toStringAsFixed(1)} m/s'),
            _buildStatRow('Win %', '${(widget.gameState.winPercentage * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
  
  /// Constrói linha de estatística
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: widget.config.textColor.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: widget.config.textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói indicadores de estado
  Widget _buildStateIndicators() {
    return Positioned(
      top: 40,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Indicador de conexão
          _buildStatusIndicator(
            'ONLINE',
            Colors.green,
            widget.gameState.isPlaying,
          ),
          
          const SizedBox(height: 4),
          
          // Indicador de modo
          _buildStatusIndicator(
            widget.gameState.gameMode.label.toUpperCase(),
            Colors.blue,
            true,
          ),
          
          const SizedBox(height: 4),
          
          // Indicador de performance
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildStatusIndicator(
                  'FPS: 60',
                  Colors.orange,
                  widget.gameState.isPlaying,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Constrói indicador de status
  Widget _buildStatusIndicator(String text, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? 
            color.withValues(alpha: 0.2) : 
            Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? color : Colors.grey,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? color : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Constrói overlay de pausa
  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: widget.config.panelBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_filled,
                size: 60,
                color: widget.config.textColor,
              ),
              const SizedBox(height: 16),
              Text(
                'JOGO PAUSADO',
                style: TextStyle(
                  color: widget.config.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toque em continuar para prosseguir',
                style: TextStyle(
                  color: widget.config.textColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Formata duração para exibição
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Configurações do HUD
class HUDConfig {
  final Color textColor;
  final Color panelBackgroundColor;
  final Color scoreBackgroundColor;
  final Color winningScoreColor;
  final Color controlButtonColor;
  
  final bool showScore;
  final bool showGameInfo;
  final bool showControls;
  final bool showStats;
  final bool showStateIndicators;
  
  const HUDConfig({
    this.textColor = Colors.white,
    this.panelBackgroundColor = Colors.black,
    this.scoreBackgroundColor = Colors.transparent,
    this.winningScoreColor = Colors.green,
    this.controlButtonColor = Colors.white24,
    this.showScore = true,
    this.showGameInfo = true,
    this.showControls = true,
    this.showStats = true,
    this.showStateIndicators = true,
  });
}
