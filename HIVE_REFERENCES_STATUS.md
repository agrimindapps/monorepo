# Análise de Referências a Hive no Monorepo

**Data**: 15 de Novembro de 2025
**Total de Referências**: 790 linhas
**Apps Afetados**: 10/10

---

## 📊 Resumo por App

### 🔴 Apps com MUITAS Referências (Prioridade Alta)

#### 1️⃣ **app-petiveti** - 228 linhas (23 arquivos)
```
Status: Migrando para Riverpod (bloqueador: Hive)
Tipos de referência:
  • @HiveType (model adapters): 5
  • HiveBox (box operations): 23
  • Hive.openBox/instance/box: 21
  • HiveAdapter (code gen): 1

Arquivos críticos:
  ├── core/data/repositories/base_repository.dart
  ├── core/di/injection_container_modular.dart
  ├── core/logging/datasources/log_local_datasource_impl.dart
  ├── core/logging/datasources/log_local_datasource_simple_impl.dart
  └── core/logging/entities/log_entry.dart

Recomendação: Migrar para Drift + Riverpod
Esforço estimado: 6-8 horas
```

#### 2️⃣ **app-receituagro** - 172 linhas (42 arquivos)
```
Status: Migrando para Riverpod (bloqueador: Hive)
Tipos de referência:
  • HiveBox (box operations): 10
  • Hive.openBox/instance/box: 6

Arquivos críticos:
  ├── core/data/repositories/user_data_repository.dart
  ├── core/di/core_package_integration.dart
  ├── core/di/injection_container.dart
  ├── core/interfaces/i_premium_service.dart
  └── core/providers/auth_notifier.dart

Recomendação: Migrar para Drift + Riverpod
Esforço estimado: 8-10 horas
```

#### 3️⃣ **app-nebulalist** - 137 linhas (23 arquivos)
```
Status: Pure Riverpod (9/10) - Hive em uso ativo
Tipos de referência:
  • HiveBox (box operations): 7
  • Hive.openBox/instance/box: 10
  • HiveAdapter (code gen): 1

Arquivos críticos:
  ├── core/config/app_config.dart
  ├── core/storage/boxes_setup.dart
  ├── core/storage/hive_adapters.dart
  ├── features/items/data/datasources/item_master_local_datasource.dart
  └── features/items/data/datasources/list_item_local_datasource.dart

⚠️ SITUAÇÃO: Hive é essencial para offline-first
Recomendação: Manter Hive (não é bloqueador)
Alternativa futura: Migrar para Drift se necessário
```

#### 4️⃣ **app-nutrituti** - 80 linhas (17 arquivos)
```
Status: Legacy + em transição
Tipos de referência:
  • @HiveType (model adapters): 3
  • HiveBox (box operations): 10
  • Hive.openBox/instance/box: 16

Arquivos críticos:
  ├── features/water/data/datasources/water_local_datasource.dart
  ├── features/water/data/models/water_achievement_model.dart
  └── features/water/domain/entities/water_record.dart

Recomendação: Migrar para Drift completamente
Esforço estimado: 4-6 horas
```

---

### 🟡 Apps com MÉDIAS Referências (Prioridade Média)

#### 5️⃣ **app-agrihurbi** - 52 linhas (22 arquivos)
```
Status: Standardizing to Riverpod
Tipos de referência:
  • @HiveType (model adapters): 3 (apenas em models)

Arquivos críticos:
  ├── core/performance/bundle_analyzer.dart
  ├── features/auth/data/models/user_model.dart
  ├── features/livestock/data/models/bovine_model.dart
  └── features/livestock/data/models/equine_model.dart

Recomendação: Remover @HiveType de models, usar Drift
Esforço estimado: 2-3 horas
```

#### 6️⃣ **app-calculei** - 48 linhas (13 arquivos)
```
Status: Migrando para Riverpod
Tipos de referência:
  • HiveBox (box operations): 7
  • Hive.openBox/instance/box: 15

Arquivos críticos:
  ├── features/cash_vs_installment_calculator/data/datasources/
  ├── features/emergency_reserve_calculator/data/datasources/
  ├── features/net_salary_calculator/data/datasources/
  └── features/overtime_calculator/data/datasources/

Recomendação: Migrar para Drift + Riverpod
Esforço estimado: 3-4 horas
```

