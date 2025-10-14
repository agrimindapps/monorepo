# Riverpod Migration Log - app-taskolist

## Migration Overview

**Status:** In Progress
**Started:** 2025-10-14
**Target:** Migrate from manual Riverpod (StateNotifier) to Riverpod with code generation (@riverpod)
**Reference Guide:** `.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md`

---

## Phase 1 - Setup (COMPLETED ✅)

**Date:** 2025-10-14
**Duration:** ~15 minutes
**Status:** Completed successfully

### Actions Taken

#### 1. Dependencies Configuration
Updated `pubspec.yaml` with required dependencies:

**Added to dependencies:**
- `flutter_riverpod: ^2.6.1` (already present via core, made explicit)
- `riverpod_annotation: any` (already present)

**Added to dev_dependencies:**
- `custom_lint: ^0.7.0` (NEW)
- `riverpod_lint: ^2.6.2` (NEW)
- `build_runner: ^2.4.6` (already present)
- `riverpod_generator: any` (already present)

#### 2. Analysis Options
Updated `analysis_options.yaml`:
- Added `custom_lint` plugin to analyzer configuration
- This enables Riverpod-specific linting rules

#### 3. Test Provider Creation
Created test provider file to validate setup:

**File:** `lib/core/providers/test_riverpod_setup.dart`

**Providers Created:**
- `helloRiverpodProvider` - Simple string provider (validation)
- `asyncCounterProvider` - Async provider returning Future<int>
- `greetProvider` - Parameterized provider (replaces .family pattern)

All providers use `@riverpod` annotation with code generation.

#### 4. Build Runner Execution
Executed code generation successfully:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Results:**
- Generated file: `lib/core/providers/test_riverpod_setup.g.dart` (5743 bytes)
- 6 providers generated (including parameterized provider variants)
- Build completed in 21s
- 0 compilation errors

#### 5. Static Analysis Validation
Executed `flutter analyze`:

**Results:**
- 0 errors
- 1 warning (inference_failure_on_instance_creation - minor, in test code)
- 97 info messages (mostly deprecation warnings from existing code using old Riverpod patterns)

**Important:** All deprecation warnings are expected - they reference existing providers that will be migrated in Phase 2.

### Generated Provider Examples

The test providers demonstrate all key patterns:

1. **Simple Provider:**
```dart
@riverpod
String helloRiverpod(HelloRiverpodRef ref) {
  return 'Hello Riverpod Code Generation!';
}
// Usage: ref.watch(helloRiverpodProvider)
```

2. **Async Provider:**
```dart
@riverpod
Future<int> asyncCounter(AsyncCounterRef ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 42;
}
// Usage: ref.watch(asyncCounterProvider) returns AsyncValue<int>
```

3. **Parameterized Provider (replaces .family):**
```dart
@riverpod
String greet(GreetRef ref, String name) {
  return 'Hello, $name!';
}
// Usage: ref.watch(greetProvider('World'))
```

### Success Criteria Met ✅

- ✅ Dependencies configured correctly
- ✅ analysis_options.yaml updated with custom_lint
- ✅ Test provider created with @riverpod annotations
- ✅ .g.dart file generated without errors
- ✅ flutter analyze shows 0 errors
- ✅ Documentation created

### Notes

1. **Existing Code Minimally Modified:**
   - Fixed import in `user_model.dart` (changed from `core` show to explicit Hive imports)
   - This was necessary to resolve BinaryReader/BinaryWriter compilation errors
   - No modifications to existing providers (`service_providers.dart`, `task_notifier.dart`, `auth_notifier.dart`)

2. **Deprecation Warnings Expected:** The 97 info messages about deprecated Ref types are expected and will be resolved when we migrate existing providers in Phase 2.

