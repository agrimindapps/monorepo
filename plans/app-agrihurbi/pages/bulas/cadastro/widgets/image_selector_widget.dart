// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

class ImageSelectorWidget extends StatelessWidget {
  final bool isMiniatura;
  final VoidCallback onTap;
  final String label;
  final File? displayImage;
  final bool hasImage;

  const ImageSelectorWidget({
    super.key,
    required this.isMiniatura,
    required this.onTap,
    required this.label,
    required this.displayImage,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
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
              Image.file(displayImage!),
            Text(label),
          ],
        ),
      ),
    );
  }
}
