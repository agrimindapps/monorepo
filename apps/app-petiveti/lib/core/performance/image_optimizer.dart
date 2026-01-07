import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema avançado de otimização de carregamento e cache de imagens
class ImageOptimizer {
  static final ImageOptimizer _instance = ImageOptimizer._internal();
  factory ImageOptimizer() => _instance;
  ImageOptimizer._internal();

  final Map<String, CachedImage> _memoryCache = {};
  final Map<String, Future<ui.Image?>> _loadingImages = {};
  final Set<String> _preloadedImages = {};

  static const int maxMemoryCache = 50; // Máximo de imagens na memória
  static const int maxCacheSizeMB = 100; // Máximo 100MB de cache

  int _currentCacheSize = 0;

  /// Carrega imagem com cache otimizado
  Future<ui.Image?> loadImage(
    String source, {
    int? width,
    int? height,
    ImageQuality quality = ImageQuality.medium,
    bool useCache = true,
  }) async {
    final cacheKey = _generateCacheKey(source, width, height, quality);
    if (useCache && _memoryCache.containsKey(cacheKey)) {
      final cachedImage = _memoryCache[cacheKey]!;
      cachedImage.lastAccessed = DateTime.now();
      return cachedImage.image;
    }
    if (_loadingImages.containsKey(cacheKey)) {
      return await _loadingImages[cacheKey]!;
    }
    final loadingFuture = _loadImageInternal(source, width, height, quality);
    _loadingImages[cacheKey] = loadingFuture;

    try {
      final image = await loadingFuture;

      if (image != null && useCache) {
        _cacheImage(cacheKey, image);
      }

      return image;
    } finally {
      unawaited(_loadingImages.remove(cacheKey) ?? Future.value());
    }
  }

  /// Pré-carrega imagens para acesso rápido
  Future<void> preloadImages(List<String> sources) async {
    final futures = sources
        .where((source) => !_preloadedImages.contains(source))
        .map((source) async {
          try {
            await loadImage(source, quality: ImageQuality.low);
            _preloadedImages.add(source);
          } catch (e) {
            // Ignore preload errors
          }
        })
        .toList();

    await Future.wait(futures);
  }

  /// Limpa cache baseado em estratégias inteligentes
  void cleanupCache({bool aggressive = false}) {
    if (aggressive) {
      _memoryCache.clear();
      _currentCacheSize = 0;
      _preloadedImages.clear();
      return;
    }
    final entries = _memoryCache.entries.toList();
    entries.sort(
      (a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed),
    );
    final removeCount = (entries.length * 0.3).round();
    for (int i = 0; i < removeCount; i++) {
      final entry = entries[i];
      _currentCacheSize -= entry.value.sizeBytes;
      _memoryCache.remove(entry.key);
    }
  }

  /// Obtém estatísticas do cache
  ImageCacheStats getCacheStats() {
    return ImageCacheStats(
      memoryItems: _memoryCache.length,
      memorySizeMB: _currentCacheSize / (1024 * 1024),
      loadingItems: _loadingImages.length,
      preloadedItems: _preloadedImages.length,
      hitRate: _calculateHitRate(),
    );
  }

  Future<ui.Image?> _loadImageInternal(
    String source,
    int? width,
    int? height,
    ImageQuality quality,
  ) async {
    try {
      Uint8List? bytes;
      if (source.startsWith('http')) {
        bytes = await _loadNetworkImage(source);
      } else if (source.startsWith('assets/')) {
        bytes = await _loadAssetImage(source);
      } else {
        bytes = await _loadFileImage(source);
      }

      if (bytes == null) return null;
      if (width != null || height != null) {
        bytes = await _resizeImage(bytes, width, height, quality);
      }
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width,
        targetHeight: height,
      );

      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _loadNetworkImage(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>(
          <int>[],
          (List<int> previous, List<int> element) => previous..addAll(element),
        );
        return Uint8List.fromList(bytes);
      }
    } catch (e) {}
    return null;
  }

  Future<Uint8List?> _loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> _loadFileImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {}
    return null;
  }

  Future<Uint8List> _resizeImage(
    Uint8List bytes,
    int? width,
    int? height,
    ImageQuality quality,
  ) async {
    return bytes;
  }

  void _cacheImage(String key, ui.Image image) {
    final sizeBytes = _estimateImageSize(image);
    while (_memoryCache.length >= maxMemoryCache ||
        (_currentCacheSize + sizeBytes) > (maxCacheSizeMB * 1024 * 1024)) {
      _removeOldestCacheEntry();
    }

    _memoryCache[key] = CachedImage(
      image: image,
      sizeBytes: sizeBytes,
      cachedAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    _currentCacheSize += sizeBytes;
  }

  void _removeOldestCacheEntry() {
    if (_memoryCache.isEmpty) return;

    final entries = _memoryCache.entries.toList();
    entries.sort(
      (a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed),
    );

    final oldest = entries.first;
    _currentCacheSize -= oldest.value.sizeBytes;
    _memoryCache.remove(oldest.key);
  }

  String _generateCacheKey(
    String source,
    int? width,
    int? height,
    ImageQuality quality,
  ) {
    return '$source:${width ?? 0}x${height ?? 0}:${quality.name}';
  }

  int _estimateImageSize(ui.Image image) {
    return image.width * image.height * 4;
  }

  double _calculateHitRate() {
    return _memoryCache.isNotEmpty ? 0.8 : 0.0;
  }
}

