// MÓDULO: Detalhes de Diagnóstico
// ARQUIVO: Página Principal
// DESCRIÇÃO: Interface principal para exibição de detalhes de diagnósticos
// RESPONSABILIDADES: Layout principal, coordenação de seções, states de loading
// DEPENDÊNCIAS: GetView, Controller, Widgets de seções
// CRIADO: 2025-06-22 | ATUALIZADO: 2025-06-22
// AUTOR: Sistema de Desenvolvimento ReceituAgro

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../controller/detalhes_diagnostico_controller.dart';
import '../models/loading_state.dart';
import '../widgets/loading_state_widget.dart';
import 'sections/application_section.dart';
import 'sections/diagnostic_section.dart';
import 'sections/image_section.dart';
import 'sections/info_section.dart';

class DetalhesDiagnosticoPage extends GetView<DetalhesDiagnosticoController> {
  const DetalhesDiagnosticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Agenda recarregamento do status de favorito após o primeiro frame
    // Sempre executa para garantir que o status seja atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verifica se tem um ID válido antes de carregar
      if (controller.diagnosticoId.isNotEmpty) {
        controller.refreshFavoriteStatus();
      }
    });

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        final isDark = themeController.isDark.value;
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF121212) : Colors.grey.shade50,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _buildModernHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(() {
                          if (controller.isLoading) {
                            return LoadingStateWidget(
                              loadingManager: controller.loadingManager.value,
                              type: LoadingStateType.loadingDiagnostic,
                              loadingWidget: const DiagnosticLoadingWidget(),
                              child: Container(),
                            );
                          }

                          // Verificar se o usuário é premium primeiro
                          if (!controller.isPremium.value) {
                            return _buildPremiumGate(context);
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Card com imagem da praga
                              ImageSection(controller: controller),
                              // Card com informações do defensivo
                              InfoSection(controller: controller),
                              // Card com informações do diagnóstico
                              DiagnosticSection(controller: controller),
                              // Card com modo de aplicação
                              ApplicationSection(controller: controller),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigator(
            overrideIndex: _getBottomNavIndex(),
          ),
        );
      },
    );
  }

  /// Determina o índice correto do BottomNavigator baseado no contexto de navegação
  int _getBottomNavIndex() {
    // Verifica se veio da página de favoritos
    final previousRoute = Get.previousRoute;
    if (previousRoute.contains('favoritos')) {
      return 2; // Favoritos
    }

    // Por padrão, assume que diagnóstico faz parte dos favoritos
    return 2; // Favoritos
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
                'Detalhes do Diagnóstico',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: warningTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Este recurso está disponível apenas para assinantes premium.',
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

  Widget _buildModernHeader(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => GetBuilder<DetalhesDiagnosticoController>(
        id: 'app_bar',
        builder: (controller) => ModernHeaderWidget(
          title: 'Diagnóstico',
          subtitle: 'Detalhes do diagnóstico',
          leftIcon: Icons.medical_services_outlined,
          rightIcon: controller.isPremium.value
              ? (controller.isFavorite.value
                  ? Icons.favorite
                  : Icons.favorite_border)
              : null,
          isDark: themeController.isDark.value,
          showBackButton: true,
          showActions: controller.isPremium.value,
          onBackPressed: () => Get.back(),
          onRightIconPressed: controller.isPremium.value
              ? () => controller.toggleFavorite()
              : null,
          additionalActions: controller.isPremium.value
              ? [
                  GestureDetector(
                    onTap: () => controller.compartilhar(),
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
