# GetIt → Riverpod Migration Status

## Current Situation (2025-11-21)

### ✅ Completed
- Removed all GetIt/Injectable from `packages/core`
- Deleted: `injection.config.dart`, `injection.dart`, `advanced_subscription_module.dart`, `external_module.dart`, `core_package_integration.dart`
- Removed 27 `@injectable` and `@lazySingleton` annotations
- Created Riverpod providers structure (`providers_setup.dart` with 70+ providers)

### ⚠️ In Progress
- **226+ references to `di.sl`** still exist in 36 files
- Temporary service locator bridge in `injection_container.dart` for backward compatibility
- Main.dart still uses GetIt pattern

### ❌ Issues
- Build not yet fully clean (working on provider generation)
- Some files broken by incomplete Riverpod migration
- Need to stabilize before continuing migration

---

## Recommended Path Forward

### Phase A: Stabilization (1-2 hours)
1. **Restore working state**
   - Ensure `injection_container.dart` has functional service locator
   - Revert broken Riverpod conversions in main.dart
   - Get flutter analyze to 0 critical errors

2. **Verify compilation**
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   ```

### Phase B: Gradual Migration (2-4 weeks)
1. **Define priority services** (migrate top 10 services first):
   - `ReceituagroDatabase`
   - `PragasRepository`, `FitossanitariosRepository`, `CulturasRepository`
   - `ReceitaAgroPremiumService`
   - Analytics, Notifications, RemoteConfig

2. **For each service**:
   - Create `@riverpod` provider in `providers_setup.dart`
   - Run code generation
   - Update consumers (notifiers/widgets) to use `ref.watch(serviceProvider)`
   - Verify tests pass
   - Update main.dart to use provider

3. **Update UI layer**:
   - Convert `StatelessWidget` → `ConsumerWidget`
   - Convert `StateNotifier` → `@riverpod` functions
   - Replace `di.sl<T>()` with `ref.watch(tProvider)`

### Phase C: Cleanup (1 week)
1. Migrate remaining 226 references
2. Remove `injection_container.dart` bridge
3. Remove GetIt from pubspec.yaml entirely
4. Verify 0 warnings

---

## Key Files

| File | Status | Action |
|------|--------|--------|
| `lib/core/di/injection_container.dart` | ⚠️ Temp | Keep for compatibility |
| `lib/core/di/providers_setup.dart` | ⚠️ Broken | Fix/regenerate |
| `lib/main.dart` | ⚠️ Broken | Revert to working version |
| `lib/core/di/modules/*.dart` | ✅ Deleted | Don't recreate |

---

## Service Count by Migration Stage

- **Not Started**: 200+ services
- **Partially Migrated**: 26 (data loaders, extensions, etc.)
- **Tests Only**: Unknown

---

## Next Command

```bash
# 1. Stabilize current state
git stash  # Save changes
git checkout -- .  # Revert to last working state
flutter analyze  # Should show ~1000 issues (tests only, no GetIt errors)

# 2. OR: Fix incrementally
flutter analyze | grep "undefined identifier" | wc -l  # Count undefined refs
# Then manually fix providers_setup.dart and main.dart
```

---

## Migration Effort Estimate

- **Stabilization**: 1-2 hours
- **Phase A-C complete**: 3-4 weeks
- **Total team effort**: ~100-150 hours for complete migration

---

**Generated**: 2025-11-21
**Status**: Requires stabilization before continuing
