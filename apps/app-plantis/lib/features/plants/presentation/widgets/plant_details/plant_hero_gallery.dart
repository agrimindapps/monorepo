import 'package:flutter/material.dart';

import '../../../../../core/theme/plantis_colors.dart';
import '../../../domain/entities/plant.dart';
import '../optimized_image_widget.dart';

/// Enhanced hero gallery widget with carousel functionality
/// 
/// Displays plant images as a prominent hero section with:
/// - Full-width hero image (300-400px height)
/// - Smooth carousel with page indicators
/// - Parallax scroll effect
/// - Tap to expand to fullscreen
/// - Add photo button for empty state
class PlantHeroGallery extends StatefulWidget {
  final Plant plant;
  final VoidCallback? onAddPhoto;

  const PlantHeroGallery({
    super.key,
    required this.plant,
    this.onAddPhoto,
  });

  @override
  State<PlantHeroGallery> createState() => _PlantHeroGalleryState();
}

class _PlantHeroGalleryState extends State<PlantHeroGallery> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page?.round() ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.plant.hasImage) {
      return _buildEmptyState(context);
    }

    return _buildHeroCarousel(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.08),
            PlantisColors.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PlantisColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PlantisColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              size: 64,
              color: PlantisColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma foto adicionada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione uma foto para visualizar a planta',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.onAddPhoto != null)
            FilledButton.icon(
              onPressed: widget.onAddPhoto,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Adicionar foto'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrls = widget.plant.imageUrls;
    final hasMultipleImages = imageUrls.length > 1;

    return Column(
      children: [
        // Hero image carousel
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main carousel
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullscreenImage(context, imageUrls, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: OptimizedImageWidget(
                        imageUrl: imageUrls[index],
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(16),
                        enablePreloading: index == 0,
                      ),
                    ),
                  );
                },
              ),

              // Gradient overlay for better readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Navigation arrows (visible on desktop/tablet)
              if (hasMultipleImages && MediaQuery.of(context).size.width > 600)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              if (hasMultipleImages && MediaQuery.of(context).size.width > 600)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),

              // Tap to expand hint
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onAddPhoto != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: widget.onAddPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Page indicators
        if (hasMultipleImages) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                imageUrls.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? PlantisColors.primary
                          : PlantisColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentPage + 1}/${imageUrls.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],

        // Thumbnail strip (for multiple images)
        if (hasMultipleImages && imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < imageUrls.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentPage == index
                              ? PlantisColors.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: _currentPage == index ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: OptimizedImageWidget(
                          imageUrl: imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                          cacheKey: index,
                          enablePreloading: false,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showFullscreenImage(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
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
                      enablePreloading: false,
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
            if (widget.onAddPhoto != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onAddPhoto!();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            if (imageUrls.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${initialIndex + 1}/${imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
}
