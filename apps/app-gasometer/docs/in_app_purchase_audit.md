# Gasometer In-App Purchase Audit — 2025-10-07

## Scope
- Evaluate the current in-app purchase (IAP) implementation inside `apps/app-gasometer`.
- Trace how the feature consumes shared services from `packages/core`.
- Highlight strengths, risks, and concrete improvement opportunities for follow-up agents.

## Architecture Snapshot
- **Presentation**: `PremiumNotifier` orchestrates state, calling use cases such as `PurchasePremium` and `GetAvailableProducts`.
- **Domain/Data**: `PremiumRepositoryImpl` delegates remote operations to `PremiumRemoteDataSourceImpl`, local cache to `PremiumLocalDataSourceImpl`, and cross-device sync to `PremiumSyncService`.
- **Core Integration**: `PremiumRemoteDataSourceImpl` wraps `core.ISubscriptionRepository` (currently bound to `core.RevenueCatService`) for RevenueCat operations (`purchaseProduct`, `restorePurchases`, `subscriptionStatus`, etc.).
- **DI**: `CoreModule` registers `core.RevenueCatService` as the shared implementation for `ISubscriptionRepository`, exposing it to the app layer via GetIt/Injectable.

## Strengths Observed
- Layered separation is consistent: presentation → domain → repository → data sources → core service.
- `PremiumSyncService` already aggregates RevenueCat, Firebase cache, and webhook updates, providing a single stream to the UI.
- Comprehensive failure hierarchy in `packages/core` enables nuanced error handling once correctly surfaced.
- Remote data source exposes `setUser`, `restorePurchases`, and `getManagementUrl`, keeping the app ready for richer account flows.

## Issues and Opportunities

### 1. RevenueCat catalog mismatch (blocker)
- **Evidence**: `GasometerEnvironmentConfig.monthlyProductId`/`yearlyProductId` reference `gasometer_premium_*`, while `RevenueCatService.getGasometerProducts()` requests `gasometer_monthly`/`gasometer_yearly` (`packages/core/lib/src/infrastructure/services/revenue_cat_service.dart`).
- **Impact**: `getAvailableProducts()` returns an empty list, breaking product display and purchases.
- **Actions**:
  - [ ] Decide on canonical product identifiers and update both the Gasometer config and `RevenueCatService` constants to match.
  - [ ] Add a regression test (e.g., fake offerings) ensuring Gasometer product IDs resolve to at least one `StoreProduct`.

### 2. RevenueCat user never identified (critical)
- **Evidence**: No caller invokes `PremiumRepository.setUser`; `_onAuthStateChanged` in `PremiumSyncService` never reaches RevenueCat `logIn`.
- **Impact**: Purchases may bind to anonymous RevenueCat users, causing entitlement loss after sign-out or on other devices.
- **Actions**:
  - [ ] Hook `PremiumSyncService._onAuthStateChanged` (or the auth flow) to call `PremiumRepository.setUser` with the authenticated user ID and attributes (email, platform, locale).
  - [ ] Add matching logout path calling `Purchases.logOut()` when the user signs out.

### 3. Subscription stream missing initial snapshot
- **Evidence**: `RevenueCatService` only pushes updates when `CustomerInfo` changes; no initial emission is made after `configure()`.
- **Impact**: `PremiumSyncService` starts with `PremiumStatus.free` even when purchases exist until the first external update occurs.
- **Actions**:
  - [ ] After configuration, call `Purchases.getCustomerInfo()` and emit the mapped `SubscriptionEntity` immediately.
  - [ ] Provide a `Future<SubscriptionEntity?> seed()` method for repositories needing synchronous reads during boot.

### 4. Failure messages degraded in app layer
- **Evidence**: `PremiumRemoteDataSourceImpl` converts `core.Failure` into `ServerFailure(coreFailure.toString())`, losing the original `message`.
- **Impact**: UI shows `Instance of 'SubscriptionPaymentFailure'` instead of localized strings.
- **Actions**:
  - [ ] Pass through `coreFailure.message` and `code` when wrapping failures.
  - [ ] Extend `_mapFailure` in `PremiumRepositoryImpl` with explicit `switch` on concrete failure types instead of string `runtimeType` matching.

