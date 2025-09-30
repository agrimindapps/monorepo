# Checklist de Centralização - Core Package

**Data de Início**: 30 de Setembro de 2025
**Meta**: Atingir 95%+ de centralização em todos os apps
**Timeline**: 5 semanas

---

## 📊 Status Atual

```
ReceitaAgro: [████████████████████] 95% (9.5/10)
Plantis:     [█████████████████░░░] 85% (8.5/10)
Gasometer:   [████████████░░░░░░░░] 60% (6.0/10)
```

---

## 🗓️ Semana 1: Gasometer Quick Wins (38 imports)

### Fase 1.1: Cloud Firestore (12 imports)
- [ ] Backup files before changes
- [ ] Replace import in `gasometer_firebase_service.dart`
- [ ] Replace import in `log_remote_data_source.dart`
- [ ] Replace import in `expenses_remote_data_source.dart`
- [ ] Replace import in `maintenance_remote_data_source.dart`
- [ ] Replace import in `user_model.dart`
- [ ] Replace import in `vehicle_remote_data_source.dart`
- [ ] Replace import in `fuel_remote_data_source.dart`
- [ ] Replace import in `premium_firebase_data_source.dart`
- [ ] Replace import in `odometer_remote_data_source.dart`
- [ ] Replace import in `premium_webhook_data_source.dart`
- [ ] Replace imports in remaining 2 files
- [ ] Remove duplicate imports (awk)
- [ ] Run flutter analyze
- [ ] Test app functionality
- [ ] Commit changes

**Resultado esperado**: 12 imports eliminados ✅

---

### Fase 1.2: Hive/Hive Flutter (11 imports)
- [ ] Backup files before changes
- [ ] Replace import in `data_cleaner_service.dart`
- [ ] Replace import in `hive_service.dart`
- [ ] Replace import in `local_data_service.dart`
- [ ] Replace import in `category_model.dart`
- [ ] Replace import in `log_entry.dart`
- [ ] Replace import in `base_model.dart`
- [ ] Replace import in `log_local_data_source.dart`
- [ ] Replace import in `logging_config.dart`
- [ ] Replace import in `expenses_repository.dart`
- [ ] Replace import in `maintenance_repository.dart`
- [ ] Replace import in `odometer_repository.dart`
- [ ] Remove duplicate imports (awk)
- [ ] Run flutter analyze
- [ ] Test app functionality
- [ ] Commit changes

**Resultado esperado**: 11 imports eliminados ✅

---

### Fase 1.3: Shared Preferences (9 imports)
- [ ] Backup files before changes
- [ ] Replace import in `enhanced_vehicle_selector.dart`
- [ ] Replace import in `data_cleaner_service.dart`
- [ ] Replace import in `local_data_service.dart`
- [ ] Replace import in `login_controller.dart`
- [ ] Replace import in `data_export_repository_impl.dart`
- [ ] Replace import in `data_export_service.dart`
- [ ] Replace import in `premium_local_data_source.dart`
- [ ] Replace imports in remaining 2 files
- [ ] Remove duplicate imports (awk)
- [ ] Run flutter analyze
- [ ] Test app functionality
- [ ] Commit changes

**Resultado esperado**: 9 imports eliminados ✅

---

### Fase 1.4: Connectivity Plus (6 imports)
- [ ] Backup files before changes
- [ ] Replace import in `startup_sync_service.dart`
- [ ] Replace import in `log_repository_impl.dart`
- [ ] Replace import in `expenses_repository.dart`
- [ ] Replace import in `odometer_repository.dart`
- [ ] Replace imports in remaining 2 files
- [ ] Remove duplicate imports (awk)
- [ ] Run flutter analyze
- [ ] Test app functionality
- [ ] Commit changes

**Resultado esperado**: 6 imports eliminados ✅

---

### Semana 1 - Validação Final
- [ ] Run full test suite (gasometer)
- [ ] Manual testing of key features
- [ ] Generate post-migration report
- [ ] Update metrics (Score: 6.0 → 8.0)
- [ ] Create PR with all changes
- [ ] Code review
- [ ] Merge to main

**Resultado esperado**: Gasometer 8.0/10 (60% → 80%) 🎯

---

## 🗓️ Semana 2: Core Package Enhancement

