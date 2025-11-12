# 🗄️ Schema do Banco de Dados - App ReceitaAgro (ATUALIZADO)

**Database**: Drift (SQLite)  
**Versão**: 1.1 (Corrigido em 12/Nov/2025)  
**Total de Tabelas**: 10  
**Total de Colunas**: 155 (reduzido de 164)

---

## 📊 MUDANÇA IMPORTANTE

### Diagnosticos: De Tabela de Usuário → Tabela Estática

**Antes**: Diagnosticos era marcada como "dados do usuário" com sync Firebase  
**Depois**: Diagnosticos é **tabela de lookup estática** (somente leitura)

**Colunas removidas**: 9 (userId, timestamps, sync fields)  
**Colunas finais**: 15 (redução de 37.5%)

---

## 📋 CATEGORIZAÇÃO CORRIGIDA

| Categoria | Tabelas | Colunas | Sync Firebase |
|-----------|---------|---------|---------------|
| **Estáticas (Lookup)** | 7 | 98 | ❌ Não |
| **Usuário (Dinâmicas)** | 2 | 27 | ✅ Sim |
| **Sistema** | 1 | 17 | Parcial |
| **TOTAL** | **10** | **155** | - |

---

## 🗂️ TABELAS ESTÁTICAS (7 - Somente Leitura)

### 1. **Diagnosticos** (15 colunas) ⚠️ CORRIGIDA

**Propósito**: Tabela de junção/relacionamento entre defensivos, culturas e pragas.

**Colunas**:
```dart
✅ id (PK)
✅ firebaseId (referência Firebase - não sync)
✅ defenisivoId (FK → Fitossanitarios)
✅ culturaId (FK → Culturas)
✅ pragaId (FK → Pragas)
✅ idReg (UNIQUE - ID único global)
✅ dsMin, dsMax, um (dosagens)
✅ minAplicacaoT, maxAplicacaoT, umT (aplicação terrestre)
✅ minAplicacaoA, maxAplicacaoA, umA (aplicação aérea)
✅ intervalo, intervalo2, epocaAplicacao
```

**Características**:
- ✅ Dados estáticos (carregados do Firebase na inicialização)
- ✅ Somente leitura (sem create/update/delete por usuário)
- ✅ Mesmos dados para todos os usuários
- ✅ Atualizado apenas por admin no backend

---

### 2. **Culturas** (6 colunas)
- Culturas agrícolas (milho, soja, café, etc)

### 3. **Pragas** (6 colunas)
- Pragas e doenças

### 4. **Fitossanitarios** (20 colunas)
- Defensivos agrícolas

### 5. **PragasInf** (9 colunas)
- Informações complementares de pragas

### 6. **FitossanitariosInfo** (14 colunas)
- Informações técnicas de defensivos

### 7. **PlantasInf** (31 colunas)
- Informações agronômicas de culturas

---

## �� TABELAS DO USUÁRIO (2 - Com Sync Firebase)

### 1. **Favoritos** (14 colunas)

**Propósito**: Itens favoritados pelo usuário

**Campos de Sync**:
- firebaseId, userId, moduleName
- createdAt, updatedAt, lastSyncAt
- isDirty, isDeleted, version

**Campos de Negócio**:
- tipo (defensivo, praga, diagnostico, cultura)
- itemId
- itemData (JSON)

---

### 2. **Comentarios** (13 colunas)

**Propósito**: Comentários do usuário sobre diagnósticos

**Campos de Sync**:
- firebaseId, userId, moduleName
- createdAt, updatedAt, lastSyncAt
- isDirty, isDeleted, version

**Campos de Negócio**:
- diagnosticoId
- conteudo

---

## ⚙️ TABELA DE SISTEMA (1)

### **AppSettings** (17 colunas)

**Propósito**: Configurações do aplicativo por usuário

**Campos**:
- userId (UNIQUE)
- theme, language, notifications
- autoSync, syncInterval, lastSync
- dataVersion, cacheSize, offlineMode
- analytics, crashReports
- premium, premiumExpiresAt
- createdAt, updatedAt

---

## 🔗 Relacionamentos