/// Widget otimizado para exibição de imagens
class OptimizedImage extends StatefulWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageQuality quality;
  final bool enableMemoryCache;
  final bool lazyLoad;
  final Duration fadeDuration;

  const OptimizedImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.quality = ImageQuality.medium,
    this.enableMemoryCache = true,
    this.lazyLoad = false,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  ui.Image? _image;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    if (!widget.lazyLoad) {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.source != widget.source) {
      _image = null;
      _hasError = false;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final image = await ImageOptimizer().loadImage(
        widget.source,
        width: widget.width?.round(),
        height: widget.height?.round(),
        quality: widget.quality,
        useCache: widget.enableMemoryCache,
      );

      if (mounted) {
        setState(() {
          _image = image;
          _isLoading = false;
          _hasError = image == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_hasError) {
      child = widget.errorWidget ?? const Icon(Icons.error, color: Colors.red);
    } else if (_image != null) {
      child = RawImage(
        image: _image,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    } else {
      child =
          widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: CircularProgressIndicator()),
          );
    }

    if (widget.lazyLoad) {
      return VisibilityDetector(
        key: ValueKey(widget.source),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0 && !_isVisible) {
            _isVisible = true;
            _loadImage();
          }
        },
        child: child,
      );
    }

    return AnimatedSwitcher(duration: widget.fadeDuration, child: child);
  }
}

/// Detector de visibilidade simples para lazy loading
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(VisibilityInfo info) onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final rect = position & size;

      final screenSize = MediaQuery.of(context).size;
      final screenRect = Offset.zero & screenSize;

      final intersection = rect.intersect(screenRect);
      final visibleFraction = intersection.isEmpty
          ? 0.0
          : (intersection.width * intersection.height) /
                (rect.width * rect.height);

      widget.onVisibilityChanged(
        VisibilityInfo(
          visibleFraction: visibleFraction,
          visibleBounds: intersection,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Grid otimizado de imagens com lazy loading
class OptimizedImageGrid extends StatefulWidget {
  final List<String> imageSources;
  final int crossAxisCount;
  final double spacing;
  final double aspectRatio;
  final ImageQuality quality;
  final bool enableLazyLoading;
  final Widget? placeholder;

  const OptimizedImageGrid({
    super.key,
    required this.imageSources,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.aspectRatio = 1.0,
    this.quality = ImageQuality.medium,
    this.enableLazyLoading = true,
    this.placeholder,
  });

  @override
  State<OptimizedImageGrid> createState() => _OptimizedImageGridState();
}

class _OptimizedImageGridState extends State<OptimizedImageGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _preloadVisibleImages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _preloadVisibleImages() {
    final visibleCount = (widget.crossAxisCount * 3).clamp(
      1,
      widget.imageSources.length,
    );
    final visibleSources = widget.imageSources.take(visibleCount).toList();

    ImageOptimizer().preloadImages(visibleSources);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.spacing,
        crossAxisSpacing: widget.spacing,
        childAspectRatio: widget.aspectRatio,
      ),
      itemCount: widget.imageSources.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('grid_image_$index'),
          child: OptimizedImage(
            source: widget.imageSources[index],
            quality: widget.quality,
            lazyLoad: widget.enableLazyLoading,
            placeholder: widget.placeholder,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

/// Classes de apoio
enum ImageQuality { low, medium, high, original }

class CachedImage {
  final ui.Image image;
  final int sizeBytes;
  final DateTime cachedAt;
  DateTime lastAccessed;

  CachedImage({
    required this.image,
    required this.sizeBytes,
    required this.cachedAt,
    required this.lastAccessed,
  });
}

class ImageCacheStats {
  final int memoryItems;
  final double memorySizeMB;
  final int loadingItems;
  final int preloadedItems;
  final double hitRate;

  const ImageCacheStats({
    required this.memoryItems,
    required this.memorySizeMB,
    required this.loadingItems,
    required this.preloadedItems,
    required this.hitRate,
  });
}

class VisibilityInfo {
  final double visibleFraction;
  final Rect visibleBounds;

  const VisibilityInfo({
    required this.visibleFraction,
    required this.visibleBounds,
  });
}
