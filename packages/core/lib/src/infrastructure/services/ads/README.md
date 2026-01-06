# Google Mobile Ads Service

Complete implementation of Google Mobile Ads for the monorepo following Clean Architecture and SOLID principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Setup](#setup)
- [Usage](#usage)
- [Web - AdSense](#web---adsense)
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
- ✅ SOLID Principles (specialized services following SRP)
- ✅ Riverpod state management
- ✅ Either<Failure, T> error handling
- ✅ Built-in frequency capping (configurable interval between ads)
- ✅ Premium user support (no ads for subscribers)
- ✅ Complete lifecycle management
- ✅ Compatible with google_mobile_ads ^6.0.0

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
│       ├── specialized_services/  # SRP-compliant services
│       ├── helpers/               # Analytics helpers
│       └── google_mobile_ads_service.dart  # Main facade
├── riverpod/domain/ads/        # Riverpod providers
└── presentation/widgets/ads/   # UI components
```

### Specialized Services (SRP)

1. **AdLifecycleManager** - Ad lifecycle tracking
2. **BannerAdService** - Banner ad operations
3. **InterstitialAdService** - Interstitial ad operations
4. **RewardedAdService** - Rewarded ad operations
5. **RewardedInterstitialAdService** - Rewarded interstitial operations
6. **AppOpenAdService** - App open ad operations

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

## Web - AdSense

Para Flutter Web, use Google AdSense em vez de AdMob. O AdSense é implementado via `HtmlElementView` para injetar elementos HTML nativos.

### Setup Web

#### 1. Adicione o script ao index.html

```html
<!-- web/index.html -->
<head>
  <!-- Google AdSense -->
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-SEU_ID"
     crossorigin="anonymous"></script>
</head>
```

#### 2. Configure o Provider

```dart
import 'package:core/core.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        adSenseConfigProvider.overrideWithValue(
          AdSenseConfigEntity.production(
            clientId: 'ca-pub-XXXXXXX',
            adSlots: {
              'banner_top': '1234567890',
              'banner_bottom': '0987654321',
            },
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### Widgets AdSense

```dart
// Importe diretamente (só funciona em builds web)
import 'package:core/src/presentation/widgets/ads/web/adsense_banner_widget.dart';

// Banner básico
AdSenseBannerWidget(
  slotName: 'banner_top',
  adSlot: '1234567890',
  height: 100,
  onAdLoaded: () => print('Ad loaded'),
  onAdFailed: (error) => print('Error: $error'),
)

// Banner responsivo
ResponsiveAdSenseBannerWidget(
  slotName: 'banner_top',
  adSlot: '1234567890',
)

// In-article (entre parágrafos)
InArticleAdSenseWidget(
  slotName: 'in_article',
  adSlot: '1234567890',
)

// In-feed (em listagens)
InFeedAdSenseWidget(
  slotName: 'in_feed',
  adSlot: '1234567890',
)
```

### Formatos AdSense

| Formato | Uso | Código |
|---------|-----|--------|
| `auto` | Detecta automaticamente | `AdSenseFormat.auto` |
| `horizontal` | Banners horizontais | `AdSenseFormat.horizontal` |
| `vertical` | Banners verticais | `AdSenseFormat.vertical` |
| `rectangle` | Retângulos | `AdSenseFormat.rectangle` |
| `inArticle` | Entre parágrafos | `AdSenseFormat.inArticle` |
| `inFeed` | Em listagens | `AdSenseFormat.inFeed` |

### Tamanhos AdSense

| Tamanho | Dimensões | Código |
|---------|-----------|--------|
| Banner | 320x50 | `AdSenseSize.banner` |
| Large Banner | 320x100 | `AdSenseSize.largeBanner` |
| Medium Rectangle | 300x250 | `AdSenseSize.mediumRectangle` |
| Full Banner | 468x60 | `AdSenseSize.fullBanner` |
| Leaderboard | 728x90 | `AdSenseSize.leaderboard` |
| Wide Skyscraper | 160x600 | `AdSenseSize.wideSkyscraper` |
| Responsivo | Adaptável | `AdSenseSize.responsive` |

### Providers Web

```dart
// Repositório web
final webAdsRepo = ref.read(webAdsRepositoryProvider);

// Verificar se deve mostrar ads
final shouldShow = await ref.read(shouldShowWebAdsProvider('banner').future);

// Definir status premium (não mostra ads)
ref.read(webAdsPremiumStatusProvider.notifier).state = true;
```

### App Multiplataforma

```dart
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

Widget buildAdBanner() {
  if (kIsWeb) {
    // Para web - importe separadamente
    return _buildWebAd();
  } else {
    // Para mobile
    return UnifiedAdBannerWidget(
      mobileConfig: MobileAdConfig.banner(
        adUnitId: 'ca-app-pub-xxx/yyy',
      ),
    );
  }
}
```

### Considerações Web

1. **AdBlockers**: Usuários com AdBlock não verão anúncios
2. **Container**: Garanta que tenha altura definida
3. **Renderer**: Funciona melhor com `--web-renderer html`
4. **SPA**: Anúncios podem não recarregar em navegações

---

## Ad Types

### Banner Ads
- **Sizes**: banner (320x50), largeBanner (320x100), mediumRectangle (300x250)
- **Use case**: Bottom of screen, between content

### Interstitial Ads
- **Size**: Fullscreen
- **Use case**: Between levels, after actions
- **Default interval**: 60 seconds between ads

### Rewarded Ads
- **Size**: Fullscreen
- **Use case**: User-initiated (watch for rewards)

### Rewarded Interstitial Ads
- **Size**: Fullscreen with reward
- **Use case**: Before premium features

### App Open Ads
- **Size**: Fullscreen
- **Use case**: App launch, resume from background

---

## Frequency Capping

The service includes built-in frequency capping with configurable minimum interval between ads (default: 60 seconds).

```dart
// Custom interval (e.g., 2 minutes)
final service = GoogleMobileAdsService(
  // ... other services
  minAdInterval: Duration(minutes: 2),
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

### Set Test Devices

```dart
final adsRepository = ref.read(adsRepositoryProvider);
await adsRepository.setTestDevices(deviceIds: ['YOUR_DEVICE_ID']);
```

---

## Best Practices

### 1. Check Ad Readiness

```dart
if (repository.isInterstitialReady) {
  await repository.showInterstitialAd();
}
```

### 2. Handle Errors Gracefully

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

### 3. Premium Users

```dart
// Set premium status checker on initialization
// Premium users will NEVER see ads (except rewarded if user-initiated)
```

---

## Support

For issues or questions:
1. Check Google Mobile Ads documentation
2. Review error logs in Firebase Crashlytics
3. Verify ad unit IDs are correct

---

**Last Updated:** 2025-11-24
**Version:** 2.0.0 (google_mobile_ads ^6.0.0)
