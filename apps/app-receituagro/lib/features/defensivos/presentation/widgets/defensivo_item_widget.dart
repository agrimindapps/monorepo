import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/models/fitossanitario_hive.dart';
import '../../../../core/extensions/fitossanitario_hive_extension.dart';

class DefensivoItemWidget extends StatelessWidget {
  final FitossanitarioHive defensivo;
  final bool isDark;
  final VoidCallback onTap;
  final bool isGridView;
  static final Map<String, Color> _colorCache = {};
  static final Map<String, IconData> _iconCache = {};

  const DefensivoItemWidget({
    super.key,
    required this.defensivo,
    required this.isDark,
    required this.onTap,
    this.isGridView = false,
  });

  Color get _getClassColor {
    final classe = defensivo.displayClass.toLowerCase();
    if (_colorCache.containsKey(classe)) {
      return _colorCache[classe]!;
    }
    Color color;
    if (classe.contains('herbicida') || classe.contains('herbic')) {
      color = Colors.green.shade700;
    } else if (classe.contains('inseticida') || classe.contains('insetic')) {
      color = Colors.red.shade600;
    } else if (classe.contains('fungicida') || classe.contains('fungic')) {
      color = Colors.blue.shade600;
    } else if (classe.contains('acaricida') || classe.contains('acaric')) {
      color = Colors.orange.shade600;
    } else if (classe.contains('bactericida') || classe.contains('bacteri')) {
      color = Colors.purple.shade600;
    } else {
      color = const Color(0xFF2E7D32);
    }

    _colorCache[classe] = color;
    return color;
  }

  IconData get _getClassIcon {
    final classe = defensivo.displayClass.toLowerCase();
    if (_iconCache.containsKey(classe)) {
      return _iconCache[classe]!;
    }
    IconData icon;
    if (classe.contains('herbicida') || classe.contains('herbic')) {
      icon = FontAwesomeIcons.leaf;
    } else if (classe.contains('inseticida') || classe.contains('insetic')) {
      icon = FontAwesomeIcons.bug;
    } else if (classe.contains('fungicida') || classe.contains('fungic')) {
      icon = FontAwesomeIcons.droplet;
    } else if (classe.contains('acaricida') || classe.contains('acaric')) {
      icon = FontAwesomeIcons.spider;
    } else if (classe.contains('bactericida') || classe.contains('bacteri')) {
      icon = FontAwesomeIcons.virus;
    } else {
      icon = FontAwesomeIcons.sprayCan;
    }

    _iconCache[classe] = icon;
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridItem();
    } else {
      return _buildListItem();
    }
  }

  Widget _buildListItem() {
    const color = Color(0xFF4CAF50); // Verde padrão como no mockup

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.leaf,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defensivo.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      defensivo.displayIngredient,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            defensivo.displayClass,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem() {
    final color = _getClassColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(_getClassIcon, size: 16, color: color),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.grey.shade700.withValues(alpha: 0.5)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      defensivo.idReg,
                      style: TextStyle(
                        fontSize: 9,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      defensivo.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      defensivo.displayIngredient,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        defensivo.displayClass,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
