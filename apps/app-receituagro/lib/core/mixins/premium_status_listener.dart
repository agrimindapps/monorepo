import 'package:flutter/material.dart';

/// Stub mixin for PremiumStatusListener - deprecated
/// DEPRECATED: Use ConsumerStatefulWidget with Riverpod instead
/// This stub provides basic compatibility but does not function
@Deprecated('Use ConsumerStatefulWidget with Riverpod premiumStatusNotifierProvider instead')
mixin PremiumStatusListener<T extends StatefulWidget> on State<T> {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  @override
  void initState() {
    super.initState();
    // Stub - no longer functional
    // Migrate to Riverpod: ConsumerStatefulWidget + ref.watch(premiumStatusNotifierProvider)
  }

  /// Override this method to handle premium status changes
  /// DEPRECATED: Use ref.listen with Riverpod instead
  void onPremiumStatusChanged(bool isPremium) {
    // Stub for compatibility
  }

  @override
  void dispose() {
    super.dispose();
  }
}
