// Flutter imports:
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onShare;
  final String title;
  final Animation<double>? animation;

  const ResultCard({
    super.key,
    required this.child,
    required this.onShare,
    required this.title,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onShare,
                        icon: const Icon(Icons.share, size: 20),
                        tooltip: 'Compartilhar',
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Exportação para PDF será implementada em breve!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 20),
                        tooltip: 'Exportar para PDF',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
            child,
          ],
        ),
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: card,
      );
    }

    return card;
  }
}

class ResultBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ResultBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const InfoChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
        ),
      ),
      avatar: Icon(
        icon,
        size: 14,
        color: Colors.grey.shade700,
      ),
      backgroundColor: Colors.grey.shade100,
      visualDensity: VisualDensity.compact,
    );
  }
}
