import 'package:core/core.dart'; // OptimizedImageService moved to core
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget otimizado para exibir imagens de pragas com lazy loading
/// Substitui o PragaImageWidget com performance melhorada para 1181+ imagens
/// 
/// Funcionalidades:
/// - Lazy loading sob demanda
/// - Cache inteligente em memória
/// - Compressão automática
/// - Placeholder otimizado
/// - Fallback automático
/// - Gerenciamento de memória
class OptimizedPragaImageWidget extends StatefulWidget {
  final String? nomeCientifico;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enablePreloading;

  const OptimizedPragaImageWidget({
    super.key,
    required this.nomeCientifico,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enablePreloading = false,
  });

  @override
  State<OptimizedPragaImageWidget> createState() => _OptimizedPragaImageWidgetState();
}

class _OptimizedPragaImageWidgetState extends State<OptimizedPragaImageWidget> {
  final OptimizedImageService _imageService = OptimizedImageService();
  late String _imagePath;
  Uint8List? _imageData;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _imagePath = _buildImagePath(widget.nomeCientifico);
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedPragaImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nomeCientifico != widget.nomeCientifico) {
      final newPath = _buildImagePath(widget.nomeCientifico);
      if (_imagePath != newPath) {
        setState(() {
          _imagePath = newPath;
          _imageData = null;
          _hasError = false;
          _errorMessage = null;
        });
        _loadImage();
      }
    }
  }

  /// Constrói o path da imagem baseado no nome científico
  String _buildImagePath(String? nomeCientifico) {
    if (nomeCientifico == null || nomeCientifico.isEmpty) {
      return 'assets/imagens/bigsize/a.jpg';
    }
    
    // Remove caracteres especiais e formata o nome científico
    final cleanName = nomeCientifico.trim();
    return 'assets/imagens/bigsize/$cleanName.jpg';
  }

  /// Carrega a imagem usando o serviço otimizado
  Future<void> _loadImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final imageData = await _imageService.loadImage(_imagePath);
      
      if (mounted) {
        setState(() {
          _imageData = imageData;
          _isLoading = false;
          _hasError = imageData == null;
          if (imageData == null) {
            _errorMessage = 'Imagem não encontrada';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Erro ao carregar imagem: $e';
        });
      }
    }
  }

  /// Widget de placeholder otimizado
  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Carregando...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de erro otimizado
  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report,
            color: Colors.grey.shade400,
            size: (widget.width != null && widget.width! < 100) ? 16 : 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Praga',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: (widget.width != null && widget.width! < 100) ? 8 : 12,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 2),
            Text(
              'Erro',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    if (_hasError || _imageData == null) {
      return _buildErrorWidget();
    }

    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null ? child : _buildPlaceholder(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_hasError) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Erro na renderização';
            });
          }
        });
        return _buildErrorWidget();
      },
    );
  }

  @override
  void dispose() {
    // O cache é gerenciado globalmente, não precisa limpar aqui
    super.dispose();
  }
}

/// Widget de debug para mostrar estatísticas do cache de imagens
class ImageCacheStatsWidget extends StatelessWidget {
  const ImageCacheStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = OptimizedImageService().getStats();
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cache de Imagens - Estatísticas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...stats.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    OptimizedImageService().clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache limpo!')),
                    );
                  },
                  child: const Text('Limpar Cache'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    OptimizedImageService().forceGarbageCollection();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('GC forçado!')),
                    );
                  },
                  child: const Text('Force GC'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}