import 'package:core/core.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layout base para páginas administrativas do Calculei
/// 
/// Tema: Teal/Verde (#009688)
class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final List<Widget>? actions;

  // Calculei theme colors
  static const _primaryColor = Color(0xFF009688); // Teal
  static const _primaryDark = Color(0xFF00796B); // Dark teal

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    this.actions,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade50,
      appBar: isDesktop ? null : _buildMobileAppBar(context, isDark),
      drawer: isDesktop ? null : _buildDrawer(context, isDark),
      body: isDesktop
          ? Row(
              children: [
                _buildSidebar(context, isDark),
                Expanded(
                  child: Column(
                    children: [
                      _buildDesktopHeader(context, isDark),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : child,
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF252545) : Colors.white,
      foregroundColor: _primaryColor,
      elevation: 0,
      title: Text(title),
      actions: actions,
    );
  }

  Widget _buildDesktopHeader(BuildContext context, bool isDark) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252545) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252545) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context, isDark),
          Expanded(child: _buildNavigationItems(context, isDark)),
          _buildSidebarFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF252545) : Colors.white,
      child: Column(
        children: [
          _buildSidebarHeader(context, isDark),
          Expanded(child: _buildNavigationItems(context, isDark)),
          _buildSidebarFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context, bool isDark) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calculei',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, bool isDark) {
    final items = [
      _NavigationItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: '/admin/dashboard',
        isSelected: currentRoute == '/admin/dashboard',
      ),
      _NavigationItem(
        icon: Icons.bug_report,
        label: 'Logs de Erros',
        route: '/admin/errors',
        isSelected: currentRoute == '/admin/errors',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items.map((item) => _buildNavItem(context, item, isDark)).toList(),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavigationItem item, bool isDark) {
    final isSelected = item.isSelected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go(item.route);
            // Safe way to close drawer if open
            try {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold != null && scaffold.hasDrawer && scaffold.isDrawerOpen) {
                Navigator.of(context).pop(); // Close drawer
              }
            } catch (_) {
              // Ignore if no scaffold found
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: _primaryColor.withValues(alpha: 0.3)) : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? _primaryColor : (isDark ? Colors.white70 : Colors.black54),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? _primaryColor : (isDark ? Colors.white : Colors.black87),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user?.email != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _primaryColor,
                    child: Text(
                      user!.email![0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.email!,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
  });
}
