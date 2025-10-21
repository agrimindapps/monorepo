/// Interface do modo multijogador local para o jogo Ping Pong
/// 
/// Fornece interface especializada para dois jogadores, incluindo
/// áreas de controle separadas, pontuação e configurações.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/multiplayer_controller.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Widget principal da interface multijogador
class MultiplayerInterface extends StatefulWidget {
  /// Controlador multijogador
  final MultiplayerController multiplayerController;
  
  /// Estado do jogo
  final PingPongGameState gameState;
  
  /// Gerenciador de temas
  final ThemeManager themeManager;
  
  /// Callbacks
  final VoidCallback? onBackToMenu;
  
  const MultiplayerInterface({
    super.key,
    required this.multiplayerController,
    required this.gameState,
    required this.themeManager,
    this.onBackToMenu,
  });
  
  @override
  State<MultiplayerInterface> createState() => _MultiplayerInterfaceState();
}

class _MultiplayerInterfaceState extends State<MultiplayerInterface> {
  /// Controla qual área de toque está ativa
  final Map<PlayerId, bool> _activeTouchAreas = {
    PlayerId.player1: false,
    PlayerId.player2: false,
  };
  
  @override
  void initState() {
    super.initState();
    widget.multiplayerController.addListener(_onMultiplayerStateChanged);
  }
  
  @override
  void dispose() {
    widget.multiplayerController.removeListener(_onMultiplayerStateChanged);
    super.dispose();
  }
  
  void _onMultiplayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.themeManager.getColors();
    final layout = widget.themeManager.getLayout();
    final typography = widget.themeManager.getTypography();
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Áreas de controle dos jogadores
            _buildPlayerControlAreas(),
            
            // HUD central
            _buildCentralHUD(),
            
            // Painel de configuração (se necessário)
            if (widget.multiplayerController.currentState == MultiplayerState.setup)
              _buildSetupPanel(),
            
