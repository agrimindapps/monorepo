import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/sync/presentation/providers/sync_providers.dart';

/// Widget that listens to auth changes and triggers sync when user logs in
class AuthSyncListener extends ConsumerStatefulWidget {
  const AuthSyncListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AuthSyncListener> createState() => _AuthSyncListenerState();
}

class _AuthSyncListenerState extends ConsumerState<AuthSyncListener> {
  String? _previousUserId;

  @override
  void initState() {
    super.initState();
    // Initialize with current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      _previousUserId = authState.currentUser?.uid;
      
      // If already logged in, start sync
      if (_previousUserId != null) {
        _startSync();
      }
    });
  }

  void _startSync() {
    // Enable auto-sync
    ref.read(autoSyncProvider.notifier).enable();
    
    // Trigger initial sync
    ref.read(syncStateProvider.notifier).syncAll();
  }

  void _stopSync() {
    // Disable auto-sync
    ref.read(autoSyncProvider.notifier).disable();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      final currentUserId = next.currentUser?.uid;
      
      // User logged in
      if (_previousUserId == null && currentUserId != null) {
        debugPrint('🔄 User logged in - Starting sync...');
        _startSync();
      }
      
      // User logged out
      if (_previousUserId != null && currentUserId == null) {
        debugPrint('🛑 User logged out - Stopping sync...');
        _stopSync();
      }
      
      // User changed (different user logged in)
      if (_previousUserId != null && 
          currentUserId != null && 
          _previousUserId != currentUserId) {
        debugPrint('🔄 User changed - Restarting sync...');
        _stopSync();
        _startSync();
      }
      
      _previousUserId = currentUserId;
    });

    return widget.child;
  }
}
