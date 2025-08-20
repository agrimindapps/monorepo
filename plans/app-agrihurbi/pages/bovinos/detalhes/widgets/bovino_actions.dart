// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/services/info_device_service.dart';
import '../../pages/bovinos_cadastro_page.dart';

class BovinoActions extends StatelessWidget {
  final String idReg;
  final Function(String) onRemove;

  const BovinoActions({
    super.key,
    required this.idReg,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (InfoDeviceService().isProduction.value) return const SizedBox.shrink();

    return Row(
      children: [
        IconButton(
          onPressed: () => onRemove(idReg),
          icon: const Icon(Icons.remove_circle, size: 30),
        ),
        IconButton(
          onPressed: () {
            Get.to(
              () => const BovinosCadastroPage(),
              arguments: {'idReg': idReg},
            );
          },
          icon: const Icon(Icons.edit, size: 30),
        ),
      ],
    );
  }
}
