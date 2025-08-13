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

class DiagnosticoTab extends StatelessWidget {
  final FavoritosController controller;

  const DiagnosticoTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Obx(() {
        // Verificar se o usuário é premium primeiro
        if (!controller.isPremium) {
          return _buildPremiumGate(context);
        }

        // Evita piscada aguardando dados estarem prontos
        if (controller.isLoading &&
            controller.favoritosData.diagnosticos.isEmpty) {
          return Container(); // Container vazio sem loading visual
        }

        final diagnosticos = controller.favoritosData.diagnosticosFiltered;
        final viewMode = controller.getViewModeForTab(2);
        final isDark = themeController.isDark.value;

        return _buildContent(
            context, diagnosticos, viewMode.value, controller, isDark);
      }),
    );
  }

  /// Constrói a tela de gate premium para usuários não premium
  Widget _buildPremiumGate(BuildContext context) {
    final warningColor = Colors.amber.shade600;
    final warningBackgroundColor = Colors.amber.shade50;
    final warningTextColor = Colors.amber.shade800;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(32.0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: warningBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: warningColor,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Diagnósticos não disponíveis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: warningTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Este recurso está disponível apenas para assinantes do app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: warningTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navegarParaPremium(context),
                  icon: const Icon(Icons.diamond),
                  label: const Text('Desbloquear Agora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warningColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navegarParaPremium(BuildContext context) {
    Get.toNamed('/receituagro/assinaturas');
  }

  Widget _buildContent(
    BuildContext context,
    List<dynamic> diagnosticos,
    String viewMode,
    FavoritosController controller,
    bool isDark,
  ) {
    if (diagnosticos.isEmpty) {
      // Verificar se há busca ativa para tab de diagnósticos (índice 2)
      final isSearching = controller.isSearchingForTab(2);
      final searchText = controller.getSearchTextForTab(2);

      if (isSearching && searchText.isNotEmpty) {
        // Mostra widget de busca sem resultados
        return NoSearchResultsWidget(
          searchText: searchText,
          accentColor: FavoritosDesignTokens.diagnosticosColor,
        );
      } else {
        // Mostra empty state normal
        return const EmptyStateWidget(
          title: 'Nenhum diagnóstico favorito',
          message: 'Você ainda não possui diagnósticos favoritos.',
          accentColor: FavoritosDesignTokens.diagnosticosColor,
        );
      }
    }

    return Column(
      children: [
        // Lista de favoritos
        Expanded(
          child: ListContentWidget(
            items: diagnosticos,
            viewMode: viewMode,
            tabIndex: 2,
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
