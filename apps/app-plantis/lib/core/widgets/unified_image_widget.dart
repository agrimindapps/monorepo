import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../adapters/plantis_image_service_adapter.dart';
import '../di/injection_container.dart';
import '../services/image_preloader_service.dart';

/// Unified image widget that consolidates all image display functionality
/// Combines features from OptimizedImageWidget and OptimizedPlantImageWidget
/// Provides a single, parameterizable widget for all image needs
class UnifiedImageWidget extends StatefulWidget {
  // Image sources (priority: base64 > network URLs > placeholder)
  final String? imageBase64;
  final String? imageUrl;
  final List<String> imageUrls;

  // Dimensions and appearance
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool useCircularBorder;

  // Customization
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;
  final Color? borderColor;
  final double? borderWidth;

  // Performance optimization
  final bool enablePreloading;
  final bool enableMemoryCache;
  final int? cacheKey;
  final bool keepAlive;

  // Plant-specific features
  final bool isPlantImage;
  final IconData? placeholderIcon;

  const UnifiedImageWidget({
    super.key,
    // Image sources
    this.imageBase64,
    this.imageUrl,
    this.imageUrls = const [],
    // Dimensions
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    // Appearance
    this.borderRadius,
    this.useCircularBorder = false,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.borderColor,
    this.borderWidth,
    // Performance
    this.enablePreloading = true,
    this.enableMemoryCache = true,
    this.cacheKey,
    this.keepAlive = false,
    // Plant-specific
    this.isPlantImage = false,
    this.placeholderIcon,
  });

  /// Factory constructor for plant images with optimized defaults
  factory UnifiedImageWidget.plant({
    Key? key,
    String? imageBase64,
    List<String> imageUrls = const [],
    double size = 80.0,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return UnifiedImageWidget(
      key: key,
      imageBase64: imageBase64,
      imageUrls: imageUrls,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      useCircularBorder: true,
      placeholder: placeholder,
      errorWidget: errorWidget,
      isPlantImage: true,
      placeholderIcon: Icons.eco,
      enableMemoryCache: true,
      keepAlive: true,
    );
  }

  /// Factory constructor for general images with network preloading
  factory UnifiedImageWidget.network({
    Key? key,
    required String imageUrl,
    double width = 100,
    double height = 100,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
    bool enablePreloading = true,
    int? cacheKey,
  }) {
    return UnifiedImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      placeholder: placeholder,
      errorWidget: errorWidget,
      enablePreloading: enablePreloading,
      cacheKey: cacheKey,
    );
  }

  @override
  State<UnifiedImageWidget> createState() => _UnifiedImageWidgetState();
}

class _UnifiedImageWidgetState extends State<UnifiedImageWidget>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // LRU cache for base64 images
  static final _LRUImageCache _base64Cache = _LRUImageCache(maxSize: 30);

  Uint8List? _cachedImageBytes;
  bool _isDecoding = false;
  String? _currentImageKey;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    if (widget.enableMemoryCache) {
      WidgetsBinding.instance.addObserver(this);
    }
    _preloadImageIfEnabled();
    _loadImage();
  }

  @override
  void didUpdateWidget(UnifiedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload if image source changed
    if (oldWidget.imageBase64 != widget.imageBase64 ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imageUrls != widget.imageUrls) {
      _preloadImageIfEnabled();
      _loadImage();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    if (widget.enableMemoryCache) {
      // Clear half the cache during memory pressure
      final targetSize = _base64Cache.maxSize ~/ 2;
      while (_base64Cache.length > targetSize) {
        _base64Cache.removeLRU();
      }
    }
  }

  void _preloadImageIfEnabled() {
    if (!widget.enablePreloading) return;

    // Preload network image
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Use enhanced image service adapter for better integration
      try {
        final adapter = sl<PlantisImageServiceAdapter>();
        adapter.preloadImage(widget.imageUrl!);
      } catch (e) {
        // Fallback to original preloader service
        ImagePreloaderService.instance.preloadImage(widget.imageUrl!);
      }
    }

    // Preload from URLs list
    if (widget.imageUrls.isNotEmpty) {
      // Use enhanced image service adapter for better integration
      try {
        final adapter = sl<PlantisImageServiceAdapter>();
        adapter.preloadImages(widget.imageUrls, priority: true);
      } catch (e) {
        // Fallback to original preloader service
        ImagePreloaderService.instance.preloadImages(
          widget.imageUrls,
          priority: true,
        );
      }
    }
  }

  void _loadImage() {
    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      _loadBase64Image();
    } else {
      // Reset cached bytes if not using base64
      setState(() {
        _cachedImageBytes = null;
        _currentImageKey = null;
      });
    }
  }

  void _loadBase64Image() {
    if (!widget.enableMemoryCache) {
      // Direct decode without caching
      _decodeImageAsync(widget.imageBase64!);
      return;
    }

    final imageKey = widget.imageBase64!;

    // Check cache first
    final cachedImage = _base64Cache.get(imageKey);
    if (cachedImage != null) {
      setState(() {
        _cachedImageBytes = cachedImage;
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

    _decodeImageAsync(imageKey);
  }

  Future<void> _decodeImageAsync(String base64String) async {
    try {
      final imageBytes = await _decodeBase64(base64String);

      if (!mounted || _currentImageKey != base64String) {
        return;
      }

      // Cache if enabled
      if (widget.enableMemoryCache) {
        _base64Cache.put(base64String, imageBytes);
      }

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    Widget child = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildImageContent(),
    );

    // Apply border if specified
    if (widget.borderColor != null && widget.borderWidth != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.borderColor!,
            width: widget.borderWidth!,
          ),
          borderRadius: _getBorderRadius(),
        ),
        child: child,
      );
    }

    // Apply border radius clipping
    child = ClipRRect(borderRadius: _getBorderRadius(), child: child);

    // Wrap with RepaintBoundary for performance
    return RepaintBoundary(
      key: widget.cacheKey != null ? ValueKey(widget.cacheKey) : null,
      child: child,
    );
  }

  BorderRadius _getBorderRadius() {
    if (widget.useCircularBorder) {
      return BorderRadius.circular(widget.width / 2);
    }
    return widget.borderRadius ?? BorderRadius.circular(8.0);
  }

  Widget _buildImageContent() {
    // Show loading placeholder while decoding
    if (_isDecoding) {
      return _buildPlaceholder();
    }

    // Priority 1: Base64 image
    if (_cachedImageBytes != null) {
      return _buildBase64Image();
    }

    // Priority 2: Primary network URL
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrl!);
    }

    // Priority 3: URLs list
    if (widget.imageUrls.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrls.first);
    }

    // Priority 4: Placeholder
    return _buildPlaceholder();
  }

  Widget _buildBase64Image() {
    if (_cachedImageBytes == null) return _buildPlaceholder();

    return Image.memory(
      _cachedImageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width.round(),
      cacheHeight: widget.height.round(),
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildNetworkImage(String url) {
    return _buildCachedNetworkImage(url);
  }

  Widget _buildCachedNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: widget.width.round(),
      memCacheHeight: widget.height.round(),
      maxWidthDiskCache: (widget.width * 2).round(),
      maxHeightDiskCache: (widget.height * 2).round(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      useOldImageOnUrlChange: true,
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return _buildDefaultPlaceholder();
  }

  Widget _buildDefaultPlaceholder() {
    final theme = Theme.of(context);
    final iconData =
        widget.placeholderIcon ??
        (widget.isPlantImage ? Icons.eco : Icons.image);

    if (widget.isPlantImage) {
      // Plant-specific placeholder with border
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape:
              widget.useCircularBorder ? BoxShape.circle : BoxShape.rectangle,
          color:
              widget.placeholderColor ?? theme.colorScheme.surfaceContainerHigh,
          border: Border.all(
            color: widget.borderColor ?? theme.colorScheme.primary,
            width: widget.borderWidth ?? 2,
          ),
          borderRadius: widget.useCircularBorder ? null : _getBorderRadius(),
        ),
        child: Icon(
          iconData,
          size: (widget.width + widget.height) / 8,
          color: theme.colorScheme.primary,
        ),
      );
    }

    // General placeholder
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color:
            widget.placeholderColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: _getBorderRadius(),
      ),
      child: Icon(
        iconData,
        size: (widget.width + widget.height) / 8,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: _getBorderRadius(),
      ),
      child: Icon(
        Icons.error_outline,
        size: (widget.width + widget.height) / 8,
        color: theme.colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.enableMemoryCache) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}

