// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../../../models/favorito_model.dart';
import '../utils/image_path_helper.dart';

class FavoritoPragaListItem extends StatelessWidget {
  final FavoritoPragaModel praga;
  final VoidCallback onTap;
  final Color iconColor;

  const FavoritoPragaListItem({
    super.key,
    required this.praga,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCircleAvatar(isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    praga.nomeComum,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    praga.nomeCientifico,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: isDark ? iconColor.withValues(alpha: 0.7) : iconColor,
                size: 24,
              ),
              onPressed: onTap,
              tooltip: 'Ver detalhes',
              splashRadius: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAvatar(bool isDark) {
    final imagePath = ImagePathHelper.getPragaImagePath(praga.nomeCientifico);

    return CircleAvatar(
      radius: 24,
      backgroundColor: isDark ? Colors.black26 : iconColor.withValues(alpha: 0.1),
      child: ClipOval(
        child: SizedBox(
          width: 40,
          height: 40,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.bug_report,
                color: iconColor,
                size: 28,
              );
            },
          ),
        ),
      ),
    );
  }
}
