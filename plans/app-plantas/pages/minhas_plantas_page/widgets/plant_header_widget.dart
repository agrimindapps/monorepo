// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../../database/planta_model.dart';
import '../../../services/shared/image_service.dart';
import '../interfaces/plantas_controller_interface.dart';

class PlantHeaderWidget extends StatelessWidget {
  final PlantaModel planta;
  final IPlantasController controller;

  const PlantHeaderWidget({
    super.key,
    required this.planta,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    final textStyles = PlantasDesignTokens.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Plant icon with custom illustration or photo
            _buildPlantIcon(context),
            SizedBox(width: dimensoes['paddingM']!),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planta.nome ?? 'Planta',
                    style: textStyles['labelLarge']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: dimensoes['paddingXS']!),
                  Row(
                    children: [
                      if (planta.especie?.isNotEmpty == true) ...[
                        Flexible(
                          child: Text(
                            planta.especie!,
                            style: textStyles['bodySmall']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_getSpaceName().isNotEmpty) ...[
                          Text(
                            ' • ',
                            style: textStyles['bodySmall']!.copyWith(
                              color: cores['textoTerciario'],
                            ),
                          ),
                        ],
                      ],
                      if (_getSpaceName().isNotEmpty)
                        Flexible(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: dimensoes['iconXS']!,
                                color: cores['textoTerciario'],
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  _getSpaceName(),
                                  style: textStyles['bodySmall']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlantIcon(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;

    return Container(
      width: dimensoes['iconXL']!,
      height: dimensoes['iconXL']!,
      decoration: BoxDecoration(
        color: cores['primaria']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
        border: Border.all(
          color: cores['primaria']!.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _buildPlantImage(context),
    );
  }

  Widget _buildPlantImage(BuildContext context) {
    if (planta.fotoBase64 != null && planta.fotoBase64!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ImageService.base64ToImage(
              planta.fotoBase64,
              width: PlantasDesignTokens.dimensoes['iconXL']!,
              height: PlantasDesignTokens.dimensoes['iconXL']!,
              fit: BoxFit.cover,
            ) ??
            _buildDefaultPlantIcon(context),
      );
    }
    return _buildDefaultPlantIcon(context);
  }

  Widget _buildDefaultPlantIcon(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);

    return CustomPaint(
      painter: PlantIllustrationPainter(
        leafColor: cores['primaria']!.withValues(alpha: 0.7),
        stemColor: cores['primaria']!,
      ),
    );
  }

  String _getSpaceName() {
    if (planta.espacoId == null || planta.espacoId!.isEmpty) {
      return '';
    }

    // Get space name from controller
    final espaco = controller.espacos.value
        .where((e) => e.id == planta.espacoId)
        .firstOrNull;

    return espaco?.nome ?? '';
  }
}

class PlantIllustrationPainter extends CustomPainter {
  final Color leafColor;
  final Color stemColor;

  PlantIllustrationPainter({
    required this.leafColor,
    required this.stemColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem
    paint.color = stemColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + 8),
          width: 3,
          height: 16,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw leaves
    paint.color = leafColor;

    // Left leaf
    final leftLeafPath = Path();
    leftLeafPath.moveTo(center.dx - 2, center.dy - 2);
    leftLeafPath.quadraticBezierTo(
      center.dx - 12,
      center.dy - 8,
      center.dx - 8,
      center.dy - 16,
    );
    leftLeafPath.quadraticBezierTo(
      center.dx - 4,
      center.dy - 12,
      center.dx - 2,
      center.dy - 2,
    );
    canvas.drawPath(leftLeafPath, paint);

    // Right leaf
    final rightLeafPath = Path();
    rightLeafPath.moveTo(center.dx + 2, center.dy - 2);
    rightLeafPath.quadraticBezierTo(
      center.dx + 12,
      center.dy - 8,
      center.dx + 8,
      center.dy - 16,
    );
    rightLeafPath.quadraticBezierTo(
      center.dx + 4,
      center.dy - 12,
      center.dx + 2,
      center.dy - 2,
    );
    canvas.drawPath(rightLeafPath, paint);

    // Center leaf
    final centerLeafPath = Path();
    centerLeafPath.moveTo(center.dx, center.dy - 4);
    centerLeafPath.quadraticBezierTo(
      center.dx - 6,
      center.dy - 12,
      center.dx,
      center.dy - 18,
    );
    centerLeafPath.quadraticBezierTo(
      center.dx + 6,
      center.dy - 12,
      center.dx,
      center.dy - 4,
    );
    canvas.drawPath(centerLeafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! PlantIllustrationPainter ||
        oldDelegate.leafColor != leafColor ||
        oldDelegate.stemColor != stemColor;
  }
}
