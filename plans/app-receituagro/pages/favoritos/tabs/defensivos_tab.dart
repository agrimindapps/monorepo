// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../constants/favoritos_design_tokens.dart';
import '../controller/favoritos_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/list_content_widget.dart';
import '../widgets/no_search_results_widget.dart';

class DefensivosTab extends StatelessWidget {
  final FavoritosController controller;

  const DefensivosTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        // Evita piscada aguardando dados estarem prontos
        if (controller.isLoading && controller.favoritosData.defensivos.isEmpty) {
          return Container(); // Container vazio sem loading visual
        }

        final defensivos = controller.favoritosData.defensivosFiltered;
        final viewMode = controller.getViewModeForTab(0);
        final isDark = themeController.isDark.value;

        return _buildContent(
            defensivos, viewMode.value, controller, isDark, context);
      }),
    );
  }



  Widget _buildContent(
    List<dynamic> defensivos,
    String viewMode,
    FavoritosController controller,
    bool isDark,
    BuildContext context,
  ) {
    if (defensivos.isEmpty) {
      // Verificar se há busca ativa para tab de defensivos (índice 0)
      final isSearching = controller.isSearchingForTab(0);
      final searchText = controller.getSearchTextForTab(0);
      
      if (isSearching && searchText.isNotEmpty) {
        // Mostra widget de busca sem resultados
        return NoSearchResultsWidget(
          searchText: searchText,
          accentColor: FavoritosDesignTokens.defensivosColor,
        );
      } else {
        // Mostra empty state normal
        return const EmptyStateWidget(
          title: 'Nenhum defensivo favorito',
          message: 'Você ainda não possui defensivos favoritos.',
          accentColor: FavoritosDesignTokens.defensivosColor,
        );
      }
    }

    return Column(
      children: [

        // Lista de favoritos
        Expanded(
          child: ListContentWidget(
            items: defensivos,
            viewMode: viewMode,
            tabIndex: 0,
            cardColor: Theme.of(context).cardColor,
            borderColor: FavoritosDesignTokens.defensivosColor,
            iconColor: FavoritosDesignTokens.defensivosColor,
            controller: controller,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
