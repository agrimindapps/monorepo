# Google Mobile Ads Service

Complete implementation of Google Mobile Ads for the monorepo following Clean Architecture and SOLID principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Setup](#setup)
- [Usage](#usage)
- [Ad Types](#ad-types)
- [Frequency Capping](#frequency-capping)
- [Premium Integration](#premium-integration)
- [Testing](#testing)
- [Analytics](#analytics)
- [Best Practices](#best-practices)

---

## Overview

This service provides a complete, production-ready implementation of Google Mobile Ads with:

- ✅ Clean Architecture (Domain/Infrastructure/Presentation)
- ✅ SOLID Principles (9 specialized services following SRP)
- ✅ Riverpod state management
- ✅ Either<Failure, T> error handling
- ✅ Hive persistence for configs and frequency tracking
- ✅ Firebase Analytics integration
- ✅ Automatic frequency capping
- ✅ Premium user support (no ads for subscribers)
- ✅ Ad preloading for better UX
- ✅ Complete lifecycle management

---

## Architecture

### Layers

```
lib/src/
├── domain/
│   ├── entities/ads/           # Pure business entities
│   └── repositories/           # Repository interfaces
├── infrastructure/
│   └── services/ads/
│       ├── specialized_services/  # 9 SRP-compliant services
│       ├── models/                # Hive persistence models
│       ├── helpers/               # Analytics helpers
│       └── google_mobile_ads_service.dart  # Main facade
├── riverpod/domain/ads/        # Riverpod providers
└── presentation/widgets/ads/   # UI components
```

### Specialized Services (SRP)

1. **AdConfigService** - Configuration management
2. **AdFrequencyManager** - Frequency capping logic
3. **AdLifecycleManager** - Ad lifecycle tracking
4. **BannerAdService** - Banner ad operations
5. **InterstitialAdService** - Interstitial ad operations
6. **RewardedAdService** - Rewarded ad operations
7. **RewardedInterstitialAdService** - Rewarded interstitial operations
8. **AppOpenAdService** - App open ad operations
9. **AdPreloaderService** - Background ad preloading

---

## Setup

### 1. Add Google Mobile Ads to AndroidManifest.xml

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <application>
        <!-- Google Mobile Ads App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

### 2. Add to Info.plist (iOS)

```xml
<!-- ios/Runner/Info.plist -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

<!-- For iOS 14+ tracking (optional) -->
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

### 3. Initialize in your app

```dart
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize ads service
    useEffect(() {
      _initializeAds(ref);
      return null;
    }, []);

    return MaterialApp(...);
  }

  Future<void> _initializeAds(WidgetRef ref) async {
    final adsRepository = ref.read(adsRepositoryProvider);

    // Get platform-specific app ID
    final appId = Platform.isAndroid
        ? 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY'  // Android
        : 'ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ'; // iOS

    await adsRepository.initialize(appId: appId);
  }
}
```

---

## Usage

### Banner Ads

#### Using Widget

```dart
import 'package:core/core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your content
          Expanded(child: ContentWidget()),

          // Banner ad at bottom
          AdBannerWidget(
            adUnitId: 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY',
            size: AdSize.banner,
            onAdLoaded: () {
              print('Banner loaded!');
            },
          ),
        ],
      ),
    );
  }
}
```

#### Adaptive Banner

```dart
AdaptiveBannerWidget(
  adUnitId: 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY',
  onAdLoaded: () {
    print('Adaptive banner loaded!');
  },
)
```

### Interstitial Ads

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showInterstitial(context, ref),
          child: Text('Show Interstitial'),
        ),
      ),
    );
  }

  Future<void> _showInterstitial(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(adsRepositoryProvider);

    // Check if ad is ready
    if (!repository.isInterstitialReady) {
      // Load ad
      final adUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
      await repository.loadInterstitialAd(adUnitId: adUnitId);
    }

    // Show ad
    final result = await repository.showInterstitialAd();

    result.fold(
      (failure) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.userMessage)),
        );
      },
      (_) {
        // Ad shown successfully
        print('Interstitial shown!');
      },
    );
  }
}
```

### Rewarded Ads

```dart
Future<void> _showRewardedAd(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(adsRepositoryProvider);

  // Check if ad is ready
  if (!repository.isRewardedReady) {
    // Load ad
    final adUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/AAAAAAAAAA';
    await repository.loadRewardedAd(adUnitId: adUnitId);
  }

  // Show ad
  final result = await repository.showRewardedAd();

  result.fold(
    (failure) {
      // Handle error
      print('Failed to show rewarded ad: ${failure.message}');
    },
    (rewardedAd) {
      // User earned reward!
      print('User earned reward!');
      // Grant reward to user
      _grantReward();
    },
  );
}

void _grantReward() {
  // Grant coins, lives, etc.
  print('Granting reward to user!');
}
```

### App Open Ads

```dart
class MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppOpenAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _showAppOpenAd();
    }
  }

  Future<void> _loadAppOpenAd() async {
    final repository = ref.read(adsRepositoryProvider);
    final adUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';
    await repository.loadAppOpenAd(adUnitId: adUnitId);
  }

  Future<void> _showAppOpenAd() async {
    final repository = ref.read(adsRepositoryProvider);

    if (repository.isAppOpenReady) {
      await repository.showAppOpenAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

---

## Ad Types

### Banner Ads
- **Sizes**: banner (320x50), largeBanner (320x100), mediumRectangle (300x250)
- **Use case**: Bottom of screen, between content
- **Frequency**: No strict limits

### Interstitial Ads
- **Size**: Fullscreen
- **Use case**: Between levels, after actions
- **Frequency**: Max 10/day, 5/session, 5min between

### Rewarded Ads
- **Size**: Fullscreen
- **Use case**: User-initiated (watch for rewards)
- **Frequency**: Max 20/day, 10/session, 1min between

### Rewarded Interstitial Ads
- **Size**: Fullscreen with reward
- **Use case**: Before premium features
- **Frequency**: Similar to interstitials

### App Open Ads
- **Size**: Fullscreen
- **Use case**: App launch, resume from background
- **Frequency**: Max 5/day, 1/session, 4h between

---

## Frequency Capping

### Default Configurations

```dart
// Interstitial
AdFrequencyConfig(
  maxAdsPerDay: 10,
  maxAdsPerSession: 5,
  minIntervalSeconds: 300, // 5 minutes
  maxAdsPerHour: 3,
)

// Rewarded
AdFrequencyConfig(
  maxAdsPerDay: 20,
  maxAdsPerSession: 10,
  minIntervalSeconds: 60, // 1 minute
  maxAdsPerHour: 5,
)

// App Open
AdFrequencyConfig(
  maxAdsPerDay: 5,
  maxAdsPerSession: 1,
  minIntervalSeconds: 14400, // 4 hours
  maxAdsPerHour: 1,
)
```

### Custom Frequency Config

```dart
final configService = ref.read(adConfigServiceProvider);
final customConfig = AdFrequencyConfig(
  maxAdsPerDay: 15,
  maxAdsPerSession: 8,
  minIntervalSeconds: 180, // 3 minutes
);
```

---

## Premium Integration

### With RevenueCat

```dart
// In ads service initialization
final adsRepository = GoogleMobileAdsService(
  // ... other services
  premiumStatusChecker: () async {
    final revenueCat = ref.read(revenueCatServiceProvider);
    return await revenueCat.isPremium();
  },
);
```

### Manual Check

```dart
final shouldShow = await ref.read(
  shouldShowAdsProvider('interstitial').future,
);

if (!shouldShow) {
  print('User is premium, no ads!');
  return;
}
```

---

## Testing

### Test Ad Unit IDs

**Android:**
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`
- App Open: `ca-app-pub-3940256099942544/3419835294`

**iOS:**
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`
- App Open: `ca-app-pub-3940256099942544/5662855259`

### Enable Test Mode

```dart
final configService = ref.read(adConfigServiceProvider);
await configService.setDevelopmentConfig();
```

---

## Analytics

### Track Ad Events

```dart
final analytics = FirebaseAnalytics.instance;
final adsAnalytics = AdsAnalyticsHelper(analytics);

// Log ad impression
await adsAnalytics.logAdImpression(
  adType: AdType.interstitial,
  placement: 'home_screen',
  adUnitId: 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY',
);

// Log ad clicked
await adsAnalytics.logAdClicked(
  adType: AdType.rewarded,
  placement: 'after_level',
);

// Log rewarded ad
await adsAnalytics.logAdRewarded(
  placement: 'watch_for_coins',
  rewardAmount: 100,
  rewardType: 'coins',
);
```

---

## Best Practices

### 1. Preload Ads

```dart
// Ads are automatically preloaded on initialization
// Manual preload:
final preloader = ref.read(adPreloaderServiceProvider);
await preloader.preloadInterstitial();
```

### 2. Check Ad Readiness

```dart
final isReady = ref.watch(isAdReadyProvider(AdType.interstitial));

if (isReady) {
  // Show ad
}
```

### 3. Handle Errors Gracefully

```dart
result.fold(
  (failure) {
    // Don't block user flow if ad fails
    if (failure is AdLoadFailure) {
      print('Ad failed to load, continuing...');
    }
  },
  (_) {
    // Ad shown
  },
);
```

### 4. Respect Frequency Caps

```dart
// Service automatically enforces frequency caps
// No manual checking needed!
```

### 5. Premium Users

```dart
// Set premium status checker on initialization
// Premium users will NEVER see ads (except rewarded if user-initiated)
```

---

## Support

For issues or questions:
1. Check Google Mobile Ads documentation
2. Review error logs in Firebase Crashlytics
3. Check frequency capping settings
4. Verify ad unit IDs are correct

---

**Last Updated:** 2025-10-10
**Version:** 1.0.0
