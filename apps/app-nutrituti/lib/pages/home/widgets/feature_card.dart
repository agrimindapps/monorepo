import 'package:flutter/material.dart';
import '../../../database/feature_item.dart';

class FeatureCard extends StatelessWidget {
  final FeatureItem feature;
  final VoidCallback onTap;
  final Color color;
  final bool isCompact;

  const FeatureCard({
    super.key,
    required this.feature,
    required this.onTap,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Color.alphaBlend(
                            color.withValues(alpha: 0.2), const Color(0xFF1E1E1E)),
                        const Color(0xFF1E1E1E),
                      ]
                    : [
                        Colors.white,
                        Color.alphaBlend(
                            color.withValues(alpha: 0.05), Colors.white),
                      ],
              ),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: isCompact
                  ? Row(
                      children: [
                        _buildIcon(),
                        const SizedBox(width: 16),
                        Expanded(child: _buildContent(context)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIcon(),
                        const Spacer(),
                        _buildContent(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        feature.icon,
        size: 32,
        color: color,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          feature.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (feature.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
