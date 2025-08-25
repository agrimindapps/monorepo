// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/design_tokens/plantas_design_tokens.dart';
import '../../../database/planta_model.dart';
import '../../../services/shared/image_service.dart';
import '../interfaces/plantas_controller_interface.dart';
import 'plant_actions_menu.dart';

class PlantGridCardWidget extends StatelessWidget {
  final PlantaModel planta;
  final IPlantasController controller;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const PlantGridCardWidget({
    super.key,
    required this.planta,
    required this.controller,
    this.onTap,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const dimensoes = PlantasDesignTokens.dimensoes;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getTarefasPendentes(planta.id),
      builder: (context, snapshot) {
        final tarefasPendentes = snapshot.data ?? [];

        return Card(
          elevation: dimensoes['elevationS'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensoes['radiusL']!),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(dimensoes['radiusL']!),
            child: Padding(
              padding: EdgeInsets.all(dimensoes['paddingM']!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with actions menu
                  Row(
                    children: [
                      Expanded(child: Container()),
                      PlantActionsMenu(
                        onEdit: onEdit,
                        onRemove: onRemove,
                      ),
                    ],
                  ),

                  // Plant icon/image placeholder
                  Expanded(
                    child: Center(
                      child: _buildPlantIcon(context),
                    ),
                  ),

                  SizedBox(height: dimensoes['marginS']),

                  // Plant name
                  Text(
                    planta.nome ?? 'Sem nome',
                    style:
                        PlantasDesignTokens.textStyles(context)['labelLarge'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: dimensoes['paddingXS']),

                  // Plant species
                  if (planta.especie?.isNotEmpty == true)
                    Text(
                      planta.especie ?? '',
                      style:
                          PlantasDesignTokens.textStyles(context)['bodySmall'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),

                  SizedBox(height: dimensoes['marginS']),

                  // Task status indicator (compact version for grid)
                  Center(
                    child: _buildCompactTaskStatus(tarefasPendentes),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlantIcon(BuildContext context) {
    final cores = PlantasDesignTokens.cores(context);
    const dimensoes = PlantasDesignTokens.dimensoes;
    const size = 60.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cores['primaria']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: cores['primaria']!.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _buildPlantImage(context, size),
    );
  }

  Widget _buildPlantImage(BuildContext context, double size) {
    if (planta.fotoBase64 != null && planta.fotoBase64!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: ImageService.base64ToImage(
              planta.fotoBase64,
              width: size,
              height: size,
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

  Widget _buildCompactTaskStatus(List<Map<String, dynamic>> tarefasPendentes) {
    return Builder(
      builder: (context) {
        final cores = PlantasDesignTokens.cores(context);
        const dimensoes = PlantasDesignTokens.dimensoes;
        final textStyles = PlantasDesignTokens.textStyles(context);

        if (tarefasPendentes.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimensoes['paddingS']!,
              vertical: dimensoes['paddingXS']!,
            ),
            decoration: BoxDecoration(
              color: cores['sucessoClaro'],
              borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
              border: Border.all(
                color: cores['sucesso']!.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: cores['sucesso'],
                  size: dimensoes['iconXS'],
                ),
                SizedBox(width: dimensoes['paddingXS']),
                Text(
                  'Em dia',
                  style: textStyles['caption']!.copyWith(
                    color: cores['sucesso'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final pendingCount = tarefasPendentes.length;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimensoes['paddingS']!,
            vertical: dimensoes['paddingXS']!,
          ),
          decoration: BoxDecoration(
            color: cores['avisoClaro'],
            borderRadius: BorderRadius.circular(dimensoes['radiusM']!),
            border: Border.all(
              color: cores['aviso']!.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: cores['aviso'],
                size: dimensoes['iconXS'],
              ),
              SizedBox(width: dimensoes['paddingXS']),
              Text(
                '$pendingCount pendentes',
                style: textStyles['caption']!.copyWith(
                  color: cores['aviso'],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
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
