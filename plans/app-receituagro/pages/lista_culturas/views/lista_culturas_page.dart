// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../widgets/bottom_navigator_widget.dart';
import '../../../widgets/modern_header_widget.dart';
import '../controller/lista_culturas_controller.dart';
import '../models/cultura_model.dart';
import 'components/cultura_search_field.dart';
import 'components/empty_state_widget.dart';
import 'components/smart_skeleton_system.dart';
import 'widgets/culturas_list_view.dart';
import 'widgets/loading_skeleton_widget.dart' show ViewMode;

class ListaCulturasPage extends StatefulWidget {
  const ListaCulturasPage({super.key});

  @override
  ListaCulturasPageState createState() => ListaCulturasPageState();
}

class ListaCulturasPageState extends State<ListaCulturasPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Controller disposal is handled by GetX automatically
    super.dispose();
  }

  Widget _buildCulturasList(ListaCulturasController controller) {
    return Card(
      elevation: 0, // Removida elevação
      color: controller.state.isDark ? const Color(0xFF1E1E22) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _buildContentBasedOnState(controller),
    );
  }

  Widget _buildContentBasedOnState(ListaCulturasController controller) {
    if (controller.state.isLoading) {
      return _buildSkeletonForState(controller);
    } else if (controller.state.culturasFiltered.isEmpty) {
      return EmptyStateWidget(
        key: const ValueKey('empty'),
        isDark: controller.state.isDark,
      );
    } else {
      return CulturasListView(
        key: ValueKey('list_${controller.state.culturasFiltered.length}'),
        culturas: controller.state.culturasFiltered,
        isDark: controller.state.isDark,
        onCulturaTap: (CulturaModel cultura) =>
            controller.handleCulturaTap(cultura),
      );
    }
  }

  /// Builds appropriate skeleton based on current state
  Widget _buildSkeletonForState(ListaCulturasController controller) {
    final state = controller.state;

    // Determine skeleton type based on loading context
    SkeletonType skeletonType;
    String? customMessage;

    if (state.isSearching) {
      skeletonType = SkeletonType.search;
      customMessage = 'Buscando culturas...';
    } else if (state.searchText.isNotEmpty) {
      skeletonType = SkeletonType.filter;
      customMessage = 'Aplicando filtros de busca...';
    } else {
      skeletonType = SkeletonType.initial;
      customMessage = 'Carregando culturas disponíveis...';
    }

    return SmartSkeletonSystem(
      key: ValueKey('skeleton_${skeletonType.name}'),
      isDark: state.isDark,
      type: skeletonType,
      viewMode:
          ViewMode.list, // Future: will be dynamic when Issue #5 is implemented
      customMessage: customMessage,
      showProgress: skeletonType == SkeletonType.initial,
    );
  }

  Widget _buildModernHeader(ListaCulturasController controller) {
    return ModernHeaderWidget(
      title: 'Culturas',
      subtitle: _getHeaderSubtitle(controller),
      leftIcon: Icons.agriculture_outlined,
      rightIcon: controller.state.isAscending
          ? Icons.arrow_upward_outlined
          : Icons.arrow_downward_outlined,
      isDark: controller.state.isDark,
      showBackButton: true,
      showActions: true,
      onBackPressed: () => Get.back(),
      onRightIconPressed: controller.toggleSort,
    );
  }

  String _getHeaderSubtitle(ListaCulturasController controller) {
    final total = controller.state.culturasList.length;
    final filtered = controller.state.culturasFiltered.length;

    if (controller.state.isLoading && total == 0) {
      return 'Carregando culturas...';
    }

    if (filtered < total) {
      return '$filtered de $total culturas';
    }

    return '$total culturas cadastradas';
  }

  @override
  Widget build(BuildContext context) {
    return GetX<ListaCulturasController>(
      builder: (controller) {
        return Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _buildModernHeader(controller),
                    CulturaSearchField(
                      controller: controller.textController,
                      isDark: controller.state.isDark,
                      isSearching:
                          controller.state.isSearching, // Novo parâmetro
                      onClear: controller.clearSearch,
                      onSubmitted:
                          controller.executeSearchImmediately, // Novo parâmetro
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: _buildCulturasList(controller),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavigator(
            overrideIndex: 1, // Pragas (culturas levam para pragas por cultura)
          ),
        );
      },
    );
  }
}
