// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../core/services/info_device_service.dart';
import '../../../widgets/page_header_widget.dart';
import 'controller/implementos_detalhes_controller.dart';
import 'widgets/basic_info_card_widget.dart';
import 'widgets/details_card_widget.dart';
import 'widgets/image_card_widget.dart';

class ImplementosAgDetalhesPage extends StatelessWidget {
  final String idReg;

  const ImplementosAgDetalhesPage({super.key, required this.idReg});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImplementosDetalhesController>(
      init: ImplementosDetalhesController(idReg: idReg),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() {
                    return PageHeaderWidget(
                      title: 'Detalhes do Implemento',
                      subtitle: controller.isLoading.value
                          ? 'Carregando...'
                          : 'Informações do implemento',
                      icon: Icons.fire_truck_sharp,
                      showBackButton: true,
                      actions: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite,
                              size: 30, color: Colors.white),
                        ),
                        if (!InfoDeviceService().isProduction.value)
                          IconButton(
                            onPressed: controller.navigateToEdit,
                            icon: const Icon(Icons.edit,
                                size: 30, color: Colors.white),
                          ),
                      ],
                    );
                  }),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageCardWidget(),
                            SizedBox(height: 10),
                            BasicInfoCardWidget(),
                            SizedBox(height: 10),
                            DetailsCardWidget(),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
