import 'package:core/core.dart' show FeedbackDialog;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/calculator_registry.dart';
import '../providers/category_providers.dart';
import '../providers/user_preferences_providers.dart';
import '../theme/adaptive_colors.dart';

/// URLs para políticas
class _LegalUrls {
  static const String privacyPolicy = 
      'https://agrimindapps.blogspot.com/2022/08/a-agrimind-apps-construiu-o-aplicativo.html';
  static const String termsOfUse = 
      'https://agrimindapps.blogspot.com/2022/08/receituagro-termos-e-condicoes.html';
}

/// Quick filter data model
class QuickFilterData {
  final String label;
  final String filterParam;
  final IconData icon;
  final Color color;

  const QuickFilterData({
    required this.label,
    required this.filterParam,
    required this.icon,
    required this.color,
  });
}

/// Reusable category menu widget for sidebar navigation
/// Uses CalculatorRegistry as single source of truth for counts
/// Includes quick filters (Favoritos, Recentes, Popular)
/// Adapts to light/dark theme
class CategoryMenu extends ConsumerWidget {
  final String? currentCategory;
  final String? currentFilter;
  final VoidCallback? onCategorySelected;
  final VoidCallback? onFilterSelected;
  final bool closeDrawerOnTap;
  final bool showBackToHome;
  final bool showQuickFilters;
  final bool showLegalLinks;
  final Widget? themeToggleButton;

  const CategoryMenu({
    super.key,
    this.currentCategory,
    this.currentFilter,
    this.onCategorySelected,
    this.onFilterSelected,
    this.closeDrawerOnTap = false,
    this.showBackToHome = false,
    this.showQuickFilters = true,
    this.showLegalLinks = true,
    this.themeToggleButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);
    final colors = context.colors;
    
    // Get filter counts
    final favoritesAsync = ref.watch(favoriteCalculatorsProvider);
    final recentsAsync = ref.watch(recentCalculatorsProvider);
    final favoritesCount = favoritesAsync.value?.length ?? 0;
    final recentsCount = recentsAsync.value?.length ?? 0;
    final popularCount = CalculatorRegistry.popularCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick filters section
        if (showQuickFilters) ...[
          _buildSectionHeader(context, 'FILTROS RÁPIDOS'),
          const SizedBox(height: 8),
          _buildFilterItem(
            context,
            label: 'Favoritos',
            filterParam: 'favoritos',
            icon: Icons.favorite,
            color: AdaptiveColors.filterFavorites,
            count: favoritesCount,
          ),
          _buildFilterItem(
            context,
            label: 'Recentes',
            filterParam: 'recentes',
            icon: Icons.history,
            color: AdaptiveColors.filterRecents,
            count: recentsCount,
          ),
          _buildFilterItem(
            context,
            label: 'Popular',
            filterParam: 'popular',
            icon: Icons.star,
            color: AdaptiveColors.filterPopular,
            count: popularCount,
          ),
          const SizedBox(height: 24),
        ],

        // Categories section
        _buildSectionHeader(context, 'CATEGORIAS'),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: colors.sidebarBorder, height: 1),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: themeToggleButton!,
          ),
          const SizedBox(height: 16),
        ],
        
        // Legal links section (Privacy Policy & Terms of Use)
        if (showLegalLinks) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: colors.sidebarBorder, height: 1),
          ),
          const SizedBox(height: 12),
          // Feedback button
          _buildFeedbackButton(context),
          const SizedBox(height: 12),
          _buildLegalLinksSection(context),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
  
  Widget _buildFeedbackButton(BuildContext context) {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (closeDrawerOnTap) {
              Navigator.of(context).pop();
            }
            FeedbackDialog.show(
              context,
              primaryColor: AdaptiveColors.filterFavorites,
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AdaptiveColors.filterFavorites.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AdaptiveColors.filterFavorites.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: AdaptiveColors.filterFavorites,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enviar Feedback',
                  style: TextStyle(
                    color: colors.sidebarTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegalLinksSection(BuildContext context) {
    final colors = context.colors;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegalLink(
            context,
            label: 'Privacidade',
            url: _LegalUrls.privacyPolicy,
            colors: colors,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '•',
              style: TextStyle(
                color: colors.sidebarTextMuted,
                fontSize: 10,
              ),
            ),
          ),
          _buildLegalLink(
            context,
            label: 'Termos de Uso',
            url: _LegalUrls.termsOfUse,
            colors: colors,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegalLink(
    BuildContext context, {
    required String label,
    required String url,
    required AdaptiveColors colors,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: TextStyle(
            color: colors.sidebarTextMuted,
            fontSize: 11,
            decoration: TextDecoration.underline,
            decorationColor: colors.sidebarTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          color: colors.sidebarTextMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFilterItem(
    BuildContext context, {
    required String label,
    required String filterParam,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    final isSelected = currentFilter == filterParam;
    final colors = context.colors;

    return InkWell(
      onTap: () {
        if (closeDrawerOnTap) {
          Navigator.of(context).pop();
        }
        
        // Navigate to home with filter parameter
        context.go('/home?filter=$filterParam');
        
        onFilterSelected?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : colors.sidebarTextMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? colors.sidebarTextPrimary
                      : colors.sidebarTextSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : colors.sidebarTextPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? color
                      : colors.sidebarTextMuted,
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

  Widget _buildCategoryItem(BuildContext context, CategoryData category) {
    final isSelected = currentCategory == category.routeParam;
    final itemColor = category.color ?? AdaptiveColors.categoryFinancial;
    final colors = context.colors;

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
                  : colors.sidebarTextMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  color: isSelected
                      ? colors.sidebarTextPrimary
                      : colors.sidebarTextSecondary,
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
                      : colors.sidebarTextPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${category.count}',
                  style: TextStyle(
                    color: isSelected
                        ? itemColor
                        : colors.sidebarTextMuted,
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
    final colors = context.colors;
    
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
          color: colors.sidebarTextPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.sidebarBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              color: colors.sidebarTextSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Voltar ao Início',
              style: TextStyle(
                color: colors.sidebarTextPrimary.withValues(alpha: 0.9),
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
