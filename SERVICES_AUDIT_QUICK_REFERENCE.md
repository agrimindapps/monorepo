# Services Audit - Quick Reference Tables

## Summary Dashboard

| Metric | app-gasometer | app-plantis | app-petiveti | Total |
|--------|---------------|-------------|--------------|-------|
| **Total Services** | 27 | 34 | 2 | 63 |
| **Health Score** | 7.5/10 | 6.0/10 | 9.0/10 | - |
| **Unused (Delete)** | 3 | 3 | 0 | **6** |
| **Duplicated** | 2 | 2 | 0 | **4** |
| **Migration Candidates** | 4 | 7 | 0 | **11** |
| **Duplicate Versions** | 3 | 7 | 0 | **10** |
| **App-Specific (Keep)** | 14 | 10 | 1 | 25 |

## All Services by Category

### app-gasometer (27 services)

| Service File | Usage | Category | Action | Priority | Effort |
|--------------|-------|----------|--------|----------|--------|
| input_sanitizer.dart | 10 | App-Specific | ✅ KEEP | - | - |
| gasometer_analytics_service.dart | 9 | App-Specific | ✅ KEEP | - | - |
| data_cleaner_service.dart | 7 | Duplicate | 🔄 CONSOLIDATE (keep this) | P1 | 2h |
| local_data_service.dart | 4 | App-Specific | ✅ KEEP | - | - |
| receipt_image_service.dart | 4 | App-Specific | ✅ KEEP | - | - |
| audit_trail_service.dart | 3 | App-Specific | ✅ KEEP | - | - |
| auth_rate_limiter.dart | 3 | App-Specific | ✅ KEEP | - | - |
| database_inspector_service.dart | 3 | Wrapper | ✅ KEEP (wraps core) | - | - |
| financial_conflict_resolver.dart | 3 | App-Specific | ✅ KEEP | - | - |
| financial_sync_service.dart | 3 | App-Specific | ✅ KEEP | - | - |
| financial_validator.dart | 3 | App-Specific | ✅ KEEP | - | - |
| platform_service.dart | 3 | Migration | 📦 MIGRATE to core | P2 | 2h |
| avatar_service.dart | 2 | Migration | 📦 MIGRATE to core | P1 | 4h |
| unified_validators.dart | 2 | App-Specific | ✅ KEEP | - | - |
| data_generator_service.dart | 1 | Test Util | 🧪 Move to test/ | P3 | 0.5h |
| data_sanitization_service.dart | 1 | Migration | 📦 MIGRATE to core | P2 | 3h |
| firebase_storage_service.dart | 1 | Duplicated | 🔄 REFACTOR (use core) | P2 | 2h |
| gasometer_data_cleaner.dart | 1 | Duplicate | ❌ DELETE (use data_cleaner) | P1 | 1h |
| gasometer_data_cleaner_service.dart | 1 | Duplicate | ❌ DELETE (use data_cleaner) | P1 | 1h |
| image_picker_service.dart | 1 | Migration | 📦 MIGRATE to core | P2 | 2h |
| unified_formatters.dart | 1 | App-Specific | ✅ KEEP | - | - |
| expense_business_service.dart | 0 | Unused | ❓ INVESTIGATE | P1 | 0.5h |
| financial_core.dart | 0 | Unused | ❓ INVESTIGATE | P1 | 0.5h |
| fuel_business_service.dart | 0 | Unused | ❓ INVESTIGATE | P1 | 0.5h |
| gasometer_firebase_service.dart | 0 | Unused | ❌ DELETE | P0 | 0.5h |
| gasometer_notification_service.dart | 0 | Unused | ❌ DELETE | P0 | 0.5h |
| startup_sync_service.dart | 0 | Unused | ❌ DELETE | P0 | 0.5h |

**Summary:**
- ✅ Keep: 14 services (app-specific business logic)
- ❌ Delete: 3 services (0 usage)
- 🔄 Consolidate: 3 services (duplicates)
- 📦 Migrate: 4 services (generic functionality)
- ❓ Investigate: 3 services (0 usage, might be in dev)

### app-plantis (34 services)

