# Relatório de Análise: Dependências GetIt no Monorepo

**Data:** 24 de novembro de 2025  
**Escopo:** Análise completa da pasta `apps/` para identificar resquícios de `GetIt`  
**Objetivo:** Avaliar o status da migração de `GetIt` para `Riverpod`

---

## 📊 Resumo Executivo

A migração de `GetIt` para `Riverpod` está **parcialmente completa** no monorepo. A maioria dos aplicativos está em um **estado híbrido**, utilizando padrões "Bridge" onde providers Riverpod internamente delegam para `GetIt`, ou ainda utilizam `GetIt` diretamente em features legadas.

### Estatísticas Gerais
- **Total de Apps Analisados:** 12
- **Apps com Dependência Ativa de GetIt:** 8
- **Apps em Migração (Híbrido):** 3
- **Apps sem Referências GetIt:** 1 (apenas `web_agrimind_site` foi excluído da análise)

---

## 🔴 Dependências Críticas (Uso Ativo)

### 1. **app-minigames** ⚠️ ALTA PRIORIDADE
**Status:** Dependência crítica e extensiva de `GetIt`

**Uso:**
- Todos os módulos de jogos usam `GetIt` para injeção de dependências
- Features afetadas: 2048, Memory, Soletrando, Sudoku, PingPong, Quiz, Tower, Snake, FlappBird, Caça-Palavra

**Arquivos Principais:**
```
lib/core/di/injection.dart → final getIt = GetIt.instance
lib/features/game_2048/di/game_2048_injection.dart → initGame2048DI(GetIt sl)
lib/features/game_2048/presentation/providers/game_2048_notifier.dart → GetIt.instance
lib/features/memory/di/memory_injection.dart → initMemoryDI(GetIt sl)
lib/features/soletrando/presentation/providers/soletrando_game_notifier.dart → GetIt.I<SoletrandoRepository>()
lib/features/pingpong/presentation/providers/pingpong_notifier.dart → GetIt.I<StartGameUseCase>()
```

**Padrão de Uso:**
```dart
// Dentro dos Notifiers
final sl = GetIt.instance;
_moveTilesUseCase = sl<MoveTilesUseCase>();
_spawnTileUseCase = sl<SpawnTileUseCase>();
```

**Dependências no pubspec.yaml:**
```yaml
get_it: ^9.1.0
injectable: (via core package)
injectable_generator: (via core package)
```

**Impacto:** 🔴 **CRÍTICO** - Não compila sem `GetIt`

---

### 2. **app-gasometer**
**Status:** Uso ativo com padrão "Bridge Provider"

**Uso:**
- Testes usam `GetIt` diretamente
- Notifiers usam Bridge Providers que encapsulam `GetIt`
- Feature `VehicleDeviceNotifier` documenta: "Uses ConnectivityService from dependency_providers.dart (GetIt registered)"

**Arquivos Principais:**
```
test/features/expenses/presentation/pages/add_expense_page_test.dart → GetIt.instance
test/features/maintenance/presentation/pages/add_maintenance_page_test.dart → GetIt.instance
test/helpers/local_di.dart → final localDi = GetIt.instance
lib/features/device_management/presentation/providers/vehicle_device_notifier.dart
```

**Padrão de Uso:**
```dart
// Bridge Pattern
final expensesUseCase = ref.watch(getAllExpensesUseCaseProvider); 
// Internamente: getAllExpensesUseCaseProvider → GetIt.instance<UseCase>()
```

**Impacto:** 🟠 **ALTO** - Testes quebram sem `GetIt`, features funcionam via Bridge

---

### 3. **app-nutrituti**
**Status:** Uso direto de `GetIt` em Controllers e Database

**Uso:**
- Acesso direto ao Database via `GetIt.I<NutritutiDatabase>()`
- Controllers (`PesoController`, `AguaController`) usam `GetIt` para injeção

**Arquivos Principais:**
```
lib/core/di/injection.dart → final getIt = GetIt.instance
lib/pages/peso/controllers/peso_controller.dart → GetIt.I<NutritutiDatabase>()
lib/pages/agua/controllers/agua_controller.dart → final getIt = GetIt.instance
lib/pages/perfil_cadastro_page.dart → GetIt.I.get<PerfilRepository>()
```

**Padrão de Uso:**
```dart
class PesoController extends ChangeNotifier {
  PesoController() : super() {
    _database = GetIt.I<NutritutiDatabase>();
  }
}
```