/// LRU (Least Recently Used) cache implementation for image caching
/// Automatically manages memory by removing least recently used items when capacity is exceeded
class _LRUImageCache {
  final int maxSize;
  final Map<String, _CacheNode> _cache = {};
  _CacheNode? _head;
  _CacheNode? _tail;

  _LRUImageCache({required this.maxSize});

  /// Get an image from cache and mark it as recently used
  Uint8List? get(String key) {
    final node = _cache[key];
    if (node == null) return null;

    // Move to front (mark as most recently used)
    _moveToFront(node);
    return node.value;
  }

  /// Put an image in cache
  void put(String key, Uint8List value) {
    final existingNode = _cache[key];

    if (existingNode != null) {
      // Update existing node and move to front
      existingNode.value = value;
      _moveToFront(existingNode);
      return;
    }

    // Create new node
    final newNode = _CacheNode(key, value);
    _cache[key] = newNode;

    // Add to front of doubly linked list
    _addToFront(newNode);

    // Remove least recently used if over capacity
    if (_cache.length > maxSize) {
      _removeLeastRecentlyUsed();
    }
  }

  /// Clear all cached images
  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
  }

  /// Get current cache size
  int get length => _cache.length;

  void _addToFront(_CacheNode node) {
    node.next = _head;
    node.prev = null;

    if (_head != null) {
      _head!.prev = node;
    }
    _head = node;

    _tail ??= node;
  }

  void _removeNode(_CacheNode node) {
    if (node.prev != null) {
      node.prev!.next = node.next;
    } else {
      _head = node.next;
    }

    if (node.next != null) {
      node.next!.prev = node.prev;
    } else {
      _tail = node.prev;
    }
  }

  void _moveToFront(_CacheNode node) {
    _removeNode(node);
    _addToFront(node);
  }

  void _removeLeastRecentlyUsed() {
    if (_tail == null) return;

    final lruNode = _tail!;
    _removeNode(lruNode);
    _cache.remove(lruNode.key);
  }

  /// Remove least recently used item (exposed for memory pressure handling)
  void removeLRU() => _removeLeastRecentlyUsed();
}

/// Node for the doubly linked list used in LRU cache
class _CacheNode {
  final String key;
  Uint8List value;
  _CacheNode? prev;
  _CacheNode? next;

  _CacheNode(this.key, this.value);
}

/// Extension for optimized ListView with image widgets
extension UnifiedImageListExtension on ListView {
  static Widget optimizedBuilder({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('unified_image_item_$index'),
          child: itemBuilder(context, index),
        );
      },
      controller: controller,
      padding: padding,
      // Performance optimizations
      cacheExtent: 500.0, // Preload 500px worth of content
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }
}
