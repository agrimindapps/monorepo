# Services Audit - Action Plan
**Quick Reference Guide for Implementation**

## Phase 1: Cleanup (Week 1) - 20 hours

### 1.1 Delete Unused Services (30 minutes)

#### Gasometer - Delete 3 files
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-gasometer

# Verify no usage (should return 0)
grep -r "startup_sync_service" lib/ || echo "✓ Safe to delete"
grep -r "gasometer_firebase_service" lib/ || echo "✓ Safe to delete"
grep -r "gasometer_notification_service" lib/ || echo "✓ Safe to delete"

# Delete files
rm lib/core/services/startup_sync_service.dart
rm lib/core/services/gasometer_firebase_service.dart
rm lib/core/services/gasometer_notification_service.dart
```

#### Plantis - Delete 3 files
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-plantis

# Verify no usage
grep -r "plantis_notification_service_legacy" lib/ || echo "✓ Safe to delete"
grep -r "auth_security_service" lib/ || echo "✓ Safe to delete"
grep -r "encrypted_hive_service" lib/ || echo "✓ Safe to delete"

# Delete files
rm lib/core/services/plantis_notification_service_legacy.dart
rm lib/core/services/auth_security_service.dart
rm lib/core/services/encrypted_hive_service.dart
```

**Commit:**
```bash
git add .
git commit -m "chore: Remove 6 unused service files

- Gasometer: Remove startup_sync, gasometer_firebase, gasometer_notification
- Plantis: Remove notification_legacy, auth_security, encrypted_hive

These services had 0 imports and were identified as unused in services audit."
```

### 1.2 Consolidate Gasometer Data Cleaners (2 hours)

**Goal:** Keep `data_cleaner_service.dart` (7 uses), deprecate 2 others

#### Step 1: Analyze differences
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-gasometer/lib/core/services

# Compare implementations
diff data_cleaner_service.dart gasometer_data_cleaner.dart
diff data_cleaner_service.dart gasometer_data_cleaner_service.dart
```

#### Step 2: Find all usages
```bash
# Find where gasometer_data_cleaner is used (1 usage)
grep -rn "gasometer_data_cleaner.dart" ../../../lib/

# Find where gasometer_data_cleaner_service is used (1 usage)
grep -rn "gasometer_data_cleaner_service.dart" ../../../lib/
```

#### Step 3: Migrate usages to data_cleaner_service.dart
- Update the 2 files that import the deprecated versions
- Test functionality

#### Step 4: Delete deprecated files
```bash
rm lib/core/services/gasometer_data_cleaner.dart
rm lib/core/services/gasometer_data_cleaner_service.dart
```

**Commit:**
```bash
git add .
git commit -m "refactor(gasometer): Consolidate data cleaner services

- Migrate all usages to data_cleaner_service.dart
- Remove gasometer_data_cleaner.dart
- Remove gasometer_data_cleaner_service.dart

Reduces confusion with 3 similar services, keeps most-used version."
```

### 1.3 Consolidate Plantis Notifications (8 hours)

**Goal:** Merge features into single enhanced service

#### Step 1: Analyze all 4 versions
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-plantis/lib/core/services

# Main version (12 uses)
wc -l plantis_notification_service.dart

# Enhanced version (2 uses)
wc -l enhanced_plantis_notification_service.dart

# V2 version (1 use)
wc -l plantis_notification_service_v2.dart

# Legacy (0 uses - already deleted in 1.1)
```

#### Step 2: Identify unique features in each
- Read each file
- Document unique features
- Create unified feature list

#### Step 3: Create consolidated version
- Start with main service (12 uses)
- Add features from enhanced version
- Add features from v2 if valuable
- Maintain backward compatibility

#### Step 4: Update all import statements
```bash
# Find all usages
grep -rn "enhanced_plantis_notification_service" ../../../lib/
grep -rn "plantis_notification_service_v2" ../../../lib/

# Update imports to use main service
# Test each component after updating
```

#### Step 5: Delete deprecated versions
```bash
rm lib/core/services/enhanced_plantis_notification_service.dart
rm lib/core/services/plantis_notification_service_v2.dart
```

**Commit:**
```bash
git add .
git commit -m "refactor(plantis): Consolidate notification services

- Merge enhanced features into main notification service
- Merge v2 features into main notification service
- Update all 15 import locations
- Remove enhanced_plantis_notification_service.dart
- Remove plantis_notification_service_v2.dart

Single source of truth for plant notifications."
```

### 1.4 Document Canonical Services (30 minutes)

Create documentation file:

