// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../constants/favoritos_design_tokens.dart';
import '../controller/favoritos_controller.dart';
import '../models/view_mode.dart';
import 'animated_favorito_wrapper.dart';
import 'favorito_widget_factory.dart';

/// Refactored ListContentWidget using Factory Pattern
/// Eliminates massive switch statements using polymorphism
class ListContentWidget extends StatelessWidget {
  final List<dynamic> items;
  final String viewMode;
  final int tabIndex;
  final Color cardColor;
  final Color borderColor;
  final Color iconColor;
  final FavoritosController controller;
  final bool? isDark;

  const ListContentWidget({
    super.key,
    required this.items,
    required this.viewMode,
    required this.tabIndex,
    required this.cardColor,
    required this.borderColor,
    required this.iconColor,
    required this.controller,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Use passed isDark parameter or fallback to ThemeController
    if (isDark != null) {
      return _buildContent(isDark!);
    }
    
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() => _buildContent(themeController.isDark.value)),
    );
  }
  
  Widget _buildContent(bool isDark) {
    // Use ViewMode enum instead of deprecated ViewModeConstants
    if (viewMode == ViewMode.grid.name) {
      return _buildGridView(isDark);
    } else {
      return _buildListView(isDark);
    }
  }

  /// Grid view using Factory Pattern - no switch statements
  Widget _buildGridView(bool isDark) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide.none, // Remove borders
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _calculateCrossAxisCount(context),
                childAspectRatio:
                    1.2, // Same as DefensivosConstants.gridChildAspectRatio
                crossAxisSpacing:
                    10.0, // Same as DefensivosConstants.gridCrossAxisSpacing
                mainAxisSpacing:
                    10.0, // Same as DefensivosConstants.gridMainAxisSpacing
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return AnimatedFavoritoWrapper(
                  index: index,
                  child: FavoritoWidgetFactory.buildGridWidget(
                    item,
                    tabIndex,
                    controller,
                    cardColor,
                    borderColor,
                    iconColor,
                    isDark,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Calculate cross axis count based on screen width
  /// Same logic as DefensivosHelpers.calculateCrossAxisCount
  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600.0) {
      // Same as DefensivosConstants.mobileBreakpoint
      return 2; // Same as DefensivosConstants.mobileCrossAxisCount
    } else if (screenWidth < 960.0) {
      // Same as DefensivosConstants.tabletBreakpoint
      return 3; // Same as DefensivosConstants.tabletCrossAxisCount
    } else {
      return 4; // Same as DefensivosConstants.desktopCrossAxisCount
    }
  }

  /// List view using Factory Pattern - no switch statements
  Widget _buildListView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none, // Remove borders
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: 0, // Removido indent para ocupar de ponta a ponta
            endIndent: 0, // Garantir que não há endIndent também
            color: FavoritosDesignTokens.getBorderColor(context),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return AnimatedFavoritoWrapper(
              index: index,
              child: FavoritoWidgetFactory.buildListWidget(
                item,
                tabIndex,
                controller,
                iconColor,
                isDark,
              ),
            );
          },
        ),
      ),
    );
  }
}
