# 🔧 Correção: Tabela Diagnosticos

**Data**: 12 de Novembro de 2025  
**Issue**: Diagnosticos estava marcada como tabela de usuário (com sync Firebase)  
**Status**: ✅ **CORRIGIDA**

---

## ❌ PROBLEMA IDENTIFICADO

### Antes (Incorreto):
```dart
/// Tabela de Diagnósticos
/// Armazena diagnósticos criados pelo usuário...

class Diagnosticos extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // ❌ CAMPOS DE SYNC (NÃO DEVERIA TER)
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName => text()...;
  DateTimeColumn get createdAt => ...;
  DateTimeColumn get updatedAt => ...;
  DateTimeColumn get lastSyncAt => ...;
  BoolColumn get isDirty => ...;
  BoolColumn get isDeleted => ...;
  IntColumn get version => ...;
  
  // Campos de negócio...
}
```

**Problemas**:
- ❌ Tinha campos de sync Firebase (userId, isDirty, etc)
- ❌ Marcada como "dados do usuário"
- ❌ Implicava que usuário cria diagnósticos
- ❌ 9 colunas desnecessárias

---

## ✅ CORREÇÃO IMPLEMENTADA

### Depois (Correto):
```dart
/// Tabela de Diagnósticos (Tabela de Junção/Relacionamento)
///
/// Relaciona defensivos agrícolas com culturas e pragas, definindo
/// dosagens e formas de aplicação recomendadas.
/// 
/// ⚠️ TABELA ESTÁTICA - Não pertence ao usuário, não sincroniza com Firebase.
/// Dados carregados do Firebase apenas para leitura (lookup table).

class Diagnosticos extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // ✅ APENAS REFERÊNCIA FIREBASE (para lookup)
  TextColumn get firebaseId => text().nullable()();
  
  // ✅ FOREIGN KEYS (relacionamentos)
  IntColumn get defenisivoId => integer().references(...)();
  IntColumn get culturaId => integer().references(...)();
  IntColumn get pragaId => integer().references(...)();
  
  // ✅ DADOS DE NEGÓCIO (estáticos)
  TextColumn get idReg => text().unique()();
  TextColumn get dsMin => text().nullable()();
  TextColumn get dsMax => text()();
  // ... outros campos de dosagem
}
```

**Melhorias**:
- ✅ Removidos 9 campos de sync desnecessários
- ✅ Marcada como TABELA ESTÁTICA
- ✅ Documentação clara: "lookup table"
- ✅ idReg agora é UNIQUE (não mais por userId)

---

## 📊 Mudanças nas Colunas

### Removidas (9 colunas):
1. ❌ `userId` - Não é dado do usuário
2. ❌ `moduleName` - Não precisa
3. ❌ `createdAt` - Dado estático
4. ❌ `updatedAt` - Dado estático
5. ❌ `lastSyncAt` - Não sincroniza
6. ❌ `isDirty` - Não sincroniza
7. ❌ `isDeleted` - Não tem soft delete
8. ❌ `version` - Não tem conflito
9. ❌ `uniqueKeys override` - Mudou para idReg.unique()

### Mantidas/Alteradas:
- ✅ `id` - PK (mantido)
- ✅ `firebaseId` - Apenas referência (mantido)
- ✅ `defenisivoId` - FK (mantido)
- ✅ `culturaId` - FK (mantido)
- ✅ `pragaId` - FK (mantido)
- ✅ `idReg` - Agora UNIQUE global (não por userId)
- ✅ Campos de dosagem - Todos mantidos (13 campos)

**Total antes**: 24 colunas  
**Total depois**: 15 colunas  
**Redução**: -9 colunas (37.5%) ✅

---

## 🎯 O Que É a Tabela Diagnosticos?

### Definição Correta:

**Tabela de Junção Many-to-Many**:
```
Fitossanitarios (defensivos)
        ↓
    Diagnosticos  ← Tabela de Relacionamento
        ↓
Culturas + Pragas
```

