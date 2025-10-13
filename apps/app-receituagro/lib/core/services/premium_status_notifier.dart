import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_status_notifier.g.dart';

/// Premium Status State
class PremiumStatusState {
  final bool isPremium;
  final DateTime? lastChecked;

  const PremiumStatusState({
    this.isPremium = false,
    this.lastChecked,
  });

  PremiumStatusState copyWith({
    bool? isPremium,
    DateTime? lastChecked,
  }) {
    return PremiumStatusState(
      isPremium: isPremium ?? this.isPremium,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

/// Premium Status Notifier using Riverpod
@riverpod
class PremiumStatusNotifier extends _$PremiumStatusNotifier {
  final StreamController<bool> _streamController = StreamController<bool>.broadcast();

  @override
  PremiumStatusState build() {
    // Cleanup on dispose
    ref.onDispose(() {
      _streamController.close();
    });

    return const PremiumStatusState();
  }

  /// Premium status stream
  Stream<bool> get premiumStatusStream => _streamController.stream;

  /// Update premium status
  void updatePremiumStatus(bool isPremium) {
    if (state.isPremium != isPremium) {
      state = state.copyWith(
        isPremium: isPremium,
        lastChecked: DateTime.now(),
      );
      _streamController.add(isPremium);
    }
  }

  /// Check premium status (stub for compatibility)
  Future<void> checkPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Derived provider for isPremium
@riverpod
bool isPremiumStatus(IsPremiumStatusRef ref) {
  return ref.watch(premiumStatusNotifierProvider).isPremium;
}

/// Singleton-style accessor for backward compatibility
/// DEPRECATED: Use Riverpod provider directly instead
@Deprecated('Use premiumStatusNotifierProvider via Riverpod instead')
class PremiumStatusNotifierCompat {
  static final PremiumStatusNotifierCompat _instance = PremiumStatusNotifierCompat._();
  static PremiumStatusNotifierCompat get instance => _instance;

  PremiumStatusNotifierCompat._();

  // This is a stub - actual implementation should use Riverpod
  bool get isPremium => false;

  Stream<bool> get premiumStatusStream => const Stream.empty();

  void updatePremiumStatus(bool isPremium) {
    // Stub - use Riverpod provider instead
  }

  Future<void> checkPremiumStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
