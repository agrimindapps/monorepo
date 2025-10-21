/// Sistema de menus para o jogo Ping Pong
/// 
/// Inclui menu principal, configurações, pausa e fim de jogo
/// com navegação fluida e animações.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';

/// Widget de menu principal
class GameMenu extends StatefulWidget {
  /// Estado atual do jogo
  final PingPongGameState gameState;
  
  /// Callbacks para ações
  final VoidCallback? onStartGame;
  final VoidCallback? onResumeGame;
  final VoidCallback? onSettings;
  final VoidCallback? onExit;
  final Function(GameMode)? onGameModeChanged;
  final Function(Difficulty)? onDifficultyChanged;
  
  /// Tipo de menu a exibir
  final MenuType menuType;
  
  /// Configurações de estilo
  final MenuConfig config;
  
  const GameMenu({
    super.key,
    required this.gameState,
    this.onStartGame,
    this.onResumeGame,
    this.onSettings,
    this.onExit,
    this.onGameModeChanged,
    this.onDifficultyChanged,
    this.menuType = MenuType.main,
    this.config = const MenuConfig(),
  });
  
  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu>
    with TickerProviderStateMixin {
  
  /// Controlador de animação principal
  late AnimationController _animationController;
  
  /// Controlador para efeitos de entrada
  late AnimationController _entranceController;
  
  /// Animações
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  /// Índice do item selecionado
  int _selectedIndex = 0;
  
  /// Lista de opções do menu atual
  List<MenuOption> _currentOptions = [];
  
  @override
  void initState() {
    super.initState();
    
    // Controlador principal
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Controlador de entrada
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Configurar animações
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));
    
    // Atualizar opções do menu
    _updateMenuOptions();
    
