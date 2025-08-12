// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../widgets/months_navigation_widget.dart';
import '../controller/abastecimento_page_controller.dart';

class AbastecimentoMonthsNavigationWidget
    extends GetView<AbastecimentoPageController> {
  const AbastecimentoMonthsNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final months = controller.abastecimentosAgrupados.isNotEmpty
          ? controller.generateMonthsList(controller.abastecimentosAgrupados)
          : <DateTime>[];

      return MonthsNavigationWidget(
        monthsList: months,
        currentIndex: controller.currentCarouselIndex.value,
        onMonthTap: (index) => controller.animateToPage(index),
      );
    });
  }
}
