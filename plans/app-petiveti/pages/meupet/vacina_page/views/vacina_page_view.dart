// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/16_vacina_model.dart';
import '../../../../widgets/animalSelect_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/no_animal_selecionado_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../../vacina_cadastro/views/vacina_form_dialog.dart';
import '../controllers/vacina_page_controller.dart';
import 'styles/vacina_colors.dart';
import 'styles/vacina_constants.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/loading_state_widget.dart';
import 'widgets/no_data_widget.dart';
import 'widgets/vacina_card_widget.dart';
import 'widgets/vacina_section_widget.dart';
import 'widgets/virtualized_vaccine_list.dart';

class VacinaPageView extends StatefulWidget {
  const VacinaPageView({super.key});

  @override
  State<VacinaPageView> createState() => _VacinaPageViewState();
}

class _VacinaPageViewState extends State<VacinaPageView> {
  late VacinaPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VacinaPageController());
    // Ensure AnimalPageController is available
    if (!Get.isRegistered<AnimalPageController>()) {
      Get.put(AnimalPageController());
    }
    
    // Ensure data is loaded after the widget is built if an animal is already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadDataIfNeeded();
    });
  }
  
  void _checkAndLoadDataIfNeeded() {
    // Check if there's an animal selected in the global controller but not in this page controller
    final animalController = Get.find<AnimalPageController>();
    if (animalController.selectedAnimalId.isNotEmpty && !controller.hasSelectedAnimal) {
      // Sync the animal selection to this page
      final selectedAnimal = animalController.selectedAnimal;
      controller.onAnimalSelected(animalController.selectedAnimalId, selectedAnimal);
    }
  }

  // UI helper methods moved to extracted widgets

  Future<void> _loadVacinas() async {
    await controller.loadVacinas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Body content
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: const VetBottomBarWidget(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Obx(() => PageHeaderWidget(
          title: 'Vacinas',
          subtitle: controller.getSubtitle(),
          icon: Icons.vaccines,
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ));
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: VacinaConstants.larguraMaximaConteudo,
        child: Column(
          children: [
            _buildAnimalSelector(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VacinaConstants.paddingConteudoPadrao,
        VacinaConstants.paddingConteudoPadrao,
        VacinaConstants.paddingConteudoPadrao,
        VacinaConstants.espacamentoDropdown,
      ),
      child: AnimalDropdownWidget(
        onAnimalSelected: (animalId, animal) {
          controller.onAnimalSelected(animalId, animal);
        },
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.shouldShowLoading()) {
        return LoadingStateWidget.data();
      } else if (controller.shouldShowError()) {
        return ErrorStateWidget.loadingData(
          message: controller.errorMessage,
          onRetry: () => controller.retryLastOperation(),
        );
      } else if (controller.shouldShowNoAnimalSelected()) {
        return const NoAnimalSelecionadoWidget();
      } else if (controller.shouldShowNoData()) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NoDataWithMonthWidget(
              monthsList: controller.getMonthsList(),
              currentIndex: controller.getCurrentMonthIndex(),
              onMonthTap: (index) => controller.setCurrentMonthIndex(index),
              message: 'Nenhuma vacina cadastrada neste período.',
            ),
          ),
        );
      } else if (controller.shouldShowVacinas()) {
        return SingleChildScrollView(child: _buildVacinasContent());
      } else {
        return const SizedBox.shrink();
      }
    });
  }


  Widget _buildVacinasContent() {
    return Obx(() {
      // Check if virtualization should be used (for large datasets)
      final shouldUseVirtualization = controller.vacinaCount > 50;
      
      if (shouldUseVirtualization) {
        return RepaintBoundary(child: _buildVirtualizedContent());
      } else {
        return RepaintBoundary(child: _buildTraditionalContent());
      }
    });
  }
  
  /// Builds content using virtualized list for better performance.
  Widget _buildVirtualizedContent() {
    return VirtualizedVaccineList(
      paginatedData: controller.paginatedData,
      config: controller.paginationConfig,
      onLoadMore: () => controller.loadNextPage(),
      onRefresh: () => controller.refreshVaccinesPaginated(),
      itemBuilder: (context, vaccine, index) {
        return VacinaCardWidget(
          vacina: vaccine,
          controller: controller,
          onEdit: () => _editVacina(vaccine),
          onDelete: () => _deleteVacina(vaccine),
        );
      },
      emptyWidget: NoDataWidget.vaccines(),
    );
  }
  
  /// Builds content using traditional grouped sections.
  Widget _buildTraditionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => VacinasAtrasadasSection(
          vacinasAtrasadas: controller.vacinasAtrasadas,
          controller: controller,
          onVacinaEdit: _editVacina,
          onVacinaDelete: _deleteVacina,
        )),
        Obx(() => ProximasVacinasSection(
          vacinasProximas: controller.vacinasProximasDoVencimento,
          controller: controller,
          onVacinaEdit: _editVacina,
          onVacinaDelete: _deleteVacina,
        )),
        Obx(() => VacinaSectionWidget(
          title: 'Todas as Vacinas',
          vacinas: controller.vacinas,
          controller: controller,
          onVacinaEdit: _editVacina,
          onVacinaDelete: _deleteVacina,
        )),
      ],
    );
  }


  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.canAddVacina() ? _addVacina : null,
          backgroundColor: controller.canAddVacina()
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addVacina() async {
    final result = await vacinaCadastro(context, null);
    if (result == true) {
      _loadVacinas();
    }
  }

  Future<void> _editVacina(VacinaVet vacina) async {
    final result = await vacinaCadastro(context, vacina);
    if (result == true) {
      _loadVacinas();
    }
  }

  Future<void> _deleteVacina(VacinaVet vacina) async {
    final confirm = await _showDeleteConfirmationDialog(vacina);

    if (confirm == true) {
      try {
        await controller.deleteVacina(vacina);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vacina excluída com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir vacina: $e'),
              backgroundColor: VacinaColors.atrasada(context),
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(VacinaVet vacina) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir a vacina ${vacina.nomeVacina}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<VacinaPageController>();
    super.dispose();
  }
}
