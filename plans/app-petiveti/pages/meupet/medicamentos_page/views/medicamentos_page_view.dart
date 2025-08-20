// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/15_medicamento_model.dart';
import '../../../../widgets/animalSelect_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_animal_selecionado_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../../medicamentos_cadastro/index.dart';
import '../controllers/medicamentos_page_controller.dart';
import 'widgets/medicamento_card.dart';
import 'widgets/no_data_message.dart';

class MedicamentosPageView extends StatefulWidget {
  const MedicamentosPageView({super.key});

  @override
  State<MedicamentosPageView> createState() => _MedicamentosPageViewState();
}

class _MedicamentosPageViewState extends State<MedicamentosPageView> {
  late MedicamentosPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MedicamentosPageController());
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
    if (animalController.selectedAnimalId.isNotEmpty &&
        !controller.hasSelectedAnimal) {
      // Sync the animal selection to this page
      final selectedAnimal = animalController.selectedAnimal;
      controller.onAnimalSelected(
          animalController.selectedAnimalId, selectedAnimal);
    }
  }

  Future<void> _loadMedicamentos() async {
    await controller.loadMedicamentos();
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
          title: 'Medicamentos',
          subtitle: controller.getSubtitle(),
          icon: Icons.medication,
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ));
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: 1020,
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
      if (controller.shouldShowLoading()) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.shouldShowError()) {
        return Center(child: Text(controller.errorMessage!));
      } else if (controller.shouldShowNoAnimalSelected()) {
        return const NoAnimalSelecionadoWidget();
      } else if (controller.shouldShowNoData()) {
        return SingleChildScrollView(child: _buildNoDataContent());
      } else if (controller.shouldShowMedicamentos()) {
        return SingleChildScrollView(child: _buildMedicamentosList());
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
          const NoDataMessage(
            icon: Icons.medication_outlined,
            message: 'Nenhum medicamento cadastrado neste período.',
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentosList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: controller.medicamentos.length,
      itemBuilder: (context, index) => MedicamentoCard(
        medicamento: controller.medicamentos[index],
        onEdit: _editMedicamento,
        onDelete: _deleteMedicamento,
        formatDate: controller.formatDateToString,
        isActive: controller.isMedicamentoActive,
        diasRestantes: controller.diasRestantesTratamento,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.canAddMedicamento() ? _addMedicamento : null,
          backgroundColor: controller.canAddMedicamento()
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addMedicamento() async {
    final result = await medicamentoCadastro(context, null);
    if (result == true) {
      _loadMedicamentos();
    }
  }

  Future<void> _editMedicamento(MedicamentoVet medicamento) async {
    final result = await medicamentoCadastro(context, medicamento);
    if (result == true) {
      _loadMedicamentos();
    }
  }

  Future<void> _deleteMedicamento(MedicamentoVet medicamento) async {
    final confirm = await _showDeleteConfirmationDialog(medicamento);

    if (confirm == true) {
      try {
        await controller.deleteMedicamento(medicamento);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medicamento excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir medicamento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(MedicamentoVet medicamento) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Deseja excluir o medicamento ${medicamento.nomeMedicamento}?'),
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
    Get.delete<MedicamentosPageController>();
    super.dispose();
  }
}