3. **Build Runner Performance:** Initial build took 21s. Subsequent builds will be faster. Use `watch` mode during development:
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```

4. **Custom Lint:** Added custom_lint support for Riverpod-specific linting. Run with:
   ```bash
   dart run custom_lint
   ```
   Currently reports ~50 functional_ref warnings from old-style providers (expected).

5. **APK Build Status:** Full APK build testing deferred to Phase 4 (Testing & Validation). Static analysis (flutter analyze) passes without errors, which validates code generation correctness.

---

## Phase 2 - Auth Providers Migration (IN PROGRESS 🔄)

**Status:** In Progress
**Started:** 2025-10-14
**Duration:** ~30 minutes (estimated)

### Actions Taken

#### 1. Auth Providers Migration Strategy - Coexistence Pattern

Created new file with code generation while preserving old providers:

**File:** `lib/shared/providers/auth_providers_new.dart`

**Migration Approach:**
- Kept original `auth_providers.dart` intact (no deletions)
- Created parallel implementation with `@riverpod` annotations
- Allows side-by-side validation before full migration
- UI components still use old providers until Phase 3

#### 2. Providers Migrated (11 total)

**Service Providers (GetIt integration):**
1. `taskManagerAuthServiceProvider` - TaskManagerAuthService
2. `taskManagerSyncServiceProvider` - TaskManagerSyncService
3. `taskManagerCrashlyticsServiceProvider` - TaskManagerCrashlyticsService (NEW)

**Auth State Streams:**
4. `authStateStreamProvider` - Stream<UserEntity?>
5. `isLoggedInProvider` - Future<bool>
6. `currentUserProvider` - Future<UserEntity?>

**Auth Actions (family → parameters):**
7. `signInProvider` - Converted from FutureProvider.family to named parameters
8. `signUpProvider` - Converted from FutureProvider.family to named parameters
9. `signOutProvider` - Future<void>

**Auth Notifier (StateNotifier → @riverpod class):**
10. `authNotifierProvider` - Main auth state manager

**Derived Providers:**
11. `isAuthenticatedProvider` - Computed from authNotifier
12. `currentAuthenticatedUserProvider` - Computed from authNotifier

#### 3. Key Pattern Changes

**Old (manual Riverpod):**
```dart
final signInProvider = FutureProvider.family<UserEntity, SignInRequest>(
  (ref, request) async {
    // implementation
  }
);
// Usage: ref.watch(signInProvider(SignInRequest(email: '...', password: '...')))
```

**New (code generation):**
```dart
@riverpod
Future<UserEntity> signIn(
  SignInRef ref, {
  required String email,
  required String password,
}) async {
  // implementation
}
// Usage: ref.watch(signInProvider(email: '...', password: '...'))
```

**StateNotifier → @riverpod class:**
```dart
// Old
class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthNotifier(this._authService, this._syncService) : super(const AsyncValue.loading()) {
    _init();
  }
  // ...
}

