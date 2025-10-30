import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/device_management_notifier.dart';

/// Builds feedback UI for device management
/// Handles error and success messages
class DeviceFeedbackBuilder {
  /// Builds feedback message widget
  static Widget buildFeedbackMessages(
    DeviceManagementState deviceState,
    WidgetRef ref,
  ) {
    if (deviceState.errorMessage != null) {
      return _buildErrorMessage(deviceState, ref);
    }

    if (deviceState.successMessage != null) {
      return _buildSuccessMessage(deviceState, ref);
    }

    return const SizedBox.shrink();
  }

  static Widget _buildErrorMessage(
    DeviceManagementState deviceState,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              deviceState.errorMessage!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
            onPressed: () {
              // Clear error by invalidating provider
              ref.invalidate(deviceManagementNotifierProvider);
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  static Widget _buildSuccessMessage(
    DeviceManagementState deviceState,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              deviceState.successMessage!,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.green.shade600, size: 18),
            onPressed: () {
              // Clear success by invalidating provider
              ref.invalidate(deviceManagementNotifierProvider);
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
