// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/implementos_detalhes_controller.dart';

class ImageCardWidget extends GetView<ImplementosDetalhesController> {
  const ImageCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Obx(() {
          final implemento = controller.implemento.value;

          if (implemento == null) {
            return const Icon(Icons.image, size: 100, color: Colors.grey);
          }

          if (implemento.imagens.isEmpty) {
            return const Icon(Icons.image, size: 100, color: Colors.grey);
          }

          return Image.network(implemento.imagens[0], fit: BoxFit.cover);
        }),
      ),
    );
  }
}
