import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/petiveti_page_header.dart';

/// Página que agrupa todas as calculadoras do app
class CalculatorsPage extends StatelessWidget {
  const CalculatorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: PetivetiPageHeader(
                icon: Icons.calculate,
                title: 'Calculadoras',
                subtitle: 'Ferramentas de cálculo para seu pet',
                showBackButton: true,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _buildSection(
                    context,
                    title: 'Nutrição e Saúde',
                    icon: Icons.favorite,
                    color: Colors.green,
                    tools: [
                      _ToolItem(
                        title: 'Calculadora de Calorias',
                        subtitle: 'Calcule as necessidades calóricas do seu pet',
                        icon: Icons.restaurant,
                        route: '/calculators/calorie',
                      ),
                      _ToolItem(
                        title: 'Peso Ideal',
                        subtitle: 'Descubra o peso ideal para seu pet',
                        icon: Icons.monitor_weight,
                        route: '/calculators/ideal-weight',
                      ),
                      _ToolItem(
                        title: 'Condição Corporal',
                        subtitle: 'Avalie a condição física',
                        icon: Icons.assignment,
                        route: '/calculators/body-condition',
                      ),
                      _ToolItem(
                        title: 'Hidratação',
                        subtitle: 'Calcule necessidades de água',
                        icon: Icons.water_drop,
                        route: '/calculators/hydration',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Atividades e Idade',
                    icon: Icons.pets,
                    color: Colors.blue,
                    tools: [
                      _ToolItem(
                        title: 'Exercícios',
                        subtitle: 'Planeje exercícios adequados',
                        icon: Icons.directions_run,
                        route: '/calculators/exercise',
                      ),
                      _ToolItem(
                        title: 'Idade do Pet',
                        subtitle: 'Converta a idade do seu pet para anos humanos',
                        icon: Icons.cake,
                        route: '/calculators/animal-age',
                      ),
                      _ToolItem(
                        title: 'Gestação',
                        subtitle: 'Acompanhe a gestação do seu pet',
                        icon: Icons.pregnant_woman,
                        route: '/calculators/pregnancy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Calculadoras Veterinárias',
                    icon: Icons.medical_services,
                    color: Colors.red,
                    tools: [
                      _ToolItem(
                        title: 'Dosagem de Medicamentos',
                        subtitle: 'Calcule dosagens precisas para medicamentos',
                        icon: Icons.medication,
                        route: '/calculators/medication-dosage',
                      ),
                      _ToolItem(
                        title: 'Fluidoterapia',
                        subtitle: 'Calcule necessidades de fluidos IV',
                        icon: Icons.water,
                        route: '/calculators/fluid-therapy',
                      ),
                      _ToolItem(
                        title: 'Anestesia',
                        subtitle: 'Cálculos para procedimentos anestésicos',
                        icon: Icons.healing,
                        route: '/calculators/anesthesia',
                      ),
                      _ToolItem(
                        title: 'Insulina para Diabetes',
                        subtitle: 'Calcule doses de insulina para pets diabéticos',
                        icon: Icons.bloodtype,
                        route: '/calculators/diabetes-insulin',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_ToolItem> tools,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
        ...tools.map((tool) => _buildToolCard(context, tool, color)),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool, Color sectionColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sectionColor.withValues(alpha: 0.15),
          child: Icon(
            tool.icon,
            color: sectionColor,
          ),
        ),
        title: Text(
          tool.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(tool.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(tool.route),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