### 5. Trial eligibility bypassed
- **Evidence**: `PremiumRemoteDataSourceImpl.isEligibleForTrial()` simply negates `hasActiveSubscription()`.
- **Impact**: Ignores RevenueCat eligibility (e.g., user already consumed introductory offer on another platform).
- **Actions**:
  - [ ] Invoke `subscriptionRepository.isEligibleForTrial(productId: …)` with Gasometer catalog IDs.
  - [ ] Surface trial status to `PremiumNotifier` for accurate UI messaging.

### 6. Incorrect userId mapping inside RevenueCatService
- **Evidence**: `_mapEntitlementToSubscription` sets `userId` to `entitlement.originalPurchaseDate.toString()`.
- **Impact**: Stored `SubscriptionEntity.userId` becomes meaningless, preventing analytics or conflict resolution by user.
- **Actions**:
  - [ ] Pass `CustomerInfo.originalAppUserId` into the mapper and persist it as the `userId`.
  - [ ] Backfill Firebase documents (`user_subscriptions`/`premium_cache`) during next sync to repair existing records.

### 7. Environment key loader is a stub
- **Evidence**: `EnvironmentConfig.getApiKey` ignores `keyName` and returns the fallback/dummy values.
- **Impact**: Production builds risk using placeholder RevenueCat keys unless overridden manually.
- **Actions**:
  - [ ] Implement secure retrieval (e.g., `const String.fromEnvironment`, platform channels, or injected `.env`) and assert when keys are missing.
  - [ ] Update `GasometerEnvironmentConfig.revenueCatApiKey` to feed the resolved key into RevenueCat initialization instead of a hard-coded fallback.

### 8. Product metadata loss
- **Evidence**: `_mapStoreProductToProductInfo` discards `introPrice`, `freeTrialPeriod`, and `discounts` although `ProductInfo` models them.
- **Impact**: Paywall cannot communicate promotions or trials accurately.
- **Actions**:
  - [ ] Populate `introPrice`, `freeTrialPeriod`, and `subscriptionPeriod` using `Package.storeProduct` data.
  - [ ] Update UI widgets (`premium_products_list.dart`) to surface the additional fields once available.

### 9. Web / unsupported platforms fallback
- **Evidence**: On web, `_ensureInitialized()` throws `NOT_AVAILABLE`, but callers do not guard operations.
- **Impact**: Web builds crash instead of gracefully disabling purchases.
- **Actions**:
  - [ ] Gate premium flows behind `Platform.isIOS/Android` (or inject capability via `EnvironmentConfig`).
  - [ ] Expose a stub `ISubscriptionRepository` for web/tests returning feature flags without throwing.

## Suggested Test Coverage
- Unit test for `PremiumRemoteDataSource.purchaseProduct` mocking `ISubscriptionRepository` to ensure failure messages propagate.
- Integration test (widget or service-level) simulating `CustomerInfo` updates to verify initial sync and stream emissions.
- Contract test for `EnvironmentConfig.getProductId`/`RevenueCatService.getGasometerProducts` alignment.

## Next Steps for Follow-up Agents
| Priority | Task | Owner Hint | Dependencies |
| --- | --- | --- | --- |
| 🔴 | Align product IDs and add regression test for offerings | Core + Gasometer app | Confirm RevenueCat catalog naming |
| 🔴 | Call `PremiumRepository.setUser` on login/logout, ensure `Purchases.logOut()` on sign-out | App auth team | Auth notifier hooks |
| 🟠 | Emit initial subscription snapshot after configuration | Core subscriptions team | Access to `Purchases` API |
| 🟠 | Preserve `Failure.message` through repository/data layers | App premium team | Refactor error adapters |
| 🟡 | Implement real environment key loader and assert on missing keys | Platform infra | Deployment secrets strategy |
| 🟡 | Fill `ProductInfo` with intro/trial metadata and update paywall UI | App premium team | Depends on #1 |
| 🟡 | Provide web-safe subscription repository stub | Core subscriptions team | Platform detection utility |

> ✅ Deliverable: Share this report with the squad, align on ownership, then create dedicated tickets referencing the sections above.
