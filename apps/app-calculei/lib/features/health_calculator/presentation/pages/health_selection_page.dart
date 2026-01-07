import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:go_router/go_router.dart';

/// Página de seleção de calculadoras de saúde
class HealthSelectionPage extends StatelessWidget {
  const HealthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CalculatorAppBar(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saúde e Bem-estar',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ferramentas para acompanhar sua saúde, calcular '
                            'necessidades nutricionais e metas de bem-estar.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calculator Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: const [
                          _CalculatorCard(
                            title: 'IMC',
                            subtitle: 'Índice de Massa Corporal',
                            icon: Icons.monitor_weight_outlined,
                            color: Colors.green,
                            route: '/calculators/health/bmi',
                          ),
                          _CalculatorCard(
                            title: 'TMB',
                            subtitle: 'Taxa Metabólica Basal',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                            route: '/calculators/health/bmr',
                          ),
                          _CalculatorCard(
                            title: 'Água',
                            subtitle: 'Necessidade Hídrica',
                            icon: Icons.water_drop,
                            color: Colors.blue,
                            route: '/calculators/health/water',
                          ),
                          _CalculatorCard(
                            title: 'Peso Ideal',
                            subtitle: '4 fórmulas científicas',
                            icon: Icons.accessibility_new,
                            color: Colors.teal,
                            route: '/calculators/health/ideal-weight',
                          ),
                          _CalculatorCard(
                            title: 'Gordura',
                            subtitle: '% de Gordura Corporal',
                            icon: Icons.pie_chart,
                            color: Colors.purple,
                            route: '/calculators/health/body-fat',
                          ),
                          _CalculatorCard(
                            title: 'Macros',
                            subtitle: 'Macronutrientes',
                            icon: Icons.pie_chart_outline,
                            color: Colors.amber,
                            route: '/calculators/health/macros',
                          ),
                          _CalculatorCard(
                            title: 'Proteínas',
                            subtitle: 'Necessidade Diária',
                            icon: Icons.restaurant,
                            color: Colors.red,
                            route: '/calculators/health/protein',
                          ),
                          _CalculatorCard(
                            title: 'Exercício',
                            subtitle: 'Calorias Queimadas',
                            icon: Icons.directions_run,
                            color: Colors.deepOrange,
                            route: '/calculators/health/exercise-calories',
                          ),
                          _CalculatorCard(
                            title: 'Cintura-Quadril',
                            subtitle: 'Risco Cardiovascular',
                            icon: Icons.straighten,
                            color: Colors.pink,
                            route: '/calculators/health/waist-hip',
                          ),
                          _CalculatorCard(
                            title: 'Álcool',
                            subtitle: 'Nível no Sangue (BAC)',
                            icon: Icons.local_bar,
                            color: Colors.brown,
                            route: '/calculators/health/blood-alcohol',
                          ),
                          _CalculatorCard(
                            title: 'Volume Sanguíneo',
                            subtitle: 'Estimativa Corporal',
                            icon: Icons.bloodtype,
                            color: Colors.red,
                            route: '/calculators/health/blood-volume',
                          ),
                          _CalculatorCard(
                            title: 'Déficit Calórico',
                            subtitle: 'Meta de Peso',
                            icon: Icons.trending_down,
                            color: Colors.indigo,
                            route: '/calculators/health/caloric-deficit',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _CalculatorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
