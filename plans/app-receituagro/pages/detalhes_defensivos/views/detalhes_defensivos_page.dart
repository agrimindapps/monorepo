// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../../widgets/reusable_comment_dialog.dart';
import '../../comentarios/controller/comentarios_controller.dart';
import '../constants/detalhes_defensivos_design_tokens.dart';
import '../controller/detalhes_defensivos_controller.dart';
import 'components/tabs_section.dart';
import 'tabs/aplicacao_tab.dart';
import 'tabs/comentarios_tab.dart';
import 'tabs/diagnostico_tab.dart';
import 'tabs/informacoes_tab.dart';

class DetalhesDefensivosPage extends GetView<DetalhesDefensivosController> {
  const DetalhesDefensivosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(context),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading) {
                      return _buildLoadingState(context);
                    }

                    if (controller.hasError) {
                      return _buildErrorState(context);
                    }

                    return _buildContent(context);
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: _buildBottomNavigator(),
    );
  }
  
  /// Constrói o BottomNavigator com índice determinado de forma segura
  Widget _buildBottomNavigator() {
    // Remove a lógica que pode causar setState durante build
    // Simplesmente retorna o BottomNavigator sem override específico
    // O próprio BottomNavigator vai gerenciar seu estado baseado na rota atual
    return const BottomNavigator();
  }

  /// Constrói o FloatingActionButton inteligente para comentários
  Widget? _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      // Só mostra o FAB se não estiver carregando e não tiver erro
      if (controller.isLoading || controller.hasError) {
        return const SizedBox.shrink();
      }

      // Verifica se há dados do defensivo
      if (controller.defensivo.value.caracteristicas.isEmpty) {
        return const SizedBox.shrink();
      }

      // Verifica se está na aba de comentários de forma mais segura
      try {
        if (controller.tabController.index != 3) {
          return const SizedBox.shrink();
        }
      } catch (e) {
        // Se houver erro ao acessar o tabController, não mostra o FAB
        return const SizedBox.shrink();
      }

      // Obtém o controller de comentários de forma segura
      try {
        final comentariosController = Get.find<ComentariosController>();
        
        final canAdd = comentariosController.state.quantComentarios <
            comentariosController.state.maxComentarios;
        final maxComentarios = comentariosController.state.maxComentarios;

        // Só mostra o FAB se o usuário tem permissão para adicionar
        if (maxComentarios == 0 || !canAdd) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () => _showCommentDialog(context),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          tooltip: 'Adicionar comentário',
          child: const Icon(Icons.add),
        );
      } catch (e) {
        // Se não conseguir obter o controller de comentários, não mostra o FAB
        return const SizedBox.shrink();
      }
    });
  }

  /// Mostra o dialog para adicionar comentário
  void _showCommentDialog(BuildContext context) {
    final defensivoData = controller.defensivo.value;
    final defensivoName = defensivoData.caracteristicas['nomeComum'] ?? 'Defensivo';
    
    showDialog(
      context: context,
      builder: (context) => ReusableCommentDialog(
        title: 'Adicionar Comentário',
        origem: 'Defensivos',
        itemName: defensivoName,
        hint: 'Digite seu comentário sobre este defensivo...',
        maxLength: 200,
        minLength: 5,
        onSave: (conteudo) async {
          final comentariosController = Get.find<ComentariosController>();
          await comentariosController.onCardSave(conteudo);
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      final defensivo = controller.defensivo.value;
      final nomeComum = defensivo.caracteristicas['nomeComum'] ??
          'Detalhes do Defensivo';
      final fabricante =
          defensivo.caracteristicas['fabricante'] ??
              'Informações completas';

      return ModernHeaderWidget(
        title: nomeComum,
        subtitle: fabricante,
        leftIcon: Icons.shield_outlined,
        rightIcon: controller.isFavorite.value
            ? Icons.favorite
            : Icons.favorite_border,
        isDark: isDark,
        showBackButton: true,
        showActions: true,
        onBackPressed: () => Get.back(),
        onRightIconPressed: () => controller.toggleFavorite(),
      );
    });
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(
            DetalhesDefensivosDesignTokens.hugeLargeSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient:
                    DetalhesDefensivosDesignTokens.createPrimaryGradient(),
                shape: BoxShape.circle,
                boxShadow: DetalhesDefensivosDesignTokens.cardShadow(
                  DetalhesDefensivosDesignTokens.primaryColor,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(
                height: DetalhesDefensivosDesignTokens.extraLargeSpacing),
            Text(
              'Carregando detalhes...',
              style: DetalhesDefensivosDesignTokens.cardTitleStyle.copyWith(
                color: DetalhesDefensivosDesignTokens.getTextColor(context),
              ),
            ),
            const SizedBox(
                height: DetalhesDefensivosDesignTokens.defaultSpacing),
            Text(
              'Aguarde enquanto buscamos as informações',
              style: DetalhesDefensivosDesignTokens.cardSubtitleStyle.copyWith(
                color: DetalhesDefensivosDesignTokens.getSubtitleColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Container(
        margin: DetalhesDefensivosDesignTokens.sectionPadding,
        padding: const EdgeInsets.all(
            DetalhesDefensivosDesignTokens.hugeLargeSpacing),
        decoration: DetalhesDefensivosDesignTokens.sectionDecoration(
          context,
          accentColor: DetalhesDefensivosDesignTokens.errorColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DetalhesDefensivosDesignTokens.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesome.triangle_exclamation_solid,
                size: DetalhesDefensivosDesignTokens.extraLargeIconSize,
                color: DetalhesDefensivosDesignTokens.errorColor,
              ),
            ),
            const SizedBox(
                height: DetalhesDefensivosDesignTokens.extraLargeSpacing),
            Text(
              'Erro ao carregar detalhes',
              style: DetalhesDefensivosDesignTokens.sectionTitleStyle.copyWith(
                color: DetalhesDefensivosDesignTokens.getTextColor(context),
              ),
            ),
            const SizedBox(
                height: DetalhesDefensivosDesignTokens.defaultSpacing),
            Text(
              'Não foi possível carregar as informações do defensivo. Verifique sua conexão e tente novamente.',
              style: DetalhesDefensivosDesignTokens.cardSubtitleStyle.copyWith(
                color: DetalhesDefensivosDesignTokens.getSubtitleColor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
                height: DetalhesDefensivosDesignTokens.hugeLargeSpacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.retryLoad(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        DetalhesDefensivosDesignTokens.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          DetalhesDefensivosDesignTokens.extraLargeSpacing,
                      vertical: DetalhesDefensivosDesignTokens.mediumSpacing,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DetalhesDefensivosDesignTokens.defaultBorderRadius,
                      ),
                    ),
                    elevation: DetalhesDefensivosDesignTokens.cardElevation,
                  ),
                ),
                const SizedBox(
                    width: DetalhesDefensivosDesignTokens.largeSpacing),
                TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(FontAwesome.arrow_left_solid),
                  label: const Text('Voltar'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        DetalhesDefensivosDesignTokens.getSubtitleColor(
                            context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        TabsSectionWidget(controller: controller),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              left: DetalhesDefensivosDesignTokens.defaultSpacing,
              right: DetalhesDefensivosDesignTokens.defaultSpacing,
              top: DetalhesDefensivosDesignTokens.smallSpacing,
              bottom: DetalhesDefensivosDesignTokens.defaultSpacing,
            ),
            decoration: BoxDecoration(
              color: DetalhesDefensivosDesignTokens.getCardColor(context),
              borderRadius: BorderRadius.circular(DetalhesDefensivosDesignTokens.defaultBorderRadius),
            ),
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _wrapTabContent(
                  InformacoesTab(controller: controller),
                  'informacoes',
                  context,
                ),
                _wrapTabContent(
                  DiagnosticoTab(controller: controller),
                  'diagnostico',
                  context,
                ),
                _wrapTabContent(
                  AplicacaoTab(controller: controller),
                  'aplicacao',
                  context,
                ),
                _wrapTabContent(
                  ComentariosTab(controller: controller),
                  'comentarios',
                  context,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrapTabContent(Widget content, String type, BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            key: ValueKey('$type-content'),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: content,
            ),
          );
        },
      ),
    );
  }
}
