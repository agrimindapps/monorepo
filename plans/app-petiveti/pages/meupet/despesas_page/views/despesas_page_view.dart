// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../widgets/animalSelect_widget.dart';
import '../../../../widgets/bottombar_widget.dart';
import '../../../../widgets/months_navigation_widget.dart';
import '../../../../widgets/no_animal_selecionado_widget.dart';
import '../../../../widgets/page_header_widget.dart';
import '../../../meupet/despesas_cadastro/index.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../controllers/despesas_page_controller.dart';
import 'widgets/despesa_card.dart';
import 'widgets/no_data_message.dart';
import 'widgets/search_field.dart';

class DespesasPageView extends StatefulWidget {
  const DespesasPageView({super.key});

  @override
  State<DespesasPageView> createState() => _DespesasPageViewState();
}

class _DespesasPageViewState extends State<DespesasPageView> {
  late DespesasPageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DespesasPageController());
    
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

  Future<void> _loadDespesas() async {
    await controller.loadDespesas();
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
          title: 'Despesas',
          subtitle: controller.getSubtitle(),
          icon: Icons.payment,
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ));
  }

  Widget _buildBody() {
    return Center(
      child: SizedBox(
        width: 1020,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAnimalSelector(),
              const SizedBox(height: 12),
              _buildSearchField(),
              Expanded(child: Obx(() => _buildContent())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return AnimalDropdownWidget(
      onAnimalSelected: (animalId, animal) {
        controller.onAnimalSelected(animalId, animal);
      },
    );
  }

  Widget _buildSearchField() {
    return Obx(() {
      if (controller.shouldShowSearchField()) {
        return DespesasSearchField(
          onSearchChanged: (value) => controller.onSearchChanged(value),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildContent() {
    if (controller.shouldShowLoading()) {
      return const Center(child: CircularProgressIndicator());
    } else if (controller.shouldShowError()) {
      return Center(child: Text(controller.errorMessage!));
    } else if (controller.shouldShowNoAnimalSelected()) {
      return const NoAnimalSelecionadoWidget();
    } else if (controller.shouldShowNoData()) {
      return SingleChildScrollView(child: _buildNoData());
    } else if (controller.shouldShowDespesas()) {
      return SingleChildScrollView(child: _buildDespesasList());
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
            icon: Icons.payment_outlined,
            message: 'Nenhuma despesa cadastrada neste período.',
          ),
        ],
      ),
    );
  }

  Widget _buildDespesasList() {
    final filteredDespesas = controller.filteredDespesas;

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredDespesas.length,
      itemBuilder: (context, index) {
        return DespesaCard(
          despesa: filteredDespesas[index],
          onTap: () => _editDespesa(filteredDespesas[index]),
          formatarData: controller.formatarData,
          formatarValor: controller.formatarValor,
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() => FloatingActionButton(
          onPressed: controller.canAddDespesa() ? _addDespesa : null,
          backgroundColor: controller.canAddDespesa()
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Colors.grey[400],
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addDespesa() async {
    final result = await despesaCadastro(
      context, 
      null,
      selectedAnimalId: controller.selectedAnimalId,
    );
    if (result == true) {
      _loadDespesas();
    }
  }

  Future<void> _editDespesa(DespesaVet despesa) async {
    final result = await despesaCadastro(
      context,
      despesa,
    );
    if (result == true) {
      _loadDespesas();
    }
  }
}
