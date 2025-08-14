import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/cultura_model.dart';

class CulturaItemWidget extends StatelessWidget {
  final CulturaModel cultura;
  final bool isDark;
  final VoidCallback onTap;

  const CulturaItemWidget({
    super.key,
    required this.cultura,
    required this.isDark,
    required this.onTap,
  });

  Color get _getGroupColor {
    final group = cultura.grupo.toLowerCase();
    if (group.contains('cereais') || group.contains('grãos')) {
      return Colors.amber.shade700;
    } else if (group.contains('frutas') || group.contains('frutíferas')) {
      return Colors.orange.shade700;
    } else if (group.contains('hortaliças') || group.contains('verduras')) {
      return Colors.green.shade700;
    } else if (group.contains('leguminosas') || group.contains('feijão')) {
      return Colors.brown.shade600;
    } else if (group.contains('oleaginosas') || group.contains('soja')) {
      return Colors.yellow.shade700;
    }
    return const Color(0xFF2E7D32);
  }

  IconData get _getGroupIcon {
    final group = cultura.grupo.toLowerCase();
    if (group.contains('cereais') || group.contains('grãos')) {
      return FontAwesomeIcons.wheatAwn;
    } else if (group.contains('frutas') || group.contains('frutíferas')) {
      return FontAwesomeIcons.apple;
    } else if (group.contains('hortaliças') || group.contains('verduras')) {
      return FontAwesomeIcons.carrot;
    } else if (group.contains('leguminosas') || group.contains('feijão')) {
      return FontAwesomeIcons.seedling;
    } else if (group.contains('oleaginosas') || group.contains('soja')) {
      return FontAwesomeIcons.leaf;
    }
    return FontAwesomeIcons.seedling;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getGroupColor;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  _getGroupIcon,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cultura.cultura,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cultura.grupo,
                            style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ID: ${cultura.idReg}',
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
}