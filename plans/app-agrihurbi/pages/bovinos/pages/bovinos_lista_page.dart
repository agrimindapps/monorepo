// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/info_device_service.dart';
import '../../../widgets/page_header_widget.dart';
import '../lista/controllers/bovinos_lista_controller.dart';
import '../lista/widgets/bovino_empty_state.dart';
import '../lista/widgets/bovino_list_item.dart';
import '../lista/widgets/bovino_loading.dart';
import 'bovinos_cadastro_page.dart';
import 'bovinos_detalhes_page.dart';

class BovinosListaPage extends GetView<BovinosListaController> {
  const BovinosListaPage({super.key});

  void _navigateToRegister() {
    Get.to(
      () => const BovinosCadastroPage(),
      arguments: {'idReg': ''},
    );
  }

  void _navigateToDetails(String idReg) {
    Get.to(
      () => const BovinosDetalhesPage(),
      arguments: {'idReg': idReg},
    );
  }

  List<Widget> _buildAppBarActions() {
    if (InfoDeviceService().isProduction.value) return [];

    return [
      IconButton(
        onPressed: controller.loadBovinos,
        icon: const Icon(Icons.refresh, size: 25),
      ),
      IconButton(
        onPressed: _navigateToRegister,
        icon: const Icon(Icons.add, size: 25),
      ),
    ];
  }

  Widget _buildBovinosList() {
    return Obx(() {
      if (controller.bovinos.isEmpty) {
        return const BovinoEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadBovinos,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade300,
              ),
              itemCount: controller.bovinos.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) => BovinoListItem(
                bovino: controller.bovinos[index],
                onTap: _navigateToDetails,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const BovinoLoading();
      }

            if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.error.value,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadBovinos,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        );
      }

      return _buildBovinosList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => PageHeaderWidget(
                    title: 'Bovinos',
                    subtitle: '${controller.bovinos.length} registros',
                    icon: Icons.pets,
                    showBackButton: true,
                    actions: _buildAppBarActions(),
                  )),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
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
}
