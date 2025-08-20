// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/implementos_lista_controller.dart';
import 'widgets/implemento_empty_state.dart';
import 'widgets/implemento_list_item.dart';
import 'widgets/implemento_loading.dart';

class ImplementosAgListaPage extends StatelessWidget {
  final controller = Get.put(ImplementosListaController());

  ImplementosAgListaPage({super.key});

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        onPressed: controller.carregarDados,
        icon: const Icon(Icons.refresh, size: 25, color: Colors.white),
      ),
      if (!InfoDeviceService().isProduction.value)
        IconButton(
          onPressed: controller.navigateToRegister,
          icon: const Icon(Icons.add, size: 25, color: Colors.white),
        ),
    ];
  }

  Widget _buildImplementosList() {
    return Obx(() {
      if (controller.implementos.isEmpty) {
        return const ImplementoEmptyState();
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            itemCount: controller.implementos.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => ImplementoListItem(
              implemento: controller.implementos[index],
              onTap: controller.navigateToDetails,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading) {
        return const ImplementoLoading();
      }
      return _buildImplementosList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PageHeaderWidget(
                    title: 'Implementos',
                    subtitle: '${controller.implementos.length} registros',
                    icon: Icons.fire_truck_sharp,
                    showBackButton: true,
                    actions: _buildAppBarActions(),
                  ),
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
        ));
  }
}
