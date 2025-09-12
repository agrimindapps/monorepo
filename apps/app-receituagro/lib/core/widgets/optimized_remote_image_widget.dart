import 'package:flutter/material.dart';

/// Simplified version of OptimizedRemoteImageWidget without RemoteAssetService dependency
/// This stub provides the same API but uses only local assets
/// TODO: Implement proper remote asset functionality when RemoteAssetService is available
class OptimizedRemoteImageWidget extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String? semanticLabel;
  final Color? color;
  final BlendMode? colorBlendMode;
  final String? fallbackAsset;
  
  const OptimizedRemoteImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.semanticLabel,
    this.color,
    this.colorBlendMode,
    this.fallbackAsset,
  });

  @override
  State<OptimizedRemoteImageWidget> createState() => _OptimizedRemoteImageWidgetState();
}

class _OptimizedRemoteImageWidgetState extends State<OptimizedRemoteImageWidget> {
  @override
  Widget build(BuildContext context) {
    // Simplified implementation - use local assets only
    return Image.asset(
      widget.imagePath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.cover,
      semanticLabel: widget.semanticLabel,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      errorBuilder: (context, error, stackTrace) {
        // Try fallback asset if provided
        if (widget.fallbackAsset != null) {
          return Image.asset(
            widget.fallbackAsset!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit ?? BoxFit.cover,
            semanticLabel: widget.semanticLabel,
            color: widget.color,
            colorBlendMode: widget.colorBlendMode,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
        }
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
}

/// Simplified stats widget without RemoteAssetService dependency
class RemoteAssetStatsWidget extends StatelessWidget {
  const RemoteAssetStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('RemoteAssetService not available'),
            const Text('Using local assets only'),
          ],
        ),
      ),
    );
  }
}