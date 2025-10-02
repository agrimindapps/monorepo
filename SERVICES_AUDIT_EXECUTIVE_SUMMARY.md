# Services Audit - Executive Summary
**Generated:** 2025-10-02
**Scope:** Complete audit of app-level services vs packages/core
**Apps Analyzed:** app-gasometer, app-plantis, app-petiveti

## Executive Overview

### Health Scores
| App | Score | Services | Status | Technical Debt |
|-----|-------|----------|--------|----------------|
| **app-petiveti** | 9.0/10 | 2 | Excellent | Very Low |
| **app-gasometer** | 7.5/10 | 27 | Good | Medium |
| **app-plantis** | 6.0/10 | 34 | Needs Improvement | **High** |

### Critical Findings

1. **6 Unused Services** - Dead code increasing maintenance burden
2. **Plantis has 4 notification service versions** - Urgent consolidation needed
3. **Gasometer has 3 data cleaner versions** - Consolidation needed
4. **Plantis duplicates secure storage** - Should use core enhanced version
5. **Plantis has complex 7-service backup subsystem** - Candidate for core extraction

### By the Numbers

| Metric | Count |
|--------|-------|
| Total Services Analyzed | 63 |
| Completely Unused | 6 |
| Duplicated with Core | 4 |
| Migration Candidates | 11 |
| Duplicate Versions | 10 |
| App-Specific (Correct) | 26 |

## App-by-App Breakdown

### app-gasometer (27 services)

**Health:** 7.5/10 - Good with room for improvement

#### Categories
- ✅ **App-Specific (14)**: Financial domain logic - correctly kept in app
- 🔄 **Duplicated (2)**: firebase_storage_service, database_inspector_service
- 📦 **Migration Candidates (4)**: avatar, image_picker, platform, data_sanitization
- ❌ **Unused (3)**: startup_sync, gasometer_firebase, gasometer_notification
- 🔀 **Duplicate Versions (3)**: Three data_cleaner variants

#### Quick Wins
1. **Delete 3 unused services** → 30 min, Very High ROI
2. **Consolidate data cleaners** → 2 hours, High ROI
3. **Migrate avatar_service to core** → 4 hours, Medium ROI

#### Top Services by Usage
1. `input_sanitizer.dart` - 10 uses (Security critical)
2. `gasometer_analytics_service.dart` - 9 uses
3. `data_cleaner_service.dart` - 7 uses

### app-plantis (34 services)

**Health:** 6.0/10 - Needs significant improvement

#### Critical Issues
1. **Notification Chaos**: 4 versions (main, v2, legacy, enhanced)
   - `plantis_notification_service.dart` - 12 uses (current)
   - `plantis_notification_service_v2.dart` - 1 use
   - `plantis_notification_service_legacy.dart` - 0 uses ❌
   - `enhanced_plantis_notification_service.dart` - 2 uses

2. **Backup Subsystem**: 7 interconnected services
   - Could benefit entire monorepo if extracted to core
   - Services: backup, backup_refactored, restore, scheduler, validation, audit, transformer

3. **Security Duplication**:
   - `secure_storage_service.dart` (7 uses) duplicates core's enhanced version
   - Should migrate to `EnhancedSecureStorageService` with plantis config

#### Categories
- ✅ **App-Specific (10)**: Plant care logic - correctly kept
- 🔄 **Duplicated (2)**: secure_storage, data_sanitization
- 📦 **Migration Candidates (7)**: form_validation, image_management, memory_monitoring, etc.
- ❌ **Unused (3)**: notification_legacy, auth_security, encrypted_hive
- 🔧 **Complex Subsystems (7)**: Backup services
- 📱 **Notification Versions (4)**: Multiple notification implementations

#### Quick Wins
1. **Delete 3 unused services** → 30 min, Very High ROI
2. **Migrate secure_storage to core** → 6 hours, High ROI
3. **Consolidate notification services** → 8 hours, **Very High ROI**

#### Top Services by Usage
1. `plantis_notification_service.dart` - 12 uses
2. `secure_storage_service.dart` - 7 uses
3. `backup_service.dart` - 6 uses

### app-petiveti (2 services)

**Health:** 9.0/10 - Excellent, target state

