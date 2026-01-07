import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Calculator categories data for the dropdown menu
class CalculatorCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<CalculatorMenuItem> calculators;

  const CalculatorCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.calculators,
  });
}

class CalculatorMenuItem {
  final String title;
  final String route;
  final IconData icon;
  final Color? iconColor;

  const CalculatorMenuItem({
    required this.title,
    required this.route,
    required this.icon,
    this.iconColor,
  });
}

/// Standardized AppBar for all calculator pages
///
/// Inspired by modern web design with:
/// - Logo on the left (always "Calculei")
/// - Navigation links in the center/right
/// - Dropdown menu for calculator categories
class CalculatorAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Additional actions for the AppBar
  final List<Widget>? actions;

  /// Whether to show the back button (defaults to true)
  final bool showBackButton;

  /// Custom back navigation function (defaults to go('/home'))
  final VoidCallback? onBack;

  /// Show the calculators dropdown (defaults to true)
  final bool showCalculatorsDropdown;

  const CalculatorAppBar({
    super.key,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.showCalculatorsDropdown = true,
  });

  static const List<CalculatorCategory> _categories = [
    CalculatorCategory(
      name: 'Trabalhista',
      icon: Icons.work_outline,
      color: Colors.blue,
      calculators: [
        CalculatorMenuItem(
          title: 'Salário Líquido',
          route: '/calculators/financial/net-salary',
          icon: Icons.monetization_on,
          iconColor: Colors.orange,
        ),
        CalculatorMenuItem(
          title: '13º Salário',
          route: '/calculators/financial/thirteenth-salary',
          icon: Icons.card_giftcard,
          iconColor: Colors.green,
        ),
        CalculatorMenuItem(
          title: 'Férias',
          route: '/calculators/financial/vacation',
          icon: Icons.beach_access,
          iconColor: Colors.blue,
        ),
        CalculatorMenuItem(
          title: 'Horas Extras',
          route: '/calculators/financial/overtime',
          icon: Icons.access_time,
          iconColor: Colors.purple,
        ),
        CalculatorMenuItem(
          title: 'Seguro Desemprego',
          route: '/calculators/financial/unemployment-insurance',
          icon: Icons.work_off,
          iconColor: Colors.red,
        ),
      ],
    ),
    CalculatorCategory(
      name: 'Financeiro',
      icon: Icons.account_balance_wallet,
      color: Colors.green,
      calculators: [
        CalculatorMenuItem(
          title: 'Reserva de Emergência',
          route: '/calculators/financial/emergency-reserve',
          icon: Icons.savings,
          iconColor: Colors.teal,
        ),
        CalculatorMenuItem(
          title: 'À Vista vs Parcelado',
          route: '/calculators/financial/cash-vs-installment',
          icon: Icons.payment,
          iconColor: Colors.indigo,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return AppBar(
      centerTitle: true,
      // No explicit styling here, relying on Theme.of(context).appBarTheme
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Back Button + Logo + Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                        onPressed: onBack ?? () => context.go('/home'),
                        tooltip: 'Voltar',
                      ),
                    if (showBackButton) const SizedBox(width: 4),
                    // Logo - Always fixed
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calculate_rounded,
                        size: 22,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // App Name - Always "Calculei"
                    Text(
                      'Calculei',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                // Right side: Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Desktop: Show navigation links
                    if (isDesktop) ...[
                      _NavLink(
                        label: 'Início',
                        onTap: () => context.go('/home'),
                        isDark: isDark,
                      ),
                    ],

                    // Calculators Dropdown
                    if (showCalculatorsDropdown)
                      _CalculatorsDropdown(
                        isDark: isDark,
                        isCompact: !isDesktop,
                      ),

                    // Custom actions
                    if (actions != null) ...actions!,

                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Navigation link for desktop
class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _NavLink({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary
                  : (widget.isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}

/// Calculators dropdown menu
class _CalculatorsDropdown extends StatefulWidget {
  final bool isDark;
  final bool isCompact;

  const _CalculatorsDropdown({required this.isDark, required this.isCompact});

  @override
  State<_CalculatorsDropdown> createState() => _CalculatorsDropdownState();
}

class _CalculatorsDropdownState extends State<_CalculatorsDropdown> {
  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        // Categories with calculators
        for (final category in CalculatorAppBar._categories) ...[
          // Category Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(category.icon, size: 16, color: category.color),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: category.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Calculator Items
          for (final calc in category.calculators)
            MenuItemButton(
              onPressed: () {
                _menuController.close();
                context.go(calc.route);
              },
              leadingIcon: Icon(
                calc.icon,
                size: 20,
                color: calc.iconColor ?? theme.colorScheme.primary,
              ),
              child: Text(calc.title),
            ),
          // Divider between categories (except last)
          if (category != CalculatorAppBar._categories.last)
            const Divider(height: 8),
        ],
      ],
      style: MenuStyle(
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      child: widget.isCompact
          ? IconButton(
              icon: Icon(
                Icons.calculate,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                if (_menuController.isOpen) {
                  _menuController.close();
                } else {
                  _menuController.open();
                }
              },
              tooltip: 'Calculadoras',
            )
          : _DropdownButton(
              isDark: widget.isDark,
              onTap: () {
                if (_menuController.isOpen) {
                  _menuController.close();
                } else {
                  _menuController.open();
                }
              },
            ),
    );
  }
}

/// Styled dropdown button for desktop
class _DropdownButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _DropdownButton({required this.isDark, required this.onTap});

  @override
  State<_DropdownButton> createState() => _DropdownButtonState();
}

class _DropdownButtonState extends State<_DropdownButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Calculadoras',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Common info button for AppBar actions
class InfoAppBarAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const InfoAppBarAction({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      onPressed: onPressed,
      tooltip: tooltip ?? 'Informações',
    );
  }
}

/// Common share button for AppBar actions
class ShareAppBarAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const ShareAppBarAction({super.key, required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        Icons.share_outlined,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      onPressed: onPressed,
      tooltip: tooltip ?? 'Compartilhar',
    );
  }
}
