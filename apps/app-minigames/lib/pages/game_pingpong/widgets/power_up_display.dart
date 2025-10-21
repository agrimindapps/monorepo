/// Widget para exibir power-ups na tela do jogo
/// 
/// Renderiza power-ups ativos com animações e efeitos visuais.
/// Também mostra indicadores de efeitos ativos na interface.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/models/power_up.dart';
import 'package:app_minigames/services/power_up_manager.dart';
import 'package:app_minigames/services/theme_manager.dart';

/// Widget principal para exibir power-ups
class PowerUpDisplay extends StatelessWidget {
  /// Gerenciador de power-ups
  final PowerUpManager powerUpManager;
  
  /// Gerenciador de temas
  final ThemeManager themeManager;
  
  /// Dimensões da tela
  final Size screenSize;
  
  const PowerUpDisplay({
    super.key,
    required this.powerUpManager,
    required this.themeManager,
    required this.screenSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: powerUpManager,
      builder: (context, child) {
        return Stack(
          children: [
            // Power-ups ativos na tela
            ...powerUpManager.activePowerUps.map((powerUp) => 
              _buildPowerUpWidget(powerUp),
            ),
            
            // Indicadores de efeitos ativos
            Positioned(
              top: 20,
              right: 20,
              child: _buildActiveEffectsPanel(),
            ),
          ],
        );
      },
    );
  }
  
  /// Constrói widget individual de power-up
  Widget _buildPowerUpWidget(PowerUp powerUp) {
    return Positioned(
      left: screenSize.width / 2 + powerUp.x - powerUp.size / 2,
      top: screenSize.height / 2 + powerUp.y - powerUp.size / 2,
      child: AnimatedBuilder(
        animation: Listenable.merge([powerUpManager]),
        builder: (context, child) {
          return Transform.scale(
            scale: powerUp.scale,
            child: Transform.rotate(
              angle: powerUp.rotation,
              child: Opacity(
                opacity: powerUp.opacity,
                child: Container(
                  width: powerUp.size,
                  height: powerUp.size,
                  decoration: BoxDecoration(
                    color: powerUp.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: powerUp.color.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    powerUp.icon,
                    color: Colors.white,
                    size: powerUp.size * 0.5,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Constrói painel de efeitos ativos
  Widget _buildActiveEffectsPanel() {
    final activeEffects = powerUpManager.activeEffects;
    if (activeEffects.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.getColors().accent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: themeManager.getColors().accent,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                'Efeitos Ativos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activeEffects.map((effect) => _buildEffectIndicator(effect)),
        ],
      ),
    );
  }
  
  /// Constrói indicador de efeito individual
  Widget _buildEffectIndicator(ActiveEffect effect) {
    final colors = themeManager.getColors();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            effect.type.icon,
            color: effect.type.color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.type.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (effect.duration > 0) ...[
                  const SizedBox(height: 2),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (effect.remainingTime / effect.duration).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: effect.isExpiring ? Colors.red : effect.type.color,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            effect.duration > 0 
              ? '${effect.remainingTime.toStringAsFixed(1)}s'
              : '∞',
            style: TextStyle(
              color: effect.isExpiring ? Colors.red : Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para exibir estatísticas de power-ups (para debug/desenvolvimento)
class PowerUpStatisticsDisplay extends StatelessWidget {
  final PowerUpManager powerUpManager;
  
  const PowerUpStatisticsDisplay({
    super.key,
    required this.powerUpManager,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: powerUpManager,
      builder: (context, child) {
        final stats = powerUpManager.getPowerUpStatistics();
        
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Power-Up Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ativos: ${stats['activePowerUps']}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Efeitos: ${stats['activeEffects']}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Taxa Spawn: ${(stats['spawnRate'] * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              Text(
                'Próximo: ${(stats['timeSinceLastSpawn'] as double).toStringAsFixed(1)}s',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget animado para exibir coleta de power-up
class PowerUpCollectionAnimation extends StatefulWidget {
  final PowerUpType powerUpType;
  final Offset position;
  final VoidCallback? onComplete;
  
  const PowerUpCollectionAnimation({
    super.key,
    required this.powerUpType,
    required this.position,
    this.onComplete,
  });
  
  @override
  State<PowerUpCollectionAnimation> createState() => _PowerUpCollectionAnimationState();
}

class _PowerUpCollectionAnimationState extends State<PowerUpCollectionAnimation>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: -50.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeOut,
    ));
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    _floatController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onComplete?.call();
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 25,
      top: widget.position.dy - 25,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _fadeAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.powerUpType.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.powerUpType.color.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.powerUpType.icon,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