### Adicionar Packages ao Core
- [ ] Open `packages/core/pubspec.yaml`
- [ ] Add `image_picker: ^1.0.0`
- [ ] Add `device_info_plus: ^9.0.0`
- [ ] Add `image: ^4.0.0`
- [ ] Add `http: ^1.0.0`
- [ ] Add `permission_handler: ^11.0.0`
- [ ] Add `path_provider: ^2.0.0`
- [ ] Run `flutter pub get` in core
- [ ] Verify no conflicts

---

### Adicionar Exports no Core
- [ ] Open `packages/core/lib/core.dart`
- [ ] Add image_picker export
- [ ] Add device_info_plus export
- [ ] Add image package export (as img)
- [ ] Add http client export
- [ ] Add permission_handler export
- [ ] Add path_provider export
- [ ] Run flutter analyze on core
- [ ] Update core package version (minor bump)

---

### Validar Core Package
- [ ] Run flutter analyze (core)
- [ ] Run flutter test (core)
- [ ] Test import in gasometer
- [ ] Test import in plantis
- [ ] Test import in receituagro
- [ ] Update documentation
- [ ] Commit changes
- [ ] Create PR
- [ ] Merge to main

**Resultado esperado**: 6 packages disponíveis via core ✅

---

## 🗓️ Semana 3: Service Extraction (Tier 1)

### Service 1: Enhanced Image Cache Manager
- [ ] Copy from Plantis to `/tmp`
- [ ] Review code for app-specific dependencies
- [ ] Remove Plantis-specific logic
- [ ] Make generic (parameterize app-specific values)
- [ ] Move to `core/lib/src/shared/services/`
- [ ] Add export in `core.dart`
- [ ] Update Plantis to import from core
- [ ] Update Gasometer to use service
- [ ] Update ReceitaAgro to use service
- [ ] Test image caching in all apps
- [ ] Document service usage
- [ ] Run benchmarks (memory usage)
- [ ] Commit changes

**Resultado esperado**: Image cache unificado (-30% memory) ✅

---

### Service 2: Avatar Service
- [ ] Copy from Gasometer to `/tmp`
- [ ] Review code for app-specific dependencies
- [ ] Remove Gasometer-specific logic
- [ ] Make generic (parameterize compression settings)
- [ ] Move to `core/lib/src/shared/services/`
- [ ] Add export in `core.dart`
- [ ] Update Gasometer to import from core
- [ ] Update Plantis to use service (plant images)
- [ ] Update ReceitaAgro to use service (profile images)
- [ ] Test image picker in all apps
- [ ] Test permissions handling (iOS/Android)
- [ ] Document service usage
- [ ] Commit changes

**Resultado esperado**: Avatar handling unificado ✅

---

### Service 3: Cloud Functions Service
- [ ] Copy from ReceitaAgro to `/tmp`
- [ ] Review code for app-specific dependencies
- [ ] Remove ReceitaAgro-specific endpoints
- [ ] Make generic (parameterize base URL)
- [ ] Move to `core/lib/src/infrastructure/services/`
- [ ] Add export in `core.dart`
- [ ] Update ReceitaAgro to import from core
- [ ] Update Gasometer to use service (if needed)
- [ ] Update Plantis to use service (if needed)
- [ ] Test authenticated HTTP calls
- [ ] Test error handling
- [ ] Document service usage
- [ ] Commit changes

**Resultado esperado**: HTTP client unificado ✅

---

### Service 4: Device Identity Service
- [ ] Copy from ReceitaAgro to `/tmp`
- [ ] Review code for app-specific dependencies
- [ ] Remove ReceitaAgro-specific logic
- [ ] Make generic
- [ ] Move to `core/lib/src/infrastructure/services/`
- [ ] Add export in `core.dart`
- [ ] Update ReceitaAgro to import from core
- [ ] Update Gasometer to use service (device management)
- [ ] Update Plantis to use service (device management)
- [ ] Test device fingerprinting
- [ ] Test multi-device subscription
- [ ] Document service usage
- [ ] Commit changes

**Resultado esperado**: Device identity unificado ✅

---

### Semana 3 - Validação Final
- [ ] Run full test suite (all apps)
- [ ] Manual testing of extracted services
- [ ] Performance benchmarks
- [ ] Memory profiling
- [ ] Update documentation
- [ ] Create PR with all services
- [ ] Code review
- [ ] Merge to main

**Resultado esperado**: 4 services reutilizáveis (~1500 lines) 🎯

---

## 🗓️ Semana 4: Widget Library

