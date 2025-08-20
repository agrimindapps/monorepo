// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../../../../widgets/animalSelect_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_animal_selecionado_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../../lembretes_cadastro/index.dart';
import '../controllers/lembretes_page_controller.dart';
import 'widgets/lembrete_card.dart';
import 'widgets/no_data_message.dart';

class LembretesPageView extends StatefulWidget {
  const LembretesPageView({super.key});

  @override
  State<LembretesPageView> createState() => _LembretesPageViewState();
}

class _LembretesPageViewState extends State<LembretesPageView> {
  late LembretesPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LembretesPageController());
    
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

  Future<void> _loadLembretes() async {
    await controller.loadLembretes();
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
          title: 'Lembretes',
          subtitle: controller.getSubtitle(),
          icon: Icons.notification_important,
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ));
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: 1020,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildAnimalSelector(),
            Expanded(child: Obx(() => _buildContent())),
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
    if (controller.shouldShowLoading()) {
      return const Center(child: CircularProgressIndicator());
    } else if (controller.shouldShowError()) {
      return Center(child: Text(controller.errorMessage!));
    } else if (controller.shouldShowNoAnimalSelected()) {
      return const NoAnimalSelecionadoWidget();
    } else if (controller.shouldShowNoData()) {
      return _buildNoData();
    } else if (controller.shouldShowLembretes()) {
      return _buildLembretesList();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNoData() {
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
            icon: Icons.notification_important_outlined,
            message: 'Nenhum lembrete cadastrado neste período.',
          ),
        ],
      ),
    );
  }

  Widget _buildLembretesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: controller.lembretes.length,
      itemBuilder: (context, index) {
        return LembreteCard(
          lembrete: controller.lembretes[index],
          onToggleConcluido: _toggleLembreteConcluido,
          onEdit: _editLembrete,
          onDelete: _deleteLembrete,
          formatDateTime: controller.formatDateTimeToString,
          isAtrasado: controller.isLembreteAtrasado,
          getStatusText: controller.getLembreteStatusText,
          getStatusColor: controller.getLembreteStatusColor,
          getStatusIcon: controller.getLembreteStatusIcon,
          getActionIcon: controller.getLembreteActionIcon,
          getActionColor: controller.getLembreteActionColor,
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.canAddLembrete() ? _addLembrete : null,
          backgroundColor: controller.canAddLembrete()
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addLembrete() async {
    final result = await lembreteCadastro(context, null);
    if (result == true) {
      _loadLembretes();
    }
  }

  Future<void> _editLembrete(LembreteVet lembrete) async {
    final result = await lembreteCadastro(context, lembrete);
    if (result == true) {
      _loadLembretes();
    }
  }

  Future<void> _toggleLembreteConcluido(LembreteVet lembrete) async {
    try {
      await controller.toggleLembreteConcluido(lembrete);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLembrete(LembreteVet lembrete) async {
    final confirm = await _showDeleteConfirmationDialog();

    if (confirm == true) {
      try {
        await controller.deleteLembrete(lembrete);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lembrete excluído com sucesso.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir lembrete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja excluir este lembrete?'),
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
}