```bash
cat > apps/SERVICES_STANDARDS.md << 'EOF'
# Monorepo Services Standards

## Service Selection Guidelines

### When to Create App-Level Service
- Domain-specific business logic (fuel calculations, plant care logic, etc.)
- App-specific integrations or wrappers
- Feature unique to one app

### When to Use Core Package Service
- Generic functionality (storage, auth, analytics, etc.)
- Cross-app features (backup, sync, notifications)
- Infrastructure concerns (security, performance, logging)

## Canonical Services by App

### app-gasometer
**Keep in App:**
- Financial domain services (conflict_resolver, validator, sync)
- Receipt image handling
- Audit trail
- Gasometer analytics wrapper

**Use from Core:**
- Firebase services
- Storage services
- Image processing (base functionality)
- Navigation
- Security

### app-plantis
**Keep in App:**
- Plant care calculator
- Plant data management
- Task generation
- Plantis-specific notifications
- Backup subsystem (for now)

**Use from Core:**
- Secure storage (migrate to EnhancedSecureStorageService)
- Form validation (migrate)
- Image management (migrate)
- Firebase services

### app-petiveti
**Model app** - uses core services extensively, minimal app-level code.

## Service Naming Conventions
- App-specific: `{app_name}_{feature}_service.dart`
- Generic: `{feature}_service.dart` (should be in core)
- Wrappers: `{app_name}_{core_feature}_wrapper.dart`
EOF

git add apps/SERVICES_STANDARDS.md
git commit -m "docs: Add monorepo services standards

Guidelines for when to create app-level vs core services."
```

## Phase 2: Migration (Weeks 2-4) - 40 hours

### 2.1 Migrate Plantis secure_storage to Core (6 hours)

#### Current State
- Plantis has `lib/core/services/secure_storage_service.dart` (7 uses)
- Core has `packages/core/lib/src/infrastructure/services/enhanced_secure_storage_service.dart`
- Core version supports app-specific configs

#### Migration Steps

**Step 1: Analyze custom data classes**
```bash
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-plantis
grep -A 20 "class UserCredentials" lib/core/services/secure_storage_service.dart
grep -A 20 "class LocationData" lib/core/services/secure_storage_service.dart
grep -A 20 "class PersonalInfo" lib/core/services/secure_storage_service.dart
```

**Step 2: Create serializers in plantis**
```bash
# Create lib/core/serializers/secure_storage_serializers.dart
# Implement SecureDataSerializer for each custom class
```

**Step 3: Initialize core service**
```dart
// In app initialization
final secureStorage = EnhancedSecureStorageService(
  appIdentifier: 'app_plantis',
  config: const SecureStorageConfig.plantis(),
);
```

**Step 4: Replace all 7 usages**
```bash
# Find all usages
grep -rn "SecureStorageService.instance" lib/

# Update each one to use core service with custom serializers
```

**Step 5: Delete local implementation**
```bash
rm lib/core/services/secure_storage_service.dart
```

**Commit:**
```bash
git add .
git commit -m "refactor(plantis): Migrate to core EnhancedSecureStorageService

- Create custom serializers for UserCredentials, LocationData, PersonalInfo
- Initialize with plantis-specific config
- Update 7 usage locations
- Remove local secure_storage_service.dart

Benefits: Use enhanced core version with better error handling and flexibility."
```

### 2.2 Migrate avatar_service to Core (4 hours)

**Current Location:** `apps/app-gasometer/lib/core/services/avatar_service.dart`
**Target Location:** `packages/core/lib/src/infrastructure/services/profile_image_service.dart` (enhance existing)

#### Steps
1. Review gasometer's avatar_service implementation
2. Compare with core's existing profile_image_service
3. Enhance core service with avatar_service features
4. Update gasometer to use enhanced core service
5. Test avatar functionality

### 2.3 Migrate platform_service to Core (2 hours)

**Current Location:** `apps/app-gasometer/lib/core/services/platform_service.dart`
**Target Location:** `packages/core/lib/src/shared/services/platform_capabilities_service.dart` (new)

### 2.4 Migrate Image Services to Core (8 hours)

Consolidate these into core:
- `form_validation_service.dart` (Plantis) → enhance core validation_service
- `image_management_service.dart` (Plantis) → enhance core image services
- `image_picker_service.dart` (Gasometer) → create core image_picker_service
- `enhanced_image_cache_manager.dart` (Plantis) → enhance cache_management_service
- `image_preloader_service.dart` (Plantis) → add to core

## Phase 3: Architecture (Weeks 5-8) - 50 hours

### 3.1 Extract Plantis Backup Subsystem (16 hours)

**Goal:** Create `packages/core/lib/src/backup/` module

#### Structure
```
packages/core/lib/src/backup/
├── services/
│   ├── backup_service.dart (main orchestrator)
│   ├── backup_restore_service.dart
│   ├── backup_validation_service.dart
│   ├── backup_audit_service.dart
│   ├── backup_scheduler.dart
│   └── backup_transformer_service.dart
├── interfaces/
│   └── i_backup_service.dart
├── models/
│   └── backup_models.dart
└── core_backup.dart (barrel export)
```