#### Categories
- ✅ **App-Specific (1)**: petiveti_data_cleaner (0 uses - investigate)
- 🔌 **Integration (1)**: core_services_integration (0 uses - investigate)

#### Observation
Petiveti demonstrates **best practices** for core package integration:
- Minimal app-level services
- Maximum reuse of core functionality
- Clean separation of concerns

**This is the target state for other apps.**

## Strategic Recommendations

### Phase 1: Cleanup (1 week, 20 hours)

**Priority: P0 - Immediate**

1. Delete 6 unused services across apps
2. Consolidate Gasometer data cleaners (3 → 1)
3. Consolidate Plantis notifications (4 → 1)
4. Document canonical service versions

**Impact:** Immediate technical debt reduction, clearer codebase

### Phase 2: Migration (2-3 weeks, 40 hours)

**Priority: P1 - High**

1. Migrate Plantis `secure_storage_service` to core (7 usages)
2. Migrate `avatar_service` to core
3. Migrate `platform_service` to core
4. Migrate image-related services to core
5. Test cross-app compatibility

**Impact:** Increased code reuse, consistent behavior across apps

### Phase 3: Architecture (3-4 weeks, 50 hours)

**Priority: P2 - Medium**

1. Extract Plantis backup subsystem to core
2. Refactor Gasometer firebase_storage to use core
3. Create migration guides
4. Establish service creation guidelines

**Impact:** Enable backup across all apps, architectural improvements

## ROI Analysis

### Quick Wins (Phase 1)
- **Effort:** 17.5 hours
- **Impact:** Very High
- **ROI:** Excellent

### Medium Term (Phase 2 + 3)
- **Effort:** 90 hours
- **Impact:** High
- **ROI:** Good

### Projected Savings
- **~80 hours** over next 6 months from reduced maintenance
- **Faster feature development** through code reuse
- **Better quality** through centralized testing

## Core Package Integration Analysis

### Current State
- **Gasometer:** Medium integration - uses some core, has duplications
- **Plantis:** Low integration - minimal core usage, many local implementations
- **Petiveti:** Excellent integration - proper core leverage

### Target State
All apps should follow **Petiveti model**:
- Minimal app-level services (only domain-specific logic)
- Maximum core package reuse
- Consistent patterns across monorepo

### Benefits of Target State
1. Faster feature development
2. Consistent behavior across apps
3. Easier maintenance and updates
4. Better test coverage (test once in core)
5. Reduced technical debt

## Migration Path

```
Step 1: Identify and delete unused services ✓
  ↓
Step 2: Consolidate duplicate versions within each app
  ↓
Step 3: Migrate generic services to core
  ↓
Step 4: Refactor app services to extend/wrap core services
  ↓
Step 5: Document patterns and guidelines
```

## Detailed Service Lists

### Services to DELETE (6 total)

#### Gasometer (3)
- `startup_sync_service.dart` - 0 uses
- `gasometer_firebase_service.dart` - 0 uses
- `gasometer_notification_service.dart` - 0 uses

#### Plantis (3)
- `plantis_notification_service_legacy.dart` - 0 uses
- `auth_security_service.dart` - 0 uses
- `encrypted_hive_service.dart` - 0 uses

### Services to CONSOLIDATE

#### Gasometer Data Cleaners (keep `data_cleaner_service.dart`)
- ✅ `data_cleaner_service.dart` - 7 uses (KEEP)
- ❌ `gasometer_data_cleaner.dart` - 1 use (DEPRECATE)
- ❌ `gasometer_data_cleaner_service.dart` - 1 use (DEPRECATE)

#### Plantis Notifications (keep enhanced version)
- ✅ `plantis_notification_service.dart` - 12 uses (ENHANCE and KEEP)
- 🔄 `enhanced_plantis_notification_service.dart` - 2 uses (MERGE features)
- 🔄 `plantis_notification_service_v2.dart` - 1 use (MERGE or DEPRECATE)
- ❌ `plantis_notification_service_legacy.dart` - 0 uses (DELETE)

### Services to MIGRATE to Core (11 total)

#### High Priority (5)
1. `secure_storage_service.dart` (Plantis) - 7 uses
2. `avatar_service.dart` (Gasometer) - 2 uses
3. `platform_service.dart` (Gasometer) - 3 uses
4. `form_validation_service.dart` (Plantis) - 3 uses
5. `image_management_service.dart` (Plantis) - 3 uses

