import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget unificado para exibição de imagens no monorepo
/// Suporta múltiplas fontes: Base64, URL de rede, bytes em memória
/// Cross-platform: funciona em Web, Mobile e Desktop
class CoreImageWidget extends StatefulWidget {
  /// Base64 string da imagem (com ou sem prefixo data:image)
  final String? imageBase64;

  /// URL da imagem de rede
  final String? imageUrl;

  /// Lista de URLs (usa a primeira disponível)
  final List<String> imageUrls;

  /// Bytes da imagem em memória
  final Uint8List? imageBytes;

  /// Largura do widget
  final double? width;

  /// Altura do widget
  final double? height;

  /// Como ajustar a imagem
  final BoxFit fit;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Se deve usar borda circular
  final bool useCircularBorder;

  /// Widget de placeholder personalizado
  final Widget? placeholder;

  /// Widget de erro personalizado
  final Widget? errorWidget;

  /// Cor de fundo do placeholder
  final Color? placeholderColor;

  /// Cor da borda
  final Color? borderColor;

  /// Largura da borda
  final double? borderWidth;

  /// Ícone do placeholder
  final IconData placeholderIcon;

  /// Se deve habilitar cache em memória
  final bool enableMemoryCache;

  /// Se deve manter vivo durante scroll
  final bool keepAlive;

  /// Duração da animação de fade
  final Duration fadeInDuration;

