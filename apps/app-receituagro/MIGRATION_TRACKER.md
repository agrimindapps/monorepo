# 🚀 HIVE → DRIFT MIGRATION TRACKER

## 📊 Status Geral
- **Início**: 11/11/2025
- **Estratégia**: Substituição direta (sem dual-write)
- **Progresso**: 0/19 arquivos migrados

---

## ✅ FASE 1: CulturaLegacyRepository → CulturasRepository

### 📝 Arquivos a Migrar (19 total)

#### Core Services (8 arquivos)
- [ ] `lib/core/services/app_data_manager.dart`
- [ ] `lib/core/services/data_initialization_service.dart`
- [ ] `lib/core/services/diagnostico_entity_resolver.dart`
- [ ] `lib/core/services/data_integrity_validator.dart`
- [ ] `lib/core/services/culturas_data_loader.dart`
- [ ] `lib/core/services/diagnostico_compatibility_service.dart`
- [ ] `lib/core/extensions/diagnostico_hive_extension.dart`

#### Features - Culturas (2 arquivos)
- [ ] `lib/features/culturas/lista_culturas_page.dart`
- [ ] `lib/features/culturas/data/repositories/culturas_repository_impl.dart`

#### Features - Defensivos (2 arquivos)
- [ ] `lib/features/defensivos/presentation/widgets/detalhe/diagnosticos_tab_widget.dart`
- [ ] `lib/features/defensivos/presentation/widgets/detalhe/diagnosticos_defensivos_components/culture_section_widget.dart`

#### Features - Pragas (2 arquivos)
- [ ] `lib/features/pragas/presentation/providers/diagnosticos_praga_notifier.dart`
- [ ] `lib/features/pragas/presentation/providers/home_pragas_notifier.dart`

#### Features - Pragas por Cultura (1 arquivo)
- [ ] `lib/features/pragas_por_cultura/data/repositories/pragas_cultura_repository_impl.dart`

#### Features - Favoritos (2 arquivos)
- [ ] `lib/features/favoritos/data/services/favoritos_data_resolver_strategy.dart`
- [ ] `lib/features/favoritos/data/services/favoritos_storage_service.dart`

#### Features - Busca Avançada (2 arquivos)
- [ ] `lib/features/busca_avancada/services/busca_data_loading_service.dart`
- [ ] `lib/features/busca_avancada/data/mappers/busca_mapper.dart`

---

## 🔄 Padrão de Substituição

### 1. Import
```dart
# ANTES
import '../data/repositories/cultura_legacy_repository.dart';

# DEPOIS  
import '../database/repositories/culturas_repository.dart';
```

### 2. Tipo
```dart
# ANTES
CulturaLegacyRepository _culturaRepository;
final culturaRepo = sl<CulturaLegacyRepository>();

# DEPOIS
CulturasRepository _culturaRepository;
final culturaRepo = sl<CulturasRepository>();
```

### 3. Modelo
```dart
# ANTES
List<CulturaHive> culturas;
CulturaHive cultura;

# DEPOIS
List<Cultura> culturas;
Cultura cultura;
```

### 4. Métodos
```dart
# ANTES
await repo.getAllItems()
await repo.getItemById(id)
await repo.addItem(item)

# DEPOIS
await repo.findAll()
await repo.findById(id)
await repo.insert(item.toCompanion())
```

---

## 📈 Próximas Fases

### FASE 2: Outros Repositórios Estáticos
- [ ] PragasLegacyRepository → PragasRepository (~12 refs)
- [ ] FitossanitarioLegacyRepository → FitossanitariosRepository (~15 refs)
- [ ] PlantasInfLegacyRepository → PlantasInfRepository (~3 refs)
- [ ] PragasInfLegacyRepository → PragasInfRepository (~3 refs)
- [ ] FitossanitarioInfoLegacyRepository → FitossanitariosInfoRepository (~3 refs)

### FASE 3: Repositórios de Dados do Usuário
- [ ] FavoritosLegacyRepository → FavoritoRepository (~5 refs)
- [ ] ComentariosLegacyRepository → ComentarioRepository (~8 refs)
- [ ] DiagnosticoLegacyRepository → DiagnosticoRepository (~20 refs) ⚠️ CRÍTICO

### FASE 4: Limpeza Final
- [ ] Remover 30 arquivos legacy
- [ ] Remover Hive do pubspec.yaml
- [ ] Validar build completo
- [ ] Testes de regressão

---

## 🎯 Ordem de Migração (do mais simples ao mais complexo)

### Batch 1 - Pages Simples (2 arquivos)
1. ✅ `lista_culturas_page.dart` - UI read-only simples
2. ✅ `culture_section_widget.dart` - Widget simples

### Batch 2 - Mappers e Loaders (3 arquivos)
3. ✅ `busca_mapper.dart` - Apenas leitura
4. ✅ `busca_data_loading_service.dart` - Service loader
5. ✅ `culturas_data_loader.dart` - Data loader

### Batch 3 - Notifiers (2 arquivos)
6. ✅ `home_pragas_notifier.dart` - State management
7. ✅ `diagnosticos_praga_notifier.dart` - State management

### Batch 4 - Services Complexos (5 arquivos)
8. ✅ `diagnostico_entity_resolver.dart`
9. ✅ `diagnostico_compatibility_service.dart`
10. ✅ `data_initialization_service.dart`
11. ✅ `data_integrity_validator.dart`
12. ✅ `app_data_manager.dart`

### Batch 5 - Repositories Impl (2 arquivos)
13. ✅ `culturas_repository_impl.dart` - Repository wrapper
14. ✅ `pragas_cultura_repository_impl.dart` - Composite repo

### Batch 6 - Favoritos (2 arquivos)
15. ✅ `favoritos_data_resolver_strategy.dart`
16. ✅ `favoritos_storage_service.dart`

### Batch 7 - Widgets Complexos (2 arquivos)
17. ✅ `diagnosticos_tab_widget.dart`
18. ✅ `diagnostico_hive_extension.dart`

---

## ⚠️ Notas Importantes

1. **Tipos de Dados**: Drift usa classes geradas (ex: `Cultura`) vs Hive manual (ex: `CulturaHive`)
2. **Métodos Async**: Todos os métodos Drift retornam `Future` ou `Stream`
3. **Companions**: Para insert/update, usar `.toCompanion()` ou criar `CulturasCompanion`
4. **Watch**: Drift suporta `watchAll()`, `watchById()` para reatividade
5. **Joins**: Usar métodos `*WithJoin()` quando precisar de dados relacionados

---

## 🐛 Issues Conhecidos
_Nenhum ainda_

---

**Última Atualização**: 11/11/2025 - Iniciando migração