| Service File | Usage | Category | Action | Priority | Effort |
|--------------|-------|----------|--------|----------|--------|
| **Notifications (4 versions)** |
| plantis_notification_service.dart | 12 | Active | ✅ KEEP (consolidate into) | - | - |
| enhanced_plantis_notification_service.dart | 2 | Enhanced | 🔄 MERGE features | P1 | 8h |
| plantis_notification_service_v2.dart | 1 | Version | 🔄 MERGE or deprecate | P1 | (incl) |
| plantis_notification_service_legacy.dart | 0 | Legacy | ❌ DELETE | P0 | 0.5h |
| **Backup Subsystem (7 services)** |
| backup_service.dart | 6 | Subsystem | 🏗️ EXTRACT to core | P2 | 16h |
| backup_restore_service.dart | 5 | Subsystem | 🏗️ (with backup) | P2 | (incl) |
| backup_validation_service.dart | 4 | Subsystem | 🏗️ (with backup) | P2 | (incl) |
| backup_audit_service.dart | 4 | Subsystem | 🏗️ (with backup) | P2 | (incl) |
| backup_data_transformer_service.dart | 4 | Subsystem | 🏗️ (with backup) | P2 | (incl) |
| backup_scheduler.dart | 1 | Subsystem | 🏗️ (with backup) | P2 | (incl) |
| backup_service_refactored.dart | 1 | Duplicate | 🔄 CONSOLIDATE | P1 | (incl) |
| **Storage Services** |
| secure_storage_service.dart | 7 | Duplicated | 🔄 MIGRATE to core | P1 | 6h |
| **App-Specific Services** |
| plants_care_calculator.dart | 4 | App-Specific | ✅ KEEP | - | - |
| plants_data_service.dart | 4 | App-Specific | ✅ KEEP | - | - |
| plants_filter_service.dart | 4 | App-Specific | ✅ KEEP | - | - |
| data_sanitization_service.dart | 4 | Duplicated | 🔄 Use core validation | P2 | 3h |
| task_notification_service.dart | 4 | App-Specific | ✅ KEEP | - | - |
| **Migration Candidates** |
| form_validation_service.dart | 3 | Migration | 📦 MIGRATE to core | P2 | 3h |
| image_management_service.dart | 3 | Migration | 📦 MIGRATE to core | P2 | 4h |
| notification_manager.dart | 3 | App-Specific | ✅ KEEP | - | - |
| task_generation_service.dart | 3 | App-Specific | ✅ KEEP | - | - |
| **Sync Services** |
| background_sync_service.dart | 2 | App-Specific | ✅ KEEP | - | - |
| conflict_history_service.dart | 2 | App-Specific | ✅ KEEP | - | - |
| data_cleaner_service.dart | 2 | Migration | 📦 MIGRATE to core | P2 | 2h |
| image_preloader_service.dart | 2 | Migration | 📦 MIGRATE to core | P2 | 2h |
| offline_sync_queue_service.dart | 2 | App-Specific | ✅ KEEP | - | - |
| plantis_notification_config.dart | 2 | App-Specific | ✅ KEEP | - | - |
| sync_coordinator_service.dart | 2 | App-Specific | ✅ KEEP | - | - |
| **Other** |
| enhanced_image_cache_manager.dart | 1 | Migration | 📦 MIGRATE to core | P2 | 3h |
| memory_monitoring_service.dart | 1 | Migration | 📦 MIGRATE to core | P2 | 2h |
| plantis_realtime_service.dart | 1 | App-Specific | ✅ KEEP | - | - |
| url_launcher_service.dart | 1 | Migration | 📦 MIGRATE to core | P2 | 1h |
| **Unused** |
| auth_security_service.dart | 0 | Unused | ❌ DELETE | P0 | 0.5h |
| encrypted_hive_service.dart | 0 | Unused | ❌ DELETE | P0 | 0.5h |

**Summary:**
- ✅ Keep: 10 services (app-specific)
- ❌ Delete: 3 services (0 usage)
- 🔄 Consolidate: 4 notification versions → 1
- 🔄 Migrate duplicates: 2 services
- 📦 Migrate generics: 7 services
- 🏗️ Extract subsystem: 7 backup services

### app-petiveti (2 services)

| Service File | Usage | Category | Action | Priority | Effort |
|--------------|-------|----------|--------|----------|--------|
| petiveti_data_cleaner.dart | 0 | App-Specific | ❓ INVESTIGATE | P1 | 0.5h |
| core_services_integration.dart | 0 | Integration | ❓ INVESTIGATE | P1 | 0.5h |

**Summary:**
- ✅ Best practices - minimal app services, maximum core usage
- ❓ Both services have 0 usage - investigate if needed

## Priority Actions

### P0 - Immediate (This Week)

| Action | Apps | Files | Effort | Impact |
|--------|------|-------|--------|--------|
| Delete unused services | Gasometer (3), Plantis (3) | 6 | 30 min | Very High |

**Files to Delete:**
- gasometer: startup_sync_service, gasometer_firebase_service, gasometer_notification_service
- plantis: notification_legacy, auth_security_service, encrypted_hive_service

### P1 - High Priority (Next 2 Weeks)

