// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../controller/home_defensivos_controller.dart';
import '../models/loading_state.dart';
import '../widgets/categories_section.dart';
import '../widgets/new_products_section.dart';
import '../widgets/optimized_widgets.dart';
import '../widgets/recent_section.dart';

class HomeDefensivosPage extends GetView<HomeDefensivosController> {
  const HomeDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: ConstrainedContainer(
          child: Column(
            children: [
              _buildModernHeader(controller),
              Expanded(
                child: Obx(() {
                  switch (controller.loadingState) {
                    case LoadingState.initial:
                      return _buildLoadingState('Aguardando inicialização...');
                    case LoadingState.loading:
                      return _buildLoadingState(
                          controller.currentStateDescription);
                    case LoadingState.error:
                      return _buildErrorState(
                          controller, controller.currentStateDescription);
                    case LoadingState.success:
                      return _buildContent(controller);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigator(
        overrideIndex: 0, // Defensivos
      ),
    );
  }

  Widget _buildModernHeader(HomeDefensivosController controller) {
    return Obx(() => ModernHeaderWidget(
          title: 'Defensivos',
          subtitle: _getSubtitle(controller),
          leftIcon: Icons.shield_outlined,
          isDark: Theme.of(Get.context!).brightness == Brightness.dark,
          showBackButton: false,
          showActions: false, // Não mostra área de ações
        ));
  }

  String _getSubtitle(HomeDefensivosController controller) {
    if (controller.loadingState == LoadingState.loading) {
      return 'Carregando dados...';
    }

    final data = controller.homeData;
    final totalDefensivos = data.defensivos;

    if (totalDefensivos > 0) {
      return '$totalDefensivos Registros';
    }

    return 'Produtos e informações defensivos';
  }

  Widget _buildLoadingState(String message) {
    return LoadingStateWidget(message: message);
  }

  Widget _buildErrorState(
      HomeDefensivosController controller, String errorMessage) {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ErrorIcon(),
              const MediumGap(),
              Text(
                'Ops! Algo deu errado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                    ),
                textAlign: TextAlign.center,
              ),
              const DefaultGap(),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const LargeGap(),
              RefreshButton(
                onPressed: () => controller.retryInitialization(),
              ),
              const MediumGap(),
              if (controller.stateTransitionLog.isNotEmpty) ...[
                TextButton(
                  onPressed: () => _showStateLogDialog(context, controller),
                  child: const Text('Ver Log de Estados'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeDefensivosController controller) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoriesSection(
                      homeData: controller.homeData,
                      onCategoryTap: controller.navigateToList,
                    ),
                    RecentSection(
                      items: controller.homeData.recentlyAccessed,
                      onItemTap: controller.onItemTap,
                    ),
                    NewProductsSection(
                      items: controller.homeData.newProducts,
                      onItemTap: controller.onItemTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _showStateLogDialog(
      BuildContext context, HomeDefensivosController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log de Estados'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: controller.stateTransitionLog.length,
            itemBuilder: (context, index) {
              final logEntry = controller.stateTransitionLog[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: MonospaceText(text: logEntry),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearStateLog();
              Navigator.of(context).pop();
            },
            child: const Text('Limpar Log'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
