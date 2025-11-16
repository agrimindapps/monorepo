# 🗺️ GASOMETER PHASE 3 ROADMAP TO 9.0/10

**Current Score**: 8.5/10  
**Target Score**: 9.0/10  
**Total Effort**: 16-18 hours

---

## 📍 CURRENT STATUS (Phase 3A - COMPLETED)

### ✅ Completed:
- settings/ Clean Architecture (domain + data layers)
- Score improvement: 8.3 → 8.5 (+0.2)
- 5 new files created
- Repository Pattern implemented

### 📊 Metrics:
- Tests: 52 passing ✅
- Analyzer: 0 errors ✅
- Complete features: 1 of 4 (25%)
- Massive files: 29 remain (8 priority files >800 lines)

---

## 🎯 PHASE 3B: Complete Features (+0.1, 2 hours)

### Goal: 8.5 → 8.6

### Tasks:
1. **legal/** (30 min)
   - Add domain layer (entities + repository interface)
   - Easiest - data layer already exists

2. **profile/** (1 hour)
   - Add data layer (models + datasource + repo impl)
   - Extract from auth integration

3. **promo/** (30 min)
   - Add data layer (models + datasource + repo impl)
   - Handle Firebase dependencies

### Deliverables:
- 15 new files (5 per feature × 3 features)
- 4/4 features with Clean Architecture
- SRP +0.1, DIP +0.1

---

## 🔥 PHASE 3C: Split Massive Files (+0.4, 10-12 hours)

### Goal: 8.6 → 9.0

### Priority 1 Files (CRITICAL - 6 hours):

#### 1. account_deletion_page.dart (1386 lines → 4 files)
**Effort**: 1.5 hours  
**Impact**: +0.1 score

**Split Plan**:
```
promo/presentation/pages/account_deletion/
├── account_deletion_page.dart (300 lines)
├── deletion_form_section.dart (350 lines)
├── deletion_confirmation_dialog.dart (350 lines)
└── deletion_reason_widgets.dart (350 lines)
```

**Extractions**:
- _buildIntroduction() → intro section
- _buildWhatWillBeDeleted() → data section
- _buildConsequences() → consequences section
- _buildConfirmationSection() → confirmation section
- _PasswordDialog → password dialog

---

#### 2. maintenance_form_notifier.dart (904 lines → 3 files)
**Effort**: 1.5 hours  
**Impact**: +0.1 score

**Split Plan**:
```
maintenance/presentation/notifiers/
├── maintenance_form_notifier.dart (300 lines - core)
├── maintenance_form_validation.dart (300 lines)
└── maintenance_form_state_manager.dart (300 lines)
```

**Responsibilities**:
- **Core**: State management, provider integration
- **Validation**: Form validation, business rules
- **State Manager**: Loading states, error handling

---

#### 3. privacy_policy_page.dart (859 lines → 3 files)
**Effort**: 1 hour  
**Impact**: +0.05 score

**Split Plan**:
```
promo/presentation/pages/privacy_policy/
├── privacy_policy_page.dart (200 lines)
├── privacy_sections.dart (330 lines)
└── privacy_content.dart (330 lines)
```

---

#### 4. fuel_riverpod_notifier.dart (839 lines → 3 files)
**Effort**: 1.5 hours  
**Impact**: +0.1 score

**Split Plan**:
```
fuel/presentation/providers/
├── fuel_riverpod_notifier.dart (300 lines)
├── fuel_crud_providers.dart (270 lines)
└── fuel_query_providers.dart (270 lines)
```

**Extractions**:
- **CRUD**: add, update, delete operations
- **Queries**: filter by vehicle, statistics, latest record

---

### Priority 2 Files (MEDIUM - 5 hours):

#### 5. auth_notifier.dart (832 lines → 3 files)
**Effort**: 1.5 hours | **Impact**: +0.05

#### 6. expense_validation_service.dart (819 lines → 3 files)
**Effort**: 1.5 hours | **Impact**: +0.05

#### 7. fuel_form_notifier.dart (815 lines → 3 files)
**Effort**: 1 hour | **Impact**: +0.05

#### 8. enhanced_vehicle_selector.dart (808 lines → 3 files)
**Effort**: 1 hour | **Impact**: +0.05

---

## 🧪 PHASE 3D: Testing & Polish (+0.1 maintain, 4 hours)

### Goal: Solidify 9.0/10

### Tasks:

#### 1. Sync Adapter Tests (2 hours)
**Coverage**: 0% → 60%
- fuel_supply_drift_sync_adapter_test.dart (20 tests)
- maintenance_drift_sync_adapter_test.dart (20 tests)
- expense_drift_sync_adapter_test.dart (20 tests)
- vehicle_drift_sync_adapter_test.dart (20 tests)

#### 2. Repository Tests (1 hour)
**Coverage**: 20% → 50%
- Add 30 tests across fuel/vehicle/expense repositories
- Mock datasources with mocktail
- Test error handling paths

#### 3. Form Notifier Tests (1 hour)
**Coverage**: 30% → 60%
- fuel_form_notifier_test.dart (20 tests)
- maintenance_form_notifier_test.dart (20 tests)

### Deliverables:
- +110 tests total
- Coverage: 40% → 60%
- All tests passing

---

## 📊 SCORE PROGRESSION

| Phase | Tasks | Effort | Score | Delta |
|-------|-------|--------|-------|-------|
| **Current** | settings/ complete | - | 8.5 | - |
| **3B** | 3 features | 2h | 8.6 | +0.1 |
| **3C** | 8 file splits | 10-12h | 9.0 | +0.4 |
| **3D** | 110 tests | 4h | 9.0 | maintain |
| **TOTAL** | All tasks | **16-18h** | **9.0** | **+0.5** |

---

## 🎯 EXECUTION STRATEGY

### Approach 1: IMPACT-FIRST (Recommended)
1. **Phase 3C** first (highest impact +0.4)
   - Addresses critical SRP violations
   - Makes codebase maintainable
   - 10-12 hours

2. **Phase 3B** alongside (quick wins)
   - Complete features incrementally
   - 2 hours total

3. **Phase 3D** last (stabilize)
   - Add tests after refactoring
   - 4 hours

**Pros**: Fastest to 9.0/10 (12 hours main path)  
**Cons**: Higher risk (big refactorings first)

---

### Approach 2: SAFE-FIRST
1. **Phase 3B** first (low risk)
   - Complete 3 features
   - 2 hours

2. **Phase 3C** Priority 1 only (4 files)
   - Split critical files
   - 6 hours
   - Score: 8.8/10

3. **Phase 3C** Priority 2 (4 files)
   - Complete remaining splits
   - 5 hours
   - Score: 9.0/10

4. **Phase 3D** tests
   - 4 hours

**Pros**: Incremental, lower risk  
**Cons**: Slower to 9.0/10 (17 hours)

---

## ✅ SUCCESS CRITERIA (9.0/10)

### Must Achieve:
- [ ] 4/4 features with Clean Architecture
- [ ] 0 files >800 lines (currently 8)
- [ ] All files <500 lines (currently 29 violations)
- [ ] Test coverage 60%+
- [ ] 52+ tests passing
- [ ] 0 analyzer errors

### Quality Gates:
- [ ] flutter analyze: 0 errors
- [ ] flutter test: all passing
- [ ] No breaking changes
- [ ] All features functional

---

## 🚀 RECOMMENDED NEXT STEP

**START WITH**: Phase 3C Priority 1 File 1

```bash
# Split account_deletion_page.dart (1386 lines)
# Expected time: 1.5 hours
# Expected impact: +0.1 score
# Risk: LOW (UI component, easy to validate)
```

**Why start here?**
1. Biggest file (highest impact)
2. Pure UI (no complex business logic)
3. Easy to validate (visual check)
4. Sets pattern for other 7 files

**Validation**:
- App builds ✅
- Navigation works ✅
- Deletion flow works ✅
- Tests pass ✅

---

## 📞 QUESTIONS FOR NEXT SESSION

1. Should we prioritize impact (Phase 3C) or safety (Phase 3B)?
2. Split all 8 files or just Priority 1 (4 files)?
3. Add tests during or after splits?
4. Target 9.0/10 or push for higher?

---

**Status**: ROADMAP READY  
**Next**: Choose approach and execute  
**Est. Time to 9.0**: 16-18 hours (2-3 sessions)