#### Benefits
- Enable backup in gasometer, petiveti, other apps
- Centralized backup logic
- Easier to test and maintain

### 3.2 Refactor Gasometer Firebase Storage (4 hours)

**Current:** `apps/app-gasometer/lib/core/services/firebase_storage_service.dart`
**Target:** Extend core's FirebaseStorageService

```dart
// New approach - gasometer receipt storage wrapper
class GasometerReceiptStorageService {
  final FirebaseStorageService _coreStorage;

  // Receipt-specific methods using core service
  Future<String> uploadFuelReceipt(...) {
    return _coreStorage.uploadFile(...);
  }
}
```

### 3.3 Create Migration Guides (8 hours)

Document patterns for:
- When to create app service vs use core
- How to wrap core services
- How to extend core services
- Migration checklist

### 3.4 Service Creation Guidelines (4 hours)

Create template and checklist for new services:
- Decision tree: app vs core
- Template files
- Testing requirements
- Documentation requirements

## Verification & Testing

### After Each Phase

#### Run Tests
```bash
# Run tests for modified app
cd apps/app-gasometer && flutter test
cd apps/app-plantis && flutter test

# Run core package tests
cd packages/core && flutter test
```

#### Verify Imports
```bash
# Check for broken imports
cd apps/app-gasometer && flutter analyze
cd apps/app-plantis && flutter analyze
```

#### Check Service Usage
```bash
# Verify old services are gone
find apps/app-gasometer -name "*_service.dart" | wc -l
find apps/app-plantis -name "*_service.dart" | wc -l

# Should match target numbers
```

## Success Metrics

### Phase 1 Success
- [ ] 6 unused services deleted
- [ ] Gasometer has 1 data_cleaner instead of 3
- [ ] Plantis has 1 notification service instead of 4
- [ ] Services standards doc created
- [ ] All tests passing

### Phase 2 Success
- [ ] Plantis using core secure storage
- [ ] 5+ generic services migrated to core
- [ ] All apps still fully functional
- [ ] Improved code reuse metrics

### Phase 3 Success
- [ ] Backup subsystem available in core
- [ ] Service creation guidelines in place
- [ ] Migration documentation complete
- [ ] All apps at "Good" health score or above

## Rollback Plans

### If Phase 1 Issues
- Git revert specific commits
- Services are just deleted, easy to restore from git

### If Phase 2 Migration Issues
- Keep old service files in git history
- Can temporarily revert to app-level implementation
- Core package is versioned, can pin to previous version

### If Phase 3 Issues
- Backup subsystem is additive, doesn't break existing apps
- Can disable/not use new core features

## Communication Plan

### Before Starting
- [ ] Review audit with team
- [ ] Get stakeholder approval
- [ ] Create tracking issues in project management

### During Implementation
- [ ] Daily updates on progress
- [ ] Flag any blockers immediately
- [ ] Update documentation as you go

### After Completion
- [ ] Demo improvements to team
- [ ] Share before/after metrics
- [ ] Document lessons learned

## Tracking Issues Template

Create GitHub issues for each major task:

```markdown
## Phase 1.1: Delete Unused Services

**Estimate:** 30 minutes
**Priority:** P0

### Files to Delete
Gasometer:
- [ ] startup_sync_service.dart
- [ ] gasometer_firebase_service.dart
- [ ] gasometer_notification_service.dart

Plantis:
- [ ] plantis_notification_service_legacy.dart
- [ ] auth_security_service.dart
- [ ] encrypted_hive_service.dart

### Verification
- [ ] grep confirms 0 usages
- [ ] Tests still pass
- [ ] Apps build successfully

### Definition of Done
- [ ] All 6 files deleted
- [ ] Commit pushed
- [ ] No broken references
```

## Quick Reference Commands

### Check Service Usage
```bash
# Count imports of a service
find apps/app-plantis -name "*.dart" -exec grep -l "service_name" {} \; | wc -l

# List files that import a service
grep -r "service_name" apps/app-plantis/lib/
```

### Service Health Check
```bash
# List all services in an app
find apps/app-gasometer/lib/core/services -name "*.dart" -exec basename {} \;

# Count total services
find apps/app-gasometer/lib/core/services -name "*.dart" | wc -l
```

### Core Package Check
```bash
# List all core services
find packages/core/lib/src -name "*service*.dart" -type f

# Count core services
find packages/core/lib/src -name "*service*.dart" -type f | wc -l
```

## Resources

- **Full Audit:** `SERVICES_AUDIT_REPORT.json`
- **Executive Summary:** `SERVICES_AUDIT_EXECUTIVE_SUMMARY.md`
- **This Action Plan:** `SERVICES_AUDIT_ACTION_PLAN.md`
- **Core Package Docs:** `packages/core/README.md`
- **Service Standards:** `apps/SERVICES_STANDARDS.md` (create in Phase 1.4)
