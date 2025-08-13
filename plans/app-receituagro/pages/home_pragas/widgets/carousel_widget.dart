// Flutter imports:
// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Project imports:
import '../constants/home_pragas_constants.dart';
import '../models/praga_item.dart';
import '../utils/image_utils.dart';
import 'carousel_item.dart';

class CarouselWidget extends StatelessWidget {
  static const Widget _carouselSpacing =
      SizedBox(height: UiConstants.carouselSpacing);
  static const Widget _dotSpacing = SizedBox(height: UiConstants.dotSpacing);

  final List<PragaItem> items;
  final CarouselSliderController carouselController;
  final Function(int) onPageChanged;
  final Function(int) onDotTap;
  final Function(String) onItemTap;
  final int currentIndex;
  final bool enableLazyLoading;
  final int preloadRadius;

  const CarouselWidget({
    super.key,
    required this.items,
    required this.carouselController,
    required this.onPageChanged,
    required this.onDotTap,
    required this.onItemTap,
    required this.currentIndex,
    this.enableLazyLoading = true,
    this.preloadRadius = UiConstants.carouselPreloadRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Pre-load adjacent images with optimization
    if (enableLazyLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadAdjacentImages(context);
      });
    }

    return Column(
      children: [
        _buildCarousel(),
        _carouselSpacing,
        _buildDotIndicators(),
        _dotSpacing,
      ],
    );
  }

  static const Widget _emptyStateWidget = SizedBox(
    height: UiConstants.carouselHeight,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: UiConstants.largeIconSize, color: Colors.grey),
          SizedBox(height: UiConstants.smallPadding),
          Text(
            'Nenhuma sugestão disponível',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() {
    return _emptyStateWidget;
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      carouselController: carouselController,
      options: CarouselOptions(
        height: 280,
        aspectRatio: 16 / 9,
        viewportFraction: 0.6,
        initialPage: 0,
        enableInfiniteScroll: items.length > 1,
        reverse: false,
        autoPlay: items.length > 1,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) {
          onPageChanged(index);
          // Preload images when page changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = Get.context;
            if (context != null) {
              _preloadAdjacentImages(context);
            }
          });
        },
      ),
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return CarouselItem(
          item: item,
          onTap: () => onItemTap(item.idReg),
          shouldPreloadImage:
              enableLazyLoading ? _shouldPreloadImage(index) : true,
          showPlaceholder: enableLazyLoading,
        );
      }).toList(),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => onDotTap(entry.key),
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == entry.key
                  ? Colors.green.shade700
                  : Colors.green.shade200,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Determines if image should be preloaded based on distance from current index
  bool _shouldPreloadImage(int index) {
    final distance = (index - currentIndex).abs();
    return distance <= preloadRadius;
  }

  /// Pre-loads images for adjacent carousel items to improve performance
  void _preloadAdjacentImages(BuildContext context) {
    if (items.isEmpty) return;

    final currentIdx = currentIndex;
    final imagesToPreload = <String>[];

    // Preload images within the specified radius
    for (int i = -preloadRadius; i <= preloadRadius; i++) {
      final targetIdx = (currentIdx + i) % items.length;
      if (targetIdx >= 0 && targetIdx < items.length) {
        final adjustedIdx =
            targetIdx < 0 ? items.length + targetIdx : targetIdx;
        if (ImageUtils.isValidImagePath(items[adjustedIdx].imagem)) {
          final imagePath = ImageUtils.buildImagePath(items[adjustedIdx].imagem);
          imagesToPreload.add(imagePath);
        }
      }
    }

    // Preload unique images with priority
    final uniqueImages = imagesToPreload.toSet();
    for (final imagePath in uniqueImages) {
      _preloadImageWithFallback(imagePath, context);
    }
  }

  /// Preloads image with error handling and fallback
  Future<void> _preloadImageWithFallback(
      String imagePath, BuildContext context) async {
    try {
      await precacheImage(
        AssetImage(imagePath),
        context,
        onError: (exception, stackTrace) {
          debugPrint('Image preload failed for $imagePath: $exception');
        },
      );
    } catch (error) {
      // Erro silencioso ao pré-carregar imagem
    }
  }
}
