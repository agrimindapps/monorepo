// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  // Data de lançamento oficial do app
  final DateTime _releaseDate = DateTime(2025, 8, 1); // 01/08/2025

  // Variáveis para a contagem regressiva
  int _days = 0;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  Timer? _timer;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Função para iniciar e atualizar a contagem regressiva
  void _startCountdown() {
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  // Função para calcular o tempo restante até o lançamento
  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = _releaseDate.difference(now);

    if (difference.isNegative) {
      setState(() {
        _days = 0;
        _hours = 0;
        _minutes = 0;
        _seconds = 0;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _days = difference.inDays;
        _hours = difference.inHours.remainder(24);
        _minutes = difference.inMinutes.remainder(60);
        _seconds = difference.inSeconds.remainder(60);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Animação de flutuação para o ícone
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(value * math.pi * 2) * 5),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withBlue(
                        (Theme.of(context).primaryColor.blue + 40)
                            .clamp(0, 255)),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calculate,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Nome do app com efeito de sombra
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Calculei',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Slogan com estilo melhorado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Text(
              'Todas as calculadoras que você precisa em um só lugar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Botões de download com design moderno
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

          const SizedBox(height: 60),

          // Preview do app com mock mais realista
          Stack(
            alignment: Alignment.center,
            children: [
              // Sombra
              Container(
                height: 410,
                width: 210,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),

              // Phone frame
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 420,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // App screenshot mockup
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              // Status bar
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.network_wifi, size: 16),
                                    SizedBox(width: 4),
                                    Icon(Icons.battery_full, size: 16),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),

                              // App bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                color: Theme.of(context).primaryColor,
                                child: const Row(
                                  children: [
                                    Icon(Icons.menu,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Calculei',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.search,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                              ),

                              // App content placeholder
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: AlignedGridView.count(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      final colors = [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context).colorScheme.secondary,
                                        Colors.orange,
                                        Colors.purple,
                                        Colors.teal,
                                        Colors.pink,
                                      ];
                                      final icons = [
                                        Icons.attach_money,
                                        Icons.health_and_safety,
                                        Icons.agriculture,
                                        Icons.pets,
                                        Icons.science,
                                        Icons.fitness_center,
                                      ];
                                      return Container(
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colors[index]
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              icons[index],
                                              color: colors[index],
                                              size: 24,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              height: 8,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: colors[index]
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Bottom navigation bar
                              Container(
                                height: 40,
                                color: Theme.of(context).primaryColor,
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(Icons.home,
                                        color: Colors.white, size: 20),
                                    Icon(Icons.favorite,
                                        color: Colors.white70, size: 20),
                                    Icon(Icons.history,
                                        color: Colors.white70, size: 20),
                                    Icon(Icons.person,
                                        color: Colors.white70, size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Notch
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 20,
                          width: 70,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Data oficial de lançamento
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Text(
              'Lançamento oficial: 01 de Agosto de 2025',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Contador regressivo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownItem(
                  context, _days.toString().padLeft(2, '0'), 'DIAS'),
              _buildCountdownSeparator(context),
              _buildCountdownItem(
                  context, _hours.toString().padLeft(2, '0'), 'HORAS'),
              _buildCountdownSeparator(context),
              _buildCountdownItem(
                  context, _minutes.toString().padLeft(2, '0'), 'MIN'),
              _buildCountdownSeparator(context),
              _buildCountdownItem(
                  context, _seconds.toString().padLeft(2, '0'), 'SEG'),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para cada elemento do contador regressivo
  Widget _buildCountdownItem(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withBlue(
                (Theme.of(context).primaryColor.blue + 30).clamp(0, 255)),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Separador para o contador regressivo
  Widget _buildCountdownSeparator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  // Botão de download com efeito de hover e estado desabilitado
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
