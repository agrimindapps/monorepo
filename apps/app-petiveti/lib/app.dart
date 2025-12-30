import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class PetiVetiApp extends ConsumerStatefulWidget {
  const PetiVetiApp({super.key});

  @override
  ConsumerState<PetiVetiApp> createState() => _PetiVetiAppState();
}

class _PetiVetiAppState extends ConsumerState<PetiVetiApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 📊 Analytics: Start initial session tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSessionTracking();
    });
  }

  @override
  void dispose() {
    // 📊 Analytics: End session on dispose
    _endSessionTracking();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          // 📊 Analytics: End session tracking
          _endSessionTracking();
          break;
        case AppLifecycleState.resumed:
          // 📊 Analytics: Start session tracking
          _startSessionTracking();
          break;
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // No action needed
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error handling lifecycle state change: $e');
      }
    }
  }

  /// 📊 Inicia tracking de sessão para analytics
  void _startSessionTracking() {
    try {
      ref.read(sessionTrackingProvider.notifier).startSession();
      ref.read(engagementMetricsProvider.notifier).startNewSession();
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Session started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to start session tracking: $e');
      }
    }
  }

  /// 📊 Finaliza tracking de sessão para analytics
  void _endSessionTracking() {
    try {
      final sessionDuration = ref.read(currentSessionDurationProvider);
      ref.read(sessionTrackingProvider.notifier).endSession();
      ref.read(engagementMetricsProvider.notifier).addSessionTime(sessionDuration);
      if (kDebugMode) {
        debugPrint('📊 [Analytics] Session ended (${sessionDuration.inSeconds}s)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to end session tracking: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'PetiVeti',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
