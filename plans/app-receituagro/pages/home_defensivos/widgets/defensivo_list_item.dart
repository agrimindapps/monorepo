// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../constants/layout_constants.dart';
import '../models/defensivo_item.dart';

class DefensivoListItem extends StatefulWidget {
  final DefensivoItem item;
  final Function(String) onTap;
  final String? heroTagPrefix;

  const DefensivoListItem({
    super.key,
    required this.item,
    required this.onTap,
    this.heroTagPrefix,
  });

  @override
  State<DefensivoListItem> createState() => _DefensivoListItemState();
}

class _DefensivoListItemState extends State<DefensivoListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String classeAgronomica =
        widget.item.classeAgronomica ?? 'Não especificado';

    return Hero(
      tag: '${widget.heroTagPrefix ?? 'defensivo'}-${widget.item.idReg}',
      child: Material(
        color: Colors.transparent,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            if (mounted) {
              setState(() => _isHovered = true);
            }
          },
          onExit: (_) {
            if (mounted) {
              setState(() => _isHovered = false);
            }
          },
          child: GestureDetector(
            onTap: () => widget.onTap(widget.item.idReg),
            child: Container(
              height: LayoutConstants.listItemHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: LayoutConstants.listItemContentPadding,
                  leading: AnimatedContainer(
                    duration: AnimationConstants.fastAnimation,
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.1 : 1.0),
                    child: CircleAvatar(
                      backgroundColor: _isHovered
                          ? Colors.green[ColorConstants.greenShade200]
                          : Colors.green[ColorConstants.greenShade100],
                      foregroundColor:
                          Colors.green[ColorConstants.greenShade700],
                      child: Icon(
                        FontAwesome.leaf_solid,
                        color: _isHovered
                            ? Colors.green[ColorConstants.greenShade700]
                            : Colors.grey[ColorConstants.greyShade600],
                        size: LayoutConstants.listItemIconSize,
                      ),
                    ),
                  ),
                  title: Text(
                    widget.item.nomeComum,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: SizeConstants.mediumFontSize,
                      fontWeight:
                          _isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: _isHovered
                          ? Colors.green[ColorConstants.greenShade800]
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.ingredienteAtivo ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SizeConstants.smallFontSize,
                          color: Colors.grey[ColorConstants.greyShade700],
                        ),
                      ),
                      Row(
                        children: [
                          AnimatedScale(
                            duration: AnimationConstants.fastAnimation,
                            scale: _isHovered ? 1.1 : 1.0,
                            child: Icon(
                              FontAwesome.tag_solid,
                              size: LayoutConstants.tagIconSize,
                              color: _isHovered
                                  ? Colors.green[ColorConstants.greyShade600]
                                  : Colors.grey[ColorConstants.greyShade500],
                            ),
                          ),
                          const SizedBox(width: LayoutConstants.smallSpacing),
                          Expanded(
                            child: Text(
                              classeAgronomica,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: SizeConstants.extraSmallFontSize,
                                color: Colors.grey[ColorConstants.greyShade500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: AnimatedContainer(
                    duration: AnimationConstants.fastAnimation,
                    transform: Matrix4.identity()
                      ..rotateZ(_isHovered ? 0.1 : 0.0),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: AnimationConstants.fastAnimation,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          key: ValueKey(_isHovered),
                          size: LayoutConstants.smallIconSize,
                        ),
                      ),
                      onPressed: () => widget.onTap(widget.item.idReg),
                      color: _isHovered
                          ? Colors.green[ColorConstants.greenShade800]
                          : Colors.green[ColorConstants.greenShade700],
                      tooltip: 'Ver detalhes',
                      splashRadius: LayoutConstants.splashRadius,
                    ),
                  ),
                  visualDensity: LayoutConstants.compactVisualDensity,
                  isThreeLine: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
