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
import '../pages/exercicios/pages/exercicio_page.dart';
import '../pages/meditacao/views/meditacao_page.dart';
import '../pages/pratos/pratos_page.dart';
import '../pages/receitas/receitas_page.dart';
import '../routes.dart';
import 'calc/calc_page.dart';
import 'peso/peso_page.dart';

// Importando as páginas para navegação direta

class MobilePageNutriTuti extends ConsumerStatefulWidget {
  const MobilePageNutriTuti({super.key});

  @override
  ConsumerState<MobilePageNutriTuti> createState() => _MobilePageNutriTutiState();
}

class _MobilePageNutriTutiState extends ConsumerState<MobilePageNutriTuti>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<FeatureItem> _features = [];

  // Mapa para associar rotas às páginas
  final Map<String, Widget> _routeWidgetMap = {
    AppRoutes.beberAgua: const BeberAguaPage(),
    AppRoutes.asmr: const AsrmPage(),
    AppRoutes.calculos: const CalcPage(),
    AppRoutes.calculosNew: const CalcPage(),
    AppRoutes.exercicios: const ExercicioPage(),
    AppRoutes.meditacao: MeditacaoPage(),
    AppRoutes.peso: const PesoPage(),
    AppRoutes.pratos: const PratosPage(),
    AppRoutes.receitas: const ReceitasPage(),
    AppRoutes.alimentos:
        const AlimentosPage(categoria: '0', onlyFavorites: false),
    // AppRoutes.config: const ConfigPage(),
  };

  // Mapa para definir cores para cada categoria
  final Map<String, Color> _categoryColors = {
    'Água': Colors.blue,
    'ASMR': Colors.purple,
    'Cálculos': Colors.amber,
    'Exercícios': Colors.green,
    'Meditação': Colors.teal,
    'Peso': Colors.red,
    'Pratos': Colors.orange,
    'Receitas': Colors.deepOrange,
    'Alimentos': Colors.lightGreen,
  };

  @override
  void initState() {
    super.initState();
    _initFeatures();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  void _initFeatures() {
    _features.addAll([
      FeatureItem(
        title: 'Água',
        description: 'Controle sua hidratação diária e receba lembretes',
        icon: FontAwesome.glass_water_solid,
        routeName: AppRoutes.beberAgua,
      ),
      FeatureItem(
        title: 'ASMR',
        description: 'Sons relaxantes para meditação e concentração',
        icon: FontAwesome.headphones_simple_solid,
        routeName: AppRoutes.asmr,
      ),
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
      FeatureItem(
        title: 'Exercícios',
        description: 'Acompanhe seus exercícios e atividades físicas',
        icon: FontAwesome.dumbbell_solid,
        routeName: AppRoutes.exercicios,
      ),
      FeatureItem(
        title: 'Meditação',
        description: 'Timer e acompanhamento das suas meditações',
        icon: FontAwesome.spa_solid,
        routeName: AppRoutes.meditacao,
      ),
      FeatureItem(
        title: 'Peso',
        description: 'Controle e histórico do seu peso',
        icon: FontAwesome.weight_scale_solid,
        routeName: AppRoutes.peso,
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
      FeatureItem(
        title: 'Alimentos',
        description: 'Consulte informações nutricionais de alimentos',
        icon: FontAwesome.apple_whole_solid,
        routeName: AppRoutes.alimentos,
      ),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToFeature(FeatureItem feature) {
    final Widget? page = _routeWidgetMap[feature.routeName];
    if (page != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTuti'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Toggle tema claro/escuro usando Riverpod
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.settings),
          //   onPressed: () => _navigateToFeature(
          //     FeatureItem(
          //       title: 'Configurações',
          //       description: 'Configurações do aplicativo',
          //       icon: Icons.settings,
          //       routeName: AppRoutes.config,
          //     ),
          //   ),
          // ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com animação
                FadeTransition(
                  opacity: _animationController.drive(
                    CurveTween(curve: Curves.easeIn),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo ao NutriTuti!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha uma das funcionalidades abaixo para começar:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Grade de funcionalidades com animação
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _features.length,
                      itemBuilder: (context, index) {
                        // Animação sequencial para cada item
                        final itemAnimation = Tween(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              index * 0.05,
                              index * 0.05 + 0.5,
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        return FadeTransition(
                          opacity: itemAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(itemAnimation),
                            child: _buildFeatureCard(_features[index]),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Botão de sair do módulo
                _buildExitModuleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(FeatureItem feature) {
    final Color baseColor =
        _categoryColors[feature.title] ?? Theme.of(context).colorScheme.primary;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: baseColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      color: isDarkMode
          ? Color.alphaBlend(
              baseColor.withValues(alpha: 0.15), Theme.of(context).cardColor)
          : Color.alphaBlend(
              baseColor.withValues(alpha: 0.05), Theme.of(context).cardColor),
      child: InkWell(
        onTap: () => _navigateToFeature(feature),
        borderRadius: BorderRadius.circular(16),
        splashColor: baseColor.withValues(alpha: 0.1),
        highlightColor: baseColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  size: 28,
                  color: baseColor,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExitModuleButton() {
    return FadeTransition(
      opacity: _animationController.drive(
        CurveTween(curve: Curves.easeIn),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          onPressed: () => _showExitModuleConfirmation(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 4,
          ),
          icon: const Icon(Icons.exit_to_app, size: 20),
          label: const Text(
            'Sair do Módulo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitModuleConfirmation() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Sair do Módulo',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Tem certeza de que deseja sair do NutriTuti e retornar ao menu principal?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitModule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _exitModule() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/app-select',
      (route) => false,
    );
  }
}
