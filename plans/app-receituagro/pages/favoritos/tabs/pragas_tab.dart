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

class PragasTab extends StatelessWidget {
  final FavoritosController controller;
  
  const PragasTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        // Evita piscada aguardando dados estarem prontos
        if (controller.isLoading && controller.favoritosData.pragas.isEmpty) {
          return Container(); // Container vazio sem loading visual
        }

        final pragas = controller.favoritosData.pragasFiltered;
        final viewMode = controller.getViewModeForTab(1);
        final isDark = themeController.isDark.value;

        return _buildContent(context, pragas, viewMode.value, controller, isDark);
      }),
    );
  }



  Widget _buildContent(
    BuildContext context,
    List<dynamic> pragas,
    String viewMode,
    FavoritosController controller,
    bool isDark,
  ) {
    
    if (pragas.isEmpty) {
      // Verificar se há busca ativa para tab de pragas (índice 1)
      final isSearching = controller.isSearchingForTab(1);
      final searchText = controller.getSearchTextForTab(1);
      
      if (isSearching && searchText.isNotEmpty) {
        // Mostra widget de busca sem resultados
        return NoSearchResultsWidget(
          searchText: searchText,
          accentColor: FavoritosDesignTokens.pragasColor,
        );
      } else {
        // Mostra empty state normal
        return const EmptyStateWidget(
          title: 'Nenhuma praga favoritada',
          message: 'Você ainda não possui pragas favoritas.',
          accentColor: FavoritosDesignTokens.pragasColor,
        );
      }
    }

    return Column(
      children: [
        
        // Lista de favoritos
        Expanded(
          child: ListContentWidget(
            items: pragas,
            viewMode: viewMode,
            tabIndex: 1,
            cardColor: Theme.of(context).cardColor,
            borderColor: FavoritosDesignTokens.pragasColor,
            iconColor: FavoritosDesignTokens.pragasColor,
            controller: controller,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}
