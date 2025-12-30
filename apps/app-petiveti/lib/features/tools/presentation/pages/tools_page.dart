import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/petiveti_page_header.dart';

/// Página de Ferramentas que agrupa calculadoras, lembretes e outras utilidades
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: PetivetiPageHeader(
                icon: Icons.build_circle,
                title: 'Ferramentas',
                subtitle: 'Calculadoras e utilidades',
                showBackButton: false,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Lembretes como primeiro item destacado
                  _buildHighlightedTool(
                    context,
                    title: 'Lembretes',
                    subtitle: 'Gerencie lembretes de vacinas, medicamentos e consultas',
                    icon: Icons.notifications_active,
                    color: Colors.orange,
                    route: '/reminders',
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    context,
                    title: 'Calculadoras',
                    icon: Icons.calculate,
                    color: Colors.blue,
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
                        title: 'Exercícios',
                        subtitle: 'Planeje exercícios adequados',
                        icon: Icons.directions_run,
                        route: '/calculators/exercise',
                      ),
                      _ToolItem(
                        title: 'Idade do Pet',
                        subtitle: 'Converta a idade do seu pet',
                        icon: Icons.cake,
                        route: '/calculators/animal-age',
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
                      _ToolItem(
                        title: 'Gestação',
                        subtitle: 'Acompanhe a gestação',
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
                        subtitle: 'Calcule dosagens precisas',
                        icon: Icons.medication,
                        route: '/calculators/medication-dosage',
                      ),
                      _ToolItem(
                        title: 'Fluidoterapia',
                        subtitle: 'Calcule necessidades de fluidos',
                        icon: Icons.water,
                        route: '/calculators/fluid-therapy',
                      ),
                      _ToolItem(
                        title: 'Anestesia',
                        subtitle: 'Cálculos para procedimentos',
                        icon: Icons.healing,
                        route: '/calculators/anesthesia',
                      ),
                      _ToolItem(
                        title: 'Insulina para Diabetes',
                        subtitle: 'Calcule doses de insulina',
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

  Widget _buildHighlightedTool(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
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
        ...tools.map((tool) => _buildToolCard(context, tool)),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolItem tool) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            tool.icon,
            color: Theme.of(context).colorScheme.primary,
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
