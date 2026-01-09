import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Category data structure
class CalculatorCategory {
  final String label;
  final IconData icon;
  final Color? color;
  final int count;
  final String routeParam;

  const CalculatorCategory({
    required this.label,
    required this.icon,
    required this.count,
    required this.routeParam,
    this.color,
  });
}

/// Reusable category menu widget for sidebar navigation
/// Matches the home page category sidebar style
class CategoryMenu extends StatelessWidget {
  final String? currentCategory;
  final VoidCallback? onCategorySelected;
  final bool closeDrawerOnTap;
  final bool showBackToHome;
  final Widget? themeToggleButton;

  const CategoryMenu({
    super.key,
    this.currentCategory,
    this.onCategorySelected,
    this.closeDrawerOnTap = false,
    this.showBackToHome = false,
    this.themeToggleButton,
  });

  // Category data - synced with home page
  static const categories = [
    CalculatorCategory(
      label: 'Todos',
      icon: Icons.apps,
      count: 0, // Will be calculated dynamically
      routeParam: 'todos',
    ),
    CalculatorCategory(
      label: 'Financeiro',
      icon: Icons.account_balance_wallet,
      color: Colors.blue,
      count: 7,
      routeParam: 'financeiro',
    ),
    CalculatorCategory(
      label: 'Construção',
      icon: Icons.construction,
      color: Colors.orange,
      count: 4,
      routeParam: 'construcao',
    ),
    CalculatorCategory(
      label: 'Saúde',
      icon: Icons.favorite_border,
      color: Colors.pink,
      count: 3,
      routeParam: 'saude',
    ),
    CalculatorCategory(
      label: 'Pet',
      icon: Icons.pets,
      color: Colors.brown,
      count: 1,
      routeParam: 'pet',
    ),
    CalculatorCategory(
      label: 'Agricultura',
      icon: Icons.agriculture,
      color: Colors.teal,
      count: 1,
      routeParam: 'agricultura',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 8),
        ...categories.map((category) => _buildCategoryItem(context, category)),
        
        // Back to home button (optional)
        if (showBackToHome) ...[
          const SizedBox(height: 24),
          _buildBackToHomeButton(context),
        ],
        
        // Theme toggle button (optional)
        if (themeToggleButton != null) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white10, height: 1),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: themeToggleButton!,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        'CATEGORIAS',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CalculatorCategory category) {
    final isSelected = currentCategory == category.routeParam;
    final itemColor = category.color ?? const Color(0xFF4CAF50);

    return InkWell(
      onTap: () {
        if (closeDrawerOnTap) {
          Navigator.of(context).pop();
        }
        
        // Navigate to home with category parameter
        context.go('/home?category=${category.routeParam}');
        
        onCategorySelected?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? itemColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: itemColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              category.icon,
              color: isSelected
                  ? itemColor
                  : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (category.count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? itemColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${category.count}',
                  style: TextStyle(
                    color: isSelected
                        ? itemColor
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (closeDrawerOnTap) {
          Navigator.of(context).pop();
        }
        context.go('/home');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Voltar ao Início',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