**Impacto:** 🟠 **ALTO** - Features core dependem de `GetIt`

---

### 4. **app-nebulalist**
**Status:** GetIt encapsulado em Providers Riverpod

**Uso:**
- UseCases registrados via `Injectable`
- Providers Riverpod fazem lookup via `GetIt`

**Arquivos Principais:**
```
lib/core/di/injection.dart → final getIt = GetIt.instance
lib/core/di/injection.config.dart → extension GetItInjectableX on GetIt
lib/features/items/domain/usecases/get_item_masters_usecase.dart → GetItemMastersUseCase
lib/features/items/presentation/providers/item_masters_provider.dart → di.getIt<GetItemMastersUseCase>()
```

**Padrão de Uso:**
```dart
@riverpod
GetItemMastersUseCase getItemMastersUseCase(GetItemMastersUseCaseRef ref) {
  return di.getIt<GetItemMastersUseCase>();
}
```

**Impacto:** 🟡 **MÉDIO** - Bridge funcional, mas ainda depende de `GetIt`

---

## 🟡 Migração Parcial (Estado Híbrido)

### 5. **app-receituagro**
**Status:** Migração documentada, mas código legado ainda presente

**Situação:**
- Documentação extensa de migração (`README_RIVERPOD_MIGRATION.md`, `MIGRATION_STATUS.md`)
- Código com comentários `@Deprecated('Use constructor injection via GetIt or Provider instead')`
- Exemplos "Before (GetIt)" vs "After (Riverpod)" em vários arquivos

**Arquivos com Referências:**
```
lib/core/di/README_RIVERPOD_MIGRATION.md → Guia completo de migração
lib/core/di/MIGRATION_STATUS.md → "Main.dart still uses GetIt pattern"
lib/core/services/premium_service.dart → 3x @Deprecated annotations
lib/core/extensions/diagnostico_drift_extension.dart → "temporariamente desabilitada durante a migração GetIt -> Riverpod"
lib/features/favoritos/data/services/favoritos_service.dart → "evita erro de acesso antes do registro no GetIt"
```

**Próximos Passos Documentados:**
```markdown
1. ✅ Criar providers Riverpod para todos os repositórios
2. 🔄 Refatorar UseCases para aceitar repositórios via parâmetro
3. 🔄 Replace `di.sl<T>()` with `ref.watch(tProvider)`
4. ❌ Remove GetIt from pubspec.yaml entirely
```

**Impacto:** 🟢 **BAIXO** - Funciona com Riverpod, código legado comentado/deprecated

---

### 6. **app-petiveti**
**Status:** Documentação afirma "Migração Completa", mas código ainda presente

**Situação:**
- `docs/ANALYSIS_REPORT.md` lista como "✅ Verificar e remover uso residual de GetIt"
- Arquivo `injectable_config.config.dart` ainda existe com `extension GetItInjectableX on GetIt`
- README.md lista "✅ Dependency Injection (GetIt + Injectable)"

**Arquivos com Referências:**
```
lib/core/di/injectable_config.config.dart → extension GetItInjectableX on GetIt
lib/database/petiveti_database.dart → "Factory constructor para injeção de dependência (GetIt/Injectable)"
docs/ANALYSIS_REPORT.md → Checklist de migração (marcado como completo)
README.md → "get_it: ^7.7.0 # Service locator"
```

**Impacto:** 🟡 **MÉDIO** - Código gerado ainda referencia `GetIt`, pode estar inativo

---

### 7. **app-plantis**
**Status:** Migração parcial com 6 módulos ainda em `GetIt`

**Situação:**
- Documento `RIVERPOD_MIGRATION_STATUS.md` detalha status de migração
- Core providers migrados, mas módulos complexos ainda usam `GetIt`
- README afirma "DI profissional (Injectable + GetIt)"

**Arquivos Principais:**
```
lib/core/di/solid_di_factory.dart → "Registra todas as dependências SOLID no GetIt" (comentado)
lib/database/providers/database_providers.dart → "Injectable no GetIt, exposto via Riverpod"
RIVERPOD_MIGRATION_STATUS.md → "Ainda há 6 módulos usando GetIt.registerLazySingleton()"
docs/ANALYSIS_REPORT.md → Lista features refatoradas para remover GetIt
```

