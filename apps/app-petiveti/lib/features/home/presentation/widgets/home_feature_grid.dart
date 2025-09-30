import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/home_provider.dart';

/// **Home Feature Grid**
/// 
/// Responsive grid of feature cards with dynamic badges and navigation.
/// Adapts layout based on screen size and displays relevant statistics.
class HomeFeatureGrid extends StatelessWidget {
  final HomeStatsState stats;

  const HomeFeatureGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Menu de funcionalidades do PetiVeti',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isTablet = screenWidth > 600;
          final crossAxisCount = isTablet ? 4 : 2;
          final maxCrossAxisExtent = screenWidth / crossAxisCount - 16;
          
          return GridView.extent(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            maxCrossAxisExtent: maxCrossAxisExtent.clamp(150, 250),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.2 : 1.0,
            children: _buildFeatureCards(context),
          );
        },
      ),
    );
  }

  List<Widget> _buildFeatureCards(BuildContext context) {
    return [
      FeatureCard(
        icon: Icons.pets,
        title: 'Meus Pets',
        subtitle: 'Gerencie seus animais',
        route: '/animals',
        color: Theme.of(context).colorScheme.primary,
        badge: stats.totalAnimals > 0 ? stats.totalAnimals.toString() : null,
      ),
      FeatureCard(
        icon: Icons.calendar_today,
        title: 'Consultas',
        subtitle: 'Agende e acompanhe',
        route: '/appointments',
        color: Theme.of(context).colorScheme.secondary,
        badge: stats.upcomingAppointments > 0 
          ? stats.upcomingAppointments.toString() 
          : null,
      ),
      FeatureCard(
        icon: Icons.vaccines,
        title: 'Vacinas',
        subtitle: 'Controle de vacinas',
        route: '/vaccines',
        color: Theme.of(context).colorScheme.tertiary,
        badge: stats.pendingVaccinations > 0 
          ? stats.pendingVaccinations.toString() 
          : null,
      ),
      FeatureCard(
        icon: Icons.medication,
        title: 'Medicamentos',
        subtitle: 'Gerencie medicações',
        route: '/medications',
        color: Theme.of(context).colorScheme.error,
        badge: stats.activeMedications > 0 
          ? stats.activeMedications.toString() 
          : null,
      ),
      FeatureCard(
        icon: Icons.monitor_weight,
        title: 'Peso',
        subtitle: 'Controle de peso',
        route: '/weight',
        color: Theme.of(context).colorScheme.surfaceTint,
      ),
      FeatureCard(
        icon: Icons.calculate,
        title: 'Calculadoras',
        subtitle: 'Ferramentas veterinárias',
        route: '/calculators',
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
    ];
  }
}

/// **Feature Card Component**
/// 
/// Individual feature card with icon, title, subtitle, and optional badge.
/// Includes semantic labeling and navigation handling.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final String? badge;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final badgeText = badge != null ? ', $badge itens pendentes' : '';
    
    return Semantics(
      label: '$title, $subtitle$badgeText',
      hint: 'Toque para acessar $title',
      button: true,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CardIcon(
                  icon: icon,
                  color: color,
                  badge: badge,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? badge;

  const _CardIcon({
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          icon,
          size: 48,
          color: color,
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}