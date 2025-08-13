// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../widgets/modern_header_widget.dart';
import '../../../widgets/section_title_widget.dart';
import '../controller/atualizacao_controller.dart';
import 'widgets/atualizacao_list_widget.dart';

class AtualizacaoPage extends StatelessWidget {
  const AtualizacaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AtualizacaoController>(
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

  Widget _buildModernHeader(AtualizacaoController controller) {
    final isDark = controller.state.isDark;
    return ModernHeaderWidget(
      title: 'Atualizações',
      subtitle: 'Histórico de versões do aplicativo',
      leftIcon: FontAwesome.code_branch_solid,
      isDark: isDark,
      showBackButton: true,
      showActions: false,
      onBackPressed: () => Get.back(),
    );
  }

  Widget _buildBody(AtualizacaoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitleWidget(
          title: 'Histórico de Versões',
          icon: FontAwesome.clock_rotate_left_solid,
        ),
        _buildContent(controller),
      ],
    );
  }

  Widget _buildContent(AtualizacaoController controller) {
    if (controller.state.isLoading) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: controller.state.isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        color: controller.state.isDark ? const Color(0xFF1E1E22) : const Color(0xFFF5F5F5),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return AtualizacaoListWidget(
      atualizacoes: controller.state.atualizacoesList,
      isDark: controller.state.isDark,
    );
  }
}
