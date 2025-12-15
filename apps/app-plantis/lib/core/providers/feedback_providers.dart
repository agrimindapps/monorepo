import 'package:flutter/material.dart';
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
/// Now properly managed by Riverpod with cleanup
@Riverpod(keepAlive: true)
FeedbackService feedbackService(Ref ref) {
  final service = FeedbackService();

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

// ============================================================================
// FEEDBACK STATE MANAGEMENT
// ============================================================================

/// State class for feedback notifications
class FeedbackNotifierState {
  final Map<String, FeedbackController> activeControllers;
  final int notificationCount;

  const FeedbackNotifierState({
    this.activeControllers = const {},
    this.notificationCount = 0,
  });

  FeedbackNotifierState copyWith({
    Map<String, FeedbackController>? activeControllers,
    int? notificationCount,
  }) {
    return FeedbackNotifierState(
      activeControllers: activeControllers ?? this.activeControllers,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }

  bool get hasActiveFeedback => activeControllers.isNotEmpty;
  int get activeFeedbackCount => activeControllers.length;
}

/// Notifier for tracking feedback state reactively
/// Allows widgets to listen to feedback changes without manual listeners
@riverpod
class FeedbackNotifier extends _$FeedbackNotifier {
  @override
  FeedbackNotifierState build() {
    final service = ref.watch(feedbackServiceProvider);

    // Listen to feedback service changes and update state
    void listener() {
      state = FeedbackNotifierState(
        activeControllers: service.activeFeedbacks,
        notificationCount: service.activeFeedbacks.length,
      );
    }

    service.addListener(listener);

    ref.onDispose(() {
      service.removeListener(listener);
    });

    return FeedbackNotifierState(
      activeControllers: service.activeFeedbacks,
      notificationCount: service.activeFeedbacks.length,
    );
  }

  /// Shows success feedback
  void showSuccess({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData icon = Icons.check_circle,
    Duration duration = const Duration(seconds: 3),
    SuccessAnimationType animation = SuccessAnimationType.checkmark,
    bool includeHaptic = true,
    VoidCallback? onComplete,
  }) {
    final service = ref.read(feedbackServiceProvider);
    service.showSuccess(
      context: context,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      duration: duration,
      animation: animation,
      includeHaptic: includeHaptic,
      onComplete: onComplete,
    );
  }

  /// Shows error feedback
  void showError({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData icon = Icons.error,
    Duration duration = const Duration(seconds: 5),
    ErrorAnimationType animation = ErrorAnimationType.shake,
    bool includeHaptic = true,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onComplete,
  }) {
    final service = ref.read(feedbackServiceProvider);
    service.showError(
      context: context,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      duration: duration,
      animation: animation,
      includeHaptic: includeHaptic,
      actionLabel: actionLabel,
      onAction: onAction,
      onComplete: onComplete,
    );
  }

  /// Shows progress feedback
  FeedbackController showProgress({
    required BuildContext context,
    required String message,
    String? semanticLabel,
    IconData? icon,
    ProgressType progressType = ProgressType.determinate,
    double progress = 0.0,
    bool includeHaptic = false,
  }) {
    final service = ref.read(feedbackServiceProvider);
    return service.showProgress(
      context: context,
      message: message,
      semanticLabel: semanticLabel,
      icon: icon,
      progressType: progressType,
      progress: progress,
      includeHaptic: includeHaptic,
    );
  }

  /// Dismisses specific feedback
  void dismiss(String key) {
    final service = ref.read(feedbackServiceProvider);
    service.dismiss(key);
  }

  /// Dismisses all feedback
  void dismissAll() {
    final service = ref.read(feedbackServiceProvider);
    service.dismissAll();
  }
}

// ============================================================================
// HELPER PROVIDERS
// ============================================================================

/// Helper provider to check if feedback is active
@riverpod
bool hasFeedbackActive(Ref ref) {
  final state = ref.watch(feedbackProvider);
  return state.hasActiveFeedback;
}

/// Helper provider to get count of active feedbacks
@riverpod
int activeFeedbackCount(Ref ref) {
  final state = ref.watch(feedbackProvider);
  return state.activeFeedbackCount;
}
