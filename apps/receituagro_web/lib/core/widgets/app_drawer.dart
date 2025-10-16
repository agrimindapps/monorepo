import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

/// Application drawer with navigation menu
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Drawer(
      child: Column(
        children: [
          // Header with user info
          authState.when(
            data: (user) {
              if (user == null) {
                return _buildGuestHeader(context);
              }
              return _buildUserHeader(context, user);
            },
            loading: () => _buildLoadingHeader(),
            error: (_, __) => _buildGuestHeader(context),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuSection(
                  context,
                  title: 'GESTÃO AGRÍCOLA',
                  items: [
                    _MenuItem(
                      icon: Icons.agriculture,
                      title: 'Defensivos',
                      subtitle: 'Gerenciar defensivos agrícolas',
                      route: '/defensivos',
                      color: Colors.green,
                    ),
                    _MenuItem(
                      icon: Icons.grass,
                      title: 'Culturas',
                      subtitle: 'Gerenciar culturas',
                      route: '/culturas',
                      color: Colors.lightGreen,
                    ),
                    _MenuItem(
                      icon: Icons.bug_report,
                      title: 'Pragas',
                      subtitle: 'Gerenciar pragas',
                      route: '/pragas',
                      color: Colors.orange,
                    ),
                  ],
                ),

                const Divider(),

                // Admin section
                authState.whenOrNull(
                  data: (user) {
                    if (user?.isAdmin == true) {
                      return _buildMenuSection(
                        context,
                        title: 'ADMINISTRAÇÃO',
                        items: [
                          _MenuItem(
                            icon: Icons.admin_panel_settings,
                            title: 'Painel Admin',
                            subtitle: 'Painel administrativo',
                            route: '/admin',
                            color: Colors.blue,
                          ),
                          _MenuItem(
                            icon: Icons.people,
                            title: 'Usuários',
                            subtitle: 'Gerenciar usuários',
                            route: '/users',
                            color: Colors.purple,
                          ),
                        ],
                      );
                    }
                    return null;
                  },
                ) ?? const SizedBox.shrink(),
              ],
            ),
          ),

          // Footer with logout
          const Divider(),
          authState.whenOrNull(
            data: (user) {
              if (user != null) {
                return _buildLogoutButton(context, ref);
              }
              return null;
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 40,
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      accountName: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              user.role.displayName,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            backgroundColor: Colors.green.shade900,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          const Text(
            'ReceituAgro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.green,
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(context, item)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == item.route;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withOpacity(0.2) : item.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: isSelected ? item.color.shade700 : item.color.shade600,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? item.color.shade700 : null,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
      ),
      selected: isSelected,
      selectedTileColor: item.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        if (!isSelected) {
          Navigator.of(context).pushNamed(item.route);
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Sair',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair'),
            content: const Text('Deseja realmente sair do sistema?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logout realizado com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
    );
  }
}

/// Internal menu item model
class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final MaterialColor color;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });
}
