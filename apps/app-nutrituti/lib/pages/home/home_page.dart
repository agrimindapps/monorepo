import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/constants/responsive_constants.dart';
import '../../database/feature_item.dart';
import '../../routes.dart';
import '../../shared/widgets/adaptive_main_navigation.dart';
import '../agua/beber_agua_page.dart';
import '../alimentos_page.dart';
import '../asrm/asrm_page.dart';
import '../exercicios/pages/exercicio_page.dart';
import '../meditacao/views/meditacao_page.dart';
import '../pratos/pratos_page.dart';
import '../receitas/receitas_page.dart';
import '../calc/calc_page.dart';
import '../peso/peso_page.dart';

import 'mobile_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navigationType = ResponsiveLayout.getNavigationType(constraints.maxWidth);
        
        // Desktop/Tablet: Use adaptive navigation with sidebar/rail
        if (navigationType != NavigationType.bottom) {
          return AdaptiveMainNavigation(
            features: _features,
            onFeatureTap: _navigateToFeature,
            categoryColors: _categoryColors,
            onExit: _showExitModuleConfirmation,
            child: const SizedBox.shrink(), // Placeholder - content is managed internally
          );
        }
        
        // Mobile: Use grid-based home page
        return MobileHomePage(
          features: _features,
          onFeatureTap: _navigateToFeature,
          categoryColors: _categoryColors,
          onExit: _showExitModuleConfirmation,
        );
      },
    );
  }
}
