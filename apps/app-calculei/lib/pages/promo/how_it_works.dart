// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HowItWorksSection extends StatefulWidget {
  const HowItWorksSection({super.key});

  @override
  State<HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<HowItWorksSection>
    with TickerProviderStateMixin {
  int _hoveredIndex = -1;
  int _activeIndex = 0;
  late final PageController _pageController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // Muda automaticamente o passo ativo a cada 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      _autoAdvance();
    });
  }

  void _autoAdvance() {
    if (!mounted) return;

    setState(() {
      _activeIndex = (_activeIndex + 1) % steps.length;
    });

    Future.delayed(const Duration(seconds: 4), () {
      _autoAdvance();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  final steps = [
    {
      'icon': Icons.search,
      'title': 'Escolha uma calculadora',
      'description':
          'Navegue pelas categorias ou use a busca para encontrar exatamente o que precisa',
      'color': const Color(0xFF4CAF50),
      'lightColor': const Color(0xFFE8F5E9),
    },
    {
      'icon': Icons.edit,
      'title': 'Insira os dados',
      'description':
          'Preencha os campos necessários com seus valores específicos de forma intuitiva',
      'color': const Color(0xFF2196F3),
      'lightColor': const Color(0xFFE3F2FD),
    },
    {
      'icon': Icons.auto_graph,
      'title': 'Obtenha resultados precisos',
      'description':
          'Visualize o resultado e explore explicações detalhadas sobre o cálculo',
      'color': const Color(0xFFFF9800),
      'lightColor': const Color(0xFFFFF3E0),
    },
    {
      'icon': Icons.save_alt,
      'title': 'Salve e compartilhe',
      'description':
          'Guarde no histórico ou compartilhe os resultados com quem precisar via WhatsApp ou e-mail',
      'color': const Color(0xFF9C27B0),
      'lightColor': const Color(0xFFF3E5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Círculo decorativo por trás do título
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculos decorativos animados
              ...List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final angle = _animationController.value * math.pi * 2;
                    final radius = 30.0 * (i + 1);
                    return Transform.translate(
                      offset: Offset(
                        math.cos(angle + (i * math.pi / 4)) * radius,
                        math.sin(angle + (i * math.pi / 4)) * radius,
                      ),
                      child: Container(
                        width: 8.0 - (i * 2),
                        height: 8.0 - (i * 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3 - (i * 0.1)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),

              // Título principal
              Column(
                children: [
                  Text(
                    'Como Funciona',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Descrição
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'Use o Calculei em apenas alguns passos simples e rápidos!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Layout responsivo
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return _buildWideLayout();
              } else {
                return _buildNarrowLayout();
              }
            },
          ),
        ],
      ),
    );
  }

  // Layout para telas largas
  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lado esquerdo - Steps
        Expanded(
          flex: 5,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: List.generate(steps.length, (index) {
                final step = steps[index];
                return _buildStepRowCard(
                  icon: step['icon'] as IconData,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  color: step['color'] as Color,
                  lightColor: step['lightColor'] as Color,
                  isActive: _activeIndex == index,
                  index: index,
                );
              }),
            ),
          ),
        ),

        const SizedBox(width: 40),

        // Lado direito - Ilustração
        Expanded(
          flex: 4,
          child: _buildIllustration(),
        ),
      ],
    );
  }

  // Layout para telas estreitas
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        // Ilustração no topo
        _buildIllustration(isSmall: true),

        const SizedBox(height: 40),

        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeIndex = index;
                });
              },
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _activeIndex == index
                      ? (step['color'] as Color)
                      : Colors.grey[300],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 30),

        // Passos (em layout de coluna)
        SizedBox(
          height: 400,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStepCard(
                  icon: step['icon'] as IconData,
                  title: step['title'] as String,
                  description: step['description'] as String,
                  color: step['color'] as Color,
                  lightColor: step['lightColor'] as Color,
                  isActive: true,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Ilustração animada do app
  Widget _buildIllustration({bool isSmall = false}) {
    return SizedBox(
      height: isSmall ? 200 : 400,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
                0, math.sin(_animationController.value * math.pi * 2) * 8),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: steps[_activeIndex]['color'] as Color,
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 10),
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Parte superior do telefone (notch)
              Container(
                width: 80,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
              ),

              // Tela do app
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: steps[_activeIndex]['lightColor'] as Color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // App bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: steps[_activeIndex]['color'] as Color,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back, color: Colors.white),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                steps[_activeIndex]['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Conteúdo específico baseado no passo ativo
                      Expanded(
                        child: IndexedStack(
                          index: _activeIndex,
                          children: [
                            // Passo 1 - Escolha uma calculadora
                            _buildMockContent(
                              child: AlignedGridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                crossAxisCount: 2,
                                itemCount: 4,
                                itemBuilder: (context, i) {
                                  return Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          [
                                            Icons.attach_money,
                                            Icons.calculate,
                                            Icons.assessment,
                                            Icons.schedule
                                          ][i],
                                          color: steps[0]['color'] as Color,
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: 60,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
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

                            // Passo 2 - Insira os dados
                            _buildMockContent(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[400]),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: 120,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Passo 3 - Obtenha resultados
                            _buildMockContent(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: steps[2]['color'] as Color,
                                            blurRadius: 10,
                                            spreadRadius: -5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                width: 80,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: steps[2]['color']
                                                      as Color,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'R\$ 1.250,75',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 16,
                                                  color: steps[2]['color']
                                                      as Color,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 100,
                                                        height: 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        width: double.infinity,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        width: 120,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Passo 4 - Salve e compartilhe
                            _buildMockContent(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Text(
                                                'Resultado:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                'R\$ 1.250,75',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildActionButton(
                                                icon: Icons.save_alt,
                                                label: 'Salvar',
                                                color:
                                                    steps[3]['color'] as Color,
                                              ),
                                              _buildActionButton(
                                                icon: Icons.share,
                                                label: 'Compartilhar',
                                                color:
                                                    steps[3]['color'] as Color,
                                              ),
                                              _buildActionButton(
                                                icon: Icons.history,
                                                label: 'Histórico',
                                                color:
                                                    steps[3]['color'] as Color,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: steps[3]['color'] as Color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chat,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 8),
                                          Text(
                                            'Enviar via WhatsApp',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botão home
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Conteúdo do mockup
  Widget _buildMockContent({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  // Botões de ação no passo 4
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  // Card de passo em layout de linha (para telas grandes)
  Widget _buildStepRowCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color lightColor,
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeIndex = index;
        });
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? lightColor
                : (_hoveredIndex == index ? Colors.white : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? color
                  : (_hoveredIndex == index
                      ? color.withValues(alpha: 0.3)
                      : Colors.transparent),
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Indicador numérico
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isActive ? color : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : color,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isActive ? color : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isActive ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Seta indicadora
              if (isActive)
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Card de passo (para layout estreito)
  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color lightColor,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
