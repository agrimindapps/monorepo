# 📊 Análise de Classes Estáticas - PLT-QUALITY-003

**Data**: 15/12/2025
**Total**: 47 classes estáticas identificadas

## 📋 Categorização

### 1. **Builders/Factories UI** (15 classes) - ✅ VÁLIDO (Manter)
Pattern válido para construção declarativa de widgets complexos.

**Recomendação**: Manter como static - são utility classes puras.

- `features/device_management/presentation/managers/device_feedback_builder.dart`
- `features/device_management/presentation/managers/device_status_builder.dart`
- `features/home/presentation/managers/landing_auth_redirect_manager.dart`
- `features/home/presentation/managers/landing_footer_builder.dart`
- `features/legal/presentation/builders/footer_section_builder.dart`
- `features/legal/presentation/builders/how_it_works_section_builder.dart`
- `features/legal/presentation/builders/promo_coming_soon_section_builder.dart`
- `features/legal/presentation/builders/testimonials_section_builder.dart`
- `features/license/presentation/builders/license_status_card_builder.dart`
- `features/license/presentation/builders/upgrade_prompt_builder.dart`
- `features/plants/presentation/builders/plant_form_dialog_builder.dart`
- `features/plants/presentation/builders/plants_sort_builder.dart`
- `features/premium/presentation/builders/premium_actions_builder.dart`
- `features/settings/presentation/managers/notification_settings_builder.dart`
- `features/settings/presentation/managers/settings_sections_builder.dart`

### 2. **Mappers/Converters** (3 classes) - ✅ VÁLIDO (Manter)
Transformações puras sem estado.

- `features/plants/domain/entities/plant_field_converter.dart`
- `features/sync/data/mappers/plant_firebase_mapper.dart`
- `features/sync/data/mappers/task_firebase_mapper.dart`

### 3. **Validators/Helpers** (3 classes) - ✅ VÁLIDO (Manter)
Funções puras de validação.

- `features/auth/utils/auth_validators.dart`
- `features/auth/utils/validation_helpers.dart`
- `features/plants/presentation/utils/failure_message_mapper.dart`

### 4. **Theme/Config** (3 classes) - ✅ VÁLIDO (Manter)
Constantes e configurações globais.

- `core/theme/plantis_colors.dart`
- `core/theme/plantis_theme.dart`
- `core/config/security_config.dart`

### 5. **DI Modules** (5 classes) - 🔧 REFATORAR
Devem usar @Riverpod ao invés de static factories.

- `core/di/modules/account_deletion_module.dart`
- `core/di/modules/domain_module.dart`
- `core/di/modules/plants_module.dart`
- `core/di/modules/spaces_module.dart`
- `core/di/modules/tasks_module.dart`

### 6. **Services com Estado** (8 classes) - 🔧 REFATORAR
Serviços que deveriam ser injetáveis.

- `core/services/data_sanitization_service.dart`
- `core/services/plantis_notification_config.dart`
- `core/services/plantis_sync_service.dart` ⚠️ **JÁ TEM INSTÂNCIA**
- `core/data/adapters/plantis_image_service_adapter.dart`
- `features/legal/data/legal_content_service.dart`
- `features/plants/domain/services/plant_task_task_adapter.dart`
- `features/plants/domain/services/plant_task_validation_service.dart`
- `shared/widgets/feedback/services/animation_service.dart` ✅ **JÁ MIGRADO**

### 7. **UI Components/Helpers** (6 classes) - ✅ VÁLIDO (Manter)
Componentes de UI declarativos.

- `core/widgets/enhanced_error_states.dart`
- `core/widgets/enhanced_loading_states.dart`
- `features/plants/presentation/widgets/plant_details/plant_details_error_widgets.dart`
- `features/plants/presentation/widgets/plant_tasks_helper.dart`
- `shared/widgets/loading/contextual_loading_manager.dart`
- `shared/widgets/loading/loading_components.dart`
- `shared/widgets/loading/skeleton_loader.dart`

### 8. **Adapters/Error Handling** (2 classes) - ✅ VÁLIDO (Manter)
Pattern Adapter puro.

- `core/error/error_adapter.dart`

### 9. **Legacy/Deprecated** (2 classes) - ⚠️ REVISAR
- `shared/widgets/feedback/progress_tracker.dart` - Verificar se ainda usado
- `shared/widgets/feedback/unified_feedback_system.dart` - Facade depreciado
- `core/router/app_router.dart` - Router config

---

## 🎯 Plano de Ação

### Prioridade Alta - Refatorar (5 DI Modules)
Estimativa: 2-3h

Converter static factories em @riverpod providers.

### Prioridade Média - Refatorar Services (6 services)
Estimativa: 3-4h

Tornar injetáveis via Riverpod.

### Prioridade Baixa - Revisar Legacy (2 classes)
Estimativa: 1h

Verificar se ainda são usados ou podem ser removidos.

### Decisão: Manter (32 classes)
São utility classes válidas sem estado:
- Builders/Factories UI (15)
- Mappers/Converters (3)
- Validators/Helpers (3)
- Theme/Config (3)
- UI Components (7)
- Adapters (1)

---

## 📊 Resumo

| Categoria | Qtd | Ação | Estimativa |
|-----------|-----|------|------------|
| Manter (válido) | 32 | ✅ Nenhuma | 0h |
| Refatorar DI | 5 | 🔧 Migrar para @riverpod | 2-3h |
| Refatorar Services | 6 | 🔧 Tornar injetáveis | 3-4h |
| Revisar Legacy | 2 | ⚠️ Analisar uso | 1h |
| **TOTAL** | **45** | | **6-8h** |

---

## 🔍 Nota sobre only_throw_errors

Os 120 casos de `only_throw_errors` são **válidos arquiteturalmente**:
- São `Failure` objects do Clean Architecture (CacheFailure, ServerFailure, etc.)
- Pattern válido para separação de domínio
- Alternativa: Fazer Failures extenderem Exception (mudança grande)

**Decisão**: Manter pattern atual e suprimir warning no analysis_options.yaml.
