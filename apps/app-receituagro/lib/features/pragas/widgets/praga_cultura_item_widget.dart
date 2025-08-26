import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/widgets/praga_image_widget.dart';
import '../models/praga_cultura_item_model.dart';
import '../models/praga_view_mode.dart';

class PragaCulturaItemWidget extends StatelessWidget {
  final PragaCulturaItemModel praga;
  final PragaViewMode viewMode;
  final bool isDark;
  final VoidCallback onTap;

  const PragaCulturaItemWidget({
    super.key,
    required this.praga,
    required this.viewMode,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return viewMode.isList 
        ? _buildListItem(context)
        : _buildGridItem(context);
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(ReceitaAgroSpacing.lg),
          child: Row(
            children: [
              _buildIcon(ReceitaAgroDimensions.itemImageSize),
              SizedBox(width: ReceitaAgroSpacing.lg),
              Expanded(
                child: _buildListContent(),
              ),
              SizedBox(width: ReceitaAgroSpacing.md),
              _buildTrailingIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: ReceitaAgroElevation.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        side: BorderSide.none,
      ),
      color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.card),
          child: Stack(
            children: [
              // Imagem da praga ocupando todo o card
              _buildFullImage(),
              // Gradiente overlay para legibilidade do texto
              _buildGradientOverlay(),
              // Conteúdo textual sobreposto
              _buildOverlayContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(double size) {
    final color = _getTypeColor();
    final icon = _getTypeIcon();

    return PragaImageWidget(
      nomeCientifico: praga.nomeCientifico,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ReceitaAgroBorderRadius.md),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: color,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          praga.displayName,
          style: ReceitaAgroTypography.itemTitle.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (praga.displaySecondaryName.isNotEmpty) ...[
          SizedBox(height: ReceitaAgroSpacing.xs),
          Text(
            praga.displaySecondaryName,
            style: ReceitaAgroTypography.itemSubtitle.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (praga.categoria?.isNotEmpty == true) ...[
          SizedBox(height: ReceitaAgroSpacing.sm),
          Text(
            praga.categoria!,
            style: ReceitaAgroTypography.itemCategory.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
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
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return const Color(0xFFE53935); // Vermelho
      case '2': // Doenças
        return const Color(0xFFFF9800); // Laranja
      case '3': // Plantas Daninhas
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF757575); // Cinza
    }
  }

  IconData _getTypeIcon() {
    switch (praga.tipoPraga) {
      case '1': // Insetos
        return FontAwesomeIcons.bug;
      case '2': // Doenças
        return FontAwesomeIcons.virus;
      case '3': // Plantas Daninhas
        return FontAwesomeIcons.seedling;
      default:
        return FontAwesomeIcons.exclamationTriangle;
    }
  }

  Widget _buildFullImage() {
    final color = _getTypeColor();
    
    return Positioned.fill(
      child: PragaImageWidget(
        nomeCientifico: praga.nomeCientifico,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero, // Sem bordas pois já está no ClipRRect
        errorWidget: Container(
          width: double.infinity,
          height: double.infinity,
          color: color.withValues(alpha: 0.1),
          child: Center(
            child: FaIcon(
              _getTypeIcon(),
              color: color,
              size: 48,
            ),
          ),
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
      bottom: ReceitaAgroSpacing.sm,
      left: ReceitaAgroSpacing.sm,
      right: ReceitaAgroSpacing.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            praga.displayName,
            style: ReceitaAgroTypography.itemTitle.copyWith(
              color: Colors.white,
              shadows: const [
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
            SizedBox(height: ReceitaAgroSpacing.xs / 2),
            Text(
              praga.displaySecondaryName,
              style: ReceitaAgroTypography.itemCategory.copyWith(
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