import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/widgets/feedback/confirmation_system.dart';
import '../../shared/widgets/feedback/feedback_system.dart';
import '../../shared/widgets/feedback/haptic_service.dart';
import '../../shared/widgets/feedback/toast_service.dart';

part 'feedback_providers.g.dart';

// ============================================================================
// FEEDBACK SERVICES
// ============================================================================

/// Provider para HapticService (singleton)
@Riverpod(keepAlive: true)
HapticService hapticService(Ref ref) {
  final service = HapticService();
  service.initialize();
  return service;
}

/// Provider para ToastService (singleton)
@Riverpod(keepAlive: true)
ToastService toastService(Ref ref) {
  final hapticService = ref.watch(hapticServiceProvider);
  return ToastService(hapticService);
}

/// Provider para ConfirmationService (singleton)
@Riverpod(keepAlive: true)
ConfirmationService confirmationService(Ref ref) {
  final hapticService = ref.watch(hapticServiceProvider);
  return ConfirmationService(hapticService);
}

/// Provider para FeedbackService (singleton)
@Riverpod(keepAlive: true)
FeedbackService feedbackService(Ref ref) {
  return FeedbackService();
}