#### 7️⃣ **app-termostecnicos** - 33 linhas (3 arquivos)
```
Status: Migrando para Riverpod
Tipos de referência:
  • Hive.openBox/instance/box: 1 (apenas em constants)

Arquivos críticos:
  ├── core/constants/app_constants.dart
  └── features/comentarios/data/models/ (backup files)

Recomendação: Remover referência única em constants
Esforço estimado: 0.5-1 hora
```

---

### 🟢 Apps com POUCAS Referências (Prioridade Baixa)

#### 8️⃣ **app-gasometer** - 25 linhas (15 arquivos)
```
Status: Migrando para Riverpod
Tipos de referência:
  • HiveBox (box operations): 4 (comentários/type hints)

Arquivos críticos:
  ├── core/di/register_module.dart
  ├── core/errors/failures.dart
  ├── core/gasometer_sync_config.dart
  └── core/providers/dependency_providers.dart

Recomendação: Remover comentários/type hints de Hive
Esforço estimado: 1-2 horas
```

#### 9️⃣ **app-taskolist** - 13 linhas (5 arquivos)
```
Status: Migrando para Riverpod
Tipos de referência:
  • HiveBox (box operations): 5 (comentários)

Arquivos críticos:
  ├── core/services/data_integrity_service.dart
  ├── core/sync/taskolist_sync_config.dart
  └── features/tasks/domain/task_list_repository.dart

Recomendação: Remover comentários/type hints de Hive
Esforço estimado: 0.5-1 hora
```

#### 🔟 **app-plantis** - 2 linhas (1 arquivo)
```
Status: Gold Standard 10/10 (Migrando para Riverpod)
Tipos de referência:
  • 2 linhas apenas (comentário em injection_container.dart)

Recomendação: Remover comentário único
Esforço estimado: <0.5 hora
```

---

## 📈 Distribuição de Tipos de Referências

```
Total: 790 linhas

Breakdown por tipo:
  • HiveBox (box operations): 66 linhas (8%)
  • Hive API calls (openBox/instance): 69 linhas (8%)
  • @HiveType (model adapters): 11 linhas (1%)
  • Comentários/Type hints: ~644 linhas (81%)
```

---

## 🎯 Plano de Ação (Priority Order)

### **Fase 1: Quick Wins (1-2 horas)**
1. ✅ **app-plantis**: Remover comentário único
2. ✅ **app-gasometer**: Limpar type hints
3. ✅ **app-taskolist**: Limpar comentários

### **Fase 2: Medium Effort (3-5 horas)**
4. **app-termostecnicos**: Remover referência em constants
5. **app-agrihurbi**: Remover @HiveType de models
6. **app-calculei**: Migrar para Drift + Riverpod

### **Fase 3: Heavy Lifting (6-10 horas)**
7. **app-nutrituti**: Migrar para Drift completamente
8. **app-petiveti**: Migrar para Drift + Riverpod (bloqueador)
9. **app-receituagro**: Migrar para Drift + Riverpod (bloqueador)

### **Fase 4: Keep As-Is**
10. **app-nebulalist**: ✅ Manter Hive (offline-first essential)

---

## 🚨 Bloqueadores Identificados

### Críticos (Impedem migração Riverpod completa)
- **app-petiveti**: 23 HiveBox operations ⚠️
- **app-receituagro**: 16 Hive API calls ⚠️

### Importantes (Podem impactar build)
- **app-nebulalist**: 18 Hive references (mas é intencional)
- **app-calculei**: 22 Hive API calls

### Menores (Fáceis de remover)
- **app-agrihurbi**: 3 @HiveType
- **app-nutrituti**: Alguns backups

---

## 📋 Recomendações Finais

1. **Usar Drift para substituição**: Hive → Drift (melhor integração com Riverpod)
2. **Remover comentários primeiro**: ~80% das refs são apenas documentação
3. **Priorizar app-petiveti e app-receituagro**: São bloqueadores da migração Riverpod
4. **Manter app-nebulalist**: Hive é essencial para offline-first (consider Drift como melhoria futura)
5. **Documentar durante migração**: Cada transição deve ter cobertura de testes

---

## 🔍 Comando para Buscar Referências

```bash
# Ver todas as referências
grep -r "hive\|Hive" apps/*/lib | head -50

# Ver app específico
grep -r "hive\|Hive" apps/app-petiveti/lib | wc -l

# Ver tipos de referências
grep -r "@HiveType" apps/*/lib
grep -r "HiveBox" apps/*/lib
grep -r "Hive\." apps/*/lib
```

---

**Documento gerado automaticamente** - Utilize em planejamento de sprints Riverpod