  const CoreImageWidget({
    super.key,
    this.imageBase64,
    this.imageUrl,
    this.imageUrls = const [],
    this.imageBytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.useCircularBorder = false,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.borderColor,
    this.borderWidth,
    this.placeholderIcon = Icons.image,
    this.enableMemoryCache = true,
    this.keepAlive = false,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  /// Factory para imagens de plantas
  factory CoreImageWidget.plant({
    Key? key,
    String? imageBase64,
    List<String> imageUrls = const [],
    double size = 80.0,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CoreImageWidget(
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
      placeholderIcon: Icons.eco,
      enableMemoryCache: true,
      keepAlive: true,
    );
  }

  /// Factory para imagens de veículos
  factory CoreImageWidget.vehicle({
    Key? key,
    String? imageBase64,
    String? imageUrl,
    List<String> imageUrls = const [],
    double width = 120,
    double height = 80,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CoreImageWidget(
      key: key,
      imageBase64: imageBase64,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      placeholder: placeholder,
      errorWidget: errorWidget,
      placeholderIcon: Icons.directions_car,
      enableMemoryCache: true,
    );
  }

  /// Factory para imagens de perfil
  factory CoreImageWidget.profile({
    Key? key,
    String? imageBase64,
    String? imageUrl,
    double size = 48.0,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CoreImageWidget(
      key: key,
      imageBase64: imageBase64,
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: BorderRadius.circular(size / 2),
      useCircularBorder: true,
      placeholder: placeholder,
      errorWidget: errorWidget,
      placeholderIcon: Icons.person,
      enableMemoryCache: true,
      keepAlive: true,
    );
  }

  /// Factory para recibos/comprovantes
  factory CoreImageWidget.receipt({
    Key? key,
    String? imageBase64,
    String? imageUrl,
    double? width,
    double? height = 200,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CoreImageWidget(
      key: key,
      imageBase64: imageBase64,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      placeholder: placeholder,
      errorWidget: errorWidget,
      placeholderIcon: Icons.receipt_long,
    );
  }

  /// Factory para imagens de rede com cache
  factory CoreImageWidget.network({
    Key? key,
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CoreImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  @override
  State<CoreImageWidget> createState() => _CoreImageWidgetState();
}

class _CoreImageWidgetState extends State<CoreImageWidget>
    with AutomaticKeepAliveClientMixin {
  // Cache LRU estático compartilhado entre todas as instâncias
  static final _CoreImageCache _cache = _CoreImageCache(maxSize: 50);

  Uint8List? _cachedBytes;
  bool _isDecoding = false;
  String? _currentCacheKey;
  Object? _loadError;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CoreImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBase64 != widget.imageBase64 ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imageUrls != widget.imageUrls ||
        oldWidget.imageBytes != widget.imageBytes) {
      _loadImage();
    }
  }

  void _loadImage() {
    _loadError = null;

    // Prioridade: bytes > base64 > url > urls
    if (widget.imageBytes != null) {
      setState(() {
        _cachedBytes = widget.imageBytes;
        _isDecoding = false;
      });
      return;
    }

    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      _loadBase64Image(widget.imageBase64!);
      return;
    }

    // URLs serão carregadas pelo CachedNetworkImage
    setState(() {
      _cachedBytes = null;
      _isDecoding = false;
    });
  }

  void _loadBase64Image(String base64String) {
    final cacheKey = base64String.hashCode.toString();

    // Tentar cache primeiro
    if (widget.enableMemoryCache) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        setState(() {
          _cachedBytes = cached;
          _currentCacheKey = cacheKey;
          _isDecoding = false;
        });
        return;
      }
    }

    // Decodificar assincronamente
    setState(() {
      _isDecoding = true;
      _currentCacheKey = cacheKey;
    });

    _decodeBase64Async(base64String, cacheKey);
  }

  Future<void> _decodeBase64Async(String base64String, String cacheKey) async {
    try {
      // Extrair dados base64 (remover prefixo data:image se existir)
      String cleanBase64 = base64String;
      if (base64String.startsWith('data:')) {
        cleanBase64 = base64String.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);

      if (!mounted || _currentCacheKey != cacheKey) return;

      if (widget.enableMemoryCache) {
        _cache.put(cacheKey, bytes);
      }

      setState(() {
        _cachedBytes = bytes;
        _isDecoding = false;
      });
    } catch (e) {
      if (mounted && _currentCacheKey == cacheKey) {
        setState(() {
          _loadError = e;
          _cachedBytes = null;
          _isDecoding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    Widget child = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildImageContent(),
    );

    // Aplicar borda se configurada
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

    // Aplicar clip
    child = ClipRRect(
      borderRadius: _getBorderRadius(),
      child: child,
    );

    return RepaintBoundary(child: child);
  }

  BorderRadius _getBorderRadius() {
    if (widget.useCircularBorder && widget.width != null) {
      return BorderRadius.circular(widget.width! / 2);
    }
    return widget.borderRadius ?? BorderRadius.circular(8);
  }

  Widget _buildImageContent() {
    // Mostrar erro se houver
    if (_loadError != null) {
      return _buildErrorWidget();
    }

    // Mostrar loading
    if (_isDecoding) {
      return _buildPlaceholder();
    }

    // Bytes em memória (incluindo base64 decodificado)
    if (_cachedBytes != null) {
      return _buildMemoryImage();
    }

    // URL única
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrl!);
    }

    // Lista de URLs
    if (widget.imageUrls.isNotEmpty) {
      return _buildNetworkImage(widget.imageUrls.first);
    }

    // Sem imagem
    return _buildPlaceholder();
  }

  Widget _buildMemoryImage() {
    return Image.memory(
      _cachedBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width?.round(),
      cacheHeight: widget.height?.round(),
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildNetworkImage(String url) {
    // Se for Base64 inline, decodificar
    if (url.startsWith('data:image/')) {
      _loadBase64Image(url);
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      memCacheWidth: widget.width?.round(),
      memCacheHeight: widget.height?.round(),
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      useOldImageOnUrlChange: true,
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    final theme = Theme.of(context);
    final iconSize = _calculateIconSize();

    return Shimmer.fromColors(
      baseColor: widget.placeholderColor ??
          theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.placeholderColor ??
              theme.colorScheme.surfaceContainerHighest,
          borderRadius: _getBorderRadius(),
        ),
        child: Icon(
          widget.placeholderIcon,
          size: iconSize,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final theme = Theme.of(context);
    final iconSize = _calculateIconSize();

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: _getBorderRadius(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: iconSize,
            color: theme.colorScheme.error,
          ),
          if ((widget.height ?? 0) > 60) ...[
            const SizedBox(height: 4),
            Text(
              'Erro',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateIconSize() {
    final minDimension = [widget.width ?? 100, widget.height ?? 100]
        .reduce((a, b) => a < b ? a : b);
    return (minDimension / 3).clamp(16.0, 48.0);
  }
}

/// Cache LRU simples para bytes de imagem
class _CoreImageCache {
  final int maxSize;
  final Map<String, _CacheEntry> _cache = {};
  final List<String> _accessOrder = [];

  _CoreImageCache({required this.maxSize});

  Uint8List? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Atualizar ordem de acesso
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return entry.bytes;
  }

  void put(String key, Uint8List bytes) {
    // Se já existe, atualizar
    if (_cache.containsKey(key)) {
      _cache[key] = _CacheEntry(bytes);
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return;
    }

    // Remover itens antigos se necessário
    while (_cache.length >= maxSize && _accessOrder.isNotEmpty) {
      final oldest = _accessOrder.removeAt(0);
      _cache.remove(oldest);
    }

    _cache[key] = _CacheEntry(bytes);
    _accessOrder.add(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  int get length => _cache.length;
}

class _CacheEntry {
  final Uint8List bytes;
  final DateTime createdAt;

  _CacheEntry(this.bytes) : createdAt = DateTime.now();
}
