import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/utils/error_handler.dart';
import 'package:app_agrihurbi/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriHurbi'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      context.push('/home/profile');
                      break;
                    case 'settings':
                      context.push('/home/settings');
                      break;
                    case 'logout':
                      final result = await authProvider.logout();
                      result.fold(
                        (failure) {
                          if (context.mounted) {
                            ErrorHandler.showErrorSnackbar(context, failure);
                          }
                        },
                        (_) {
                          if (context.mounted) {
                            ErrorHandler.showSuccessSnackbar(
                              context, 
                              'Logout realizado com sucesso!',
                            );
                            context.go('/login');
                          }
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Configurações'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app_outlined),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.secondaryColor,
                    child: Icon(
                      Icons.person,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              title: 'Rebanho',
              icon: Icons.pets,
              color: AppColors.cattle,
              onTap: () => context.push('/home/livestock'),
            ),
            _buildFeatureCard(
              context,
              title: 'Calculadoras',
              icon: Icons.calculate,
              color: AppTheme.accentColor,
              onTap: () => context.push('/home/calculators'),
            ),
            _buildFeatureCard(
              context,
              title: 'Clima',
              icon: Icons.wb_sunny,
              color: AppColors.sunny,
              onTap: () => context.push('/home/weather'),
            ),
            _buildFeatureCard(
              context,
              title: 'Notícias',
              icon: Icons.newspaper,
              color: AppColors.completed,
              onTap: () => context.push('/home/news'),
            ),
            _buildFeatureCard(
              context,
              title: 'Mercados',
              icon: Icons.trending_up,
              color: AppColors.active,
              onTap: () => context.push('/home/markets'),
            ),
            _buildFeatureCard(
              context,
              title: 'Configurações',
              icon: Icons.settings,
              color: AppColors.inactive,
              onTap: () => context.push('/home/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}