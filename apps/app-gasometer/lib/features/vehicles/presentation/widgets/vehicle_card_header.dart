import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Vehicle card header widget following SOLID principles
/// 
/// Follows SRP: Single responsibility of displaying vehicle header info
/// Follows OCP: Open for extension via custom styling
class VehicleCardHeader extends StatelessWidget {
  const VehicleCardHeader({
    super.key,
    required this.vehicle,
    this.showIcon = true,
  });

  final VehicleEntity vehicle;
  final bool showIcon;

  /// Verifica se o veículo tem uma imagem válida
  bool get _hasImage {
    final imagePath = vehicle.metadata['foto'] as String?;
    return imagePath != null && imagePath.isNotEmpty;
  }

  /// Obtém o caminho/URL da imagem do veículo
  String? get _imageSource {
    return vehicle.metadata['foto'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingLg,
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            _buildVehicleAvatar(context),
            const SizedBox(width: GasometerDesignTokens.spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SemanticText.heading(
                  '${vehicle.brand} ${vehicle.model}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeLg,
                    fontWeight: GasometerDesignTokens.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SemanticText.subtitle(
                  '${vehicle.year} • ${vehicle.color}',
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: GasometerDesignTokens.opacitySecondary,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleAvatar(BuildContext context) {
    const size = GasometerDesignTokens.iconSizeAvatar;
    
    if (_hasImage) {
      final imageSource = _imageSource!;
      
      // Se for uma URL de rede ou Base64, usar CoreImageWidget
      if (imageSource.startsWith('http') || imageSource.startsWith('data:')) {
        return CoreImageWidget.vehicle(
          imageUrl: imageSource.startsWith('http') ? imageSource : null,
          imageBase64: imageSource.startsWith('data:') ? imageSource : null,
          width: size,
          height: size,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(size / 2),
          errorWidget: _buildPlaceholderAvatar(context, size),
        );
      }
      
      // Se for um caminho local, também pode ser Base64 armazenado
      // Tentar como Base64 primeiro
      return CoreImageWidget.vehicle(
        imageBase64: imageSource,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(size / 2),
        errorWidget: _buildPlaceholderAvatar(context, size),
      );
    }
    
    return _buildPlaceholderAvatar(context, size);
  }

  Widget _buildPlaceholderAvatar(BuildContext context, double size) {
    return Semantics(
      label: 'Ícone do veículo',
      hint: 'Representação visual do veículo ${vehicle.brand} ${vehicle.model}',
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(
          alpha: GasometerDesignTokens.opacityOverlay,
        ),
        child: Icon(
          Icons.directions_car,
          color: Theme.of(context).colorScheme.primary,
          size: GasometerDesignTokens.iconSizeListItem,
        ),
      ),
    );
  }
}
