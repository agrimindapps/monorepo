// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/controllers/theme_controller.dart';
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../../../widgets/reusable_comment_dialog.dart';
import '../../comentarios/controller/comentarios_controller.dart';
import '../controller/detalhes_pragas_controller.dart';
import 'components/tabs_section.dart';

/// Página principal de detalhes de pragas seguindo padrão MVC
class DetalhesPragasPage extends GetView<DetalhesPragasController> {
  const DetalhesPragasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildModernHeader(),
                Expanded(
                  child: GetBuilder<DetalhesPragasController>(
                    id: 'main_body',
                    builder: (controller) => _buildBody(),
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Determina o índice correto do BottomNavigator baseado no contexto de navegação
  int _getBottomNavIndex() {
    // Verifica se veio da página de favoritos
    final previousRoute = Get.previousRoute;
    if (previousRoute.contains('favoritos')) {
      return 2; // Favoritos
    }

    // Por padrão, assume que veio de pragas
    return 1; // Pragas
  }

  Widget _buildModernHeader() {
    return GetBuilder<DetalhesPragasController>(
      id: 'praga_data',
      builder: (controller) {
        String title = 'Detalhes da Praga';
        String subtitle = 'Informações completas';

        if (controller.isPragaLoaded && controller.pragaUnica != null) {
          title = controller.pragaUnica!.nomeComum;
          subtitle = controller.pragaUnica!.nomeCientifico.isNotEmpty
              ? controller.pragaUnica!.nomeCientifico
              : 'Informações completas';
        }

        return GetBuilder<ThemeController>(
          builder: (themeController) => GetBuilder<DetalhesPragasController>(
            id: 'app_bar',
            builder: (controller) => ModernHeaderWidget(
              title: title,
              subtitle: subtitle,
              leftIcon: FontAwesome.bug_solid,
              rightIcon: controller.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              isDark: themeController.isDark.value,
              showBackButton: true,
              showActions: true,
              onBackPressed: () => Get.back(),
              onRightIconPressed: () => controller.toggleFavorite(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando dados da praga...'),
          ],
        ),
      );
    }

    if (!controller.isPragaLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Não foi possível carregar os dados da praga',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: const Column(
            children: [
              Expanded(child: TabsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return GetBuilder<DetalhesPragasController>(
      id: 'floating_action_button',
      builder: (controller) {
        // Só mostra o FAB se está carregado e na aba de comentários (índice 2)
        if (!controller.isPragaLoaded || controller.tabController.index != 2) {
          return const SizedBox.shrink();
        }

        // Verifica se o usuário tem permissão para adicionar comentários
        try {
          final comentariosController = Get.find<ComentariosController>();
          final canAdd = comentariosController.state.quantComentarios <
              comentariosController.state.maxComentarios;
          final maxComentarios = comentariosController.state.maxComentarios;

          if (maxComentarios == 0 || !canAdd) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () => _showCommentDialog(),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          );
        } catch (e) {
          // Se o controller não estiver disponível, não mostra o FAB
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _showCommentDialog() {
    final pragaData = controller.pragaUnica;
    final pragaName = pragaData?.nomeComum ?? 'Praga';
    final comentariosController = Get.find<ComentariosController>();

    showDialog(
      context: Get.context!,
      builder: (context) => ReusableCommentDialog(
        title: 'Adicionar Comentário',
        origem: 'Pragas',
        itemName: pragaName,
        hint: 'Digite seu comentário sobre esta praga...',
        maxLength: 200,
        minLength: 5,
        onSave: (conteudo) async {
          await comentariosController.onCardSave(conteudo);
        },
      ),
    );
  }
}

/// Widget para exibir estado de loading específico do módulo de pragas
class PragaLoadingWidget extends StatelessWidget {
  final String? message;

  const PragaLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

/// Widget para exibir estado de erro específico do módulo de pragas
class PragaErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const PragaErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ],
      ),
    );
  }
}