```
┌─────────────────────────────────────────────┐
│           DIAGRAMA ATUALIZADO               │
└─────────────────────────────────────────────┘

TABELAS ESTÁTICAS (Dados globais, somente leitura):

Diagnosticos (LOOKUP)
├─→ Fitossanitarios (RESTRICT)
├─→ Culturas (RESTRICT)
└─→ Pragas (RESTRICT)

PragasInf → Pragas (CASCADE)
FitossanitariosInfo → Fitossanitarios (CASCADE)
PlantasInf → Culturas (CASCADE)

TABELAS DE USUÁRIO (Dados pessoais, sync Firebase):

Favoritos
└── (tipo + itemId) → Referência polimórfica para:
    - Diagnosticos
    - Culturas
    - Pragas
    - Fitossanitarios

Comentarios
└── diagnosticoId → Diagnosticos (sem FK formal)
```

---

## 📊 Estatísticas Atualizadas

| Métrica | Antes | Depois | Mudança |
|---------|-------|--------|---------|
| **Total de Colunas** | 164 | 155 | -9 ✅ |
| **Tabelas com Sync** | 4 | 2 | -2 ✅ |
| **Tabelas Estáticas** | 6 | 7 | +1 ✅ |
| **Foreign Keys** | 6 | 6 | - |
| **Unique Constraints** | 8 | 8 | - |
| **Índices Automáticos** | 24+ | 24+ | - |

---

## 🎯 Fluxo de Dados Correto

### Inicialização do App:

```
1. App inicia
2. Carrega dados estáticos do Firebase:
   ✅ Culturas
   ✅ Pragas  
   ✅ Fitossanitarios
   ✅ Diagnosticos ← LOOKUP (somente leitura)
   ✅ *Info tables
3. Usuário faz login
4. Sincroniza dados pessoais:
   ✅ Favoritos
   ✅ Comentarios
   ✅ AppSettings
```

### Uso do App:

```
BUSCA DE DIAGNÓSTICO:
Usuário seleciona: Cultura + Praga
   ↓
App consulta Diagnosticos (LOOKUP)
   ↓
Retorna defensivos recomendados
   ↓
Usuário pode FAVORITAR (cria registro em Favoritos)
Usuário pode COMENTAR (cria registro em Comentarios)
```

---

## ✅ Validações Implementadas

### Build Runner:
```bash
✅ flutter pub run build_runner build
   - 535 outputs gerados
   - 0 erros
   - Build em 41s
```

### Schema Consistency:
- ✅ Diagnosticos sem campos de sync
- ✅ Apenas 2 tabelas com sync (Favoritos, Comentarios)
- ✅ 7 tabelas estáticas (incluindo Diagnosticos)
- ✅ Relacionamentos mantidos

---

## 🚀 Impacto da Mudança

### Benefícios:

1. **Clareza Conceitual** ✅
   - Separação clara: dados globais vs dados do usuário
   - Schema mais fácil de entender

2. **Performance** ✅
   - -9 colunas na tabela mais consultada
   - Menos índices desnecessários
   - Queries mais simples

3. **Manutenibilidade** ✅
   - Código mais limpo
   - Menos lógica de sync
   - Menos pontos de falha

4. **Consistência** ✅
   - Alinhado com modelo de negócio
   - Evita confusão sobre ownership dos dados

---

## 📝 Migrações Futuras

### Se Precisar Adicionar Dados do Usuário:

**NÃO fazer**: Adicionar campos de usuário em Diagnosticos

**FAZER**: Criar nova tabela:
```dart
class UserDiagnosticos extends Table {
  // Campos de sync
  IntColumn get diagnosticoId => integer().references(Diagnosticos, #id)();
  TextColumn get userId => text()();
  TextColumn get observacoes => text().nullable()();
  // etc...
}
```

---

## 🎯 Resumo Final

### Schema Atualizado:

**10 Tabelas | 155 Colunas**

**Estáticas (7 tabelas - 98 cols)**:
- Diagnosticos ✅ CORRIGIDA
- Culturas
- Pragas  
- Fitossanitarios
- PragasInf
- FitossanitariosInfo
- PlantasInf

**Usuário (2 tabelas - 27 cols)**:
- Favoritos
- Comentarios

**Sistema (1 tabela - 17 cols)**:
- AppSettings

**Capacidade**: ~2 MB dados / 50 MB máximo

---

**Versão**: 1.1  
**Data da Correção**: 2025-11-12 17:40 UTC  
**Status**: ✅ **Schema Corrigido e Validado**  
**Build**: ✅ **Sucesso** (41s, 535 outputs)
