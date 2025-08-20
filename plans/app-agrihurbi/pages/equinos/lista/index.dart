// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/equinos_lista_controller.dart';
import 'widgets/equino_empty_state.dart';
import 'widgets/equino_list_item.dart';
import 'widgets/equino_loading.dart';

class EquinosListaPage extends GetView<EquinosListaController> {
  const EquinosListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() {
                return PageHeaderWidget(
                  title: 'Equinos',
                  subtitle: '${controller.equinosCount} registros',
                  icon: Icons.pets,
                  showBackButton: true,
                  actions: _buildAppBarActions(),
                );
              }),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (InfoDeviceService().isProduction.value) return [];

    return [
      IconButton(
        onPressed: controller.carregarDados,
        icon: const Icon(Icons.refresh, size: 25, color: Colors.white),
      ),
      IconButton(
        onPressed: controller.navigateToRegister,
        icon: const Icon(Icons.add, size: 25, color: Colors.white),
      ),
    ];
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const EquinoLoadingWidget();
      }
      return _buildEquinosList();
    });
  }

  Widget _buildEquinosList() {
    if (!controller.hasEquinos) {
      return const EquinoEmptyStateWidget();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.grey.shade300,
          ),
          itemCount: controller.equinos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => EquinoListItemWidget(
            equino: controller.equinos[index],
            onTap: controller.navigateToDetails,
          ),
        ),
      ),
    );
  }
}