### Widget 1: Premium Gate Widget
- [ ] Create `core/lib/src/presentation/widgets/premium_gate_widget.dart`
- [ ] Implement basic widget structure
- [ ] Add upgrade CTA
- [ ] Add feature list display
- [ ] Add customization parameters
- [ ] Add tests
- [ ] Add documentation
- [ ] Add example usage
- [ ] Export in core.dart
- [ ] Update Gasometer to use widget
- [ ] Update Plantis to use widget
- [ ] Update ReceitaAgro to use widget
- [ ] Test in all apps
- [ ] Commit changes

---

### Widget 2: Enhanced Empty State Widget
- [ ] Create `core/lib/src/presentation/widgets/enhanced_empty_state_widget.dart`
- [ ] Implement basic widget structure
- [ ] Add icon support
- [ ] Add action button
- [ ] Add customization parameters
- [ ] Add tests
- [ ] Add documentation
- [ ] Add example usage
- [ ] Export in core.dart
- [ ] Replace empty states in Gasometer (5+ widgets)
- [ ] Replace empty states in Plantis (3+ widgets)
- [ ] Replace empty states in ReceitaAgro (2+ widgets)
- [ ] Test in all apps
- [ ] Commit changes

---

### Widget 3: Loading State Widget
- [ ] Create `core/lib/src/presentation/widgets/loading_state_widget.dart`
- [ ] Implement basic widget structure
- [ ] Add shimmer support (uses core shimmer package)
- [ ] Add message parameter
- [ ] Add customization parameters
- [ ] Add tests
- [ ] Add documentation
- [ ] Add example usage
- [ ] Export in core.dart
- [ ] Replace loading widgets in all apps
- [ ] Test in all apps
- [ ] Commit changes

---

### Widget 4: Sync Status Widget
- [ ] Create `core/lib/src/presentation/widgets/sync_status_widget.dart`
- [ ] Implement basic widget structure
- [ ] Add sync indicator
- [ ] Add last sync timestamp
- [ ] Add manual sync button
- [ ] Add customization parameters
- [ ] Add tests
- [ ] Add documentation
- [ ] Add example usage
- [ ] Export in core.dart
- [ ] Add to Gasometer (offline-first)
- [ ] Add to Plantis (offline-first)
- [ ] Test in both apps
- [ ] Commit changes

---

### Widget 5: Profile Avatar Widget
- [ ] Uncomment existing `core/lib/src/presentation/widgets/profile_avatar.dart`
- [ ] Review and improve implementation
- [ ] Integrate with AvatarService (from Semana 3)
- [ ] Add customization parameters
- [ ] Add tests
- [ ] Add documentation
- [ ] Add example usage
- [ ] Export in core.dart (uncomment)
- [ ] Update all apps to use widget
- [ ] Test in all apps
- [ ] Commit changes

---

### Semana 4 - Validação Final
- [ ] Run full test suite (all apps)
- [ ] Manual testing of all widgets
- [ ] UI consistency check
- [ ] Accessibility audit (a11y)
- [ ] Update documentation
- [ ] Create PR with widget library
- [ ] Code review
- [ ] Merge to main

**Resultado esperado**: 5 widgets compartilhados (UI consistency) 🎯

---

## 🗓️ Semana 5: Integration & Final Touches

### Plantis Quick Fixes (10 imports)
- [ ] Replace shared_preferences (3 imports)
  - [ ] `notifications_settings_provider.dart`
  - [ ] `offline_sync_queue_service.dart`
  - [ ] `settings_local_datasource.dart`
- [ ] Replace hive (2 imports)
  - [ ] `sync_queue.dart`
- [ ] Replace cloud_firestore (1 import)
  - [ ] `plant_tasks_remote_datasource.dart`
- [ ] Replace connectivity_plus (1 import)
  - [ ] `offline_sync_queue_service.dart`
- [ ] Replace url_launcher (1 import)
  - [ ] `url_launcher_service.dart`
- [ ] Replace path_provider (1 import)
  - [ ] `enhanced_image_cache_manager.dart` (moved to core)
- [ ] Replace device_info_plus (1 import)
  - [ ] `device_model.dart`
- [ ] Run flutter analyze
- [ ] Test app
- [ ] Commit changes

**Resultado esperado**: Plantis 9.5/10 (85% → 95%) ✅

---

### ReceitaAgro Final Touches (6 imports)
- [ ] Replace shared_preferences (3 imports)
  - [ ] `theme_preference_migration.dart`
  - [ ] `theme_provider.dart`
  - [ ] `promotional_notification_manager.dart`