    // Iniciar animação de entrada
    _entranceController.forward();
  }
  
  @override
  void didUpdateWidget(GameMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.menuType != widget.menuType) {
      _updateMenuOptions();
      _entranceController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }
  
  /// Atualiza opções do menu baseado no tipo
  void _updateMenuOptions() {
    switch (widget.menuType) {
      case MenuType.main:
        _currentOptions = _getMainMenuOptions();
        break;
      case MenuType.pause:
        _currentOptions = _getPauseMenuOptions();
        break;
      case MenuType.gameOver:
        _currentOptions = _getGameOverMenuOptions();
        break;
      case MenuType.settings:
        _currentOptions = _getSettingsMenuOptions();
        break;
    }
    
    _selectedIndex = 0;
  }
  
  /// Opções do menu principal
  List<MenuOption> _getMainMenuOptions() {
    return [
      MenuOption(
        title: 'Iniciar Jogo',
        icon: Icons.play_arrow,
        onTap: widget.onStartGame,
        description: 'Começar uma nova partida',
      ),
      if (widget.gameState.currentState == GameState.paused)
        MenuOption(
          title: 'Continuar',
          icon: Icons.play_circle_filled,
          onTap: widget.onResumeGame,
          description: 'Continuar jogo pausado',
        ),
      MenuOption(
        title: 'Modo de Jogo',
        icon: Icons.sports_esports,
        isExpandable: true,
        children: GameMode.values.map((mode) => MenuOption(
          title: mode.label,
          onTap: () => widget.onGameModeChanged?.call(mode),
          isSelected: widget.gameState.gameMode == mode,
        )).toList(),
      ),
      MenuOption(
        title: 'Dificuldade',
        icon: Icons.tune,
        isExpandable: true,
        children: Difficulty.values.map((difficulty) => MenuOption(
          title: difficulty.label,
          onTap: () => widget.onDifficultyChanged?.call(difficulty),
          isSelected: widget.gameState.difficulty == difficulty,
        )).toList(),
      ),
      MenuOption(
        title: 'Configurações',
        icon: Icons.settings,
        onTap: widget.onSettings,
        description: 'Ajustar configurações do jogo',
      ),
      MenuOption(
        title: 'Sair',
        icon: Icons.exit_to_app,
        onTap: widget.onExit,
        description: 'Voltar ao menu principal',
      ),
    ];
  }
  
  /// Opções do menu de pausa
  List<MenuOption> _getPauseMenuOptions() {
    return [
      MenuOption(
        title: 'Continuar',
        icon: Icons.play_arrow,
        onTap: widget.onResumeGame,
        description: 'Continuar o jogo',
      ),
      MenuOption(
        title: 'Reiniciar',
        icon: Icons.refresh,
        onTap: widget.onStartGame,
        description: 'Reiniciar a partida',
      ),
      MenuOption(
        title: 'Configurações',
        icon: Icons.settings,
        onTap: widget.onSettings,
        description: 'Ajustar configurações',
      ),
      MenuOption(
        title: 'Menu Principal',
        icon: Icons.home,
        onTap: widget.onExit,
        description: 'Voltar ao menu principal',
      ),
    ];
  }
  
  /// Opções do menu de fim de jogo
  List<MenuOption> _getGameOverMenuOptions() {
    final playerWon = widget.gameState.playerWon;
    
    return [
      MenuOption(
        title: 'Jogar Novamente',
        icon: Icons.replay,
        onTap: widget.onStartGame,
        description: 'Iniciar uma nova partida',
      ),
      MenuOption(
        title: 'Estatísticas',
        icon: Icons.bar_chart,
        onTap: () => _showStatistics(),
        description: 'Ver estatísticas da partida',
      ),
      MenuOption(
        title: 'Menu Principal',
        icon: Icons.home,
        onTap: widget.onExit,
        description: 'Voltar ao menu principal',
      ),
    ];
  }
  
  /// Opções do menu de configurações
  List<MenuOption> _getSettingsMenuOptions() {
    return [
      MenuOption(
        title: 'Áudio',
        icon: Icons.volume_up,
        isExpandable: true,
        children: [
          MenuOption(title: 'Volume Geral: 80%'),
          MenuOption(title: 'Efeitos Sonoros: 70%'),
          MenuOption(title: 'Música: 30%'),
        ],
      ),
      MenuOption(
        title: 'Controles',
        icon: Icons.gamepad,
        isExpandable: true,
        children: [
          MenuOption(title: 'Sensibilidade: Média'),
          MenuOption(title: 'Feedback Tátil: Ativo'),
        ],
      ),
      MenuOption(
        title: 'Visual',
        icon: Icons.palette,
        isExpandable: true,
        children: [
          MenuOption(title: 'Tema: Padrão'),
          MenuOption(title: 'Efeitos: Ativos'),
          MenuOption(title: 'Trail da Bola: Ativo'),
        ],
      ),
      MenuOption(
        title: 'Voltar',
        icon: Icons.arrow_back,
        onTap: () => Navigator.of(context).pop(),
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildMenuContent(),
            ),
          ),
        );
      },
    );
  }
  
  /// Constrói conteúdo do menu
  Widget _buildMenuContent() {
    return Container(
      decoration: BoxDecoration(
        color: widget.config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
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
          // Cabeçalho do menu
          _buildMenuHeader(),
          
          // Lista de opções
          _buildMenuOptions(),
          
          // Rodapé (se necessário)
          if (widget.menuType == MenuType.gameOver)
            _buildGameOverFooter(),
        ],
      ),
    );
  }
  
  /// Constrói cabeçalho do menu
  Widget _buildMenuHeader() {
    String title;
    IconData icon;
    
    switch (widget.menuType) {
      case MenuType.main:
        title = 'Ping Pong';
        icon = Icons.sports_tennis;
        break;
      case MenuType.pause:
        title = 'Jogo Pausado';
        icon = Icons.pause_circle_filled;
        break;
      case MenuType.gameOver:
        title = widget.gameState.playerWon ? 'Vitória!' : 'Derrota!';
        icon = widget.gameState.playerWon ? Icons.emoji_events : Icons.sentiment_dissatisfied;
        break;
      case MenuType.settings:
        title = 'Configurações';
        icon = Icons.settings;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.config.headerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: widget.config.textColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: widget.config.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói lista de opções
  Widget _buildMenuOptions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: _currentOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return _buildMenuOption(option, index);
        }).toList(),
      ),
    );
  }
  
  /// Constrói uma opção do menu
  Widget _buildMenuOption(MenuOption option, int index) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? 
            widget.config.selectedColor.withValues(alpha: 0.2) :
            Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(
          color: widget.config.selectedColor,
          width: 2,
        ) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            option.onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                if (option.icon != null)
                  Icon(
                    option.icon,
                    color: isSelected ? 
                        widget.config.selectedColor :
                        widget.config.textColor,
                    size: 24,
                  ),
                
                const SizedBox(width: 12),
                
                // Título
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          color: isSelected ? 
                              widget.config.selectedColor :
                              widget.config.textColor,
                          fontSize: 18,
                          fontWeight: isSelected ? 
                              FontWeight.bold : 
                              FontWeight.normal,
                        ),
                      ),
                      if (option.description != null)
                        Text(
                          option.description!,
                          style: TextStyle(
                            color: widget.config.textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Indicador de expansão
                if (option.isExpandable)
                  Icon(
                    Icons.chevron_right,
                    color: widget.config.textColor.withValues(alpha: 0.7),
                  ),
                
                // Indicador de seleção
                if (option.isSelected)
                  Icon(
                    Icons.check_circle,
                    color: widget.config.selectedColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Constrói rodapé do game over
  Widget _buildGameOverFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.config.footerColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Placar final
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Placar Final: ',
                style: TextStyle(
                  color: widget.config.textColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              Text(
                '${widget.gameState.playerScore} x ${widget.gameState.aiScore}',
                style: TextStyle(
                  color: widget.config.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Tempo de jogo
          Text(
            'Tempo de jogo: ${_formatDuration(widget.gameState.gameDuration)}',
            style: TextStyle(
              color: widget.config.textColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Mostra estatísticas detalhadas
  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas da Partida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Hits Totais', widget.gameState.totalHits.toString()),
            _buildStatRow('Maior Rally', widget.gameState.maxRally.toString()),
            _buildStatRow('Velocidade Máxima', '${widget.gameState.maxBallSpeed.toStringAsFixed(1)} m/s'),
            _buildStatRow('Win Rate', '${(widget.gameState.winPercentage * 100).toStringAsFixed(1)}%'),
          ],
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
  
  /// Constrói linha de estatística
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
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

/// Tipos de menu
enum MenuType {
  main,
  pause,
  gameOver,
  settings,
}

/// Opção de menu
class MenuOption {
  final String title;
  final String? description;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isExpandable;
  final bool isSelected;
  final List<MenuOption>? children;
  
  MenuOption({
    required this.title,
    this.description,
    this.icon,
    this.onTap,
    this.isExpandable = false,
    this.isSelected = false,
    this.children,
  });
}

/// Configurações do menu
class MenuConfig {
  final Color backgroundColor;
  final Color headerColor;
  final Color footerColor;
  final Color textColor;
  final Color selectedColor;
  
  const MenuConfig({
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.headerColor = const Color(0xFF2A2A2A),
    this.footerColor = const Color(0xFF2A2A2A),
    this.textColor = Colors.white,
    this.selectedColor = Colors.cyan,
  });
}
