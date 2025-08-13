// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../core/controllers/theme_controller.dart';
import '../../widgets/bottom_navigator_widget.dart';
import '../../widgets/modern_header_widget.dart';
import 'controller/favoritos_controller.dart';
import 'tabs/defensivos_tab.dart';
import 'tabs/diagnostico_tab.dart';
import 'tabs/pragas_tab.dart';
import 'widgets/favoritos_search_field_widget.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with WidgetsBindingObserver, RouteAware {
  late FavoritosController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // O controller já é registrado no binding, apenas obter a referência
    controller = Get.find<FavoritosController>();


    // Recarrega favoritos quando a página é exibida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshFavorites();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Recarrega favoritos quando o app volta para o foreground
    if (state == AppLifecycleState.resumed) {
      controller.refreshFavorites();
    }
  }

  @override
  void didPopNext() {
    // Chamado quando retornamos para esta página de outra página
    super.didPopNext();
    controller.refreshFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final isDark = themeController.isDark.value;
        
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _buildModernHeader(isDark),
                    Obx(() {
                      if (controller.hasError) {
                        return Expanded(
                          child: _buildErrorState(controller, isDark),
                        );
                      }

                      return Expanded(
                        child: Column(
                          children: [
                            _buildTabBar(controller, isDark),
                            if (controller.hasAnyFavorites && _shouldShowSearchField(controller))
                              _buildSearchField(controller, isDark),
                            Expanded(
                              child: _buildTabContent(controller),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavigator(
            overrideIndex: 2, // Favoritos
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(bool isDark) {
    return Obx(() => ModernHeaderWidget(
      title: 'Favoritos',
      subtitle: _getHeaderSubtitle(),
      leftIcon: Icons.favorite_outlined,
      isDark: isDark,
      showBackButton: false,
      showActions: false,
    ));
  }

  String _getHeaderSubtitle() {
    if (controller.hasError) {
      return 'Erro ao carregar favoritos';
    }
    
    final data = controller.favoritosData;
    final totalFavoritos = data.defensivos.length + data.pragas.length + data.diagnosticos.length;
    
    if (totalFavoritos > 0) {
      return 'Você tem $totalFavoritos itens salvos';
    }
    
    return 'Seus itens salvos';
  }

  Widget _buildSearchField(FavoritosController controller, bool isDark) {
    return Obx(() => FavoritosSearchFieldWidget(
          controller: controller.searchControllers[controller.currentTabIndex],
          isDark: isDark,
          selectedViewMode: controller.currentViewMode,
          onToggleViewMode: controller.toggleViewMode,
          onClear: () => controller.clearSearch(controller.currentTabIndex),
          onChanged: (_) =>
              controller.onSearchChanged(controller.currentTabIndex),
          hintText: _getSearchHintForTab(controller.currentTabIndex),
          accentColor: _getAccentColorForTab(controller.currentTabIndex),
        ));
  }

  String _getSearchHintForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Localizar defensivos...';
      case 1:
        return 'Localizar pragas...';
      case 2:
        return 'Localizar diagnósticos...';
      default:
        return 'Localizar...';
    }
  }

  Color _getAccentColorForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const Color(0xFF2E7D32); // Verde para defensivos
      case 1:
        return const Color(0xFFD32F2F); // Vermelho para pragas
      case 2:
        return const Color(0xFF1976D2); // Azul para diagnóstico
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Widget _buildTabBar(FavoritosController controller, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: _buildGradientTabBarDecoration(isDark),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Obx(() => Row(
              children: controller.tabTitles.asMap().entries.map((entry) {
                final index = entry.key;
                final title = entry.value;
                final isSelected = controller.currentTabIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.navigateToTab(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.shade700
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: isSelected ? MainAxisSize.min : MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getTabIcon(index),
                              size: isSelected ? 16 : 14,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.green.shade800,
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  /// Decoração com gradiente para o tabbar (inspirado em detalhes_defensivos)
  BoxDecoration _buildGradientTabBarDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.green.shade100,
          Colors.green.shade200,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.green.shade200.withValues(alpha: 0.5),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildTabContent(FavoritosController controller) {
    return Obx(() {
      switch (controller.currentTabIndex) {
        case 0:
          return DefensivosTab(controller: controller);
        case 1:
          return PragasTab(controller: controller);
        case 2:
          return DiagnosticoTab(controller: controller);
        default:
          return DefensivosTab(controller: controller);
      }
    });
  }

  Widget _buildErrorState(FavoritosController controller, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.retryInitialization,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowSearchField(FavoritosController controller) {
    if (controller.currentTabIndex == 2 && !controller.isPremium) {
      return false;
    }
    return true;
  }

  IconData _getTabIcon(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return FontAwesome.spray_can_solid;
      case 1:
        return FontAwesome.bug_solid;
      case 2:
        return FontAwesome.stethoscope_solid;
      default:
        return Icons.favorite;
    }
  }
}
