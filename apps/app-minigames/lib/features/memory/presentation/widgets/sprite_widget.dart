import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that renders a specific part (sprite) of an image asset.
class SpriteWidget extends StatefulWidget {
  final String assetPath;
  final Rect sourceRect;
  final BoxFit fit;

  const SpriteWidget({
    super.key,
    required this.assetPath,
    required this.sourceRect,
    this.fit = BoxFit.contain,
  });

  @override
  State<SpriteWidget> createState() => _SpriteWidgetState();
}

class _SpriteWidgetState extends State<SpriteWidget> {
  ui.Image? _image;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final data = await rootBundle.load(widget.assetPath);
      final list = Uint8List.view(data.buffer);
      final codec = await ui.instantiateImageCodec(list);
      final frame = await codec.getNextFrame();
      
      if (mounted) {
        setState(() {
          _image = frame.image;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 20, 
          height: 20, 
          child: CircularProgressIndicator(strokeWidth: 2)
        )
      );
    }

    if (_error != null || _image == null) {
      return const Center(child: Icon(Icons.broken_image, size: 20));
    }

    return CustomPaint(
      painter: _SpritePainter(
        image: _image!,
        sourceRect: widget.sourceRect,
        fit: widget.fit,
      ),
      child: Container(),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final Rect sourceRect;
  final BoxFit fit;

  _SpritePainter({
    required this.image,
    required this.sourceRect,
    required this.fit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;

    // Calculate destination rect based on BoxFit
    final destRect = _calculateDestRect(size);

    canvas.drawImageRect(
      image,
      sourceRect,
      destRect,
      paint,
    );
  }
  
  Rect _calculateDestRect(Size canvasSize) {
    // Simple implementation of BoxFit.contain
    // For a more complete implementation, applyFittedBox logic is needed
    // But since our cards are squares and sprites usually are too, 
    // we can just stretch or fit.
    
    // Assuming contain logic for now as it's safest
    final srcAspectRatio = sourceRect.width / sourceRect.height;
    final dstAspectRatio = canvasSize.width / canvasSize.height;
    
    double w = canvasSize.width;
    double h = canvasSize.height;
    double x = 0;
    double y = 0;
    
    if (srcAspectRatio > dstAspectRatio) {
      // Source is wider, fit to width
      h = w / srcAspectRatio;
      y = (canvasSize.height - h) / 2;
    } else {
      // Source is taller, fit to height
      w = h * srcAspectRatio;
      x = (canvasSize.width - w) / 2;
    }
    
    return Rect.fromLTWH(x, y, w, h);
  }

  @override
  bool shouldRepaint(covariant _SpritePainter oldDelegate) {
    return image != oldDelegate.image || sourceRect != oldDelegate.sourceRect;
  }
}