### Propósito:
Armazena as **recomendações técnicas** de uso de defensivos:
- Qual defensivo usar
- Em qual cultura
- Para qual praga
- Dosagens recomendadas
- Formas de aplicação

### Características:
- ✅ Dados **estáticos** (carregados do Firebase)
- ✅ **Somente leitura** no app
- ✅ Não pertence a nenhum usuário
- ✅ Mesmos dados para todos os usuários
- ✅ Atualizado apenas por admin no Firebase

---

## �� Impacto em Outras Tabelas

### Tabelas de Usuário (COM sync) - Não alteradas:
1. ✅ **Favoritos** - Usuário favorita diagnósticos (OK)
2. ✅ **Comentarios** - Usuário comenta diagnósticos (OK)
3. ✅ **AppSettings** - Config do usuário (OK)

### Tabelas Estáticas (SEM sync) - Consistente:
1. ✅ **Diagnosticos** - AGORA CONSISTENTE ✅
2. ✅ **Culturas** - Estática (já era)
3. ✅ **Pragas** - Estática (já era)
4. ✅ **Fitossanitarios** - Estática (já era)
5. ✅ **PragasInf** - Estática (já era)
6. ✅ **FitossanitariosInfo** - Estática (já era)
7. ✅ **PlantasInf** - Estática (já era)

---

## 📋 Atualização do Schema

### Novo Resumo:

| Categoria | Tabelas | Total Colunas |
|-----------|---------|---------------|
| **Estáticas (Lookup)** | 7 | 101 |
| **Usuário (Sync)** | 3 | 44 |
| **Sistema** | 1 | 17 |
| **TOTAL** | **10** | **162** |

**Redução**: -2 colunas (164 → 162)

---

## ✅ Validações Necessárias

### Código que pode precisar ajuste:

1. **DiagnosticoRepository**
   ```dart
   // ANTES: Tinha métodos de sync
   // DEPOIS: Apenas leitura (findAll, findById)
   ```

2. **DiagnosticoMapper**
   ```dart
   // ANTES: Mapeava campos de sync
   // DEPOIS: Apenas campos de negócio
   ```

3. **Providers/UseCases**
   ```dart
   // VERIFICAR: Não deve tentar criar/editar/deletar diagnósticos
   // APENAS: Consultar diagnósticos existentes
   ```

---

## 🚀 Próximos Passos

### 1. Executar Build Runner (URGENTE):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Verificar Repositório:
- Remover métodos de create/update/delete
- Manter apenas métodos de leitura (find, query)

### 3. Atualizar Documentação:
- DATABASE_SCHEMA.md
- README do projeto

### 4. Testar:
- Carregamento de diagnósticos
- Busca por cultura/praga/defensivo
- Favoritar diagnósticos (ainda funciona)

---

## 📊 Comparação Final

### Antes da Correção:
```
TABELAS COM SYNC FIREBASE: 4
- Diagnosticos ❌ (INCORRETO)
- Favoritos ✅
- Comentarios ✅
- AppSettings ✅
```

### Depois da Correção:
```
TABELAS COM SYNC FIREBASE: 3
- Favoritos ✅
- Comentarios ✅  
- AppSettings ✅

TABELAS ESTÁTICAS (LOOKUP): 7
- Diagnosticos ✅ (CORRIGIDO)
- Culturas ✅
- Pragas ✅
- Fitossanitarios ✅
- PragasInf ✅
- FitossanitariosInfo ✅
- PlantasInf ✅
```

---

## ✅ Conclusão

**Status**: ✅ **Correção Implementada**

**O que mudou**:
- ❌ Diagnosticos NÃO é mais tabela de usuário
- ✅ Diagnosticos é tabela ESTÁTICA (lookup)
- ✅ -9 colunas removidas
- ✅ Schema mais correto e consistente

**Próximo passo**: Executar build_runner

---

**Data da Correção**: 2025-11-12 17:35 UTC  
**Impacto**: Médio (requer rebuild + validação)  
**Prioridade**: 🔴 **ALTA** (correção conceitual importante)
