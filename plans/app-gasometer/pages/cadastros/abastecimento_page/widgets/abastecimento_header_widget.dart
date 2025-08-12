// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../widgets/appbar_widget.dart';
import '../controller/abastecimento_page_controller.dart';

class AbastecimentoHeaderWidget extends GetView<AbastecimentoPageController>
    implements PreferredSizeWidget {
  const AbastecimentoHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PageHeaderWidget(
        title: 'Abastecimentos',
        icon: Icons.local_gas_station,
        iconColor: Colors.black,
        iconBackgroundColor: Colors.grey.shade100,
        iconBorderColor: Colors.grey.shade300,
        showBackButton: false,
        actions: [
          Obx(() => controller.abastecimentosAgrupados.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    controller.showHeader.value
                        ? Icons.assessment
                        : Icons.assessment_outlined,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: () => controller.toggleHeader(),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
