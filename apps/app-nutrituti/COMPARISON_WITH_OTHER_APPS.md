# 📊 Comparativo: Migrações Hive → Drift no Monorepo

**Data:** 13/11/2024

---

## 🎯 VISÃO GERAL

| App | Features | Tabelas | DAOs | Métodos | Tempo | Complexidade |
|-----|----------|---------|------|---------|-------|--------------|
| **termostecnicos** | 1 | 1 | 1 | ~10 | 3h | ⭐⭐☆☆☆ |
| **petiveti** | 8 | 8 | 8 | ~120 | 1 dia | ⭐⭐⭐☆☆ |
| **nutrituti** | 6 | 7 | 6 | ~92 | 2-3 dias | ⭐⭐⭐☆☆ |

---

## 📋 DETALHAMENTO POR APP

### 1. app-termostecnicos (MAIS SIMPLES)

**Características:**
- Dicionário de termos técnicos
- Apenas 1 feature com Hive (Comentários)
- Termos carregados de JSON Assets
- Settings usa SharedPreferences

**Escopo:**
- ✅ 1 tabela: Comentarios
- ✅ 1 DAO: ComentarioDao
- ❌ Termos (JSON Assets) - não migrar
- ❌ Settings (SharedPrefs) - não migrar

**Tempo:** 3 horas
**Complexidade:** ⭐⭐☆☆☆ BAIXA
**Status:** ✅ COMPLETO

---

### 2. app-petiveti (REFERÊNCIA PADRÃO)

**Características:**
- App de cuidados com pets
- 8 features com persistência
- Sincronização Firebase
- Clean Architecture

**Escopo:**
- ✅ 8 tabelas: Pet, Vacina, Medicamento, Consulta, Peso, Banho, Alimentação, Lembrete
- ✅ 8 DAOs completos
- ✅ ~120 métodos

**Tempo:** 1 dia
**Complexidade:** ⭐⭐⭐☆☆ MÉDIA
**Status:** ✅ COMPLETO (100% validado)

---

### 3. app-nutrituti (ATUAL)

**Características:**
- App de nutrição e saúde
- 6 features com persistência
- 20+ calculadoras (DTOs, não migrar)
- Clean Architecture (Water feature)
- Offline-first (Exercícios)
- Firebase sync (3 features)

**Escopo:**

#### ✅ PERSISTÊNCIA - PRECISA MIGRAR (6 features)

1. **Perfil** - Dados do usuário
   - Tabela: PerfilTable
   - DAO: PerfilDao (~12 métodos)
   - Complexidade: ⭐⭐☆☆☆

2. **Peso** - Rastreamento
   - Tabela: PesoTable
   - DAO: PesoDao (~15 métodos)
   - Features: Firebase sync + soft delete
   - Complexidade: ⭐⭐⭐☆☆

3. **Água Legacy** - Hidratação
   - Tabela: AguaTable
   - DAO: AguaDao (~15 métodos)
   - Features: Firebase sync + SharedPrefs
   - Complexidade: ⭐⭐⭐☆☆

4. **Water Clean Arch** - Hidratação v2
   - Tabelas: WaterRecordTable + WaterAchievementTable
   - DAO: WaterDao (~20 métodos)
   - Features: Clean Arch + enum + 2 tables
   - Complexidade: ⭐⭐⭐⭐☆

5. **Exercícios** - Atividades físicas
   - Tabela: ExercicioTable
   - DAO: ExercicioDao (~18 métodos)
   - Features: Offline-first + sync queue (3 boxes → 1 table)
   - Complexidade: ⭐⭐⭐⭐☆

6. **Comentários** - Anotações
   - Tabela: ComentarioTable
   - DAO: ComentarioDao (~12 métodos)
   - Complexidade: ⭐☆☆☆☆

#### ❌ DTOs - NÃO PRECISA MIGRAR

**20+ Calculadoras** (estruturas temporárias):
- Adiposidade, Álcool Sangue, Calorias Diárias
- Calorias por Exercício, Cintura Quadril, Composição Corporal
- Deficit Superavit, Densidade Nutrientes, Densidade Óssea
- Gasto Energético, Gordura Corporal, Índice Adiposidade
- Macronutrientes, Massa Corporal, Necessidade Hídrica
- Peso Ideal, Proteínas Diárias, TMB, Volume Sanguíneo

