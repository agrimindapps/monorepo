import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Layout base para páginas administrativas do Plantis
/// 
/// Fornece:
/// - Sidebar de navegação responsivo
/// - Header com título e ações
/// - Dark mode support
/// - Tema verde do Plantis
class AdminLayout extends StatelessWidget {
  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String currentRoute;
  final String title;
  final Widget child;
  final List<Widget> actions;

  // Plantis theme colors
  static const _primaryColor = Color(0xFF4CAF50); // Verde
  static const _accentColor = Color(0xFF2E7D32); // Verde escuro
  static const _cardColor = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D1E) : Colors.grey[50],
      appBar: isMobile ? _buildMobileAppBar(context, isDark) : null,
      drawer: isMobile ? _buildDrawer(context, isDark) : null,
      body: Row(
        children: [
          // Sidebar (apenas desktop/tablet)
          if (!isMobile) _buildSidebar(context, isDark, isTablet),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header (desktop/tablet)
                if (!isMobile) _buildHeader(context, isDark),

                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.eco, color: _primaryColor, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? _cardColor : Colors.white,
      elevation: 0,
      actions: actions,
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? _cardColor : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? _accentColor : _primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'CantinhoVerde',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Feedbacks',
                  route: '/admin/dashboard',
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.bug_report_outlined,
                  label: 'Logs de Erros',
                  route: '/admin/errors',
                  isDark: isDark,
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  label: 'Sair',
                  route: '/admin',
                  isDark: isDark,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark, bool isTablet) {
    final width = isTablet ? 72.0 : 240.0;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo/Brand
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: isTablet
                ? const Icon(Icons.eco, color: _primaryColor, size: 32)
                : Row(
                    children: [
                      const Icon(Icons.eco, color: _primaryColor, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CantinhoVerde',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          Divider(
            color: isDark ? Colors.white10 : Colors.grey[200],
            height: 1,
          ),

          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Feedbacks',
                  route: '/admin/dashboard',
                  isDark: isDark,
                  isTablet: isTablet,
                ),
                _buildSidebarItem(
                  context,
                  icon: Icons.bug_report_outlined,
                  label: 'Logs de Erros',
                  route: '/admin/errors',
                  isDark: isDark,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),

          // Logout
          Divider(
            color: isDark ? Colors.white10 : Colors.grey[200],
            height: 1,
          ),
          _buildSidebarItem(
            context,
            icon: Icons.logout,
            label: 'Sair',
            route: '/admin',
            isDark: isDark,
            isTablet: isTablet,
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? _cardColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForRoute(currentRoute),
            size: 28,
            color: _primaryColor,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isDark,
    required bool isTablet,
    VoidCallback? onTap,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Tooltip(
        message: isTablet ? label : '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () => context.go(route),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? _primaryColor.withOpacity(0.2) : _primaryColor.withOpacity(0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive
                    ? Border.all(color: _primaryColor.withOpacity(0.3))
                    : null,
              ),
              child: isTablet
                  ? Icon(
                      icon,
                      size: 24,
                      color: isActive
                          ? _primaryColor
                          : (isDark ? Colors.white70 : Colors.black54),
                    )
                  : Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isActive
                              ? _primaryColor
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? _primaryColor
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? _primaryColor : (isDark ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? _primaryColor : null,
        ),
      ),
      selected: isActive,
      selectedTileColor: _primaryColor.withOpacity(0.1),
      onTap: onTap ?? () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }

  IconData _getIconForRoute(String route) {
    switch (route) {
      case '/admin/dashboard':
        return Icons.dashboard_outlined;
      case '/admin/errors':
        return Icons.bug_report_outlined;
      default:
        return Icons.admin_panel_settings;
    }
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/admin');
    }
  }
}
