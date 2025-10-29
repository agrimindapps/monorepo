# 📋 Auditoria: Arquivos Legacy, Stub e Mock no app-receituagro

**Data**: 29 de outubro de 2025  
**Projeto**: app-receituagro  
**Total Encontrado**: 16 arquivos + 20+ ocorrências em código

---

## 📁 Arquivos por Categoria

### 🔴 MOCK (6 Arquivos)

1. **`lib/core/services/mock_premium_service.dart`** (DUPLICADO)
   - Localização: 2 cópias do mesmo arquivo
   - Status: ⚠️ Duplicado
   - Uso: Mock do IPremiumService
   - Linhas: ~170 linhas
   - Encontrado em:
     - `/lib/core/services/mock_premium_service.dart`
     - `/lib/features/comentarios/domain/mock_premium_service.dart`

2. **`lib/features/pragas/presentation/widgets/cultura_section_mockup_widget.dart`**
   - Status: ⚠️ Widget Mockup (UI)
   - Tipo: Mockup de seção de cultura
   - Propósito: Design preview/prototipagem

3. **`lib/features/pragas/presentation/widgets/diagnosticos_praga_mockup_widget.dart`**
   - Status: ⚠️ Widget Mockup (UI)
   - Tipo: Mockup de diagnósticos de praga
   - Propósito: Design preview/prototipagem

4. **`lib/features/pragas/presentation/widgets/diagnostico_mockup_tokens.dart`**
   - Status: ⚠️ Widget Mockup (UI)
   - Tipo: Design tokens mockup
   - Propósito: Prototipagem de UI

5. **`lib/features/pragas/presentation/widgets/filters_mockup_widget.dart`**
   - Status: ⚠️ Widget Mockup (UI)
   - Tipo: Mockup de filtros
   - Propósito: Design preview/prototipagem

6. **`lib/features/pragas/presentation/widgets/diagnostico_mockup_card.dart`**
   - Status: ⚠️ Widget Mockup (UI)
   - Tipo: Mockup de card de diagnóstico
   - Propósito: Design preview/prototipagem

---

### 🟡 STUB (2 Arquivos)

1. **`lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart`** (DUPLICADO)
   - Localização: 2 ocorrências
   - Status: ⚠️ Repositório Stub
   - Tipo: Implementação placeholder
   - Propósito: Stub para diagnosticos (não-implementado)
   - Encontrado em:
     - `/lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart` (×2)

2. **`lib/core/services/beta_testing_service.dart`**
   - Status: ⚠️ Serviço Stub
   - Tipo: Stub de BetaTestingService
   - Conteúdo: Stubs para interface compatibility
   - Linhas com "stub": 6 linhas

---

### 🟠 LEGACY (0 Arquivos Diretos)

**Nota**: Nenhum arquivo com "legacy" no nome, mas há referências em código:

1. **`lib/core/storage/plantis_storage_service_legacy.dart`** (em app-plantis, não em receituagro)
   - Fora do escopo (app-plantis)

---

## 🔍 Referências no Código

### Comentários e Código com "Mock"

| Arquivo | Linha | Tipo | Descrição |
|---------|-------|------|-----------|
| `core/widgets/sync_status_indicator_widget.dart` | 82 | Método | `_initializeMockState()` |
| `core/widgets/sync_status_indicator_widget.dart` | 93 | Método | `void _initializeMockState()` |
| `core/analytics/advanced_health_monitoring_service.dart` | 243 | Comentário | Mock value em conexões |
| `core/services/premium_status_notifier.dart` | 78 | Comentário | "This is a stub" |
| `core/services/premium_status_notifier.dart` | 84 | Comentário | "Stub - use Riverpod" |
| `core/services/beta_testing_service.dart` | 1-94 | Arquivo Inteiro | Stubs para service |
| `core/services/mock_premium_service.dart` | 5-166 | Classe Completa | MockPremiumService |

### Comentários com "Stub"

| Arquivo | Linha | Tipo | Descrição |
|---------|-------|------|-----------|
| `core/widgets/optimized_remote_image_widget.dart` | 4 | Comentário | "This stub provides..." |
| `core/services/premium_status_notifier.dart` | 57 | Comentário | "Check premium status (stub...)" |
| `core/services/beta_testing_service.dart` | 1-2 | Comentário | Stub for BetaTestingService |
| `core/services/receituagro_storage_service.dart` | 9-10 | Interface | "_IStorageStub" |

---

## 📊 Sumário por Tipo