**AtividadeFisicaRepository:**
- Lista estática hardcoded (94 atividades)
- Apenas conversões toMap/fromMap

**Totais:**
- ✅ 7 tabelas Drift
- ✅ 6 DAOs
- ✅ ~92 métodos
- ❌ 20+ calculadoras (ignorar)

**Tempo:** 22 horas (~3 dias)
**Complexidade:** ⭐⭐⭐☆☆ MÉDIA
**Status:** 📋 PLANEJAMENTO COMPLETO

---

## 🎯 ANÁLISE COMPARATIVA

### Por que nutrituti tem 6 features mas leva mais tempo que petiveti (8 features)?

#### Fatores de Complexidade ADICIONAIS em nutrituti:

1. **Clean Architecture (Water)**
   - Primeira feature com Clean Arch completa
   - Domain layer separada
   - 2 tabelas relacionadas
   - Enum converter necessário
   - +1 dia de trabalho adicional

2. **Offline-first (Exercícios)**
   - Sync queue management
   - 3 Hive boxes para consolidar em 1 Drift table
   - Conflict resolution
   - Background sync
   - +1 dia de trabalho adicional

3. **Firebase Sync (3 features)**
   - Peso, Água, Exercícios
   - Dupla persistência (local + remote)
   - Connectivity checks
   - Conflito de dados

4. **Duplicação (Água/Water)**
   - Duas implementações coexistindo
   - Legacy + Clean Arch

#### Fatores que REDUZEM complexidade:

1. **Calculadoras são DTOs**
   - 20+ calculadoras NÃO precisam migração
   - Se fossem persistência, seriam +20 tabelas
   - **Economiza:** ~2 dias de trabalho

2. **AtividadeFisicaRepository é estático**
   - Lista hardcoded, não usa banco
   - Apenas estruturas temporárias
   - **Economiza:** ~1 dia de trabalho

3. **Templates validados**
   - petiveti 100% completo
   - termostecnicos validado
   - Padrões bem definidos
   - **Economiza:** ~1 dia de trabalho

---

## 📊 MÉTRICAS FINAIS

### Comparação Real vs Percepção Inicial

| Métrica | Inicial | Após Análise | Diferença |
|---------|---------|--------------|-----------|
| Arquivos com Hive | 15 | 6 features reais | -9 DTOs |
| Tabelas necessárias | ~15 | 7 | -8 tabelas |
| Tempo estimado | 5-7 dias | 2-3 dias | -3 dias |
| Complexidade | ALTA | MÉDIA | ✅ Reduzida |

### Razão da Diferença

**Inicial (15 arquivos Hive encontrados):**
- ❌ Incluía calculadoras (DTOs)
- ❌ Incluía repositório estático
- ❌ Incluía models temporários

**Após Análise Cirúrgica (6 features reais):**
- ✅ Apenas features COM PERSISTÊNCIA
- ✅ Apenas features COM DATABASE
- ✅ Apenas features COM ESTADO LOCAL

---

## 🎯 CONCLUSÃO

### nutrituti é MÉDIA complexidade porque:

**Pontos Complexos (+):**
- ✅ Clean Architecture (Water)
- ✅ Offline-first (Exercícios)
- ✅ Firebase sync (3 features)
- ✅ Enum converter
- ✅ Sync queue management

**Pontos Simples (-):**
- ✅ 20+ calculadoras não precisam migração
- ✅ Repositório estático não precisa migração
- ✅ Settings já usa SharedPreferences
- ✅ Templates validados disponíveis

**Resultado:** MÉDIA complexidade, 2-3 dias

---

## 📈 PROGRESSÃO DAS MIGRAÇÕES

```
termostecnicos (3h)
    ↓
petiveti (1 dia) ← REFERÊNCIA
    ↓
nutrituti (2-3 dias) ← ATUAL
    ↓
[próximos apps...]
```

**Aprendizados acumulados:**
- ✅ Padrões consolidados
- ✅ Templates validados
- ✅ Processo otimizado
- ✅ Estimativas precisas

---

**📅 Criado:** 13/11/2024  
**🎯 Objetivo:** Documentar diferenças entre migrações  
**📝 Status:** Análise nutrituti COMPLETA
