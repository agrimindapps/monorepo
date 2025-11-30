// Flutter imports:
import 'package:flutter/material.dart';

// Domain imports:
import '../../domain/entities/enums.dart';

/// Tutorial page for snake game
class SnakeTutorialPage extends StatefulWidget {
  final VoidCallback onComplete;
  final bool showDontShowAgain;

  const SnakeTutorialPage({
    super.key,
    required this.onComplete,
    this.showDontShowAgain = true,
  });

  @override
  State<SnakeTutorialPage> createState() => _SnakeTutorialPageState();
}

class _SnakeTutorialPageState extends State<SnakeTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<_TutorialSlide> _slides = [
    const _TutorialSlide(
      title: 'Bem-vindo ao Neon Snake!',
      description: 'Guie a cobra para comer a comida e crescer. '
          'Quanto maior você ficar, maior será sua pontuação!',
      icon: '🐍',
      color: Colors.greenAccent,
    ),
    _TutorialSlide(
      title: 'Controles',
      description: 'Deslize na tela para mudar de direção ou use as '
          'setas do teclado/controles na parte inferior.',
      icon: '👆',
      color: Colors.blueAccent,
      additionalContent: _ControlsPreview(),
    ),
    _TutorialSlide(
      title: 'Power-Ups',
      description: 'Colete power-ups para ganhar habilidades especiais!',
      icon: '⚡',
      color: Colors.amberAccent,
      additionalContent: _PowerUpsPreview(),
    ),
    _TutorialSlide(
      title: 'Modos de Jogo',
      description: 'Experimente diferentes modos para desafios únicos!',
      icon: '🎮',
      color: Colors.purpleAccent,
      additionalContent: _GameModesPreview(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F0F1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text(
                    'PULAR',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return _buildSlide(slide);
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _slides[_currentPage].color
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Don't show again checkbox
              if (widget.showDontShowAgain && _currentPage == _slides.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        onChanged: (value) {
                          setState(() => _dontShowAgain = value ?? false);
                        },
                        activeColor: Colors.greenAccent,
                      ),
                      const Text(
                        'Não mostrar novamente',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              // Next/Start button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _slides[_currentPage].color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1 ? 'COMEÇAR!' : 'PRÓXIMO',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_TutorialSlide slide) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: slide.color.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Text(
              slide.icon,
              style: const TextStyle(fontSize: 80),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: slide.color,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Additional content
          if (slide.additionalContent != null)
            Expanded(child: slide.additionalContent!),
        ],
      ),
    );
  }
}

class _TutorialSlide {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final Widget? additionalContent;

  const _TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.additionalContent,
  });
}

class _ControlsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('↑', 'Cima'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('←', 'Esquerda'),
            const SizedBox(width: 40),
            _buildKey('→', 'Direita'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('↓', 'Baixo'),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'ou deslize na tela',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildKey(String key, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Text(
              key,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PowerUpsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final powerUps = PowerUpType.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: powerUps.length,
      itemBuilder: (context, index) {
        final powerUp = powerUps[index];
        return _buildPowerUpCard(powerUp);
      },
    );
  }

  Widget _buildPowerUpCard(PowerUpType powerUp) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: powerUp.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: powerUp.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            powerUp.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            powerUp.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: powerUp.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameModesPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: SnakeGameMode.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final mode = SnakeGameMode.values[index];
        return _buildModeCard(mode);
      },
    );
  }

  Widget _buildModeCard(SnakeGameMode mode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(
            mode.emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  mode.description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