#### Medium Priority (6)
6. `image_picker_service.dart` (Gasometer) - 1 use
7. `enhanced_image_cache_manager.dart` (Plantis) - 1 use
8. `image_preloader_service.dart` (Plantis) - 2 uses
9. `memory_monitoring_service.dart` (Plantis) - 1 use
10. `url_launcher_service.dart` (Plantis) - 1 use
11. `data_sanitization_service.dart` (Gasometer) - 1 use

### Plantis Backup Subsystem (Consider for Core)

Complex subsystem of 7 interconnected services:
1. `backup_service.dart` - 6 uses
2. `backup_restore_service.dart` - 5 uses
3. `backup_validation_service.dart` - 4 uses
4. `backup_audit_service.dart` - 4 uses
5. `backup_data_transformer_service.dart` - 4 uses
6. `backup_scheduler.dart` - 1 use
7. `backup_service_refactored.dart` - 1 use (consolidate with #1)

**Recommendation:** Extract to `packages/core/lib/src/backup/` to enable backup across all apps.

## Service Usage Heatmap

### Gasometer Top 10
1. `input_sanitizer.dart` - 10 uses 🔥
2. `gasometer_analytics_service.dart` - 9 uses 🔥
3. `data_cleaner_service.dart` - 7 uses
4. `local_data_service.dart` - 4 uses
5. `receipt_image_service.dart` - 4 uses
6. `audit_trail_service.dart` - 3 uses
7. `auth_rate_limiter.dart` - 3 uses
8. `database_inspector_service.dart` - 3 uses
9. `financial_conflict_resolver.dart` - 3 uses
10. `financial_sync_service.dart` - 3 uses

### Plantis Top 10
1. `plantis_notification_service.dart` - 12 uses 🔥🔥
2. `secure_storage_service.dart` - 7 uses 🔥
3. `backup_service.dart` - 6 uses
4. `backup_restore_service.dart` - 5 uses
5. `data_sanitization_service.dart` - 4 uses
6. `plants_care_calculator.dart` - 4 uses
7. `plants_data_service.dart` - 4 uses
8. `plants_filter_service.dart` - 4 uses
9. `task_notification_service.dart` - 4 uses
10. `backup_validation_service.dart` - 4 uses

## Next Steps

### Immediate Actions (This Week)
1. Review this audit with team
2. Get approval for Phase 1 cleanup
3. Create issues for deletion of 6 unused services
4. Start consolidation of duplicate versions

### Short Term (Next 2 Weeks)
1. Execute Phase 1 cleanup
2. Begin Phase 2 migrations (start with secure_storage)
3. Document migration patterns

### Medium Term (Next Month)
1. Complete Phase 2 migrations
2. Begin Phase 3 architectural improvements
3. Create service creation guidelines

### Long Term (Next Quarter)
1. Complete all phases
2. Achieve Petiveti-level integration for all apps
3. Establish monorepo service governance

---

## Appendix: Core Package Services Available

packages/core provides 67+ services including:

**Firebase Services:**
- firebase_auth_service, enhanced_firebase_auth_service
- firebase_analytics_service, enhanced_analytics_service
- firebase_crashlytics_service
- firebase_storage_service
- firebase_device_service

**Storage Services:**
- hive_storage_service, core_hive_storage_service
- enhanced_encrypted_storage_service
- enhanced_secure_storage_service
- enhanced_storage_service

**Image Services:**
- image_service
- enhanced_image_service
- enhanced_image_service_unified
- profile_image_service
- optimized_image_service

**Sync Services (Per-App):**
- gasometer_sync_service
- plantis_sync_service
- petiveti_sync_service
- receituagro_sync_service
- taskolist_sync_service
- agrihurbi_sync_service

**Other Services:**
- navigation_service, enhanced_navigation_service
- local_notification_service, enhanced_notification_service
- connectivity_service, enhanced_connectivity_service
- validation_service
- security_service, enhanced_security_service
- performance_service
- database_inspector_service
- device_management_service
- account_deletion_service, enhanced_account_deletion_service
- revenue_cat_service
- And many more...

**Apps should prioritize using core services before creating app-level implementations.**
