import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/defensivo_model.dart';

class DefensivoItemWidget extends StatelessWidget {
  final DefensivoModel defensivo;
  final bool isDark;
  final VoidCallback onTap;
  final bool isGridView;

  const DefensivoItemWidget({
    super.key,
    required this.defensivo,
    required this.isDark,
    required this.onTap,
    this.isGridView = false,
  });

  Color get _getClassColor {
    final classe = defensivo.displayClass.toLowerCase();
    if (classe.contains('herbicida') || classe.contains('herbic')) {
      return Colors.green.shade700;
    } else if (classe.contains('inseticida') || classe.contains('insetic')) {
      return Colors.red.shade600;
    } else if (classe.contains('fungicida') || classe.contains('fungic')) {
      return Colors.blue.shade600;
    } else if (classe.contains('acaricida') || classe.contains('acaric')) {
      return Colors.orange.shade600;
    } else if (classe.contains('bactericida') || classe.contains('bacteri')) {
      return Colors.purple.shade600;
    }
    return const Color(0xFF2E7D32);
  }

  IconData get _getClassIcon {
    final classe = defensivo.displayClass.toLowerCase();
    if (classe.contains('herbicida') || classe.contains('herbic')) {
      return FontAwesomeIcons.leaf;
    } else if (classe.contains('inseticida') || classe.contains('insetic')) {
      return FontAwesomeIcons.bug;
    } else if (classe.contains('fungicida') || classe.contains('fungic')) {
      return FontAwesomeIcons.droplet;
    } else if (classe.contains('acaricida') || classe.contains('acaric')) {
      return FontAwesomeIcons.spider;
    } else if (classe.contains('bactericida') || classe.contains('bacteri')) {
      return FontAwesomeIcons.virus;
    }
    return FontAwesomeIcons.sprayCan;
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
    final color = const Color(0xFF4CAF50); // Verde padrão como no mockup
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícone circular à esquerda (como no mockup)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.leaf,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do produto
                    Text(
                      defensivo.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Ingrediente ativo
                    Text(
                      defensivo.displayIngredient,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tag da categoria
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              // Seta à direita
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 20,
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    child: FaIcon(
                      _getClassIcon,
                      size: 16,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.grey.shade700.withValues(alpha: 0.5)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      defensivo.idReg,
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                        color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      defensivo.displayIngredient,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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