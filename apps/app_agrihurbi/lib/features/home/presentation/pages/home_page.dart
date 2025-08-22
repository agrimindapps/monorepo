import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_agrihurbi/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_agrihurbi/core/theme/app_theme.dart';
import 'package:app_agrihurbi/core/router/app_router.dart';

/// Home page
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriHurbi'),
        actions: [
          GetBuilder<AuthController>(
            builder: (controller) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      AppNavigation.toProfile();
                      break;
                    case 'settings':
                      AppNavigation.toSettings();
                      break;
                    case 'logout':
                      controller.logout();
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
              onTap: () => AppNavigation.toLivestock(),
            ),
            _buildFeatureCard(
              context,
              title: 'Calculadoras',
              icon: Icons.calculate,
              color: AppTheme.accentColor,
              onTap: () => AppNavigation.toCalculators(),
            ),
            _buildFeatureCard(
              context,
              title: 'Clima',
              icon: Icons.wb_sunny,
              color: AppColors.sunny,
              onTap: () => AppNavigation.toWeather(),
            ),
            _buildFeatureCard(
              context,
              title: 'Notícias',
              icon: Icons.newspaper,
              color: AppColors.completed,
              onTap: () => AppNavigation.toNews(),
            ),
            _buildFeatureCard(
              context,
              title: 'Mercados',
              icon: Icons.trending_up,
              color: AppColors.active,
              onTap: () => AppNavigation.toMarkets(),
            ),
            _buildFeatureCard(
              context,
              title: 'Configurações',
              icon: Icons.settings,
              color: AppColors.inactive,
              onTap: () => AppNavigation.toSettings(),
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
                color.withOpacity(0.8),
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