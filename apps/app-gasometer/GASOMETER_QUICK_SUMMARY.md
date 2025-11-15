# ⚡ app-gasometer - Análise Rápida

**Score SOLID:** 5.5/10 ⚠️  
**Status:** CRÍTICO - Refatoração necessária

---

## 🔴 TOP 5 PROBLEMAS CRÍTICOS

### 1. God Services em core/ (CRÍTICO)
- **61 arquivos**, 11,644 linhas em `core/services/`
- Maior: `data_cleaner_service.dart` (487 linhas)
- **Violação massiva de SRP**

### 2. Repositories Duplicados (CRÍTICO)
- **3 implementações** de VehicleRepository:
  - `database/repositories/vehicle_repository.dart`
  - `features/vehicles/data/repositories/vehicle_repository_impl.dart`
  - `features/vehicles/data/repositories/vehicle_repository_drift_impl.dart`

### 3. Database/ fora de Features (ALTA)
- 6 repositories em `database/repositories/`
- **Deveriam estar em** `features/*/data/repositories/`
- Violação de Clean Architecture

### 4. Features Incompletas (ALTA)
- **settings/** - SEM domain/ e data/ (2/10)
- **profile/** - SEM data/ (5/10)
- **promo/** - SEM data/ (5/10)
- **legal/** - SEM domain/ (4/10)

### 5. God Classes (ALTA)
- `account_deletion_page.dart` - **1386 linhas**
- `maintenance_form_notifier.dart` - **904 linhas**
- `auth_notifier.dart` - **832 linhas**
- **31 arquivos >500 linhas** (limite: 500)

---

## 📊 COMPARAÇÃO COM app-plantis

| Métrica | gasometer | plantis | Diff |
|---------|-----------|---------|------|
| **Score SOLID** | 5.5/10 | 9.5/10 | -4.0 |
| **Arquivos .dart** | 690 | 234 | +2.9x |
| **Services em core/** | 61 | 0 | +61 |
| **Maior arquivo** | 1386 | 342 | +4x |
| **Analyzer errors** | 2 | 0 | +2 |

---

## 🎯 REFATORAÇÃO PRIORITÁRIA

### Fase 1 (CRÍTICO - 2 semanas)
1. ✅ Consolidar `error/` e `errors/` (2 dias)
2. ✅ Resolver duplicação VehicleRepository (3 dias)
3. ✅ Mover database repos → features (5 dias)

### Fase 2 (ALTA - 6 semanas)
1. ✅ God Services → Specialized Services (15-20 dias)
2. ✅ Eliminar duplicação fuel services (5-8 dias)
3. ✅ Split God Classes >500 linhas (8-10 dias)

### Fase 3 (MÉDIA - 3 semanas)
1. ✅ Completar domain em 4 features (3-5 dias)
2. ✅ Mover models core/ → features/ (2 dias)

**Total:** 39-55 dias de trabalho

---

## 🚦 AÇÕES IMEDIATAS

**PARAR:**
- ❌ Adicionar services em `core/services/`
- ❌ Criar features sem domain/data/presentation
- ❌ Arquivos >500 linhas

**COMEÇAR:**
- ✅ Services em `features/*/domain/services/`
- ✅ Quality Gates no CI/CD
- ✅ Code review rigoroso

**EXECUTAR:**
1. Consolidar error/errors/ (2 dias)
2. Mover VehicleRepository (3 dias)
3. Estabelecer padrões documentados

---

## 📈 META: 8/10 em 3 meses

**Critérios de Sucesso:**
- ✅ 0 services em core/ (exceto cross-feature)
- ✅ 0 duplicação de repositories
- ✅ 100% features com domain/data/presentation
- ✅ 0 arquivos >500 linhas
- ✅ 0 analyzer errors

---

**Documento Completo:** GASOMETER_STRUCTURE_ANALYSIS.md (1280 linhas)
