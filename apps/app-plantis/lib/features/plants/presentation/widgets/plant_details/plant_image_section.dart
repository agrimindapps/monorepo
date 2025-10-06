import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../domain/entities/plant.dart';
import '../optimized_image_widget.dart';

/// Widget responsável por exibir e gerenciar as imagens da planta
class PlantImageSection extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onEditImages;

  const PlantImageSection({super.key, required this.plant, this.onEditImages});

  @override
  Widget build(BuildContext context) {
    if (!plant.hasImage) {
      return _buildEmptyImageState(context);
    }

    return _buildImageGallery(context);
  }

  Widget _buildEmptyImageState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.1),
            PlantisColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: PlantisColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma foto adicionada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (onEditImages != null)
            TextButton.icon(
              onPressed: onEditImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Adicionar fotos'),
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos (${plant.imagesCount})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (onEditImages != null)
              TextButton.icon(
                onPressed: onEditImages,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (plant.primaryImageUrl != null)
          GestureDetector(
            onTap: () => _showImagePreview(context, plant.imageUrls, 0),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: OptimizedImageWidget(
                  imageUrl: plant.primaryImageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16),
                  enablePreloading: true,
                ),
              ),
            ),
          ),
        if (plant.imageUrls.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: plant.imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < plant.imageUrls.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap:
                        () =>
                            _showImagePreview(context, plant.imageUrls, index),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border:
                            index == 0
                                ? Border.all(
                                  color: PlantisColors.primary,
                                  width: 2,
                                )
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: OptimizedImageWidget(
                          imageUrl: plant.imageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          cacheKey: index,
                          enablePreloading: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => _showFullGallery(context),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Ver todas as fotos'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showImagePreview(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder:
          (context) => Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: OptimizedImageWidget(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.contain,
                          cacheKey: index,
                          enablePreloading:
                              false, // Disable for fullscreen view
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
                if (imageUrls.length > 1)
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index == initialIndex
                                    ? Colors.white
                                    : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _showFullGallery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text('Fotos de ${plant.displayName}'),
                elevation: 0,
              ),
              body: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: plant.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap:
                        () =>
                            _showImagePreview(context, plant.imageUrls, index),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: OptimizedImageWidget(
                          imageUrl: plant.imageUrls[index],
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          cacheKey: index,
                          enablePreloading:
                              false, // Gallery view doesn't need preloading
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}