| Action | Apps | Files | Effort | Impact |
|--------|------|-------|--------|--------|
| Consolidate Gasometer data cleaners | Gasometer | 3 → 1 | 2h | High |
| Consolidate Plantis notifications | Plantis | 4 → 1 | 8h | Very High |
| Migrate secure_storage to core | Plantis | 1 | 6h | High |
| Migrate avatar_service to core | Gasometer | 1 | 4h | Medium |

**Total Effort:** ~20 hours
**Total Impact:** Very High

### P2 - Medium Priority (Next Month)

| Action | Apps | Files | Effort | Impact |
|--------|------|-------|--------|--------|
| Migrate platform_service | Gasometer | 1 | 2h | Low |
| Migrate image services | Both | 5 | 12h | Medium |
| Migrate form_validation | Plantis | 1 | 3h | Low |
| Migrate utility services | Both | 4 | 8h | Low |
| Extract backup subsystem | Plantis | 7 | 16h | High |
| Refactor firebase_storage | Gasometer | 1 | 2h | Low |

**Total Effort:** ~43 hours
**Total Impact:** Medium-High

### P3 - Low Priority (Future)

| Action | Apps | Files | Effort | Impact |
|--------|------|-------|--------|--------|
| Move test utilities | Gasometer | 1 | 0.5h | Low |
| Investigate 0-usage services | Gasometer (3), Petiveti (2) | 5 | 2.5h | Low |

## Migration Candidates Summary

| Service | Current App | Usage | Target Core Location | Effort | Priority |
|---------|-------------|-------|---------------------|--------|----------|
| secure_storage_service | Plantis | 7 | enhanced_secure_storage_service | 6h | P1 |
| avatar_service | Gasometer | 2 | profile_image_service (enhance) | 4h | P1 |
| image_management_service | Plantis | 3 | image services (enhance) | 4h | P2 |
| form_validation_service | Plantis | 3 | validation_service (enhance) | 3h | P2 |
| platform_service | Gasometer | 3 | platform_capabilities_service (new) | 2h | P2 |
| enhanced_image_cache_manager | Plantis | 1 | cache_management_service | 3h | P2 |
| image_preloader_service | Plantis | 2 | image services (new feature) | 2h | P2 |
| memory_monitoring_service | Plantis | 1 | performance_service (enhance) | 2h | P2 |
| image_picker_service | Gasometer | 1 | image_picker_service (new) | 2h | P2 |
| data_cleaner_service | Plantis | 2 | data_cleaner_service (new) | 2h | P2 |
| url_launcher_service | Plantis | 1 | url_launcher_service (new) | 1h | P2 |

**Total Migration Effort:** ~31 hours
**Total Services:** 11

## Consolidation Summary

### Gasometer Data Cleaners
- **Keep:** data_cleaner_service.dart (7 uses)
- **Delete:** gasometer_data_cleaner.dart (1 use)
- **Delete:** gasometer_data_cleaner_service.dart (1 use)
- **Effort:** 2 hours

### Plantis Notifications
- **Keep:** plantis_notification_service.dart (12 uses) - enhance with features from others
- **Merge:** enhanced_plantis_notification_service.dart (2 uses)
- **Merge:** plantis_notification_service_v2.dart (1 use)
- **Delete:** plantis_notification_service_legacy.dart (0 uses)
- **Effort:** 8 hours

### Plantis Backup (Future - Extract to Core)
- **Extract all 7 services** to packages/core/lib/src/backup/
- Becomes available for all apps
- **Effort:** 16 hours

## ROI Analysis

### Quick Wins (P0 + P1)

| Effort | Impact | ROI | Services Affected |
|--------|--------|-----|-------------------|
| 17.5h | Very High | Excellent | 17 services |

**Breakdown:**
- Delete: 0.5h per service × 6 = 3h
- Consolidate Gasometer: 2h
- Consolidate Plantis: 8h
- Migrate secure_storage: 6h

**Benefits:**
- -6 unused services (cleaner codebase)
- -7 duplicate versions (reduced confusion)
- +1 core service usage (better architecture)
- Improved maintainability

### Full Implementation (P0 + P1 + P2)

| Effort | Impact | ROI | Services Affected |
|--------|--------|-----|-------------------|
| 60.5h | High | Good | 34+ services |

**Benefits:**
- Significantly cleaner codebase
- 11 new core services available for reuse
- Backup feature available across all apps
- Reduced long-term maintenance by ~80h over 6 months

## Usage Heatmap

### High Usage (5+ uses) - Critical Services

