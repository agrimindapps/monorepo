import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:go_router/go_router.dart';

/// Página de seleção de calculadoras de pets
class PetSelectionPage extends StatelessWidget {
  const PetSelectionPage({super.key});

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
                                Icons.pets,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cuidados com seu Pet',
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
                            'Ferramentas para acompanhar a saúde e o desenvolvimento '
                            'do seu animal de estimação.',
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
                            title: 'Idade',
                            subtitle: 'Idade em anos humanos',
                            icon: Icons.pets,
                            color: Colors.blue,
                            route: '/calculators/pet/age',
                          ),
                          _CalculatorCard(
                            title: 'Gestação',
                            subtitle: 'Acompanhe a gravidez',
                            icon: Icons.child_friendly,
                            color: Colors.pink,
                            route: '/calculators/pet/pregnancy',
                          ),
                          _CalculatorCard(
                            title: 'Condição Corporal',
                            subtitle: 'BCS - Escore 1-9',
                            icon: Icons.fitness_center,
                            color: Colors.orange,
                            route: '/calculators/pet/body-condition',
                          ),
                          _CalculatorCard(
                            title: 'Calorias',
                            subtitle: 'Necessidade Diária',
                            icon: Icons.restaurant,
                            color: Colors.green,
                            route: '/calculators/pet/caloric-needs',
                          ),
                          _CalculatorCard(
                            title: 'Medicamento',
                            subtitle: 'Dosagem por Peso',
                            icon: Icons.medication,
                            color: Colors.red,
                            route: '/calculators/pet/medication',
                          ),
                          _CalculatorCard(
                            title: 'Fluidoterapia',
                            subtitle: 'Volume de Fluidos',
                            icon: Icons.water_drop,
                            color: Colors.cyan,
                            route: '/calculators/pet/fluid-therapy',
                          ),
                          _CalculatorCard(
                            title: 'Peso Ideal',
                            subtitle: 'Meta de Peso',
                            icon: Icons.monitor_weight,
                            color: Colors.purple,
                            route: '/calculators/pet/ideal-weight',
                          ),
                          _CalculatorCard(
                            title: 'Conversão',
                            subtitle: 'Unidades de Medida',
                            icon: Icons.swap_horiz,
                            color: Colors.grey,
                            route: '/calculators/pet/unit-conversion',
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
