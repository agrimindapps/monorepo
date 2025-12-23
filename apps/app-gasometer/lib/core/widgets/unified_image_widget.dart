import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Widget unificado para exibição de imagens no Gasometer
///
/// Suporta múltiplas fontes de imagem:
/// - Base64 DataURI (novo padrão)
/// - Caminho de arquivo local
/// - URL de rede (via CachedNetworkImage)
///
/// Otimizado para performance com:
/// - Cache LRU em memória
/// - Decodificação assíncrona
/// - Gestão de memória com MemoryPressure
class UnifiedImageWidget extends StatefulWidget {
  const UnifiedImageWidget({
    super.key,
    this.imageBase64,
    this.imagePath,
    this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.borderColor,
    this.borderWidth,
    this.enableMemoryCache = true,
    this.placeholderIcon = Icons.image,
  });

  /// Imagem em Base64 (com ou sem prefixo DataURI)
  final String? imageBase64;

  /// Caminho do arquivo local
  final String? imagePath;

  /// URL da imagem na rede
  final String? imageUrl;

  /// Largura do widget
  final double width;

  /// Altura do widget
  final double height;

  /// Como a imagem deve preencher o espaço
  final BoxFit fit;

  /// Borda arredondada
  final BorderRadius? borderRadius;

  /// Widget placeholder customizado
  final Widget? placeholder;

  /// Widget de erro customizado
  final Widget? errorWidget;

  /// Cor do placeholder padrão
  final Color? placeholderColor;

  /// Cor da borda
  final Color? borderColor;

  /// Largura da borda
  final double? borderWidth;

  /// Se deve usar cache em memória
  final bool enableMemoryCache;

  /// Ícone do placeholder
  final IconData placeholderIcon;

  /// Factory para imagens de veículos
  factory UnifiedImageWidget.vehicle({
    Key? key,
    String? imageBase64,
    String? imagePath,
    double size = 80,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return UnifiedImageWidget(
      key: key,
      imageBase64: imageBase64,
      imagePath: imagePath,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      placeholderIcon: Icons.directions_car,
    );
  }

  /// Factory para comprovantes/recibos
  factory UnifiedImageWidget.receipt({
    Key? key,
    String? imageBase64,
    String? imagePath,
    double width = double.infinity,
    double height = 200,
    BoxFit fit = BoxFit.cover,
  }) {
    return UnifiedImageWidget(
      key: key,
      imageBase64: imageBase64,
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
      placeholderIcon: Icons.receipt,
    );
  }

  @override
  State<UnifiedImageWidget> createState() => _UnifiedImageWidgetState();
}

class _UnifiedImageWidgetState extends State<UnifiedImageWidget>
    with WidgetsBindingObserver {
  static final _LRUImageCache _base64Cache = _LRUImageCache(maxSize: 30);

  Uint8List? _cachedImageBytes;
  bool _isDecoding = false;
  String? _currentImageKey;

  @override
  void initState() {
    super.initState();
    if (widget.enableMemoryCache) {
      WidgetsBinding.instance.addObserver(this);
    }
    _loadImage();
  }

  @override
  void didUpdateWidget(UnifiedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageBase64 != widget.imageBase64 ||
        oldWidget.imagePath != widget.imagePath ||
        oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    if (widget.enableMemoryCache) {
      final targetSize = _base64Cache.maxSize ~/ 2;
      while (_base64Cache.length > targetSize) {
        _base64Cache.removeLRU();
      }
    }
  }

  void _loadImage() {
    if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) {
      _loadBase64Image();
    } else {
      setState(() {
        _cachedImageBytes = null;
        _currentImageKey = null;
      });
    }
  }

  void _loadBase64Image() {
    if (!widget.enableMemoryCache) {
      _decodeImageAsync(widget.imageBase64!);
      return;
    }

    final imageKey = widget.imageBase64!;
    final cachedImage = _base64Cache.get(imageKey);
    if (cachedImage != null) {
      setState(() {
        _cachedImageBytes = cachedImage;
        _currentImageKey = imageKey;
        _isDecoding = false;
      });
      return;
    }

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
      final imageBytes = _decodeBase64(base64String);

      if (!mounted || _currentImageKey != base64String) {
        return;
      }

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

  /// Decodifica Base64 removendo prefixo DataURI se presente
  static Uint8List _decodeBase64(String base64String) {
    String cleanBase64 = base64String;
    if (base64String.contains(',')) {
      cleanBase64 = base64String.split(',').last;
    }
    return base64Decode(cleanBase64);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildImageContent(),
    );

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

    child = ClipRRect(borderRadius: _getBorderRadius(), child: child);
    return RepaintBoundary(child: child);
  }

  BorderRadius _getBorderRadius() {
    return widget.borderRadius ?? BorderRadius.circular(8.0);
  }

  Widget _buildImageContent() {
    // Prioridade: Base64 > Arquivo local > URL
    if (_isDecoding) {
      return _buildPlaceholder();
    }

    if (_cachedImageBytes != null) {
      return _buildBase64Image();
    }

    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return _buildFileImage();
    }

    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return _buildNetworkImage();
    }

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

  Widget _buildFileImage() {
    return Image.file(
      File(widget.imagePath!),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width.round(),
      cacheHeight: widget.height.round(),
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.width.round(),
      cacheHeight: widget.height.round(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.placeholderColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: _getBorderRadius(),
      ),
      child: Icon(
        widget.placeholderIcon,
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

/// Cache LRU para imagens decodificadas
class _LRUImageCache {
  final int maxSize;
  final Map<String, _CacheNode> _cache = {};
  _CacheNode? _head;
  _CacheNode? _tail;

  _LRUImageCache({required this.maxSize});

  Uint8List? get(String key) {
    final node = _cache[key];
    if (node == null) return null;
    _moveToFront(node);
    return node.value;
  }

  void put(String key, Uint8List value) {
    final existingNode = _cache[key];

    if (existingNode != null) {
      existingNode.value = value;
      _moveToFront(existingNode);
      return;
    }

    final newNode = _CacheNode(key, value);
    _cache[key] = newNode;
    _addToFront(newNode);

    if (_cache.length > maxSize) {
      _removeLeastRecentlyUsed();
    }
  }

  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
  }

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

  void removeLRU() => _removeLeastRecentlyUsed();
}

class _CacheNode {
  final String key;
  Uint8List value;
  _CacheNode? prev;
  _CacheNode? next;

  _CacheNode(this.key, this.value);
}