| Service | App | Uses | Status |
|---------|-----|------|--------|
| plantis_notification_service.dart | Plantis | 12 | ✅ Keep (consolidate into) |
| input_sanitizer.dart | Gasometer | 10 | ✅ Keep |
| gasometer_analytics_service.dart | Gasometer | 9 | ✅ Keep |
| secure_storage_service.dart | Plantis | 7 | 🔄 Migrate to core |
| data_cleaner_service.dart | Gasometer | 7 | ✅ Keep (consolidate into) |
| backup_service.dart | Plantis | 6 | 🏗️ Extract to core |
| backup_restore_service.dart | Plantis | 5 | 🏗️ Extract to core |

### Medium Usage (2-4 uses)

| Service | App | Uses | Status |
|---------|-----|------|--------|
| local_data_service.dart | Gasometer | 4 | ✅ Keep |
| receipt_image_service.dart | Gasometer | 4 | ✅ Keep |
| plants_care_calculator.dart | Plantis | 4 | ✅ Keep |
| plants_data_service.dart | Plantis | 4 | ✅ Keep |
| plants_filter_service.dart | Plantis | 4 | ✅ Keep |
| task_notification_service.dart | Plantis | 4 | ✅ Keep |
| (Many more...) | - | 2-4 | Various |

### Low/No Usage (0-1 uses) - Review Needed

| Service | App | Uses | Status |
|---------|-----|------|--------|
| (6 services) | Various | 0 | ❌ Delete |
| (Many services) | Various | 1 | Review |

## Core Package Services Reference

### Available in packages/core (67+ services)

**Firebase:**
- firebase_auth_service, enhanced_firebase_auth_service
- firebase_analytics_service, enhanced_analytics_service
- firebase_crashlytics_service
- firebase_storage_service
- firebase_device_service

**Storage:**
- hive_storage_service, core_hive_storage_service
- enhanced_encrypted_storage_service ← **Plantis should use this**
- enhanced_secure_storage_service ← **Plantis should use this**
- enhanced_storage_service

**Images:**
- image_service
- enhanced_image_service
- enhanced_image_service_unified
- profile_image_service ← **Could enhance with avatar_service**
- optimized_image_service

**Sync (Per-App):**
- gasometer_sync_service
- plantis_sync_service
- petiveti_sync_service
- receituagro_sync_service
- taskolist_sync_service
- agrihurbi_sync_service

**Infrastructure:**
- navigation_service, enhanced_navigation_service
- local_notification_service, enhanced_notification_service
- connectivity_service, enhanced_connectivity_service
- validation_service ← **Could enhance with form_validation**
- security_service, enhanced_security_service
- performance_service ← **Could add memory_monitoring**
- database_inspector_service ← **Gasometer correctly wraps this**

## Decision Matrix

### Should I Create App-Level Service?

```
Is it domain-specific business logic? ────YES──→ App-level ✅
│
NO
│
Is it already in core package? ────YES──→ Use core ✅
│
NO
│
Could it benefit other apps? ────YES──→ Add to core 📦
│
NO
│
Is it app-specific integration/wrapper? ────YES──→ App-level wrapper ✅
│
NO
│
Reconsider - might belong in core 🤔
```

### Examples

**App-Level (Correct):**
- ✅ Financial conflict resolution (gasometer-specific)
- ✅ Plant care calculator (plantis-specific)
- ✅ Receipt image service (gasometer domain)
- ✅ Task generation (plantis feature)

**Core Package (Should Migrate):**
- 📦 Avatar/profile image processing (all apps need)
- 📦 Platform capabilities detection (cross-app)
- 📦 Form validation (generic)
- 📦 Image caching (infrastructure)

**Wrapper (Correct Pattern):**
- ✅ GasOMeterDatabaseInspectorService wraps core's DatabaseInspectorService
- ✅ App-specific analytics wraps core analytics with custom events

## Next Steps Checklist

### Week 1
- [ ] Review audit with team
- [ ] Get approval for deletions
- [ ] Delete 6 unused services (P0)
- [ ] Run tests to confirm no breakage
- [ ] Commit: "chore: Remove unused services"

### Week 2
- [ ] Consolidate Gasometer data cleaners
- [ ] Start Plantis notification consolidation
- [ ] Commit: "refactor: Consolidate duplicate services"

### Week 3
- [ ] Complete Plantis notification consolidation
- [ ] Start secure_storage migration
- [ ] Test thoroughly (security critical)

### Week 4
- [ ] Complete secure_storage migration
- [ ] Start avatar_service migration
- [ ] Update documentation

### Month 2
- [ ] Migrate remaining P2 services
- [ ] Extract backup subsystem
- [ ] Create service guidelines
- [ ] Final review and cleanup

---

**Generated:** 2025-10-02 | **Total Services:** 63 | **Apps:** 3 | **Core Services:** 67+
