// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../controller/home_pragas_controller.dart';
import '../widgets/menu_card.dart';
import '../widgets/recent_section.dart';
import '../widgets/suggested_section.dart';

class HomePragasPage extends StatelessWidget {
  static const Widget _sectionSpacing = SizedBox(height: 4);

  const HomePragasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mantém Get.put por enquanto - HomePragasController não tem binding configurado
    final controller = Get.put(HomePragasController());

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(controller),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      child: Obx(() {
                        if (!controller.isControllerInitialized) {
                          return _buildInitializingWidget();
                        }

                        if (controller.isLoading) {
                          return _buildLoadingWidget();
                        }

                        return _buildContent(controller);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigator(
        overrideIndex: 1, // Pragas
      ),
    );
  }

  Widget _buildModernHeader(HomePragasController controller) {
    return Obx(() => ModernHeaderWidget(
      title: 'Pragas e Doenças',
      subtitle: _getSubtitle(controller),
      leftIcon: Icons.bug_report_outlined,
      isDark: Theme.of(Get.context!).brightness == Brightness.dark,
      showBackButton: false,
      showActions: false, // Não mostra área de ações
    ));
  }

  String _getSubtitle(HomePragasController controller) {
    if (controller.isLoading) {
      return 'Carregando dados...';
    }
    
    if (!controller.isControllerInitialized) {
      return 'Inicializando...';
    }
    
    final data = controller.homeData;
    final totalPragas = data.counts.insetos + data.counts.doencas + data.counts.plantas;
    
    if (totalPragas > 0) {
      return 'Identifique e controle $totalPragas pragas';
    }
    
    return 'Identificação e controle de pragas';
  }

  static Widget _buildInitializingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        SizedBox(height: 24),
        Text(
          'Inicializando sistema...',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 80),
      ],
    );
  }

  static Widget _buildLoadingWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 80),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        SizedBox(height: 24),
        Text(
          'Carregando dados...',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 80),
      ],
    );
  }

  Widget _buildContent(HomePragasController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _safeBuild(() => _buildMenuSection(controller)),
        _sectionSpacing,
        _safeBuild(() => _buildSuggestedSection(controller)),
        _sectionSpacing,
        _safeBuild(() => _buildRecentSection(controller)),
      ],
    );
  }

  Widget _buildMenuSection(HomePragasController controller) {
    return MenuCard(
      counts: controller.homeData.counts,
      onInsectsTap: (_) => controller.navigateToInsetos(),
      onDoencasTap: (_) => controller.navigateToDoencas(),
      onPlantasTap: (_) => controller.navigateToPlantasDaninhas(),
      onCulturasTap: () => controller.navigateToCulturasList(
          source: 'home_pragas_culturas_card'),
    );
  }

  Widget _buildSuggestedSection(HomePragasController controller) {
    return SuggestedSection(
      items: controller.homeData.pragasSugeridas,
      isLoading: controller.isLoading,
      carouselController: controller.carouselController,
      onPageChanged: controller.onCarouselPageChanged,
      onDotTap: controller.animateToCarouselPage,
      onItemTap: (id) => controller.navigateToPragaDetails(id,
          source: 'home_pragas_suggested_carousel'),
      currentIndex: controller.carouselCurrentIndex,
    );
  }

  Widget _buildRecentSection(HomePragasController controller) {
    return RecentSection(
      items: controller.homeData.ultimasPragasAcessadas,
      isLoading: controller.isLoading,
      isLoadingMore: controller.isLoadingMoreRecent,
      hasMore: controller.hasMoreRecent,
      onItemTap: (id) => controller.navigateToPragaDetails(id,
          source: 'home_pragas_recent_list'),
      onLoadMore: controller.loadMoreRecentPests,
      onScrollPositionChanged: controller.onScrollPositionChanged,
    );
  }

  Widget _safeBuild(Widget Function() builder) {
    try {
      return builder();
    } catch (e) {
      debugPrint('Erro ao construir widget: $e');
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber[700], size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Não foi possível carregar esta seção',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
