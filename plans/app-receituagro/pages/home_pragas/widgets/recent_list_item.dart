// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/praga_item.dart';
import '../utils/device_performance_helper.dart';
import '../utils/image_utils.dart';
import '../utils/praga_type_helper.dart';

class RecentListItem extends StatelessWidget {
  static const Widget _iconSpacing = SizedBox(width: 4);

  final PragaItem item;
  final Function(String) onTap;
  final bool isLazyLoaded;

  const RecentListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.isLazyLoaded = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = PragaTypeHelper.getTipoAvatarColor(item.tipo);
    final pragaIcon = PragaTypeHelper.getTipoIcon(item.tipo);

    return Hero(
      tag: 'home_pragas_recent_${item.idReg}',
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: 70,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.fromSTEB(15, 0, 10, 0),
            leading: _buildAvatar(avatarColor, pragaIcon),
            title: Text(
              item.nomeComum ?? 'Nome desconhecido',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.nomeCientifico != null)
                  Text(
                    item.nomeCientifico!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PragaTypeHelper.getTipoIcon(item.tipo),
                      size: 10,
                      color: Colors.grey.shade500,
                    ),
                    _iconSpacing,
                    Text(
                      PragaTypeHelper.getTipoText(item.tipo),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 14),
              onPressed: () => onTap(item.idReg),
              color: Colors.green.shade700,
              tooltip: 'Ver detalhes',
              splashRadius: 20,
            ),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
            isThreeLine: true,
            onTap: () => onTap(item.idReg),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Color avatarColor, IconData pragaIcon) {
    if (!ImageUtils.isValidImagePath(item.imagem)) {
      return CircleAvatar(
        backgroundColor: avatarColor,
        child: Icon(pragaIcon, color: Colors.green.shade700, size: 20),
      );
    }

    final imagePath = ImageUtils.buildImagePath(item.imagem);
    return Builder(
      builder: (context) {
        final imageDimensions =
            DevicePerformanceHelper.getOptimizedImageDimensions(context);
        return CircleAvatar(
          backgroundColor: avatarColor,
          child: ClipOval(
            child: isLazyLoaded
                ? _buildLazyLoadedImage(imagePath, imageDimensions, pragaIcon, avatarColor)
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(pragaIcon,
                          color: Colors.green.shade700, size: 20);
                    },
                    cacheWidth: imageDimensions.avatarSize,
                    cacheHeight: imageDimensions.avatarSize,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLazyLoadedImage(
      String imagePath, dynamic imageDimensions, IconData pragaIcon, Color avatarColor) {
    return FutureBuilder<Widget>(
      future: _loadImageAsync(imagePath, imageDimensions, pragaIcon),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        }
        if (snapshot.hasError) {
          return Icon(pragaIcon, color: Colors.green.shade700, size: 20);
        }
        return _buildShimmerPlaceholder(avatarColor, pragaIcon);
      },
    );
  }

  Future<Widget> _loadImageAsync(
      String imagePath, dynamic imageDimensions, IconData pragaIcon) async {
    try {

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          return Icon(pragaIcon, color: Colors.green.shade700, size: 20);
        },
        cacheWidth: imageDimensions.avatarSize,
        cacheHeight: imageDimensions.avatarSize,
      );
    } catch (e) {
      return Icon(pragaIcon, color: Colors.green.shade700, size: 20);
    }
  }


  Widget _buildShimmerPlaceholder(Color avatarColor, IconData pragaIcon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            avatarColor.withValues(alpha: 0.3),
            avatarColor.withValues(alpha: 0.1),
            avatarColor.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          pragaIcon,
          color: Colors.green.shade700.withValues(alpha: 0.6),
          size: 16,
        ),
      ),
    );
  }
}