- [ ] Replace hive_flutter (1 import)
  - [ ] `data_inspector_page.dart`
- [ ] Replace device_info_plus (1 import)
  - [ ] `device_identity_service.dart` (moved to core)
- [ ] Replace http (1 import)
  - [ ] `cloud_functions_service.dart` (moved to core)
- [ ] Run flutter analyze
- [ ] Test app
- [ ] Commit changes

**Resultado esperado**: ReceitaAgro 10/10 (95% → 100%) ✅

---

### Gasometer Service Integration
- [ ] Update to use EnhancedImageCacheManager from core
  - [ ] Receipt images
  - [ ] Profile images
  - [ ] Vehicle images
- [ ] Update to use AvatarService from core
  - [ ] Profile image picker
  - [ ] Image compression
- [ ] Update to use CloudFunctionsService from core (if needed)
- [ ] Update to use DeviceIdentityService from core
  - [ ] Device management feature
- [ ] Remove local service duplicates
- [ ] Run flutter analyze
- [ ] Test all features
- [ ] Commit changes

---

### Final Validation
- [ ] Run full test suite (all 3 apps)
- [ ] Run integration tests
- [ ] Performance benchmarks
- [ ] Memory profiling
- [ ] Code coverage report
- [ ] Security audit
- [ ] Accessibility audit
- [ ] Manual testing (all critical paths)

---

### Documentation
- [ ] Update core package README
- [ ] Document all new services
- [ ] Document all new widgets
- [ ] Update architecture docs
- [ ] Create migration guide
- [ ] Update CHANGELOG
- [ ] Generate API docs
- [ ] Add examples

---

### Cleanup
- [ ] Remove all .bak files
- [ ] Remove unused imports
- [ ] Remove dead code
- [ ] Run dart format
- [ ] Fix all warnings
- [ ] Update dependencies
- [ ] Run flutter analyze (0 issues)

---

### Final Report
- [ ] Generate post-migration metrics
- [ ] Compare before/after
- [ ] Calculate ROI achieved
- [ ] Document lessons learned
- [ ] Create success presentation
- [ ] Share with team

---

## 📈 Métricas Finais (A preencher)

### Antes da Migração
```
Total de imports diretos: 74
Código duplicado: ~3500 linhas
Packages redundantes: 15
```

### Após a Migração (Preencher ao final)
```
Total de imports diretos: _____
Código duplicado: _____ linhas
Packages redundantes: _____

Economia de código: ____%
Melhoria de performance: ____%
Redução de memory usage: ____%
```

### Scores Finais (Preencher ao final)

| App | Score Inicial | Score Final | Melhoria |
|-----|---------------|-------------|----------|
| ReceitaAgro | 9.5/10 | _____/10 | +___% |
| Plantis | 8.5/10 | _____/10 | +___% |
| Gasometer | 6.0/10 | _____/10 | +___% |

---

## 🎯 Meta Alcançada?

- [ ] ReceitaAgro: 10/10 (100% centralização)
- [ ] Plantis: 9.5/10 (95%+ centralização)
- [ ] Gasometer: 9.5/10 (95%+ centralização)
- [ ] Todos os apps com < 5 imports diretos
- [ ] 4+ services extraídos para core
- [ ] 5+ widgets compartilhados
- [ ] 6 packages adicionados ao core
- [ ] Performance melhorada (benchmarks)
- [ ] Documentação completa
- [ ] Zero issues no flutter analyze

---

## 🎉 Celebração

- [ ] Team presentation
- [ ] Update roadmap
- [ ] Plan next improvements
- [ ] Knowledge sharing session
- [ ] Post-mortem meeting
- [ ] Update technical debt tracker

---

## 📝 Notas e Lições Aprendidas

(Espaço para anotações durante a execução)

### Semana 1:
```
[Adicionar notas aqui]
```

### Semana 2:
```
[Adicionar notas aqui]
```

### Semana 3:
```
[Adicionar notas aqui]
```

### Semana 4:
```
[Adicionar notas aqui]
```

### Semana 5:
```
[Adicionar notas aqui]
```

---

**Gerado por**: Claude Sonnet 4.5 (Flutter Architect)
**Data de Criação**: 30 de Setembro de 2025
**Última Atualização**: _____

**Para usar este checklist:**
1. Imprimir ou manter aberto durante execução
2. Marcar [ ] com [x] conforme completa tasks
3. Adicionar notas em cada seção
4. Atualizar métricas ao final de cada semana
5. Celebrar marcos importantes! 🎉
