import 'package:core/core.dart';

import '../interfaces/logging_service.dart';
import '../logging/repositories/log_repository.dart';
import '../services/logging_service_impl.dart';

/// Provider for LogRepository from GetIt
final logRepositoryProvider = Provider<LogRepository>((ref) {
  return getIt<LogRepository>();
});

/// Provider for IAnalyticsRepository (optional dependency)
final analyticsRepositoryProvider = Provider<IAnalyticsRepository?>((ref) {
  try {
    return getIt<IAnalyticsRepository>();
  } catch (_) {
    return null;
  }
});

/// Provider for ICrashlyticsRepository (optional dependency)
final crashlyticsRepositoryProvider = Provider<ICrashlyticsRepository?>((ref) {
  try {
    return getIt<ICrashlyticsRepository>();
  } catch (_) {
    return null;
  }
});

/// Provider for ILoggingService
/// **DIP - Dependency Inversion Principle**
/// Injects concrete implementation without singleton pattern
final loggingServiceProvider = Provider<ILoggingService>((ref) {
  final logRepo = ref.watch(logRepositoryProvider);
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final crashlyticsRepo = ref.watch(crashlyticsRepositoryProvider);

  return LoggingServiceImpl(
    logRepository: logRepo,
    analyticsRepository: analyticsRepo,
    crashlyticsRepository: crashlyticsRepo,
  );
});
