import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:go_router/go_router.dart';

/// Página de seleção de calculadoras agrícolas
class AgricultureSelectionPage extends StatelessWidget {
  const AgricultureSelectionPage({super.key});

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
                                Icons.agriculture,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ferramentas para o Campo',
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
                            'Calculadoras para auxiliar no planejamento da safra, '
                            'adubação, irrigação e manejo de animais.',
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
                            title: 'NPK',
                            subtitle: 'Adubação de culturas',
                            icon: Icons.grass,
                            color: Colors.green,
                            route: '/calculators/agriculture/npk',
                          ),
                          _CalculatorCard(
                            title: 'Semeadura',
                            subtitle: 'Taxa de sementes',
                            icon: Icons.agriculture,
                            color: Colors.amber,
                            route: '/calculators/agriculture/seed-rate',
                          ),
                          _CalculatorCard(
                            title: 'Irrigação',
                            subtitle: 'Necessidade hídrica',
                            icon: Icons.water,
                            color: Colors.blue,
                            route: '/calculators/agriculture/irrigation',
                          ),
                          _CalculatorCard(
                            title: 'Fertilizante',
                            subtitle: 'Dosagem por área',
                            icon: Icons.science,
                            color: Colors.purple,
                            route: '/calculators/agriculture/fertilizer-dosing',
                          ),
                          _CalculatorCard(
                            title: 'Correção pH',
                            subtitle: 'Calcário necessário',
                            icon: Icons.landscape,
                            color: Colors.brown,
                            route: '/calculators/agriculture/soil-ph',
                          ),
                          _CalculatorCard(
                            title: 'Densidade',
                            subtitle: 'Plantas por hectare',
                            icon: Icons.grid_on,
                            color: Colors.lightGreen,
                            route: '/calculators/agriculture/planting-density',
                          ),
                          _CalculatorCard(
                            title: 'Produtividade',
                            subtitle: 'Previsão de colheita',
                            icon: Icons.trending_up,
                            color: Colors.orange,
                            route: '/calculators/agriculture/yield-prediction',
                          ),
                          _CalculatorCard(
                            title: 'Ração',
                            subtitle: 'Consumo de animais',
                            icon: Icons.pets,
                            color: Colors.red,
                            route: '/calculators/agriculture/feed',
                          ),
                          _CalculatorCard(
                            title: 'Ganho Peso',
                            subtitle: 'Tempo para meta',
                            icon: Icons.monitor_weight,
                            color: Colors.teal,
                            route: '/calculators/agriculture/weight-gain',
                          ),
                          _CalculatorCard(
                            title: 'Reprodução',
                            subtitle: 'Ciclo e gestação',
                            icon: Icons.child_friendly,
                            color: Colors.pink,
                            route: '/calculators/agriculture/breeding-cycle',
                          ),
                          _CalculatorCard(
                            title: 'Evapotranspiração',
                            subtitle: 'ETo e clima',
                            icon: Icons.wb_sunny,
                            color: Colors.cyan,
                            route: '/calculators/agriculture/evapotranspiration',
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
