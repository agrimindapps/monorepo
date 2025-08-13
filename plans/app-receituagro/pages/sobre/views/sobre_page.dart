// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../widgets/modern_header_widget.dart';
import '../../../widgets/section_title_widget.dart';
import '../controller/sobre_controller.dart';
import '../models/sobre_model.dart';
import 'widgets/app_info_widget.dart';
import 'widgets/contato_list_widget.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SobreController>(
      init: SobreController(), // Inicializa o controller se não estiver disponível
      builder: (controller) {
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
                          padding: const EdgeInsets.all(8.0),
                          child: _buildBody(controller),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(SobreController? controller) {
    final isDark = controller?.state.isDark ?? false;
    return ModernHeaderWidget(
      title: 'Sobre o App',
      subtitle: 'Informações e contatos',
      leftIcon: FontAwesome.circle_info_solid,
      isDark: isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () {
        if (controller != null) {
          controller.voltarPagina();
        } else {
          Get.back();
        }
      },
    );
  }

  Widget _buildBody(SobreController? controller) {
    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.state.hasError) {
      return _buildErrorState(controller);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppInfoWidget(
          sobreData: controller.state.sobreData,
          versaoAtual: controller.versaoAtual,
          isDark: controller.state.isDark,
          onVersionTap: () => controller.navegarParaAtualizacoes(),
        ),
        const SizedBox(height: 16),
        _buildContatoSection(controller),
        const SizedBox(height: 16),
        _buildCopyrightSection(controller),
      ],
    );
  }

  Widget _buildErrorState(SobreController? controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: (controller?.state.isDark ?? false) ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 16),
          Text(
            controller?.state.error ?? 'Erro desconhecido',
            style: TextStyle(
              color: (controller?.state.isDark ?? false) ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller?.limparErro(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildContatoSection(SobreController? controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Contato',
          icon: FontAwesome.address_book_solid,
        ),
        ContatoListWidget(
          contatos: controller?.state.contatos ?? [],
          isDark: controller?.state.isDark ?? false,
          onContatoTap: (ContatoModel contato) => _handleContatoTap(controller, contato),
        ),
      ],
    );
  }

  Widget _buildCopyrightSection(SobreController? controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
          child: Text(
            controller?.state.sobreData.copyright ?? 'Copyright @ Agrimind',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: (controller?.state.isDark ?? false) ? Colors.white : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            controller?.state.sobreData.rightsReserved ?? 'Todos os Direitos Reservados',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: (controller?.state.isDark ?? false) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _handleContatoTap(SobreController? controller, ContatoModel contato) {
    if (controller == null) return;
    
    switch (contato.iconType) {
      case 'email':
        controller.abrirEmail();
        break;
      case 'facebook':
      case 'instagram':
        controller.abrirLinkExterno(contato.url, contato.path);
        break;
    }
  }
}