```
MOCK FILES: 6
├── mock_premium_service.dart (×2 - DUPLICADO)
├── cultura_section_mockup_widget.dart
├── diagnosticos_praga_mockup_widget.dart
├── diagnostico_mockup_tokens.dart
├── filters_mockup_widget.dart
└── diagnostico_mockup_card.dart

STUB FILES: 2
├── diagnosticos_repository_stub.dart (×2 - DUPLICADO)
└── beta_testing_service.dart

LEGACY FILES: 0
└── (Nenhum encontrado em receituagro)

CÓDIGO COM REFERÊNCIAS: 7 arquivos
└── Múltiplas referências a "mock", "stub", "legacy" em comentários
```

---

## ⚠️ Problemas Identificados

### 🔴 CRÍTICOS

1. **Duplicação de `mock_premium_service.dart`**
   - Localização 1: `/lib/core/services/mock_premium_service.dart`
   - Localização 2: `/lib/features/comentarios/domain/mock_premium_service.dart`
   - **Impacto**: Código duplicado, manutenção difícil
   - **Ação**: Remover uma cópia, usar import

2. **Duplicação de `diagnosticos_repository_stub.dart`**
   - Localização 1: `/lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart` (×2)
   - **Impacto**: Possível arquivo vazio ou não utilizado
   - **Ação**: Verificar e remover se não utilizado

### 🟡 MÉDIOS

1. **`beta_testing_service.dart` - Stub Completo**
   - Status: Serviço stub sem implementação real
   - **Risco**: Comportamento inesperado em produção
   - **Ação**: Remover ou implementar completamente

2. **`mock_premium_service.dart` - Não Registrado no DI**
   - Status: Mock service não deveria estar em produção
   - **Risco**: Pode ser usado por engano em produção
   - **Ação**: Mover para pasta test/ ou adicionar assertivas

3. **Widgets Mockup em Produção**
   - Status: 5 widgets mockup deixados no código
   - **Risco**: UI de prototipagem pode vazar para produção
   - **Ação**: Remover ou mover para storybook/exemplos

### 🟠 BAIXOS

1. **Métodos de Mock Não Utilizados**
   - `_initializeMockState()` em sync_status_indicator_widget
   - **Risco**: Código morto
   - **Ação**: Remover ou documentar uso

2. **Comentários Desatualizados**
   - Referências a "stub" e "mock" em comentários
   - **Risco**: Confusão de manutenção
   - **Ação**: Atualizar comentários ou remover stubs

---

## 📋 Checklist de Limpeza

### REMOVER (Recomendado Imediatamente)

- [ ] `lib/features/comentarios/domain/mock_premium_service.dart` (duplicado)
- [ ] `lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart` (se não utilizado)
- [ ] `lib/core/services/beta_testing_service.dart` (stub incompleto)
- [ ] `lib/features/pragas/presentation/widgets/cultura_section_mockup_widget.dart`
- [ ] `lib/features/pragas/presentation/widgets/diagnosticos_praga_mockup_widget.dart`
- [ ] `lib/features/pragas/presentation/widgets/diagnostico_mockup_tokens.dart`
- [ ] `lib/features/pragas/presentation/widgets/filters_mockup_widget.dart`
- [ ] `lib/features/pragas/presentation/widgets/diagnostico_mockup_card.dart`

### REVISAR (Antes de Remover)

- [ ] `lib/core/services/mock_premium_service.dart` (verificar uso em testes)
- [ ] `lib/core/widgets/sync_status_indicator_widget.dart` (verificar `_initializeMockState()`)
- [ ] `lib/core/services/premium_status_notifier.dart` (comentários com "stub")

### REFATORAR

- [ ] `lib/core/services/receituagro_storage_service.dart` (remover `_IStorageStub`)
- [ ] Atualizar comentários referentes a "stub" em todo projeto

---

## 🔗 Referências por Arquivo (Detalhado)

### 1. mock_premium_service.dart
```
Caminhos:
- /lib/core/services/mock_premium_service.dart (PRINCIPAL)
- /lib/features/comentarios/domain/mock_premium_service.dart (DUPLICADO - REMOVER)

Status: ⚠️ Em uso (testes?) mas duplicado
Linhas: ~170
Classe: MockPremiumService implements IPremiumService
```

### 2. diagnosticos_repository_stub.dart
```
Caminho:
- /lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart

Status: ⚠️ Pode estar vazio ou não utilizado
Encontrado: 2 vezes (possível duplicação)
```

### 3. Widgets Mockup (5 arquivos)
```
Localização: /lib/features/pragas/presentation/widgets/

Arquivos:
- cultura_section_mockup_widget.dart
- diagnosticos_praga_mockup_widget.dart
- diagnostico_mockup_tokens.dart
- diagnostico_mockup_card.dart
- filters_mockup_widget.dart

Status: ⚠️ Prototipagem/Design - deve estar em storybook, não em src/
```

