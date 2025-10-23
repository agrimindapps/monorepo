# Connectivity Monitoring - GasOMeter

## Overview

This module implements real-time connectivity monitoring for GasOMeter, automatically triggering sync when connectivity is restored. It follows the pattern established in `app-plantis` with enhancements for integration with UnifiedSyncManager.

## Architecture

### Components

1. **ConnectivityService** (from `core` package)
   - Monitors network connectivity using `connectivity_plus`
   - Provides reactive stream of connectivity status
   - Handles different network types (WiFi, Mobile, Ethernet, etc.)

2. **ConnectivityStateManager**
   - Persists connectivity state between app sessions
   - Uses SharedPreferences for storage
   - Implements 24-hour cache expiration

3. **ConnectivitySyncIntegration**
   - Coordinates ConnectivityService and UnifiedSyncManager
   - Automatically triggers sync when connectivity is restored
   - Handles errors gracefully without crashing the app

4. **ConnectivityBanner**
   - UI component that displays offline status
   - Provides retry button for manual connectivity check
   - Auto-hides when back online

## Usage

### Initialization

The connectivity monitoring is automatically initialized in `main.dart`:

```dart
await _initializeConnectivityMonitoring();
```

This happens after Firebase and Sync services are initialized.

### UI Integration

To show the connectivity banner in your pages:

```dart
import 'package:gasometer/shared/widgets/connectivity_banner.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Page')),
      body: Column(
        children: [
          ConnectivityBanner(), // Shows when offline
          Expanded(
            child: MyPageContent(),
          ),
        ],
      ),
    );
  }
}
```

Or use the extension methods:

```dart
// Show banner manually
context.showConnectivityBanner();

// Hide banner
context.hideConnectivityBanner();
```

### Accessing Connectivity Status

```dart
import 'package:core/core.dart';
import 'package:gasometer/core/di/injection_container.dart';

final connectivityService = getIt<ConnectivityService>();

// Check current status
final isOnlineResult = await connectivityService.isOnline();
isOnlineResult.fold(
  (failure) => print('Error: ${failure.message}'),
  (isOnline) => print('Online: $isOnline'),
);

// Listen to changes
connectivityService.connectivityStream.listen((isOnline) {
  print('Connectivity changed: $isOnline');
});

// Force connectivity check
await connectivityService.forceConnectivityCheck();
```

## Automatic Sync on Reconnection

When the device reconnects to the internet:

1. ConnectivityService detects the change
2. ConnectivitySyncIntegration receives the event
3. Automatically triggers `UnifiedSyncManager.forceSyncApp('gasometer')`
4. All pending changes are synced to Firebase

This ensures data is always up-to-date without user intervention.

## State Persistence

Connectivity state is saved to SharedPreferences with:
- Last known state (online/offline)
- Timestamp of last check

States older than 24 hours are considered expired and default to "online".

## Error Handling

All connectivity errors are handled gracefully:
- Connectivity check failures default to offline mode
- Sync errors are logged but don't crash the app
- UI shows appropriate error messages

## Testing

Run the connectivity tests:

```bash
flutter test test/core/services/connectivity_state_manager_test.dart
```

Test coverage: 11/11 tests passing (100%)

## Dependencies

- `connectivity_plus: ^6.1.2` - Network connectivity detection
- `shared_preferences` - State persistence
- `rxdart` - Stream utilities (debouncing)

## Implementation Details

### Debouncing

Connectivity changes are debounced by 1 second to avoid multiple triggers during network transitions.

### Stream Management

All streams are properly disposed to prevent memory leaks:
- ConnectivityService disposes subscription on app termination
- ConnectivitySyncIntegration can be manually disposed if needed

### Logging

All connectivity events are logged using `dart:developer`:
- Connectivity changes (online/offline)
- Sync triggers
- Errors and warnings

Look for logs with name: `ConnectivitySync`

## Future Enhancements

- [ ] Add connectivity quality indicators (signal strength)
- [ ] Implement smart sync (only sync changed entities)
- [ ] Add user preference for auto-sync on metered connections
- [ ] Network speed detection (2G/3G/4G/5G/WiFi)
- [ ] Connectivity analytics tracking
