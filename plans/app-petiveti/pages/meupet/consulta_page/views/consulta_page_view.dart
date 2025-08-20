// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../constants/design_tokens.dart';
import '../../../../widgets/animalSelect_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_animal_selecionado_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../../consulta_cadastro/index.dart';
import '../controllers/consulta_page_controller.dart';
import 'widgets/consulta_filter_bar.dart';
import 'widgets/consulta_list.dart';
import 'widgets/consulta_search_bar.dart';
import 'widgets/consulta_stats_card.dart';
import 'widgets/empty_state.dart';

class ConsultaPageView extends StatefulWidget {
  const ConsultaPageView({super.key});

  @override
  State<ConsultaPageView> createState() => _ConsultaPageViewState();
}

class _ConsultaPageViewState extends State<ConsultaPageView> {
  late ConsultaPageController controller;

  @override
  void initState() {
    super.initState();
    
    // Try to find existing controller first, create only if not found
    try {
      controller = Get.find<ConsultaPageController>();
    } catch (e) {
      controller = Get.put(ConsultaPageController());
    }
    
    // Ensure data is loaded after the widget is built if an animal is already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadDataIfNeeded();
    });
  }
  
  void _checkAndLoadDataIfNeeded() {
    // Check if there's an animal selected in the global controller but not in this page controller
    final animalController = Get.find<AnimalPageController>();
    
    // Only sync if animal is different from what's currently selected in this controller
    if (animalController.selectedAnimalId.isNotEmpty && 
        animalController.selectedAnimalId != controller.selectedAnimalId) {
      final selectedAnimal = animalController.selectedAnimal;
      controller.onAnimalSelected(animalController.selectedAnimalId, selectedAnimal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
          title: 'Consultas',
          subtitle: controller.getSubtitle(),
          icon: Icons.medical_services,
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
          actions: [
            if (controller.hasConsultas)
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: _exportConsultas,
                tooltip: 'Exportar consultas',
              ),
          ],
        ));
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: DesignTokens.maxContentWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: AnimalDropdownWidget(
        onAnimalSelected: (animalId, animal) {
          controller.onAnimalSelected(animalId, animal);
        },
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (!controller.hasSelectedAnimal) {
        return const NoAnimalSelecionadoWidget();
      } else if (controller.shouldShowLoading()) {
        return const Padding(
          padding: EdgeInsets.all(DesignTokens.spacing32),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.shouldShowError()) {
        return Padding(
          padding: const EdgeInsets.all(DesignTokens.spacing16),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: DesignTokens.colorError),
                const SizedBox(height: DesignTokens.spacing16),
                Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: DesignTokens.colorError),
                ),
                const SizedBox(height: DesignTokens.spacing16),
                ElevatedButton(
                  onPressed: controller.refreshConsultas,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      } else if (controller.shouldShowNoData()) {
        return SingleChildScrollView(child: _buildNoDataContent());
      } else if (controller.shouldShowConsultas()) {
        return SingleChildScrollView(child: _buildConsultasList());
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildNoDataContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          MonthsNavigationWidget(
            monthsList: controller.getMonthsList(),
            currentIndex: controller.getCurrentMonthIndex(),
            onMonthTap: (index) => controller.setCurrentMonthIndex(index),
          ),
          const SizedBox(height: 8),
          _buildSearchAndFilters(),
          const SizedBox(height: DesignTokens.spacing16),
          EmptyState(
            title: 'Nenhuma consulta encontrada',
            subtitle: controller.hasSelectedAnimal 
                ? 'Ainda não há consultas registradas para ${controller.selectedAnimal?.nome ?? "este animal"}'
                : 'Selecione um animal para ver suas consultas',
            icon: Icons.medical_services_outlined,
            actionLabel: controller.hasSelectedAnimal ? 'Nova Consulta' : null,
            onAction: controller.hasSelectedAnimal ? _addNewConsulta : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConsultasList() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSearchAndFilters(),
          Obx(() {
            if (controller.hasConsultas) {
              return ConsultaStatsCard(controller: controller);
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: DesignTokens.spacing8),
          ConsultaList(controller: controller),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        ConsultaSearchBar(controller: controller),
        const SizedBox(height: DesignTokens.spacing12),
        ConsultaFilterBar(controller: controller),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.hasSelectedAnimal ? _addNewConsulta : null,
          backgroundColor: controller.hasSelectedAnimal
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          tooltip: 'Nova consulta',
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addNewConsulta() async {
    if (!controller.hasSelectedAnimal) {
      Get.snackbar(
        'Erro',
        'Selecione um animal primeiro',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DesignTokens.colorError,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await consultaCadastro(context, null);
    if (result == true) {
      controller.refreshConsultas();
    }
  }

  void _exportConsultas() async {
    if (!controller.hasSelectedAnimal) {
      Get.snackbar(
        'Erro',
        'Selecione um animal primeiro',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DesignTokens.colorError,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exportando consultas...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final csvData = await controller.exportConsultasToCsv(controller.selectedAnimalId!);
      
      // Close loading dialog
      Get.back();
      
      if (csvData.isNotEmpty) {
        Get.snackbar(
          'Sucesso',
          'Consultas exportadas com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DesignTokens.colorSuccess,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Erro',
          'Falha ao exportar consultas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DesignTokens.colorError,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Erro',
        'Erro ao exportar consultas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DesignTokens.colorError,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    Get.delete<ConsultaPageController>();
    super.dispose();
  }
}
