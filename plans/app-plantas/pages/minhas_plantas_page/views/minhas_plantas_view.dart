// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/planta_model.dart';
import '../../../widgets/app_bottom_nav_widget.dart';
import '../../../widgets/search_bar_widget.dart';
import '../controller/minhas_plantas_controller.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/plant_card_widget.dart';
import '../widgets/plant_grid_card_widget.dart';

class MinhasPlantasView extends GetView<MinhasPlantasController> {
  const MinhasPlantasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: PlantasColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildContent(),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(),
          bottomNavigationBar: const AppBottomNavWidget(
            currentPage: BottomNavPage.plantas,
          ),
        ));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Minhas Plantas',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: PlantasColors.textColor,
              ),
            ),
          ),
          Obx(() {
            final plantCount = controller.plantasComTarefas.value.length;
            if (plantCount > 0) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: PlantasColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PlantasColors.primaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$plantCount ${plantCount == 1 ? 'planta' : 'plantas'}',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: PlantasColors.primaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() => controller.plantas.value.isNotEmpty
        ? Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      controller: controller.searchController,
                      searchText: controller.searchText.value,
                      hintText: 'Buscar plantas...',
                      onClear: () => controller.limparBusca(),
                      onChanged: (text) => controller.filtrarPlantas(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.toggleViewMode(),
                    icon: Icon(
                      controller.viewMode.value == 'list'
                          ? Icons.grid_view
                          : Icons.list,
                      color: PlantasColors.primaryColor,
                    ),
                    tooltip: controller.viewMode.value == 'list'
                        ? 'Visualizar em grade'
                        : 'Visualizar em lista',
                  ),
                ],
              ),
            ))
        : const SizedBox.shrink());
  }

  Widget _buildContent() {
    return Expanded(
      child: Obx(() {
        final plantas = controller.plantasComTarefas.value;
        final hasSearchText = controller.searchText.value.isNotEmpty;

        if (plantas.isEmpty) {
          return EmptyStateWidget(
            hasSearchText: hasSearchText,
            searchText: controller.searchText.value,
            onAddPlant: () => controller.adicionarPlanta(),
          );
        }

        return _buildPlantsList(plantas);
      }),
    );
  }

  Widget _buildPlantsList(List<PlantaModel> plantas) {
    return Obx(() {
      if (controller.viewMode.value == 'grid') {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: plantas.length,
          itemBuilder: (context, index) {
            final planta = plantas[index];
            return PlantGridCardWidget(
              planta: planta,
              controller: controller,
              onTap: () => controller.visualizarPlanta(planta),
              onEdit: () => controller.editarPlanta(planta),
              onRemove: () => controller.confirmarRemocaoPlanta(planta),
            );
          },
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          itemCount: plantas.length,
          itemBuilder: (context, index) {
            final planta = plantas[index];
            return PlantCardWidget(
              planta: planta,
              controller: controller,
              onTap: () => controller.visualizarPlanta(planta),
              onEdit: () => controller.editarPlanta(planta),
              onRemove: () => controller.confirmarRemocaoPlanta(planta),
            );
          },
        );
      }
    });
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => controller.adicionarPlanta(),
      backgroundColor: PlantasColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.add,
        size: 28.0,
      ),
    );
  }
}