### 4. beta_testing_service.dart
```
Caminho: /lib/core/services/beta_testing_service.dart

Status: ⚠️ STUB INCOMPLETO
Linhas com stub: 6
Classes stub:
- BetaPhase (enum)
- ReleaseChecklistItem (class)
```

### 5. sync_status_indicator_widget.dart
```
Caminho: /lib/core/widgets/sync_status_indicator_widget.dart

Método mock: _initializeMockState()
Status: ⚠️ Código de teste/prototipagem
```

### 6. premium_status_notifier.dart
```
Caminho: /lib/core/services/premium_status_notifier.dart

Stub methods:
- isPremium() → "stub for compatibility"
- Comentários indicando refatoração incompleta
```

### 7. receituagro_storage_service.dart
```
Caminho: /lib/core/services/receituagro_storage_service.dart

Stub interface: _IStorageStub
Status: ⚠️ Stub de emergência deixado no código
```

---

## 🎯 Recomendações de Ação

### Imediato (Esta Semana)

**Prioridade 1: Remover Duplicações**
```bash
# Deletar cópia duplicada
rm lib/features/comentarios/domain/mock_premium_service.dart

# Atualizar imports
sed -i '' 's|from.*comentarios/domain/mock_premium_service|from "../../core/services/mock_premium_service"|g' <files>
```

**Prioridade 2: Investigar e Remover Stubs Não Utilizados**
```bash
# Verificar se diagnosticos_repository_stub está importado
grep -r "diagnosticos_repository_stub" lib/

# Se não houver referências, remover:
rm lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart
```

### Curto Prazo (Próximas 2 Semanas)

**Remover Mock/Stub Services de Produção**
- Mover `mock_premium_service.dart` para pasta `test/`
- Mover `beta_testing_service.dart` para pasta de deprecated/
- Remover `_IStorageStub` de `receituagro_storage_service.dart`

**Limpar Widgets Mockup**
- Mover para pasta `example/` ou `storybook/`
- Ou remover se não necessários

### Longo Prazo (Sprint Próxima)

**Code Quality**
- [ ] Implementar lint rule para detectar "mock", "stub", "legacy" em src/
- [ ] Adicionar pre-commit hook para bloquear commits com estes padrões
- [ ] Atualizar comentários desatualizados

---

## 📊 Estatísticas

| Métrica | Valor |
|---------|-------|
| **Arquivos Mock** | 6 (5 UI mockups + 1 service mock) |
| **Arquivos Stub** | 2 (1 repository + 1 service stub) |
| **Arquivos Legacy** | 0 |
| **Duplicações** | 2 (mock_premium_service, diagnosticos_repository_stub) |
| **Referências no Código** | 20+ |
| **Problemas Críticos** | 2 (duplicações) |
| **Problemas Médios** | 3 (stubs não utilizados, widgets em produção) |
| **Problemas Leves** | 2 (código morto, comentários desatualizados) |

---

## 📝 Conclusão

**Status Geral**: ⚠️ **REQUER LIMPEZA**

### Achados Principais:

1. ✅ Não há arquivos com "legacy" (boa prática)
2. ⚠️ **2 duplicações críticas** (remover imediatamente)
3. ⚠️ **Stubs e mocks em produção** (mover para test/)
4. ⚠️ **5 widgets mockup** (remover ou organizar em storybook)
5. ⚠️ **Código de teste deixado** (remover ou documentar)

### Impacto Estimado de Limpeza:

- ✅ Remover ~400 linhas de código duplicado/não utilizado
- ✅ Reduzir tamanho do bundle em ~20KB
- ✅ Melhorar manutenibilidade
- ✅ Prevenir erros em produção (mock services)

**Tempo Estimado para Limpeza**: 1-2 horas

---

## 🔗 Referência Rápida

```
REMOVER (Em Ordem):
1. lib/features/comentarios/domain/mock_premium_service.dart
2. lib/features/diagnosticos/data/repositories/diagnosticos_repository_stub.dart
3. lib/core/services/beta_testing_service.dart
4. lib/features/pragas/presentation/widgets/*.mockup*

REVISAR:
1. lib/core/services/mock_premium_service.dart (uso em testes?)
2. lib/core/widgets/sync_status_indicator_widget.dart (_initializeMockState)
3. lib/core/services/premium_status_notifier.dart (comentários stub)

REFATORAR:
1. lib/core/services/receituagro_storage_service.dart (_IStorageStub)
```