            // Overlay de fim de jogo
            if (widget.multiplayerController.currentState == MultiplayerState.finished)
              _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }
  
  /// Constrói áreas de controle dos jogadores
  Widget _buildPlayerControlAreas() {
    final config = widget.multiplayerController.config;
    
    if (!config.enableTouchControls) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        // Área do Jogador 1 (esquerda)
        Expanded(
          child: _buildPlayerControlArea(PlayerId.player1),
        ),
        
        // Área do Jogador 2 (direita)
        Expanded(
          child: _buildPlayerControlArea(PlayerId.player2),
        ),
      ],
    );
  }
  
  /// Constrói área de controle de um jogador
  Widget _buildPlayerControlArea(PlayerId playerId) {
    final playerConfig = widget.multiplayerController.playerConfigs[playerId];
    final colors = widget.themeManager.getColors();
    final isActive = _activeTouchAreas[playerId] ?? false;
    
    if (playerConfig == null) return const SizedBox.shrink();
    
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _activeTouchAreas[playerId] = true;
        });
        widget.multiplayerController.handleTouchInput(
          playerId,
          details.localPosition,
          TouchAction.start,
        );
      },
      onPanUpdate: (details) {
        widget.multiplayerController.handleTouchInput(
          playerId,
          details.localPosition,
          TouchAction.move,
        );
      },
      onPanEnd: (details) {
        setState(() {
          _activeTouchAreas[playerId] = false;
        });
        widget.multiplayerController.handleTouchInput(
          playerId,
          details.localPosition,
          TouchAction.end,
        );
      },
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? 
                   playerConfig.color.withValues(alpha: 0.8) :
                   playerConfig.color.withValues(alpha: 0.3),
            width: isActive ? 3.0 : 1.0,
          ),
          gradient: LinearGradient(
            begin: playerId == PlayerId.player1 ? Alignment.centerLeft : Alignment.centerRight,
            end: playerId == PlayerId.player1 ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              playerConfig.color.withValues(alpha: isActive ? 0.2 : 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone do jogador
            Icon(
              Icons.touch_app,
              size: 48,
              color: playerConfig.color.withValues(alpha: isActive ? 1.0 : 0.5),
            ),
            
            const SizedBox(height: 16),
            
            // Nome do jogador
            Text(
              playerConfig.name,
              style: TextStyle(
                color: playerConfig.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Instruções de controle
            _buildControlInstructions(playerConfig),
          ],
        ),
      ),
    );
  }
  
  /// Constrói instruções de controle
  Widget _buildControlInstructions(PlayerConfig config) {
    String instructions;
    
    switch (config.preferredControls) {
      case ControlScheme.arrows:
        instructions = '↑ ↓ ou toque';
        break;
      case ControlScheme.wasd:
        instructions = 'W S ou toque';
        break;
      case ControlScheme.ijkl:
        instructions = 'I K ou toque';
        break;
      case ControlScheme.numpad:
        instructions = '8 2 ou toque';
        break;
    }
    
    return Text(
      instructions,
      style: TextStyle(
        color: config.color.withValues(alpha: 0.8),
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  /// Constrói HUD central
  Widget _buildCentralHUD() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    
    return Center(
      child: Column(
        children: [
          // Pontuação
          const SizedBox(height: 60),
          _buildMultiplayerScore(),
          
          // Informações do jogo
          const SizedBox(height: 20),
          _buildGameInfo(),
          
          // Controles centrais
          const Spacer(),
          _buildCentralControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  /// Constrói pontuação multijogador
  Widget _buildMultiplayerScore() {
    final player1Config = widget.multiplayerController.playerConfigs[PlayerId.player1];
    final player2Config = widget.multiplayerController.playerConfigs[PlayerId.player2];
    final typography = widget.themeManager.getTypography();
    
    if (player1Config == null || player2Config == null) {
      return const SizedBox.shrink();
    }
    
    final player1Score = _getPlayerScore(PlayerId.player1);
    final player2Score = _getPlayerScore(PlayerId.player2);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pontuação Jogador 1
          _buildPlayerScore(
            player1Config.name,
            player1Score,
            player1Config.color,
            typography.scoreSize,
          ),
          
          // Separador
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontSize: typography.titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Pontuação Jogador 2
          _buildPlayerScore(
            player2Config.name,
            player2Score,
            player2Config.color,
            typography.scoreSize,
          ),
        ],
      ),
    );
  }
  
  /// Constrói pontuação de um jogador
  Widget _buildPlayerScore(String name, int score, Color color, double fontSize) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
  
  /// Obtém pontuação de um jogador
  int _getPlayerScore(PlayerId playerId) {
    final config = widget.multiplayerController.playerConfigs[playerId];
    if (config == null) return 0;
    
    return config.paddleSide == PaddleSide.left ? 
           widget.gameState.playerScore : 
           widget.gameState.aiScore;
  }
  
  /// Constrói informações do jogo
  Widget _buildGameInfo() {
    final colors = widget.themeManager.getColors();
    final state = widget.multiplayerController.currentState;
    final duration = widget.multiplayerController.stats.currentMatchDuration;
    
    String statusText;
    Color statusColor;
    
    switch (state) {
      case MultiplayerState.setup:
        statusText = 'Configurando...';
        statusColor = Colors.orange;
        break;
      case MultiplayerState.ready:
        statusText = 'Pronto para começar';
        statusColor = Colors.green;
        break;
      case MultiplayerState.playing:
        statusText = widget.gameState.isPaused ? 'PAUSADO' : 'EM JOGO';
        statusColor = widget.gameState.isPaused ? Colors.orange : Colors.green;
        break;
      case MultiplayerState.paused:
        statusText = 'PAUSADO';
        statusColor = Colors.orange;
        break;
      case MultiplayerState.finished:
        statusText = 'Partida finalizada';
        statusColor = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (duration != null) ...[
            const SizedBox(width: 16),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                color: colors.onBackground.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Constrói controles centrais
  Widget _buildCentralControls() {
    final state = widget.multiplayerController.currentState;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botão de ação principal
        if (state == MultiplayerState.ready)
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Iniciar',
            onPressed: widget.multiplayerController.startMatch,
            color: Colors.green,
          ),
        
        if (state == MultiplayerState.playing)
          _buildControlButton(
            icon: widget.gameState.isPaused ? Icons.play_arrow : Icons.pause,
            label: widget.gameState.isPaused ? 'Continuar' : 'Pausar',
            onPressed: widget.multiplayerController.togglePause,
            color: Colors.orange,
          ),
        
        if (state == MultiplayerState.finished)
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Nova Partida',
            onPressed: widget.multiplayerController.startMatch,
            color: Colors.green,
          ),
        
        const SizedBox(width: 16),
        
        // Botão de parar/voltar
        if (state == MultiplayerState.playing || state == MultiplayerState.finished)
          _buildControlButton(
            icon: Icons.stop,
            label: 'Parar',
            onPressed: widget.multiplayerController.stopMatch,
            color: Colors.red,
          ),
        
        const SizedBox(width: 16),
        
        // Botão de menu
        _buildControlButton(
          icon: Icons.home,
          label: 'Menu',
          onPressed: widget.onBackToMenu,
          color: Colors.blue,
        ),
      ],
    );
  }
  
  /// Constrói botão de controle
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Constrói painel de configuração
  Widget _buildSetupPanel() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configuração Multijogador',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Configurações dos jogadores
              _buildPlayerSetup(PlayerId.player1),
              const SizedBox(height: 16),
              _buildPlayerSetup(PlayerId.player2),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Marca como pronto
                      setState(() {
                        // Atualiza estado para ready
                      });
                    },
                    child: const Text('Pronto'),
                  ),
                  TextButton(
                    onPressed: widget.onBackToMenu,
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói configuração de jogador
  Widget _buildPlayerSetup(PlayerId playerId) {
    final config = widget.multiplayerController.playerConfigs[playerId];
    if (config == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                // Cor do jogador
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: config.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Esquema de controle
                Text(
                  'Controles: ${_getControlSchemeName(config.preferredControls)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Obtém nome do esquema de controle
  String _getControlSchemeName(ControlScheme scheme) {
    switch (scheme) {
      case ControlScheme.arrows:
        return 'Setas';
      case ControlScheme.wasd:
        return 'WASD';
      case ControlScheme.ijkl:
        return 'IJKL';
      case ControlScheme.numpad:
        return 'Numpad';
    }
  }
  
  /// Constrói overlay de fim de jogo
  Widget _buildGameOverOverlay() {
    final winner = _determineWinner();
    final winnerConfig = widget.multiplayerController.playerConfigs[winner];
    
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de vitória
              Icon(
                Icons.emoji_events,
                size: 80,
                color: winnerConfig?.color ?? Colors.amber,
              ),
              
              const SizedBox(height: 20),
              
              // Texto de vitória
              Text(
                '${winnerConfig?.name ?? "Jogador"} Venceu!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: winnerConfig?.color ?? Colors.amber,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Placar final
              Text(
                'Placar Final: ${_getPlayerScore(PlayerId.player1)} x ${_getPlayerScore(PlayerId.player2)}',
                style: const TextStyle(fontSize: 18),
              ),
              
              const SizedBox(height: 24),
              
              // Estatísticas rápidas
              _buildQuickStats(),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.multiplayerController.startMatch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nova Partida'),
                  ),
                  TextButton.icon(
                    onPressed: widget.onBackToMenu,
                    icon: const Icon(Icons.home),
                    label: const Text('Menu Principal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Determina o vencedor
  PlayerId _determineWinner() {
    final player1Score = _getPlayerScore(PlayerId.player1);
    final player2Score = _getPlayerScore(PlayerId.player2);
    
    return player1Score > player2Score ? PlayerId.player1 : PlayerId.player2;
  }
  
  /// Constrói estatísticas rápidas
  Widget _buildQuickStats() {
    final duration = widget.multiplayerController.stats.currentMatchDuration;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (duration != null)
            _buildStatRow('Duração da Partida', _formatDuration(duration)),
          
          _buildStatRow('Hits Totais', widget.gameState.totalHits.toString()),
          _buildStatRow('Maior Rally', widget.gameState.maxRally.toString()),
        ],
      ),
    );
  }
  
  /// Constrói linha de estatística
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
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
