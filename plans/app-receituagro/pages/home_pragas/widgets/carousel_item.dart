// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/praga_item.dart';
import '../utils/device_performance_helper.dart';
import '../utils/image_utils.dart';
import '../utils/praga_type_helper.dart';

class CarouselItem extends StatelessWidget {
  static const Widget _itemSpacing = SizedBox(height: 8);
  static const Widget _typeSpacing = SizedBox(width: 4);

  final PragaItem item;
  final VoidCallback onTap;
  final bool shouldPreloadImage;
  final bool showPlaceholder;

  const CarouselItem({
    super.key,
    required this.item,
    required this.onTap,
    this.shouldPreloadImage = true,
    this.showPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = PragaTypeHelper.getTipoCardColor(item.tipo);
    final pragaIcon = PragaTypeHelper.getTipoIcon(item.tipo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            _buildImageOrPlaceholder(cardColor, pragaIcon),
            _buildGradientOverlay(),
            _buildItemInfo(),
            _buildTouchLayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOrPlaceholder(Color cardColor, IconData pragaIcon) {
    if (ImageUtils.isValidImagePath(item.imagem) && shouldPreloadImage) {
      final imagePath = ImageUtils.buildImagePath(item.imagem);
      return Builder(
        builder: (context) {
          final imageDimensions =
              DevicePerformanceHelper.getOptimizedImageDimensions(context);
          return Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderContainer(cardColor, pragaIcon);
            },
            cacheWidth: imageDimensions.carouselWidth,
            cacheHeight: imageDimensions.carouselHeight,
          );
        },
      );
    }
    return _buildPlaceholderContainer(cardColor, pragaIcon);
  }

  Widget _buildPlaceholderContainer(Color cardColor, IconData pragaIcon) {
    return Container(
      color: cardColor,
      child: Center(
        child: Icon(
          pragaIcon,
          size: 80,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }


  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.9],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: _buildItemDetails(),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.nomeComum ?? 'Nome desconhecido',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.nomeCientifico != null)
          Text(
            item.nomeCientifico!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        _itemSpacing,
        _buildTypeTag(),
      ],
    );
  }

  Widget _buildTypeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PragaTypeHelper.getTipoIcon(item.tipo),
            color: Colors.white,
            size: 12,
          ),
          _typeSpacing,
          Text(
            PragaTypeHelper.getTipoText(item.tipo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo() {
    return const SizedBox.shrink();
  }

  Widget _buildTouchLayer() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),
      ),
    );
  }
}
