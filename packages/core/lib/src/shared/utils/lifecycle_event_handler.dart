import 'package:flutter/widgets.dart';

/// Widget lifecycle observer that handles app state changes
///
/// Use this to integrate [InjectionContainer.dispose] with app lifecycle.
///
/// Usage in main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize services
///   await InjectionContainer.init();
///
///   // Add lifecycle observer
///   WidgetsBinding.instance.addObserver(
///     LifecycleEventHandler(
///       detachedCallBack: () async {
///         await InjectionContainer.dispose();
///       },
///     ),
///   );
///
///   runApp(MyApp());
/// }
/// ```
class LifecycleEventHandler extends WidgetsBindingObserver {
  /// Called when app is paused (goes to background)
  final Future<void> Function()? pausedCallBack;

  /// Called when app resumes from background
  final Future<void> Function()? resumedCallBack;

  /// Called when app is detached (terminated)
  ///
  /// **Important**: This is where you should dispose services
  final Future<void> Function()? detachedCallBack;

  /// Called when app is inactive (e.g., phone call)
  final Future<void> Function()? inactiveCallBack;

  /// Called when app is hidden (iOS specific)
  final Future<void> Function()? hiddenCallBack;

  LifecycleEventHandler({
    this.pausedCallBack,
    this.resumedCallBack,
    this.detachedCallBack,
    this.inactiveCallBack,
    this.hiddenCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        await pausedCallBack?.call();
        break;
      case AppLifecycleState.resumed:
        await resumedCallBack?.call();
        break;
      case AppLifecycleState.detached:
        await detachedCallBack?.call();
        break;
      case AppLifecycleState.inactive:
        await inactiveCallBack?.call();
        break;
      case AppLifecycleState.hidden:
        await hiddenCallBack?.call();
        break;
    }
  }
}
