import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized plant image widget with memory caching and lazy loading
class OptimizedPlantImageWidget extends StatefulWidget {
  final String? imageBase64;
  final List<String> imageUrls;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedPlantImageWidget({
    super.key,
    this.imageBase64,
    this.imageUrls = const [],
    this.size = 80.0,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<OptimizedPlantImageWidget> createState() =>
      _OptimizedPlantImageWidgetState();
}

class _OptimizedPlantImageWidgetState extends State<OptimizedPlantImageWidget> {
  static final Map<String, Uint8List> _imageCache = {};
  static const int _maxCacheSize = 50; // Limit memory usage

  Uint8List? _cachedImageBytes;
  bool _isDecoding = false;
  String? _currentImageKey;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedPlantImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reload if image source changed
    if (oldWidget.imageBase64 != widget.imageBase64 ||
        oldWidget.imageUrls != widget.imageUrls) {
      _loadImage();
    }
  }

  void _loadImage() {
    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      _loadBase64Image();
    } else if (widget.imageUrls.isNotEmpty) {
      // Network images will be handled by CachedNetworkImage
      setState(() {
        _cachedImageBytes = null;
        _currentImageKey = null;
      });
    } else {
      setState(() {
        _cachedImageBytes = null;
        _currentImageKey = null;
      });
    }
  }

  void _loadBase64Image() {
    final imageKey = widget.imageBase64!;

    // Check if already cached
    if (_imageCache.containsKey(imageKey)) {
      setState(() {
        _cachedImageBytes = _imageCache[imageKey];
        _currentImageKey = imageKey;
        _isDecoding = false;
      });
      return;
    }

    // Skip if already decoding the same image
    if (_isDecoding && _currentImageKey == imageKey) {
      return;
    }

    setState(() {
      _isDecoding = true;
      _currentImageKey = imageKey;
    });

    // Decode in background to avoid blocking UI
    _decodeImageAsync(imageKey);
  }

  Future<void> _decodeImageAsync(String base64String) async {
    try {
      // Use compute for heavy operations to avoid blocking UI
      final imageBytes = await _decodeBase64(base64String);

      // Check if widget is still mounted and this is still the current image
      if (!mounted || _currentImageKey != base64String) {
        return;
      }

      // Manage cache size
      if (_imageCache.length >= _maxCacheSize) {
        // Remove oldest entries (simple FIFO for now)
        final keysToRemove = _imageCache.keys.take(10).toList();
        for (final key in keysToRemove) {
          _imageCache.remove(key);
        }
      }

      // Cache the decoded image
      _imageCache[base64String] = imageBytes;

      setState(() {
        _cachedImageBytes = imageBytes;
        _isDecoding = false;
      });
    } catch (e) {
      if (mounted && _currentImageKey == base64String) {
        setState(() {
          _cachedImageBytes = null;
          _isDecoding = false;
        });
      }
    }
  }

  static Future<Uint8List> _decodeBase64(String base64String) async {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          widget.borderRadius ?? BorderRadius.circular(widget.size / 2),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Show loading placeholder while decoding
    if (_isDecoding) {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }

    // Show cached base64 image
    if (_cachedImageBytes != null) {
      return Image.memory(
        _cachedImageBytes!,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
        errorBuilder:
            (context, error, stackTrace) =>
                widget.errorWidget ?? _buildDefaultPlaceholder(),
        // Optimize memory usage
        cacheWidth: widget.size.round(),
        cacheHeight: widget.size.round(),
      );
    }

    // Show network image if available
    if (widget.imageUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrls.first,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
        placeholder:
            (context, url) => widget.placeholder ?? _buildDefaultPlaceholder(),
        errorWidget:
            (context, url, error) =>
                widget.errorWidget ?? _buildDefaultPlaceholder(),
        // Memory optimization
        memCacheWidth: widget.size.round(),
        memCacheHeight: widget.size.round(),
        maxWidthDiskCache: (widget.size * 2).round(),
        maxHeightDiskCache: (widget.size * 2).round(),
      );
    }

    // Default placeholder
    return widget.placeholder ?? _buildDefaultPlaceholder();
  }

  Widget _buildDefaultPlaceholder() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE3F2FD),
            border: Border.all(color: const Color(0xFF55D85A), width: 2),
          ),
          child: Icon(
            Icons.eco,
            size: widget.size * 0.45,
            color: const Color(0xFF55D85A),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Don't clear cache on dispose - let it persist for performance
    super.dispose();
  }

}
