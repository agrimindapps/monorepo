// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/implementos_cadastro_controller.dart';

class ImageSelectorWidget extends StatelessWidget {
  final bool isMiniatura;
  final VoidCallback onTap;
  final String label;
  final ImplementosCadastroController controller;

  const ImageSelectorWidget({
    super.key,
    required this.isMiniatura,
    required this.onTap,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = isMiniatura
        ? controller.imageMiniatura != null
        : controller.images.isNotEmpty;
    final displayImage = isMiniatura
        ? controller.imageMiniatura
        : (controller.images.isNotEmpty ? controller.images[0] : null);

    return Card(
      child: Container(
        height: 240,
        width:
            (MediaQuery.of(context).size.width / 2) - (isMiniatura ? 20 : 16),
        color: Colors.blueGrey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!hasImage)
              Center(
                child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.add_a_photo),
                ),
              )
            else if (displayImage != null)
              Image.file(displayImage),
            Text(label),
          ],
        ),
      ),
    );
  }
}
