/// Painel de configurações avançado para o jogo Ping Pong
/// 
/// Interface rica para personalizar todas as configurações do jogo,
/// incluindo gameplay, interface, áudio e acessibilidade.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../config/game_configuration.dart';
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Widget principal do painel de configurações
class SettingsPanel extends StatefulWidget {
  /// Gerenciador de configurações
  final GameConfiguration gameConfiguration;
  
  /// Gerenciador de temas
  final ThemeManager themeManager;
  
  /// Callback para voltar
  final VoidCallback? onBack;
  
  const SettingsPanel({
    super.key,
    required this.gameConfiguration,
    required this.themeManager,
    this.onBack,
  });
  
  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with TickerProviderStateMixin {
  
  /// Controlador de tabs
  late TabController _tabController;
  
  /// Controlador de animação
  late AnimationController _animationController;
  
  /// Animação de entrada
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 6, vsync: this);
    
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
    
    widget.gameConfiguration.addListener(_onConfigChanged);
  }
  
  @override
  void dispose() {
    widget.gameConfiguration.removeListener(_onConfigChanged);
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onConfigChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          title: Text(
            'Configurações',
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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: colors.onSurface),
              onPressed: _resetToDefaults,
              tooltip: 'Restaurar Padrões',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.onSurface),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Exportar Configurações'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 8),
                      Text('Importar Configurações'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: colors.accent,
            unselectedLabelColor: colors.onSurface.withValues(alpha: 0.6),
            indicatorColor: colors.accent,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Gameplay'),
              Tab(text: 'Interface'),
              Tab(text: 'Áudio'),
              Tab(text: 'Controles'),
              Tab(text: 'Acessibilidade'),
              Tab(text: 'Performance'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGameplayTab(),
            _buildInterfaceTab(),
            _buildAudioTab(),
            _buildControlsTab(),
            _buildAccessibilityTab(),
            _buildPerformanceTab(),
          ],
        ),
      ),
    );
  }
  
  /// Constrói tab de gameplay
  Widget _buildGameplayTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.gameplay;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Configurações de Jogo', colors, typography),
          SizedBox(height: spacing.medium),
          
          // Dificuldade padrão
          _buildDropdownSetting(
            'Dificuldade Padrão',
            settings.defaultDifficulty.label,
            Difficulty.values.map((d) => DropdownMenuItem(
              value: d,
              child: Text(d.label),
            )).toList(),
            (value) => _updateGameplaySettings(settings.copyWith(defaultDifficulty: value as Difficulty)),
            colors,
            typography,
          ),
          
          // Modo de jogo preferido
          _buildDropdownSetting(
            'Modo de Jogo Preferido',
            settings.preferredGameMode.label,
            GameMode.values.map((m) => DropdownMenuItem(
              value: m,
              child: Text(m.label),
            )).toList(),
            (value) => _updateGameplaySettings(settings.copyWith(preferredGameMode: value as GameMode)),
            colors,
            typography,
          ),
          
          // Multiplicador de velocidade da bola
          _buildSliderSetting(
            'Velocidade da Bola',
            settings.ballSpeedMultiplier,
            0.5,
            2.0,
            '${(settings.ballSpeedMultiplier * 100).toInt()}%',
            (value) => _updateGameplaySettings(settings.copyWith(ballSpeedMultiplier: value)),
            colors,
            typography,
          ),
          
          // Multiplicador de velocidade da raquete
          _buildSliderSetting(
            'Velocidade da Raquete',
            settings.paddleSpeedMultiplier,
            0.5,
            2.0,
            '${(settings.paddleSpeedMultiplier * 100).toInt()}%',
            (value) => _updateGameplaySettings(settings.copyWith(paddleSpeedMultiplier: value)),
            colors,
            typography,
          ),
          
          // Pontuação alvo
          _buildSliderSetting(
            'Pontuação para Vitória',
            settings.targetScore.toDouble(),
            5.0,
            25.0,
            '${settings.targetScore} pontos',
            (value) => _updateGameplaySettings(settings.copyWith(targetScore: value.toInt())),
            colors,
            typography,
          ),
          
          // Switches
          _buildSwitchSetting(
            'Dificuldade Adaptativa',
            'Ajusta automaticamente a dificuldade baseada na performance',
            settings.enableAdaptiveDifficulty,
            (value) => _updateGameplaySettings(settings.copyWith(enableAdaptiveDifficulty: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Reinício Automático',
            'Inicia automaticamente uma nova partida após o fim do jogo',
            settings.autoRestart,
            (value) => _updateGameplaySettings(settings.copyWith(autoRestart: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Início Rápido',
            'Pula o menu e vai direto para o jogo',
            settings.quickStart,
            (value) => _updateGameplaySettings(settings.copyWith(quickStart: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de interface
  Widget _buildInterfaceTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.interface;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Aparência e Interface', colors, typography),
          SizedBox(height: spacing.medium),
          
          // Tipo de tema
          _buildDropdownSetting(
            'Tema',
            settings.themeType.name,
            ThemeType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text(t.name),
            )).toList(),
            (value) => _updateInterfaceSettings(settings.copyWith(themeType: value as ThemeType)),
            colors,
            typography,
          ),
          
          // Escala da interface
          _buildSliderSetting(
            'Tamanho da Interface',
            settings.uiScale,
            0.8,
            1.5,
            '${(settings.uiScale * 100).toInt()}%',
            (value) => _updateInterfaceSettings(settings.copyWith(uiScale: value)),
            colors,
            typography,
          ),
          
          // Opacidade da interface
          _buildSliderSetting(
            'Opacidade da Interface',
            settings.interfaceOpacity,
            0.3,
            1.0,
            '${(settings.interfaceOpacity * 100).toInt()}%',
            (value) => _updateInterfaceSettings(settings.copyWith(interfaceOpacity: value)),
            colors,
            typography,
          ),
          
          // Switches de interface
          _buildSwitchSetting(
            'Mostrar FPS',
            'Exibe contador de frames por segundo',
            settings.showFps,
            (value) => _updateInterfaceSettings(settings.copyWith(showFps: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Mostrar Estatísticas',
            'Exibe estatísticas durante o jogo',
            settings.showStatistics,
            (value) => _updateInterfaceSettings(settings.copyWith(showStatistics: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Animações',
            'Ativa animações da interface',
            settings.enableAnimations,
            (value) => _updateInterfaceSettings(settings.copyWith(enableAnimations: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Efeitos de Partículas',
            'Ativa efeitos visuais especiais',
            settings.enableParticleEffects,
            (value) => _updateInterfaceSettings(settings.copyWith(enableParticleEffects: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Rastro da Bola',
            'Mostra rastro visual da bola',
            settings.showBallTrail,
            (value) => _updateInterfaceSettings(settings.copyWith(showBallTrail: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de áudio
  Widget _buildAudioTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.audio;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Áudio e Feedback', colors, typography),
          SizedBox(height: spacing.medium),
          
          // Volume master
          _buildSliderSetting(
            'Volume Geral',
            settings.masterVolume,
            0.0,
            1.0,
            '${(settings.masterVolume * 100).toInt()}%',
            (value) => _updateAudioSettings(settings.copyWith(masterVolume: value)),
            colors,
            typography,
          ),
          
          // Volume de efeitos
          _buildSliderSetting(
            'Volume dos Efeitos',
            settings.effectsVolume,
            0.0,
            1.0,
            '${(settings.effectsVolume * 100).toInt()}%',
            (value) => _updateAudioSettings(settings.copyWith(effectsVolume: value)),
            colors,
            typography,
          ),
          
          // Volume da música
          _buildSliderSetting(
            'Volume da Música',
            settings.musicVolume,
            0.0,
            1.0,
            '${(settings.musicVolume * 100).toInt()}%',
            (value) => _updateAudioSettings(settings.copyWith(musicVolume: value)),
            colors,
            typography,
          ),
          
          // Intensidade do feedback tátil
          _buildDropdownSetting(
            'Intensidade do Feedback Tátil',
            settings.hapticIntensity.name,
            HapticIntensity.values.map((h) => DropdownMenuItem(
              value: h,
              child: Text(h.name),
            )).toList(),
            (value) => _updateAudioSettings(settings.copyWith(hapticIntensity: value as HapticIntensity)),
            colors,
            typography,
          ),
          
          // Switches de áudio
          _buildSwitchSetting(
            'Ativar Som',
            'Liga/desliga todos os efeitos sonoros',
            settings.enableSound,
            (value) => _updateAudioSettings(settings.copyWith(enableSound: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Ativar Música',
            'Liga/desliga música de fundo',
            settings.enableMusic,
            (value) => _updateAudioSettings(settings.copyWith(enableMusic: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Feedback Tátil',
            'Ativa vibração para eventos do jogo',
            settings.enableHapticFeedback,
            (value) => _updateAudioSettings(settings.copyWith(enableHapticFeedback: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Áudio 3D',
            'Ativa posicionamento espacial do som',
            settings.enable3DAudio,
            (value) => _updateAudioSettings(settings.copyWith(enable3DAudio: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de controles
  Widget _buildControlsTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.controls;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Controles e Entrada', colors, typography),
          SizedBox(height: spacing.medium),
          
          // Sensibilidade do toque
          _buildSliderSetting(
            'Sensibilidade do Toque',
            settings.touchSensitivity,
            0.3,
            3.0,
            '${(settings.touchSensitivity * 100).toInt()}%',
            (value) => _updateControlSettings(settings.copyWith(touchSensitivity: value)),
            colors,
            typography,
          ),
          
          // Zona morta
          _buildSliderSetting(
            'Zona Morta',
            settings.deadZone,
            0.0,
            0.5,
            '${(settings.deadZone * 100).toInt()}%',
            (value) => _updateControlSettings(settings.copyWith(deadZone: value)),
            colors,
            typography,
          ),
          
          // Velocidade do auto-movimento
          _buildSliderSetting(
            'Velocidade do Auto-Movimento',
            settings.autoMoveSpeed,
            0.1,
            1.0,
            '${(settings.autoMoveSpeed * 100).toInt()}%',
            (value) => _updateControlSettings(settings.copyWith(autoMoveSpeed: value)),
            colors,
            typography,
          ),
          
          // Esquema de controle primário
          _buildDropdownSetting(
            'Controle Primário',
            settings.primaryControlScheme.name,
            ControlScheme.values.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            )).toList(),
            (value) => _updateControlSettings(settings.copyWith(primaryControlScheme: value as ControlScheme)),
            colors,
            typography,
          ),
          
          // Esquema de controle secundário
          _buildDropdownSetting(
            'Controle Secundário',
            settings.secondaryControlScheme.name,
            ControlScheme.values.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            )).toList(),
            (value) => _updateControlSettings(settings.copyWith(secondaryControlScheme: value as ControlScheme)),
            colors,
            typography,
          ),
          
          // Switches de controles
          _buildSwitchSetting(
            'Ativar Gestos',
            'Permite controle por gestos na tela',
            settings.enableGestures,
            (value) => _updateControlSettings(settings.copyWith(enableGestures: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Inverter Eixo Vertical',
            'Inverte direção do movimento vertical',
            settings.invertVerticalAxis,
            (value) => _updateControlSettings(settings.copyWith(invertVerticalAxis: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Auto-Movimento',
            'Ativa assistência automática de movimento',
            settings.enableAutoMove,
            (value) => _updateControlSettings(settings.copyWith(enableAutoMove: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de acessibilidade
  Widget _buildAccessibilityTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.accessibility;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Acessibilidade', colors, typography),
          SizedBox(height: spacing.medium),
          
          // Tamanho da fonte
          _buildSliderSetting(
            'Tamanho da Fonte',
            settings.fontSize,
            0.8,
            2.0,
            '${(settings.fontSize * 100).toInt()}%',
            (value) => _updateAccessibilitySettings(settings.copyWith(fontSize: value)),
            colors,
            typography,
          ),
          
          // Tamanho mínimo dos botões
          _buildSliderSetting(
            'Tamanho Mínimo dos Botões',
            settings.buttonMinSize,
            32.0,
            64.0,
            '${settings.buttonMinSize.toInt()}px',
            (value) => _updateAccessibilitySettings(settings.copyWith(buttonMinSize: value)),
            colors,
            typography,
          ),
          
          // Tipo de daltonismo
          _buildDropdownSetting(
            'Suporte a Daltonismo',
            settings.colorBlindType.name,
            ColorBlindType.values.map((c) => DropdownMenuItem(
              value: c,
              child: Text(c.name),
            )).toList(),
            (value) => _updateAccessibilitySettings(settings.copyWith(colorBlindType: value as ColorBlindType)),
            colors,
            typography,
          ),
          
          // Switches de acessibilidade
          _buildSwitchSetting(
            'Modo Alto Contraste',
            'Aumenta contraste para melhor visibilidade',
            settings.highContrastMode,
            (value) => _updateAccessibilitySettings(settings.copyWith(highContrastMode: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Leitor de Tela',
            'Ativa compatibilidade com leitores de tela',
            settings.enableScreenReader,
            (value) => _updateAccessibilitySettings(settings.copyWith(enableScreenReader: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Reduzir Movimento',
            'Diminui animações para sensibilidade a movimento',
            settings.reduceMotion,
            (value) => _updateAccessibilitySettings(settings.copyWith(reduceMotion: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Suporte a Daltonismo',
            'Ajusta cores para diferentes tipos de daltonismo',
            settings.enableColorBlindSupport,
            (value) => _updateAccessibilitySettings(settings.copyWith(enableColorBlindSupport: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Comandos de Voz',
            'Permite controle por comandos de voz',
            settings.enableVoiceCommands,
            (value) => _updateAccessibilitySettings(settings.copyWith(enableVoiceCommands: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Indicadores Visuais',
            'Mostra indicadores visuais para eventos sonoros',
            settings.showVisualIndicators,
            (value) => _updateAccessibilitySettings(settings.copyWith(showVisualIndicators: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói tab de performance
  Widget _buildPerformanceTab() {
    final colors = widget.themeManager.getColors();
    final typography = widget.themeManager.getTypography();
    final spacing = widget.themeManager.getSpacing();
    final settings = widget.gameConfiguration.performance;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Performance e Otimização', colors, typography),
          SizedBox(height: spacing.medium),
          
          // FPS alvo
          _buildSliderSetting(
            'FPS Alvo',
            settings.targetFps.toDouble(),
            30.0,
            120.0,
            '${settings.targetFps} FPS',
            (value) => _updatePerformanceSettings(settings.copyWith(targetFps: value.toInt())),
            colors,
            typography,
          ),
          
          // Máximo de partículas
          _buildSliderSetting(
            'Máximo de Partículas',
            settings.maxParticles.toDouble(),
            25.0,
            500.0,
            '${settings.maxParticles}',
            (value) => _updatePerformanceSettings(settings.copyWith(maxParticles: value.toInt())),
            colors,
            typography,
          ),
          
          // Qualidade visual
          _buildDropdownSetting(
            'Qualidade Visual',
            settings.visualQuality.name,
            QualityLevel.values.map((q) => DropdownMenuItem(
              value: q,
              child: Text(q.name),
            )).toList(),
            (value) => _updatePerformanceSettings(settings.copyWith(visualQuality: value as QualityLevel)),
            colors,
            typography,
          ),
          
          // Switches de performance
          _buildSwitchSetting(
            'V-Sync',
            'Sincroniza com a taxa de atualização da tela',
            settings.enableVSync,
            (value) => _updatePerformanceSettings(settings.copyWith(enableVSync: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Otimização de Física',
            'Ativa otimizações no motor de física',
            settings.enablePhysicsOptimization,
            (value) => _updatePerformanceSettings(settings.copyWith(enablePhysicsOptimization: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Otimização de Memória',
            'Ativa gerenciamento inteligente de memória',
            settings.enableMemoryOptimization,
            (value) => _updatePerformanceSettings(settings.copyWith(enableMemoryOptimization: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Batching',
            'Agrupa chamadas de renderização para melhor performance',
            settings.enableBatching,
            (value) => _updatePerformanceSettings(settings.copyWith(enableBatching: value)),
            colors,
            typography,
          ),
          
          _buildSwitchSetting(
            'Processamento em Background',
            'Permite processamento quando o jogo não está em foco',
            settings.enableBackgroundProcessing,
            (value) => _updatePerformanceSettings(settings.copyWith(enableBackgroundProcessing: value)),
            colors,
            typography,
          ),
        ],
      ),
    );
  }
  
  /// Constrói cabeçalho de seção
  Widget _buildSectionHeader(String title, ThemeColors colors, ResponsiveTypography typography) {
    return Text(
      title,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: typography.titleSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  /// Constrói configuração com switch
  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
    ThemeColors colors,
    ResponsiveTypography typography,
  ) {
    return Card(
      color: colors.surface,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: typography.bodySize,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.7),
            fontSize: typography.captionSize,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colors.accent,
      ),
    );
  }
  
  /// Constrói configuração com slider
  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
    ThemeColors colors,
    ResponsiveTypography typography,
  ) {
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: typography.bodySize,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: typography.bodySize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              activeColor: colors.accent,
              inactiveColor: colors.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói configuração com dropdown
  Widget _buildDropdownSetting<T>(
    String title,
    String currentValue,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
    ThemeColors colors,
    ResponsiveTypography typography,
  ) {
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: typography.bodySize,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<T>(
              value: items.firstWhere((item) => item.child.toString().contains(currentValue)).value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: colors.surface,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: typography.bodySize,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Atualiza configurações de gameplay
  void _updateGameplaySettings(GameplaySettings settings) {
    widget.gameConfiguration.updateGameplaySettings(settings);
  }
  
  /// Atualiza configurações de interface
  void _updateInterfaceSettings(InterfaceSettings settings) {
    widget.gameConfiguration.updateInterfaceSettings(settings);
  }
  
  /// Atualiza configurações de áudio
  void _updateAudioSettings(AudioSettings settings) {
    widget.gameConfiguration.updateAudioSettings(settings);
  }
  
  /// Atualiza configurações de controles
  void _updateControlSettings(ControlSettings settings) {
    widget.gameConfiguration.updateControlSettings(settings);
  }
  
  /// Atualiza configurações de acessibilidade
  void _updateAccessibilitySettings(AccessibilitySettings settings) {
    widget.gameConfiguration.updateAccessibilitySettings(settings);
  }
  
  /// Atualiza configurações de performance
  void _updatePerformanceSettings(PerformanceSettings settings) {
    widget.gameConfiguration.updatePerformanceSettings(settings);
  }
  
  /// Reseta configurações para padrão
  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Configurações'),
        content: const Text('Tem certeza que deseja restaurar todas as configurações para os valores padrão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.gameConfiguration.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações restauradas para o padrão')),
              );
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
  
  /// Lida com ações do menu
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportSettings();
        break;
      case 'import':
        _importSettings();
        break;
    }
  }
  
  /// Exporta configurações
  void _exportSettings() {
    widget.gameConfiguration.exportSettings();
    // Aqui você implementaria a lógica para salvar/compartilhar o arquivo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações exportadas')),
    );
  }
  
  /// Importa configurações
  void _importSettings() {
    // Aqui você implementaria a lógica para carregar um arquivo de configurações
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de importação em desenvolvimento')),
    );
  }
}

extension on ColorBlindType {
  String get name {
    switch (this) {
      case ColorBlindType.none:
        return 'Nenhum';
      case ColorBlindType.deuteranopia:
        return 'Deuteranopia';
      case ColorBlindType.protanopia:
        return 'Protanopia';
      case ColorBlindType.tritanopia:
        return 'Tritanopia';
    }
  }
}