**Status Documentado:**
```markdown
✅ Migração Completa:
- Tasks Providers (removido GetIt)
- Plants Providers (removido GetIt)
- Spaces Provider (removido GetIt)
- Account Providers (removido GetIt)
- Settings Notifier (removido GetIt)

🔄 Ainda em GetIt:
- 6 módulos complexos não especificados
```

**Impacto:** 🟡 **MÉDIO** - Híbrido funcional, migração 70% completa

---

### 8. **app-taskolist**
**Status:** GetIt como Singleton Wrapper para Database

**Uso:**
- Database acessada via `GetIt.I<TaskolistDatabase>()`
- Provider Riverpod encapsula o acesso

**Arquivos Principais:**
```
lib/core/di/injection.config.dart → extension GetItInjectableX on GetIt
lib/core/providers/core_providers.dart → GetIt.I<TaskolistDatabase>()
DRIFT_WEB_MIGRATION_COMPLETE.md → "✅ GetIt - Service locator singleton"
```

**Padrão Documentado:**
```dart
@riverpod
TaskolistDatabase taskolistDatabase(TaskolistDatabaseRef ref) {
  final db = GetIt.I<TaskolistDatabase>();
  return db;
}
```

**Avisos de Análise:**
```
info • The import of 'package:get_it/get_it.dart' is unnecessary 
info • The imported package 'get_it' isn't a dependency of the importing package
```

**Impacto:** 🟡 **MÉDIO** - Funciona, mas análise indica refatoração possível

---

## 🟢 Uso Secundário / Documentação

### 9. **app-calculei**
**Status:** Código de configuração presente, uso real não detectado

**Arquivos:**
```
lib/core/di/injection.config.dart → extension GetItInjectableX on GetIt
README.md → "get_it: ^8.0.2 # Service locator"
```

**Impacto:** 🟢 **BAIXO** - Possivelmente código gerado não utilizado

---

### 10. **app-termostecnicos**
**Status:** Apenas documentação

**Arquivos:**
```
README.md → "get_it: ^8.0.2 # Service locator"
```

**Impacto:** 🟢 **MÍNIMO** - Apenas referência em README

---

### 11. **web_receituagro**
**Status:** Dependência ativa (Web)

**Arquivos:**
```
lib/core/di/injection.dart → final getIt = GetIt.instance
lib/core/di/injection.config.dart → extension GetItInjectableX on GetIt
pubspec.lock → get_it: 8.2.0 (9.0.5 available)
README.md → "✅ Dependency Injection (Injectable + GetIt)"
```

**Impacto:** 🟠 **ALTO** - Projeto web usa `GetIt` ativamente

---

## 📋 Plano de Ação Recomendado

### Prioridade 1 (Crítico) - 40-60 horas
1. **app-minigames**: Migração completa para Riverpod
   - Criar `@riverpod` providers para todos os UseCases
   - Refatorar 9 features de jogos
   - Remover dependências `get_it` e `injectable`
   - **Complexidade:** ALTA (muitos módulos independentes)

### Prioridade 2 (Alto) - 20-30 horas
2. **app-gasometer**: Eliminar `GetIt` dos testes e finalizar Bridge
   - Substituir `GetIt.instance` nos testes por `ProviderContainer`
   - Documentar padrão Bridge como temporário
   - **Complexidade:** MÉDIA

3. **app-nutrituti**: Migrar Controllers para Riverpod
   - Converter `ChangeNotifier` Controllers para `AsyncNotifier`
   - Criar providers para Database e Repositories
   - **Complexidade:** MÉDIA

### Prioridade 3 (Médio) - 10-15 horas
4. **app-petiveti**: Limpeza de código gerado
   - Verificar se `injectable_config.config.dart` está em uso
   - Remover se inativo, ou documentar dependência
   - **Complexidade:** BAIXA

5. **app-plantis**: Finalizar 6 módulos restantes
   - Identificar quais módulos ainda usam `GetIt.registerLazySingleton()`
   - Migrar conforme padrão já estabelecido
   - **Complexidade:** MÉDIA

6. **app-taskolist**: Refatorar provider do Database
   - Criar provider Riverpod puro sem `GetIt`
   - Atualizar dependências no `pubspec.yaml`
   - **Complexidade:** BAIXA

### Prioridade 4 (Baixo) - 5-8 horas
7. **app-receituagro**: Remover código deprecated
   - Deletar código comentado e arquivos de migração
   - Limpar `@Deprecated` annotations
   - **Complexidade:** BAIXA

