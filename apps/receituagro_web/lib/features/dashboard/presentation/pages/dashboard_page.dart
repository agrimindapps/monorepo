import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/internal_page_layout.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Dashboard page - Internal home after login
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return InternalPageLayout(
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            authState.whenOrNull(
              data: (user) {
                if (user != null) {
                  return _buildWelcomeHeader(context, user.name);
                }
                return null;
              },
            ) ?? const SizedBox.shrink(),

            const SizedBox(height: 32),

            // Quick access cards
            Text(
              'Acesso Rápido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _QuickAccessCard(
                      icon: Icons.agriculture,
                      title: 'Defensivos',
                      subtitle: 'Gerenciar defensivos agrícolas',
                      color: Colors.green,
                      onTap: () => Navigator.of(context).pushNamed('/defensivos'),
                    ),
                    _QuickAccessCard(
                      icon: Icons.grass,
                      title: 'Culturas',
                      subtitle: 'Gerenciar culturas',
                      color: Colors.lightGreen,
                      onTap: () => Navigator.of(context).pushNamed('/culturas'),
                    ),
                    _QuickAccessCard(
                      icon: Icons.bug_report,
                      title: 'Pragas',
                      subtitle: 'Gerenciar pragas',
                      color: Colors.orange,
                      onTap: () => Navigator.of(context).pushNamed('/pragas'),
                    ),
                    // Admin card (only for admins)
                    authState.whenOrNull(
                      data: (user) {
                        if (user?.isAdmin == true) {
                          return _QuickAccessCard(
                            icon: Icons.admin_panel_settings,
                            title: 'Admin',
                            subtitle: 'Painel administrativo',
                            color: Colors.blue,
                            onTap: () => Navigator.of(context).pushNamed('/admin'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ) ?? const SizedBox.shrink(),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Information section
            _buildInfoSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.agriculture,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sistema de Gestão Agrícola',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Sistema',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'Usuário',
              value: authState.whenOrNull(
                    data: (user) => user?.name ?? 'N/A',
                  ) ??
                  'Carregando...',
            ),
            const Divider(),
            _buildInfoRow(
              context,
              icon: Icons.badge,
              label: 'Função',
              value: authState.whenOrNull(
                    data: (user) => user?.role.displayName ?? 'N/A',
                  ) ??
                  'Carregando...',
            ),
            const Divider(),
            _buildInfoRow(
              context,
              icon: Icons.email,
              label: 'Email',
              value: authState.whenOrNull(
                    data: (user) => user?.email ?? 'N/A',
                  ) ??
                  'Carregando...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }
}

/// Quick access card widget
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final MaterialColor color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color.shade700,
                ),
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
                      color: Colors.grey[600],
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
