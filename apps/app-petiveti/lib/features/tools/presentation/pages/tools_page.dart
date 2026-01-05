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
                subtitle: 'Recursos úteis para cuidar do seu pet',
                showBackButton: false,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
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
                  const SizedBox(height: 16),
                  
                  // Calculadoras como segundo item destacado
                  _buildHighlightedTool(
                    context,
                    title: 'Calculadoras',
                    subtitle: 'Calorias, peso ideal, hidratação, dosagem e muito mais',
                    icon: Icons.calculate,
                    color: Colors.blue,
                    route: '/calculators',
                  ),
                  const SizedBox(height: 24),
                  
                  // Outras ferramentas
                  _buildSectionTitle(context, 'Outras Utilidades', Icons.apps, Colors.purple),
                  const SizedBox(height: 12),
                  
                  _buildToolCard(
                    context,
                    title: 'Agenda de Vacinas',
                    subtitle: 'Visualize o calendário de vacinação',
                    icon: Icons.calendar_month,
                    color: Colors.teal,
                    route: '/vaccines',
                  ),
                  _buildToolCard(
                    context,
                    title: 'Controle de Peso',
                    subtitle: 'Histórico e gráficos de peso',
                    icon: Icons.show_chart,
                    color: Colors.indigo,
                    route: '/weight',
                  ),
                  _buildToolCard(
                    context,
                    title: 'Despesas',
                    subtitle: 'Acompanhe os gastos com seu pet',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    route: '/expenses',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
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
                padding: const EdgeInsets.all(8),
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

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
