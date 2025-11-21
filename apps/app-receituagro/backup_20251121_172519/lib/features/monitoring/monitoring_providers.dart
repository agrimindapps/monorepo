import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart' as di;
import 'domain/services/monitoring_alert_service.dart';
import 'domain/services/monitoring_formatter_service.dart';
import 'domain/services/monitoring_ui_mapper_service.dart';

part 'monitoring_providers.g.dart';

@riverpod
MonitoringFormatterService monitoringFormatterService(MonitoringFormatterServiceRef ref) {
  return di.sl<MonitoringFormatterService>();
}

@riverpod
MonitoringUIMapperService monitoringUIMapperService(MonitoringUIMapperServiceRef ref) {
  return di.sl<MonitoringUIMapperService>();
}

@riverpod
MonitoringAlertService monitoringAlertService(MonitoringAlertServiceRef ref) {
  return di.sl<MonitoringAlertService>();
}
