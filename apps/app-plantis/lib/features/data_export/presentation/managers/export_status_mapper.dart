import 'package:flutter/material.dart';

import '../../domain/entities/export_request.dart';
import '../../../../core/theme/plantis_colors.dart';

/// Maps export status to visual elements (colors and icons)
/// Extracts status mapping logic from page
class ExportStatusMapper {
  /// Gets color for export request status
  Color getStatusColor(ExportRequestStatus status) {
    switch (status) {
      case ExportRequestStatus.completed:
        return PlantisColors.leaf;
      case ExportRequestStatus.processing:
        return PlantisColors.primary;
      case ExportRequestStatus.pending:
        return Colors.orange;
      case ExportRequestStatus.failed:
      case ExportRequestStatus.expired:
        return Colors.red;
    }
  }

  /// Gets icon for export request status
  IconData getStatusIcon(ExportRequestStatus status) {
    switch (status) {
      case ExportRequestStatus.completed:
        return Icons.check_circle;
      case ExportRequestStatus.processing:
        return Icons.hourglass_empty;
      case ExportRequestStatus.pending:
        return Icons.schedule;
      case ExportRequestStatus.failed:
        return Icons.error;
      case ExportRequestStatus.expired:
        return Icons.timer_off;
    }
  }
}
