import 'package:injectable/injectable.dart';

import '../../domain/entities/maintenance_entity.dart';

/// Service responsible for mapping maintenance types
/// Follows SRP by handling only type conversion logic
@lazySingleton
class MaintenanceTypeMapper {
  /// Map string to MaintenanceType enum
  MaintenanceType stringToType(String type) {
    switch (type.toLowerCase().trim()) {
      case 'preventiva':
        return MaintenanceType.preventive;
      case 'corretiva':
        return MaintenanceType.corrective;
      case 'revisão':
      case 'revisao':
        return MaintenanceType.inspection;
      case 'emergencial':
        return MaintenanceType.emergency;
      default:
        return MaintenanceType.preventive;
    }
  }

  /// Map MaintenanceType enum to string
  String typeToString(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return 'Preventiva';
      case MaintenanceType.corrective:
        return 'Corretiva';
      case MaintenanceType.inspection:
        return 'Revisão';
      case MaintenanceType.emergency:
        return 'Emergencial';
    }
  }

  /// Map string to MaintenanceStatus enum
  MaintenanceStatus stringToStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pendente':
      case 'pending':
        return MaintenanceStatus.pending;
      case 'em andamento':
      case 'in_progress':
      case 'inprogress':
        return MaintenanceStatus.inProgress;
      case 'concluída':
      case 'concluida':
      case 'completed':
        return MaintenanceStatus.completed;
      case 'cancelada':
      case 'cancelled':
      case 'canceled':
        return MaintenanceStatus.cancelled;
      default:
        return MaintenanceStatus.pending;
    }
  }

  /// Map MaintenanceStatus enum to string
  String statusToString(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'Pendente';
      case MaintenanceStatus.inProgress:
        return 'Em Andamento';
      case MaintenanceStatus.completed:
        return 'Concluída';
      case MaintenanceStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Get all available maintenance types
  List<MaintenanceType> getAllTypes() {
    return MaintenanceType.values;
  }

  /// Get all available maintenance statuses
  List<MaintenanceStatus> getAllStatuses() {
    return MaintenanceStatus.values;
  }

  /// Get maintenance type icon emoji
  String getTypeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return '🔧';
      case MaintenanceType.corrective:
        return '🔨';
      case MaintenanceType.inspection:
        return '🔍';
      case MaintenanceType.emergency:
        return '🚨';
    }
  }

  /// Get maintenance status icon emoji
  String getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return '⏳';
      case MaintenanceStatus.inProgress:
        return '⚙️';
      case MaintenanceStatus.completed:
        return '✅';
      case MaintenanceStatus.cancelled:
        return '❌';
    }
  }

  /// Get maintenance type color code (hex)
  String getTypeColor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.preventive:
        return '#4CAF50'; // Green
      case MaintenanceType.corrective:
        return '#FF9800'; // Orange
      case MaintenanceType.inspection:
        return '#2196F3'; // Blue
      case MaintenanceType.emergency:
        return '#F44336'; // Red
    }
  }

  /// Get maintenance status color code (hex)
  String getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return '#FFC107'; // Amber
      case MaintenanceStatus.inProgress:
        return '#2196F3'; // Blue
      case MaintenanceStatus.completed:
        return '#4CAF50'; // Green
      case MaintenanceStatus.cancelled:
        return '#9E9E9E'; // Grey
    }
  }

  /// Parse multiple type strings to enum list
  List<MaintenanceType> parseTypes(List<String> typeStrings) {
    return typeStrings.map((str) => stringToType(str)).toList();
  }

  /// Parse multiple status strings to enum list
  List<MaintenanceStatus> parseStatuses(List<String> statusStrings) {
    return statusStrings.map((str) => stringToStatus(str)).toList();
  }

  /// Check if a type is critical (emergency or corrective)
  bool isCriticalType(MaintenanceType type) {
    return type == MaintenanceType.emergency ||
        type == MaintenanceType.corrective;
  }

  /// Check if a status is active (not completed or cancelled)
  bool isActiveStatus(MaintenanceStatus status) {
    return status == MaintenanceStatus.pending ||
        status == MaintenanceStatus.inProgress;
  }
}
