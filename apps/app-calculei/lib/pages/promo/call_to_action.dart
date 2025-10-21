// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

class CallToActionSection extends StatefulWidget {
  const CallToActionSection({super.key});

  @override
  State<CallToActionSection> createState() => _CallToActionSectionState();
}

class _CallToActionSectionState extends State<CallToActionSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Círculo decorativo de fundo
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Círculo decorativo de fundo
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.1),
              ),
            ),
          ),

          // Container principal com efeito de glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withBlue(
                          (Theme.of(context).primaryColor.blue + 30)
                              .clamp(0, 255)),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Ícone animado
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.calculate,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Título principal com efeito de brilho
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Pronto para simplificar seus cálculos?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Descrição com destaque
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: const Text(
                        'Baixe agora o Calculei e tenha acesso a centenas de calculadoras profissionais na palma da sua mão.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Informação de lançamento oficial
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Lançamento oficial em 01 de Agosto de 2025',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Benefícios rápidos em badges
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _buildFeatureBadge(context, 'Gratuito'),
                        _buildFeatureBadge(context, 'Offline'),
                        _buildFeatureBadge(context, 'Completo'),
                        _buildFeatureBadge(context, 'Sem anúncios*'),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Botões de download atraentes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _downloadButton(
                          icon: Icons.apple,
                          text: 'App Store',
                          subtitle: 'Em breve',
                          onPressed: () {},
                          context: context,
                          index: 0,
                        ),
                        const SizedBox(width: 20),
                        _downloadButton(
                          icon: Icons.android,
                          text: 'Google Play',
                          subtitle: 'Em breve',
                          onPressed: () {},
                          context: context,
                          index: 1,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Nota de rodapé
                    Text(
                      '* Versão gratuita com funções básicas. Plano premium disponível sem anúncios.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Decoração flutuante
          Positioned(
            top: -20,
            right: 60,
            child: _buildFloatingEmoji('💡'),
          ),

          Positioned(
            bottom: -15,
            left: 60,
            child: _buildFloatingEmoji('📊'),
          ),

          Positioned(
            bottom: 40,
            right: 40,
            child: _buildFloatingEmoji('✨'),
          ),
        ],
      ),
    );
  }

  // Emoji flutuante para decoração
  Widget _buildFloatingEmoji(String emoji) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  // Badge de característica
  Widget _buildFeatureBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Botão de download com efeito de hover
  Widget _downloadButton({
    required IconData icon,
    required String text,
    required String subtitle,
    required VoidCallback onPressed,
    required BuildContext context,
    required int index,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color:
                isHovered ? Colors.white : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.2 : 0.1),
                blurRadius: isHovered ? 15 : 8,
                spreadRadius: isHovered ? 2 : 0,
                offset: Offset(0, isHovered ? 5 : 3),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isHovered
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.8),
                size: 30,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
