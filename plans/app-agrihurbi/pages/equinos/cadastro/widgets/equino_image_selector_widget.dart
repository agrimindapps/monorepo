// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

class EquinoImageSelector extends StatelessWidget {
  const EquinoImageSelector({
    super.key,
    required this.isMiniatura,
    required this.onTap,
    this.image,
    this.images,
    this.label = '',
    this.onRemove,
  });

  final bool isMiniatura;
  final VoidCallback onTap;
  final File? image;
  final List<File>? images;
  final String label;
  final Function(int)? onRemove;

  @override
  Widget build(BuildContext context) {
    if (isMiniatura) {
      return _buildMiniaturaSelector(context);
    } else {
      return _buildImagesSelector(context);
    }
  }

  Widget _buildMiniaturaSelector(BuildContext context) {
    final hasImage = image != null;

    return Card(
      child: Container(
        height: 240,
        width: (MediaQuery.of(context).size.width / 2) - 20,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!hasImage) ...[
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(Icons.add_a_photo, size: 32),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage && onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => onRemove!(0),
                  icon: const Icon(Icons.close, color: Colors.red),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSelector(BuildContext context) {
    final hasImages = images != null && images!.isNotEmpty;

    return Card(
      child: Container(
        height: 240,
        width: (MediaQuery.of(context).size.width / 2) - 16,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: hasImages
                  ? _buildImagesList()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: onTap,
                            icon:
                                const Icon(Icons.add_photo_alternate, size: 32),
                          ),
                          const SizedBox(height: 8),
                          const Text('Adicionar Imagens'),
                        ],
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (hasImages)
                    IconButton(
                      onPressed: onTap,
                      icon: const Icon(Icons.add, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images!.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  images![index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => onRemove!(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
