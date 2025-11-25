import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'domain/services/monitoring_alert_service.dart';
import 'domain/services/monitoring_formatter_service.dart';
import 'domain/services/monitoring_ui_mapper_service.dart';

part 'monitoring_providers.g.dart';

@riverpod
MonitoringFormatterService monitoringFormatterService(Ref ref) {
  return MonitoringFormatterService();
}

@riverpod
MonitoringUIMapperService monitoringUIMapperService(Ref ref) {
  return MonitoringUIMapperService();
}

@riverpod
MonitoringAlertService monitoringAlertService(Ref ref) {
  return MonitoringAlertService();
}
