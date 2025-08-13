// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/espacos_controller.dart';
import '../widgets/espacos_widget.dart';

class EspacosView extends GetView<EspacosController> {
  const EspacosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: PlantasColors.backgroundColor,
          appBar: _buildAppBar(context),
          body: const EspacosWidget(),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: PlantasColors.surfaceColor,
      elevation: 0,
      title: Text(
        'espacos.titulo'.tr,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: PlantasColors.textColor,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back,
          color: PlantasColors.textColor,
        ),
        tooltip: 'espacos.voltar_tooltip'.tr,
      ),
      actions: [
        IconButton(
          onPressed: controller.showNovoEspacoDialog,
          icon: Icon(
            Icons.add,
            color: PlantasColors.primaryColor,
            size: 28,
          ),
          tooltip: 'espacos.adicionar_tooltip'.tr,
        ),
      ],
    );
  }
}