8. **web_receituagro**: Migração ou documentação
   - Decidir se mantém `GetIt` (projeto web legado) ou migra
   - **Complexidade:** BAIXA (se documentação) ou ALTA (se migração)

---

## 🎯 Estratégias de Migração

### Padrão Recomendado (Riverpod Puro)
```dart
// ANTES (GetIt)
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial()) {
    _useCase = GetIt.instance<MyUseCase>();
  }
  late final MyUseCase _useCase;
}

// DEPOIS (Riverpod)
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() {
    final useCase = ref.watch(myUseCaseProvider);
    return MyState.initial();
  }
}

@riverpod
MyUseCase myUseCase(MyUseCaseRef ref) {
  return MyUseCase(ref.watch(myRepositoryProvider));
}
```

### Padrão Bridge (Temporário)
```dart
// Para migrações graduais - não recomendado para código novo
@riverpod
MyUseCase myUseCase(MyUseCaseRef ref) {
  return di.getIt<MyUseCase>(); // Delega para GetIt existente
}
```

---

## 📊 Métricas de Migração

| Aplicativo | Status | GetIt Usage | Prioridade | Esforço Estimado |
|-----------|--------|-------------|------------|------------------|
| app-minigames | 🔴 Crítico | Extensivo (9 features) | P1 | 40-60h |
| app-gasometer | 🟠 Alto | Testes + Bridge | P2 | 10-15h |
| app-nutrituti | 🟠 Alto | Controllers + DB | P2 | 10-15h |
| app-nebulalist | 🟡 Médio | Bridge Providers | P3 | 5-8h |
| app-plantis | 🟡 Médio | 6 módulos legados | P3 | 10-15h |
| app-taskolist | 🟡 Médio | DB Singleton | P3 | 3-5h |
| app-petiveti | 🟡 Médio | Código gerado (?) | P3 | 2-4h |
| app-receituagro | 🟢 Baixo | Código deprecated | P4 | 3-5h |
| app-calculei | 🟢 Baixo | Config não usada | P4 | 1-2h |
| web_receituagro | 🟠 Alto | Ativo (Web) | P4 | 2h (doc) ou 20h (migração) |
| app-termostecnicos | 🟢 Mínimo | Apenas README | P4 | 0.5h |

**Total Estimado (Migração Completa):** 87.5 - 145.5 horas

---

## ⚠️ Riscos e Considerações

### Riscos Técnicos
1. **Breaking Changes**: Migração de `GetIt` para Riverpod pode quebrar testes existentes
2. **Estado Compartilhado**: `GetIt` singletons vs Riverpod providers têm ciclo de vida diferente
3. **Código Gerado**: Arquivos `.g.dart` e `.config.dart` precisam ser regenerados
4. **Dependências Circulares**: Algumas podem aparecer durante migração

### Decisões Arquiteturais Pendentes
1. **app-minigames**: Manter estrutura por feature ou centralizar DI?
2. **web_receituagro**: Migrar ou manter `GetIt` para projeto web legado?
3. **Padrão Bridge**: Documentar como antipadrão ou oficializar como transição?

### Compatibilidade
- Alguns apps compilaram com sucesso após **re-adicionar** `GetIt` (`app-minigames`)
- Isso indica que a remoção prévia de `GetIt` pode ter sido prematura
- Recomenda-se migração feature-por-feature em vez de remoção em massa

---

## 📝 Conclusão

O monorepo está em **estado de transição** entre `GetIt` e `Riverpod`. Não há nenhum aplicativo 100% livre de `GetIt`, embora alguns tenham migrações bem avançadas.

**Recomendação:** 
- Para **novos projetos**: usar Riverpod puro desde o início
- Para **projetos existentes**: migração gradual priorizando features críticas
- **Não remover** `GetIt` das dependências até completar migração por app

**Próximo Passo Imediato:**
Decidir se deseja:
1. Aceitar estado híbrido atual (funcional)
2. Iniciar migração completa começando por `app-minigames` (P1)
3. Documentar padrão Bridge como oficial para novos desenvolvedores

---

**Gerado em:** 24 de novembro de 2025  
**Comando de Análise:** `grep -rE "GetIt|get_it|GetIt\.I|sl<|locator<" apps/`  
**Escopo:** Todos os apps exceto `web_agrimind_site`, diretórios de build e plataformas nativas
