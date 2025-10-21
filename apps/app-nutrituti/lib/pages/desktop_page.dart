// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../core/theme/theme_providers.dart';
import '../database/feature_item.dart';
import '../pages/agua/beber_agua_page.dart';
import '../pages/alimentos_page.dart';
import '../pages/asrm/asrm_page.dart';
import '../pages/config_page.dart';
import '../pages/exercicios/pages/exercicio_page.dart';
import '../pages/meditacao/views/meditacao_page.dart';
// Importando as páginas para navegação direta
import '../pages/pratos/pratos_page.dart'; // Ajustar se necessário
import '../pages/receitas/receitas_page.dart';
import '../routes.dart';
import 'calc/calc_page.dart';
import 'peso/peso_page.dart';

class DesktopPageNutriTuti extends ConsumerStatefulWidget {
  const DesktopPageNutriTuti({super.key});

  @override
  ConsumerState<DesktopPageNutriTuti> createState() => _DesktopPageNutriTutiState();
}

class _DesktopPageNutriTutiState extends ConsumerState<DesktopPageNutriTuti> {
  final PageController _pageController = PageController();
  bool _isMenuExpanded = true;
  bool _isMenuVisibleContent = true;

  final List<FeatureItem> _nutritionFeatures = [
    FeatureItem(
      title: 'Alimentos',
      description: 'Consulte informações nutricionais de alimentos',
      icon: FontAwesome.apple_whole_solid,
      routeName: AppRoutes.alimentos,
    ),
    FeatureItem(
      title: 'Pratos',
      description: 'Crie e analise a composição de seus pratos',
      icon: FontAwesome.utensils_solid,
      routeName: AppRoutes.pratos,
    ),
    FeatureItem(
      title: 'Receitas',
      description: 'Descubra receitas saudáveis e nutritivas',
      icon: FontAwesome.bowl_food_solid,
      routeName: AppRoutes.receitas,
    ),
  ];

  final List<FeatureItem> _healthFeatures = [
    FeatureItem(
      title: 'Peso',
      description: 'Controle e histórico do seu peso',
      icon: FontAwesome.weight_scale_solid,
      routeName: AppRoutes.peso,
    ),
    FeatureItem(
      title: 'Água',
      description: 'Controle sua hidratação diária e receba lembretes',
      icon: FontAwesome.glass_water_solid,
      routeName: AppRoutes.beberAgua,
    ),
    FeatureItem(
      title: 'Exercícios',
      description: 'Acompanhe seus exercícios e atividades físicas',
      icon: FontAwesome.dumbbell_solid,
      routeName: AppRoutes.exercicios,
    ),
  ];

  final List<FeatureItem> _wellbeingFeatures = [
    FeatureItem(
      title: 'Meditação',
      description: 'Timer e acompanhamento das suas meditações',
      icon: FontAwesome.spa_solid,
      routeName: AppRoutes.meditacao,
    ),
    FeatureItem(
      title: 'ASMR',
      description: 'Sons relaxantes para meditação e concentração',
      icon: FontAwesome.headphones_simple_solid,
      routeName: AppRoutes.asmr,
    ),
  ];

  final List<FeatureItem> _calcFeatures = [
    FeatureItem(
      title: 'Cálculos',
      description: 'Diversos cálculos nutricionais e de saúde',
      icon: FontAwesome.calculator_solid,
      routeName: AppRoutes.calculos,
    ),
    FeatureItem(
      title: 'Cálculos New',
      description: 'Diversos New cálculos nutricionais e de saúde',
      icon: FontAwesome.calculator_solid,
      routeName: AppRoutes.calculosNew,
    ),
  ];

  // Combina todas as features para uso no dashboard principal
  //List<FeatureItem> get _allFeatures => [
  //      ..._nutritionFeatures,
  //      ..._healthFeatures,
  //      ..._wellbeingFeatures,
  //      ..._calcFeatures,
  //    ];

