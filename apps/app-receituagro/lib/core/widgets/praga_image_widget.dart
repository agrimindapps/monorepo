import 'package:flutter/material.dart';

/// Widget reutilizável para exibir imagens de pragas
/// Usa o nome científico para localizar a imagem e fallback para a.jpg em caso de erro
class PragaImageWidget extends StatefulWidget {
  final String? nomeCientifico;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const PragaImageWidget({
    super.key,
    required this.nomeCientifico,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<PragaImageWidget> createState() => _PragaImageWidgetState();
}

class _PragaImageWidgetState extends State<PragaImageWidget> {
  late String _imagePath;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _imagePath = _buildImagePath(widget.nomeCientifico);
  }

  @override
  void didUpdateWidget(PragaImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nomeCientifico != widget.nomeCientifico) {
      setState(() {
        _imagePath = _buildImagePath(widget.nomeCientifico);
        _hasError = false;
      });
    }
  }

  /// Constrói o path da imagem baseado no nome científico
  String _buildImagePath(String? nomeCientifico) {
    if (nomeCientifico == null || nomeCientifico.isEmpty) {
      return 'assets/imagens/bigsize/a.jpg';
    }
    final cleanName = nomeCientifico.trim();
    return 'assets/imagens/bigsize/$cleanName.jpg';
  }

  /// Widget de placeholder padrão
  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Widget de erro padrão
  Widget _buildDefaultErrorWidget() {
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
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Praga',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: _hasError
          ? _buildFallbackImage()
          : Image.asset(
              _imagePath,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: frame != null
                      ? child
                      : widget.placeholder ?? _buildDefaultPlaceholder(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_hasError) {
                    setState(() {
                      _hasError = true;
                    });
                  }
                });
                return widget.errorWidget ?? _buildDefaultErrorWidget();
              },
            ),
    );
  }

  /// Constrói a imagem de fallback (a.jpg)
  Widget _buildFallbackImage() {
    return Image.asset(
      'assets/imagens/bigsize/a.jpg',
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null
              ? child
              : widget.placeholder ?? _buildDefaultPlaceholder(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }
}