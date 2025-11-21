import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/extensions/praga_drift_extension.dart';
import '../../../core/widgets/optimized_praga_image_widget.dart';
import '../../../database/receituagro_database.dart';
import '../data/praga_view_mode.dart';

class PragaItemWidget extends StatelessWidget {
  final Praga praga;
  final PragaViewMode viewMode;
  final bool isDark;
  final VoidCallback onTap;

  const PragaItemWidget({
    super.key,
    required this.praga,
    required this.viewMode,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return viewMode.isList ? _buildListItem(context) : _buildGridItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildContent()),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? const Color(0xFF222228) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              _buildFullImage(),
              _buildGradientOverlay(),
              _buildOverlayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getTypeColor();
    final size = viewMode.isList ? 48.0 : 56.0;

    return OptimizedPragaImageWidget(
      nomeCientifico: praga.displaySecondaryName,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Center(
          child: FaIcon(
            _getTypeIcon(),
            color: color,
            size: viewMode.isList ? 20 : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: viewMode.isList
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          praga.displayName,
          style: TextStyle(
            fontSize: viewMode.isList ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: viewMode.isList ? TextAlign.start : TextAlign.center,
          maxLines: viewMode.isList ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.displaySecondaryName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            praga.displaySecondaryName,
            style: TextStyle(
              fontSize: viewMode.isList ? 14 : 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: viewMode.isList ? TextAlign.start : TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      size: 24,
    );
  }

  Color _getTypeColor() {
    switch (praga.displayType.toLowerCase()) {
      case 'inseto':
        return const Color(0xFFE53935); // Vermelho
      case 'doença':
        return const Color(0xFFFF9800); // Laranja
      case 'planta daninha':
        return const Color(0xFF4CAF50); // Verde
      case 'nematoide':
        return const Color(0xFF9C27B0); // Roxo
      default:
        return const Color(0xFF757575); // Cinza
    }
  }

  IconData _getTypeIcon() {
    switch (praga.displayType.toLowerCase()) {
      case 'inseto':
        return FontAwesomeIcons.bug;
      case 'doença':
        return FontAwesomeIcons.virus;
      case 'planta daninha':
        return FontAwesomeIcons.seedling;
      case 'nematoide':
        return FontAwesomeIcons.worm;
      default:
        return FontAwesomeIcons.triangleExclamation;
    }
  }

  Widget _buildFullImage() {
    final color = _getTypeColor();

    return Positioned.fill(
      child: OptimizedPragaImageWidget(
        nomeCientifico: praga.displaySecondaryName,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero, // Sem bordas pois já está no ClipRRect
        errorWidget: Container(
          width: double.infinity,
          height: double.infinity,
          color: color.withValues(alpha: 0.1),
          child: Center(child: FaIcon(_getTypeIcon(), color: color, size: 48)),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80, // Altura do overlay
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            praga.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (praga.displaySecondaryName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              praga.displaySecondaryName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                shadows: const [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
