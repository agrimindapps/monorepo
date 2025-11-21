import 'package:flutter/material.dart';
import '../../../database/receituagro_database.dart';

enum CulturaItemMode { list, grid }

class CulturaItemWidget extends StatelessWidget {
  final Cultura cultura;
  final bool isDark;
  final VoidCallback onTap;
  final CulturaItemMode mode;

  const CulturaItemWidget({
    super.key,
    required this.cultura,
    required this.isDark,
    required this.onTap,
    this.mode = CulturaItemMode.list,
  });

  @override
  Widget build(BuildContext context) {
    return mode == CulturaItemMode.grid
        ? _buildGridItem(context)
        : _buildListItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.agriculture, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  cultura.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.agriculture, size: 24, color: color),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  cultura.nome,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