  Widget _buildPage(int index) {
    // Por enquanto, só temos a página principal
    return _buildDashboardPage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTuti'),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Menu de navegação com grupos
            Consumer(
              builder: (context, ref, child) {
                final isDark = ref.watch(themeNotifierProvider);

                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isMenuExpanded ? 280 : 68,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF18181B)
                            : Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Logo section
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  14, 6, 6, 6), // Reduzido padding
                              child: Icon(
                                FontAwesome.seedling_solid,
                                size: 28, // Reduzido tamanho
                                color: isDark
                                    ? Colors.teal.shade600
                                    : Colors.teal.shade800,
                              ),
                            ),
                            if (_isMenuVisibleContent) ...[
                              const SizedBox(width: 6), // Reduzido espaçamento
                              Text(
                                'NutriTuti',
                                style: TextStyle(
                                  fontSize: 16, // Reduzido tamanho da fonte
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.teal.shade600
                                      : Colors.teal.shade800,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ],
                        ),

                        const SizedBox(height: 20), // Reduzido espaçamento

                        // Conteúdo do menu com rolagem
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Grupo 1: Nutrição
                                _buildGroupTitle(
                                    'NUTRIÇÃO', FontAwesome.apple_whole_solid),
                                _buildNavItem(
                                    0,
                                    FontAwesome.apple_whole_solid,
                                    'Alimentos',
                                    'Banco de alimentos e nutrientes'),
                                _buildNavItem(0, FontAwesome.utensils_solid,
                                    'Pratos', 'Crie e analise seus pratos'),
                                _buildNavItem(0, FontAwesome.bowl_food_solid,
                                    'Receitas', 'Receitas saudáveis'),

                                _buildDivider(), // Divisor entre grupos

                                // Grupo 2: Saúde
                                _buildGroupTitle(
                                    'SAÚDE', FontAwesome.heart_pulse_solid),
                                _buildNavItem(0, FontAwesome.weight_scale_solid,
                                    'Peso', 'Controle seu peso'),
                                _buildNavItem(0, FontAwesome.glass_water_solid,
                                    'Água', 'Rastreie sua hidratação'),
                                _buildNavItem(0, FontAwesome.dumbbell_solid,
                                    'Exercícios', 'Atividades físicas'),

                                _buildDivider(), // Divisor entre grupos

                                // Grupo 3: Bem-estar
                                _buildGroupTitle(
                                    'BEM-ESTAR', FontAwesome.spa_solid),
                                _buildNavItem(0, FontAwesome.spa_solid,
                                    'Meditação', 'Práticas de mindfulness'),
                                _buildNavItem(
                                    0,
                                    FontAwesome.headphones_simple_solid,
                                    'ASMR',
                                    'Sons relaxantes'),

                                _buildDivider(), // Divisor entre grupos

                                // Grupo 4: Cálculos
                                _buildGroupTitle(
                                    'CÁLCULOS', FontAwesome.calculator_solid),
                                _buildNavItem(0, FontAwesome.calculator_solid,
                                    'Calculadora', 'Cálculos nutricionais'),
                                _buildNavItem(0, FontAwesome.calculator_solid,
                                    'Calculadora New', 'Novos cálculos'),
                              ],
                            ),
                          ),
                        ),

                        // Divisor antes do grupo Sistema
                        _buildDivider(),

                        // Grupo 5: Sistema (fixo na parte inferior)
                        _buildGroupTitle('SISTEMA', Icons.settings),
                        _buildNavItem(0, Icons.settings_outlined,
                            'Configurações', 'Preferências do aplicativo'),
                        _buildNavItem(0, Icons.person_outline, 'Perfil',
                            'Gerenciar seu perfil'),

                        const SizedBox(
                            height: 60), // Espaço para o botão de toggle
                      ],
                    ),
                  ),
                    // Toggle Button posicionado na borda
                    Positioned(
                      bottom: 20, // Ajustado para ficar mais próximo da borda
                      right: -15,
                      child: Container(
                        width: 32, // Reduzido tamanho
                        height: 32, // Reduzido tamanho
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black
                              : const Color(0xFFF7FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 16, // Reduzido tamanho
                        onPressed: () {
                          setState(() {
                            _isMenuExpanded = !_isMenuExpanded;
                            if (!_isMenuExpanded) {
                              _isMenuVisibleContent = false;
                            } else {
                              Future.delayed(const Duration(milliseconds: 150),
                                  () {
                                setState(() {
                                  _isMenuVisibleContent = true;
                                });
                              });
                            }
                          });
                        },
                          icon: AnimatedRotation(
                            turns: _isMenuExpanded ? 0 : 0.5,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _isMenuExpanded
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              color: isDark
                                  ? Colors.teal.shade600
                                  : Colors.teal.shade800,
                              size: 16, // Reduzido tamanho
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 1, // Por enquanto só temos a página principal
                itemBuilder: (context, index) {
                  return KeyedSubtree(
                    key: PageStorageKey('page_$index'),
                    child: _buildPage(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para criar divisores entre grupos
  Widget _buildDivider() {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = ref.watch(themeNotifierProvider);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _isMenuVisibleContent ? 12 : 8,
            vertical: 8,
          ),
          child: Divider(
            color: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            height: 1,
            thickness: 1,
          ),
        );
      },
    );
  }

  // Método para criar títulos de grupo
  Widget _buildGroupTitle(String title, IconData icon) {
    if (!_isMenuVisibleContent) {
      return Consumer(
        builder: (context, ref, child) {
          final isDark = ref.watch(themeNotifierProvider);

          return Divider(
            color: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200,
            height: 16, // Reduzido altura
            thickness: 1,
          );
        },
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final isDark = ref.watch(themeNotifierProvider);

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 6), // Reduzido padding
          child: Row(
            children: [
              Icon(
                icon,
                size: 12, // Reduzido tamanho
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 8), // Reduzido espaçamento
              Text(
                title,
                style: TextStyle(
                  fontSize: 11, // Reduzido tamanho da fonte
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8, // Adicionado letter spacing
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para construir os itens do menu
  Widget _buildNavItem(int index, IconData icon, String label, String tooltip) {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = ref.watch(themeNotifierProvider);

        return Tooltip(
          message: _isMenuExpanded ? '' : tooltip,
          preferBelow: false,
          child: InkWell(
            onTap: () {
              // Navegação direta para as páginas baseadas no ícone
              if (icon == FontAwesome.apple_whole_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AlimentosPage(
                          categoria: '0', onlyFavorites: false)),
                );
              } else if (icon == FontAwesome.utensils_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PratosPage()),
                );
              } else if (icon == FontAwesome.bowl_food_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceitasPage()),
                );
              } else if (icon == FontAwesome.weight_scale_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PesoPage()),
                );
              } else if (icon == FontAwesome.glass_water_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BeberAguaPage()),
                );
              } else if (icon == FontAwesome.dumbbell_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExercicioPage()),
                );
              } else if (icon == FontAwesome.spa_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MeditacaoPage()),
                );
              } else if (icon == FontAwesome.headphones_simple_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AsrmPage()),
                );
              } else if (icon == FontAwesome.calculator_solid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalcPage()),
                );
              } else if (icon == Icons.settings_outlined ||
                  icon == Icons.person_outline) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfigPage()),
                );
              } else {
                // Caso contrário, usa a navegação por PageView
                _pageController.jumpToPage(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(
                horizontal: _isMenuVisibleContent ? 8 : 6, // Reduzido margin
                vertical: 3, // Reduzido margin vertical
              ),
              padding: EdgeInsets.symmetric(
                horizontal: _isMenuVisibleContent ? 12 : 6, // Reduzido padding
                vertical: 8, // Reduzido padding vertical
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8), // Reduzido border radius
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18, // Reduzido tamanho
                    color: isDark
                        ? Colors.teal.shade300
                        : Colors.teal.shade700,
                  ),
                  if (_isMenuVisibleContent) ...[
                    const SizedBox(width: 10), // Reduzido espaçamento
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13, // Reduzido tamanho da fonte
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Página principal de dashboard
  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-vindo ao NutriTuti!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escolha uma das funcionalidades para gerenciar sua saúde e bem-estar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // Seção: Nutrição
            _buildSectionTitle('Nutrição', FontAwesome.apple_whole_solid),
            _buildFeatureGrid(_nutritionFeatures),
            const SizedBox(height: 32),

            // Seção: Saúde
            _buildSectionTitle('Saúde', FontAwesome.heart_pulse_solid),
            _buildFeatureGrid(_healthFeatures),
            const SizedBox(height: 32),

            // Seção: Bem-estar
            _buildSectionTitle('Bem-estar', FontAwesome.spa_solid),
            _buildFeatureGrid(_wellbeingFeatures),
            const SizedBox(height: 32),

            // Seção: Cálculos
            _buildSectionTitle('Cálculos', FontAwesome.calculator_solid),
            _buildFeatureGrid(_calcFeatures),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(List<FeatureItem> features) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(features[index]);
      },
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegação direta para as páginas baseadas no ícone
          if (feature.icon == FontAwesome.apple_whole_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AlimentosPage(
                      categoria: '0', onlyFavorites: false)),
            );
          } else if (feature.icon == FontAwesome.utensils_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PratosPage()),
            );
          } else if (feature.icon == FontAwesome.bowl_food_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceitasPage()),
            );
          } else if (feature.icon == FontAwesome.weight_scale_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PesoPage()),
            );
          } else if (feature.icon == FontAwesome.glass_water_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BeberAguaPage()),
            );
          } else if (feature.icon == FontAwesome.dumbbell_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExercicioPage()),
            );
          } else if (feature.icon == FontAwesome.spa_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeditacaoPage()),
            );
          } else if (feature.icon == FontAwesome.headphones_simple_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AsrmPage()),
            );
          } else if (feature.icon == FontAwesome.calculator_solid) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalcPage()),
            );
          } else if (feature.icon == Icons.settings_outlined ||
              feature.icon == Icons.person_outline) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfigPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                feature.icon,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