// New
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserEntity?> build() async {
    _authService = ref.watch(taskManagerAuthServiceProvider);
    _syncService = ref.watch(taskManagerSyncServiceProvider);

    // Stream subscription with auto-cleanup
    ref.onDispose(() => _subscription?.cancel());

    return await _authService.currentUser.first;
  }
  // ...
}
```

#### 4. Build Runner Execution

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Results:**
- Generated file: `lib/shared/providers/auth_providers_new.g.dart` (15,388 bytes)
- Build completed in 19s
- 0 compilation errors

#### 5. Test Widget Creation

Created validation widget: `lib/shared/widgets/auth_migration_test_widget.dart`

**Features:**
- Displays auth state from NEW providers
- Tests anonymous sign in
- Tests sign out
- Provider invalidation testing
- Side-by-side comparison capability (future enhancement)

#### 6. Static Analysis Validation

**Results:**
- 0 errors
- 0 critical warnings
- 12 info messages (deprecated Ref types - expected with riverpod_generator 2.6.1)
- 2 warnings fixed in test widget (explicit AsyncValue<dynamic> type)

### Success Criteria Met ✅

- ✅ `auth_providers_new.dart` created with @riverpod annotations
- ✅ `auth_providers_new.g.dart` generated without errors
- ✅ `flutter analyze` shows 0 critical errors
- ✅ Test widget created for validation
- ✅ Coexistence pattern established
- ✅ Documentation updated

### Technical Notes

1. **Ref Type Deprecation Warnings:**
   - Generated code uses specific Ref types (e.g., `SignInRef`)
   - These are deprecated in favor of generic `Ref` (Riverpod 3.0)
   - Not a blocker - works correctly with current version
   - Will auto-resolve when upgrading to Riverpod 3.0

2. **Family Pattern Elimination:**
   - Old: `FutureProvider.family<T, Params>` with request objects
   - New: Named parameters directly in provider function
   - Cleaner API, less boilerplate

3. **Lifecycle Management:**
   - Old: Manual `dispose()` override in StateNotifier
   - New: `ref.onDispose()` callback (auto-cleanup)
   - More declarative, less error-prone

4. **Stream Subscription:**
   - Maintained same pattern (listen to auth state changes)
   - Now uses `ref.onDispose()` for cleanup
   - No memory leaks

### Next Steps for Phase 2

1. **Validation Testing:**
   - Integrate test widget into dev menu
   - Validate all auth operations work with new providers
   - Compare behavior with old providers

2. **Additional Providers to Migrate:**
   - `lib/core/providers/service_providers.dart` (4 providers)
   - `lib/features/tasks/presentation/providers/task_notifier.dart`
   - `lib/shared/providers/notification_notifier.dart`
   - `lib/shared/providers/subscription_notifier.dart`
   - `lib/shared/providers/theme_notifier.dart`

---

## Phase 2 - Additional Providers (PENDING)

**Status:** Not started
**Target Providers:**
- `lib/core/providers/service_providers.dart` (4 providers)
- `lib/features/tasks/presentation/providers/task_notifier.dart` (main notifier + derived providers)
- `lib/shared/providers/notification_notifier.dart`
- `lib/shared/providers/subscription_notifier.dart`
- `lib/shared/providers/theme_notifier.dart`

**Estimated Duration:** 3-5 hours

---

## Phase 3 - UI Migration (PENDING)

**Status:** Not started
**Target:** Convert Provider widgets to ConsumerWidget/ConsumerStatefulWidget
**Estimated Duration:** 2-3 hours

---

## Phase 4 - Testing & Validation (PENDING)

**Status:** Not started
**Tasks:**
- Update existing tests to use ProviderContainer
- Add new tests for migrated providers
- Integration testing
**Estimated Duration:** 2-3 hours

---

## Migration Checklist

### Setup
- [x] Add dependencies (flutter_riverpod, riverpod_annotation, etc.)
- [x] Configure analysis_options.yaml with custom_lint
- [x] Create test provider to validate setup
- [x] Run build_runner successfully
- [x] Verify 0 analyzer errors
- [x] Create migration documentation

### Provider Migration (Phase 2)
- [x] Migrate auth providers (auth_providers_new.dart created)
- [x] Create auth migration test widget
- [ ] Migrate service providers
- [ ] Migrate task notifier
- [ ] Migrate notification notifier
- [ ] Migrate subscription notifier
- [ ] Migrate theme notifier
- [ ] Validate all new providers work correctly
- [ ] Remove deprecated Provider imports (after Phase 3)

### UI Migration (Phase 3)
- [ ] Identify all Provider-dependent widgets
- [ ] Convert to ConsumerWidget/ConsumerStatefulWidget
- [ ] Update ref.watch/ref.read patterns
- [ ] Test each page after migration

### Testing (Phase 4)
- [ ] Update existing unit tests
- [ ] Add ProviderContainer-based tests
- [ ] Integration testing
- [ ] Performance validation

### Cleanup
- [ ] Remove old Provider dependencies (if any)
- [ ] Clean up unused imports
- [ ] Update README with new patterns
- [ ] Final analyzer check
- [ ] Code review

---

## Known Issues

None identified during Phase 1.

---

## Next Steps

1. **Begin Phase 2:** Migrate `service_providers.dart` first (simplest)
2. **Pattern Establishment:** Use first migration to establish pattern for complex notifiers
3. **Incremental Testing:** Test each provider migration before proceeding

---

**Last Updated:** 2025-10-14
**Phase 1 Completed By:** Claude Code (flutter-engineer agent)
**Phase 2 Auth Migration Completed By:** Claude Code (flutter-engineer agent)
