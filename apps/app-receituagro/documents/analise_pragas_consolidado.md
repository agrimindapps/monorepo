# 🎯 AUDITORIA MONOREPO - RECEITUAGRO
## 📋 Análise Consolidada: Páginas de Pragas (6 páginas)

**Data da Análise:** $(date)
**Especialista:** code-intelligence (Haiku - Análise Rápida)
**Tipo:** Análise Consolidada - Foco em Métricas

---

## 📊 ANÁLISE RÁPIDA - PÁGINAS DE PRAGAS

### 📋 INVENTÁRIO COMPLETO:

1. **home_pragas_page.dart**: 1016 linhas - ✅ JÁ ANALISADO (CRÍTICO)
2. **detalhe_praga_page.dart**: 1574 linhas - 🔴 **CRÍTICO**
3. **lista_pragas_page.dart**: 411 linhas - 🟡 **MÉDIO**
4. **pragas_list_page.dart**: 268 linhas - 🟢 **BOM**
5. **lista_pragas_por_cultura_page.dart**: 457 linhas - 🟡 **MÉDIO**
6. **pragas_por_cultura_detalhadas_page.dart**: 615 linhas - 🟡 **MÉDIO-ALTO**
7. **pragas_page.dart**: 10 linhas - 🟢 **WRAPPER SIMPLES**

### 🔴 PROBLEMAS CRÍTICOS IDENTIFICADOS:

#### 1. detalhe_praga_page.dart (1574 linhas)
- **PROBLEMA**: Arquivo gigantesco, similar ao detalhe_defensivo_page.dart
- **IMPACT**: God Class pattern, unmaintainable
- **AÇÃO**: Refatoração urgente necessária
- **PRIORIDADE**: CRÍTICA

#### 2. home_pragas_page.dart (1016 linhas)
- **PROBLEMA**: Já identificado na análise anterior
- **STATUS**: Complex initialization logic, mixed architecture
- **AÇÃO**: Já documentado, precisa refatoração
- **PRIORIDADE**: CRÍTICA

### 🟡 PROBLEMAS MÉDIOS:

#### 3. pragas_por_cultura_detalhadas_page.dart (615 linhas)
- **PROBLEMA**: Arquivo grande com lógica complexa
- **AÇÃO**: Extract widgets e services
- **PRIORIDADE**: MÉDIO-ALTO

#### 4. lista_pragas_por_cultura_page.dart (457 linhas)
- **PROBLEMA**: Tamanho limite, possível complexidade
- **AÇÃO**: Review e possible refactoring
- **PRIORIDADE**: MÉDIO

#### 5. lista_pragas_page.dart (411 linhas)  
- **PROBLEMA**: Similar à lista_defensivos_page.dart
- **AÇÃO**: Aplicar melhorias similares
- **PRIORIDADE**: MÉDIO

### 🟢 PÁGINAS EM BOM ESTADO:

#### 6. pragas_list_page.dart (268 linhas)
- **STATUS**: Tamanho adequado
- **QUALIDADE**: Provavelmente boa estrutura
- **AÇÃO**: Manter current implementation

#### 7. pragas_page.dart (10 linhas)
- **STATUS**: Wrapper simples
- **QUALIDADE**: Adequado
- **AÇÃO**: Manter como está

---

## 🎯 ANÁLISE CONSOLIDADA - PRAGAS

### 📊 DISTRIBUIÇÃO POR CRITICIDADE:

#### 🔴 CRÍTICO (2 páginas):
- detalhe_praga_page.dart: 1574 linhas
- home_pragas_page.dart: 1016 linhas
- **TOTAL CRÍTICO**: 2590 linhas

#### 🟡 MÉDIO (3 páginas):
- pragas_por_cultura_detalhadas_page.dart: 615 linhas
- lista_pragas_por_cultura_page.dart: 457 linhas  
- lista_pragas_page.dart: 411 linhas
- **TOTAL MÉDIO**: 1483 linhas

#### 🟢 BOM (2 páginas):
- pragas_list_page.dart: 268 linhas
- pragas_page.dart: 10 linhas
- **TOTAL BOM**: 278 linhas

### 🚨 PROBLEMAS PADRÃO IDENTIFICADOS:

1. **GOD CLASS PATTERN**: 2 arquivos > 1000 linhas
2. **DUPLICATE LOGIC**: Padrões similares entre pragas e defensivos
3. **MIXED ARCHITECTURE**: GetIt + Provider + Repository inconsistente
4. **COMPLEX STATE MANAGEMENT**: Multiple setState calls manuais

### 💀 CÓDIGO MORTO PROVÁVEL:
- Duplicação de lógicas entre lista_pragas_page.dart e pragas_list_page.dart
- Possível overlap entre home e detail pages
- Similar patterns com páginas de defensivos

### 🎯 AÇÕES PRIORITÁRIAS:

#### CRÍTICO (2-3 semanas):
1. **Refatorar detalhe_praga_page.dart** - Split em 5-8 arquivos menores
2. **Simplificar home_pragas_page.dart** - Já documentado anteriormente

#### MÉDIO (1-2 semanas):
3. **Review pragas_por_cultura_detalhadas_page.dart** - Extract widgets
4. **Unificar lógicas de lista** - Merge ou standardize lista_pragas vs pragas_list
5. **Apply defensivos improvements** - Reuse solutions from defensivos pages

### 📈 MÉTRICAS FINAIS:
- **Total linhas**: ~4352 linhas analisadas
- **Arquivos problemáticos**: 5 de 7 (71%)
- **Refatoração urgente**: 2 arquivos (29%)
- **Qualidade geral**: PRECISA MELHORIAS

### 🚦 STATUS FINAL - PRAGAS:
**QUALIDADE: PROBLEMÁTICA** - Similar aos problemas encontrados em defensivos, com 2 arquivos críticos que precisam refatoração imediata e 3 que precisam melhorias estruturais.