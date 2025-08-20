// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

class BovinoImageSelector extends StatelessWidget {
  final bool isMiniatura;
  final VoidCallback onTap;
  final File? imageFile;
  final String label;

  const BovinoImageSelector({
    super.key,
    required this.isMiniatura,
    required this.onTap,
    this.imageFile,
    this.label = '',
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
            if (imageFile == null)
              Center(
                child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.add_a_photo),
                ),
              )
            else
              Image.file(imageFile!),
            Text(label),
          ],
        ),
      ),
    );
  }
}
