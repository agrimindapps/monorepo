import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

/// Web layout with fixed sidebar for desktop
class WebInternalLayout extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const WebInternalLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Use drawer on mobile, fixed sidebar on web
    final useDrawer = screenWidth < 900;

    if (useDrawer) {
      return _buildMobileLayout(context, ref, authState);
    } else {
      return _buildWebLayout(context, ref, authState);
    }
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    return Scaffold(
      appBar: _buildAppBar(context, ref, authState),
      drawer: _buildDrawer(context, ref, authState),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Fixed sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildSidebarContent(context, ref, authState),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, ref, authState, showDrawerButton: false),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState, {
    bool showDrawerButton = true,
  }) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showDrawerButton,
      actions: [
        if (actions != null) ...actions!,
        _buildUserMenu(context, ref, authState),
      ],
    );
  }

  Widget _buildUserMenu(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: PopupMenuButton<String>(
            tooltip: 'Menu do usuário',
            icon: CircleAvatar(
              backgroundColor: Colors.green.shade700,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        user.role.displayName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.green.shade100,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  dense: true,
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
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
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              }
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Drawer _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    return Drawer(
      child: _buildSidebarContent(context, ref, authState),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue authState,
  ) {
    return Column(
      children: [
        // Header
        authState.when(
          data: (user) {
            if (user == null) return _buildGuestHeader();
            return _buildUserHeader(user);
          },
          loading: () => _buildLoadingHeader(),
          error: (_, __) => _buildGuestHeader(),
        ),

        // Menu items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildMenuSection(
                context,
                title: 'Sistema de Gestão Agrícola',
                subtitle: 'Bem-vindo, lucinely!',
              ),
              const SizedBox(height: 16),
              _buildMenuTitle('Acesso Rápido'),
              _buildMenuItem(
                context,
                icon: Icons.agriculture,
                title: 'Defensivos',
                subtitle: 'Gerenciar defensivos agrícolas',
                route: '/defensivos',
                color: Colors.green,
              ),
              _buildMenuItem(
                context,
                icon: Icons.grass,
                title: 'Culturas',
                subtitle: 'Gerenciar culturas',
                route: '/culturas',
                color: Colors.lightGreen,
              ),
              _buildMenuItem(
                context,
                icon: Icons.bug_report,
                title: 'Pragas',
                subtitle: 'Gerenciar pragas',
                route: '/pragas',
                color: Colors.orange,
              ),
              authState.whenOrNull(
                    data: (user) {
                      if (user?.isAdmin == true) {
                        return Column(
                          children: [
                            const Divider(),
                            _buildMenuTitle('ADMINISTRAÇÃO'),
                            _buildMenuItem(
                              context,
                              icon: Icons.admin_panel_settings,
                              title: 'Painel Admin',
                              subtitle: 'Painel administrativo',
                              route: '/admin',
                              color: Colors.blue,
                            ),
                          ],
                        );
                      }
                      return null;
                    },
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),

        // Footer with system info
        const Divider(),
        _buildSystemInfo(authState),
      ],
    );
  }

  Widget _buildUserHeader(user) {
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.agriculture,
              size: 28,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo, lucinely!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistema de Gestão Agrícola',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader() {
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
      ),
      child: const Center(
        child: Icon(
          Icons.agriculture,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return const SizedBox(
      height: 150,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Container();
  }

  Widget _buildMenuTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required MaterialColor color,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color.shade100 : color.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? color.shade700 : color.shade600,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color.shade700 : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }

  Widget _buildSystemInfo(AsyncValue authState) {
    return authState.whenOrNull(
          data: (user) {
            if (user == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Sistema',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person, 'Usuário:', user.name),
                  _buildInfoRow(Icons.work, 'Função:', user.role.displayName),
                  _buildInfoRow(Icons.email, 'Email:', user.email),
                ],
              ),
            );
          },
        ) ??
        const SizedBox.shrink();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
