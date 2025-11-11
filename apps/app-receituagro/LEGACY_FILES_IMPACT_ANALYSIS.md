# 📊 Análise de Impacto - Arquivos Legacy (Hive)

**Data:** 11 de novembro de 2025  
**Status da Migração:** Hive → Drift em andamento

## 🎯 Resumo Executivo

### Status Geral
- **Total de arquivos legacy analisados:** 22 arquivos
- **Arquivos com uso ativo:** 22 (100%)
- **Podem ser removidos agora:** ❌ 0 arquivos
- **Requerem migração:** ✅ Todos

---

## 📁 Categorias de Arquivos Legacy

### 1️⃣ **Modelos de Dados (_legacy.dart)** - 10 arquivos

#### Status: 🔴 **CRÍTICOS - NÃO PODEM SER REMOVIDOS**

| Arquivo | Usos Ativos | Impacto de Remoção |
|---------|-------------|---------------------|
| `cultura_legacy.dart` | 15+ refs | ALTO - Usado em toda aplicação |
| `diagnostico_legacy.dart` | 20+ refs | CRÍTICO - Core do sistema |
| `fitossanitario_legacy.dart` | 15+ refs | ALTO - Defensivos principais |
| `pragas_legacy.dart` | 12+ refs | ALTO - Sistema de pragas |
| `comentario_legacy.dart` | 8+ refs | MÉDIO - Sistema de comentários |
| `favorito_item_legacy.dart` | 5+ refs | MÉDIO - Sistema de favoritos |
| `plantas_inf_legacy.dart` | 3+ refs | BAIXO - Dados complementares |
| `pragas_inf_legacy.dart` | 3+ refs | BAIXO - Dados complementares |
| `fitossanitario_info_legacy.dart` | 3+ refs | BAIXO - Info adicional |
| `premium_status_legacy.dart` | 4+ refs | MÉDIO - Sistema de assinatura |

**Dependências:**
- Usados por: repositories, services, extensions, features, migration tool
- Padrão de nomenclatura: `*Hive` (ex: `DiagnosticoHive`, `CulturaHive`)
- Importados em ~90 arquivos diferentes

**Ação Necessária:** 
✅ Manter até migração completa para Drift
📋 Criar equivalentes Drift antes de remover

---

### 2️⃣ **Repositórios Legacy (*_legacy_repository.dart)** - 10 arquivos

#### Status: 🔴 **CRÍTICOS - USADOS ATIVAMENTE**

| Repositório | Uso no DI | Features Dependentes |
|-------------|-----------|----------------------|
| `CulturaLegacyRepository` | ✅ `sl<>` | Culturas, Busca, Diagnósticos |
| `DiagnosticoLegacyRepository` | ✅ `sl<>` | Diagnósticos (core) |
| `FitossanitarioLegacyRepository` | ✅ `sl<>` | Defensivos, Busca |
| `PragasLegacyRepository` | ✅ `sl<>` | Pragas, Diagnósticos |
| `ComentariosLegacyRepository` | ✅ | Comentários |
| `FavoritosLegacyRepository` | ✅ | Favoritos |
| `PremiumLegacyRepository` | ✅ | Assinatura Premium |
| `PlantasInfLegacyRepository` | ✅ | Info complementar |
| `PragasInfLegacyRepository` | ✅ | Info complementar |
| `FitossanitarioInfoLegacyRepository` | ✅ | Info complementar |

**Locais de Uso:**
```dart
// Injeção de dependência ativa
sl<CulturaLegacyRepository>()
sl<DiagnosticoLegacyRepository>()
sl<FitossanitarioLegacyRepository>()
sl<PragasLegacyRepository>()

// Uso direto em services
final culturaRepo = CulturaLegacyRepository();
final pragasRepo = PragasLegacyRepository();
final fitossanitarioRepo = FitossanitarioLegacyRepository();
final diagnosticoRepo = DiagnosticoLegacyRepository();
```

**Arquivos Consumidores:**
- `app_data_manager.dart`
- `diagnostico_entity_resolver.dart`
- `diagnostico_compatibility_service.dart`
- `fitossanitarios_data_loader.dart`
- `diagnosticos_data_loader.dart`
- Features: defensivos, pragas, culturas, diagnósticos, busca

**Ação Necessária:**
✅ Criar repositórios Drift equivalentes
🔄 Substituir gradualmente as referências
📋 Atualizar sistema de DI

---

### 3️⃣ **Serviços de Suporte** - 2 arquivos

#### `legacy_adapter_registry.dart`
- **Status:** 🟡 PARCIALMENTE DESATIVADO
- **Função:** Registro de adapters Hive
- **Código atual:** Todos os `registerAdapter()` estão comentados
- **Usos ativos:** 12 referências
  - `receituagro_data_cleaner.dart` (6 usos)
  - `main.dart` (1 uso - inicialização)
  
**Impacto de Remoção:** BAIXO
- Adapters já estão desativados
- Pode ser removido após:
  1. Remover chamada em `main.dart`
  2. Atualizar `receituagro_data_cleaner.dart`

#### `legacy_migration_service.dart`
- **Status:** 🔴 ATIVO (se usado)
- **Função:** Migração de dados Hive antigos
- **Necessário para:** Usuários com dados legacy

**Ação:** Verificar se há usuários com dados antigos antes de remover

---

### 4️⃣ **Utilitários** - 1 arquivo

#### `box_manager.dart`
- **Status:** 🔴 **CRÍTICO - AMPLAMENTE USADO**
- **Função:** Gerenciamento seguro de boxes Hive
- **Usos:** 26+ referências diretas

**Arquivos Dependentes:**
```dart
// Extensions
diagnostico_enrichment_extension.dart (5 usos)

// Services  
data_integrity_service.dart (3 usos)
user_data_repository.dart (6 usos)

// Migration
hive_to_drift_migration_tool.dart (3 usos)
```

**Métodos usados:**
- `BoxManager.withBox<T, R>()` - Operação com fechamento automático
- `BoxManager.readBox<T, R>()` - Leitura sem fechar (usado em extensions)
- `BoxManager.withMultipleBoxes<R>()` - Múltiplas boxes simultâneas

**Impacto de Remoção:** CRÍTICO
- Sistema atual depende completamente
- Necessário até migração completa

---

## 🔍 Análise de Dependências Transitivas

### Arquivos que usam modelos legacy:

#### Core do Sistema
1. **`diagnostico_with_warnings.dart`**
   - Usa: 4 modelos legacy (Diagnostico, Cultura, Fitossanitario, Pragas)
   - Função: Wrapper para enriquecimento de dados
   - Impacto: CRÍTICO

2. **`diagnostico_enrichment_extension.dart`**
   - Usa: 4 modelos + BoxManager
   - Função: Extensions para enriquecer diagnósticos
   - Impacto: CRÍTICO

3. **`data_integrity_service.dart`**
   - Usa: 4 modelos + BoxManager
   - Função: Validação de integridade referencial
   - Impacto: ALTO

#### Features
4. **Defensivos** (5 arquivos)
   - `detalhe_defensivo_page.dart`
   - `defensivo_item_widget.dart`
   - `defensivo_details_entity.dart`
   - `defensivo_mapper.dart`
   - `diagnosticos_tab_widget.dart`

5. **Pragas** (4 arquivos)
   - `praga_entity.dart`
   - `praga_mapper.dart`
   - `detalhe_praga_notifier.dart`

6. **Culturas** (3 arquivos)
   - `lista_culturas_page.dart`
   - `cultura_item_widget.dart`
   - `cultura_mapper.dart`

7. **Diagnósticos** (2 arquivos)
   - `detalhe_diagnostico_notifier.dart`
   - `diagnostico_mapper.dart`

8. **Busca Avançada** (1 arquivo)
   - `busca_mapper.dart` - Usa 4 modelos

#### Sync & Conflict Resolution
9. **`conflict_resolver.dart`** - Comentário e Diagnóstico
10. **`sync_operations.dart`** - Diagnóstico
11. **`diagnostico_grouping_service.dart`**

#### Migration
12. **`hive_to_drift_migration_tool.dart`**
    - Usa: 3 modelos (Diagnostico, Favorito, Comentario)
    - Função: Tool de migração Hive → Drift
    - Status: ESSENCIAL durante migração

---

## 📊 Estatísticas de Uso

### Modelos Mais Usados (Top 5)
1. **DiagnosticoHive** - ~20+ referências diretas
2. **FitossanitarioHive** - ~15+ referências
3. **CulturaHive** - ~15+ referências
4. **PragasHive** - ~12+ referências
5. **ComentarioHive** - ~8+ referências

### Repositórios Mais Usados
1. **DiagnosticoLegacyRepository** - Core system
2. **FitossanitarioLegacyRepository** - Defensivos
3. **CulturaLegacyRepository** - Culturas
4. **PragasLegacyRepository** - Pragas

---

## ⚠️ Riscos de Remoção Prematura

### Se removermos agora:
1. ❌ **Build quebra completamente** - ~90 arquivos com imports
2. ❌ **Features principais param** - Diagnósticos, Defensivos, Pragas, Culturas
3. ❌ **Dados de usuários perdidos** - Sem caminho de migração
4. ❌ **Sistema de sync falha** - Conflict resolution depende de modelos
5. ❌ **Tool de migração inoperante** - Precisa de ambos os sistemas

---

## ✅ Plano de Migração Recomendado

### Fase 1: Preparação (Atual)
- [x] Renomear arquivos Hive → Legacy
- [ ] Criar modelos Drift equivalentes
- [ ] Criar repositórios Drift equivalentes
- [ ] Implementar camada de compatibilidade

### Fase 2: Migração Gradual
- [ ] Implementar dual-write (Hive + Drift)
- [ ] Migrar dados existentes (migration tool)
- [ ] Atualizar features uma a uma para usar Drift
- [ ] Validar integridade dos dados

### Fase 3: Transição
- [ ] Mudar reads para Drift
- [ ] Desativar writes em Hive
- [ ] Período de observação (1-2 semanas)
- [ ] Validar que todos os dados foram migrados

### Fase 4: Limpeza (Futuro)
- [ ] Remover `BoxManager` e substituir por repositórios Drift
- [ ] Remover repositories legacy
- [ ] Remover modelos legacy
- [ ] Remover `legacy_adapter_registry.dart`
- [ ] Remover dependência do Hive do pubspec.yaml
- [ ] Atualizar documentação

---

## 🎯 Próximos Passos Imediatos

### 1. Consolidar a Migração

#### A. Criar Equivalentes Drift (PRIORIDADE ALTA)
```bash
# Para cada modelo legacy, criar:
lib/database/tables/
  ├── culturas_table.dart      # ← de cultura_legacy.dart
  ├── diagnosticos_table.dart  # ← de diagnostico_legacy.dart
  ├── fitossanitarios_table.dart
  └── pragas_table.dart

lib/database/repositories/
  ├── culturas_repository.dart      # ← de cultura_legacy_repository.dart
  ├── diagnosticos_repository.dart  # ← de diagnostico_legacy_repository.dart
  └── ...
```

#### B. Implementar Migration Tool Completo
- [ ] Ler dados de boxes Hive
- [ ] Transformar para formato Drift
- [ ] Inserir em banco Drift
- [ ] Validar integridade
- [ ] Reportar progresso

#### C. Atualizar Sistema de DI
```dart
// Antes (atual)
sl.registerLazySingleton(() => DiagnosticoLegacyRepository());

// Depois (dual-support durante transição)
sl.registerLazySingleton(() => DiagnosticoRepository(
  legacyRepo: DiagnosticoLegacyRepository(), // fallback
  driftDb: sl<ReceituagroDatabase>(),
));

// Final (após migração)
sl.registerLazySingleton(() => DiagnosticoRepository(
  db: sl<ReceituagroDatabase>(),
));
```

### 2. Testar Migration Tool
```dart
// Criar testes para validar:
- Migração de diagnósticos com referências válidas
- Migração de favoritos
- Migração de comentários
- Validação de foreign keys
- Tratamento de dados órfãos
```

### 3. Documentar Processo
- [ ] Criar guia de migração para usuários
- [ ] Documentar rollback strategy
- [ ] Criar checklist de validação

---

## 📝 Conclusão

### Resposta à Pergunta Original
> "Será que esses arquivos legacy já não podem ser removidos?"

**❌ NÃO - Os arquivos legacy NÃO podem ser removidos ainda.**

### Razões:
1. **100% dos arquivos estão em uso ativo** - 90+ referências no código
2. **Sistema depende completamente do Hive** - Não há alternativa Drift implementada
3. **Dados de usuários estão em Hive** - Sem caminho de migração = perda de dados
4. **Build quebraria completamente** - Impacto em todas as features principais

### O que PRECISA ser feito primeiro:
1. ✅ Implementar tabelas Drift equivalentes
2. ✅ Implementar repositórios Drift equivalentes  
3. ✅ Criar e testar migration tool completo
4. ✅ Migrar dados de usuários existentes
5. ✅ Atualizar todas as features para usar Drift
6. ✅ Período de transição e validação
7. ✅ Só então: remover código legacy

### Tempo Estimado:
- **Desenvolvimento:** 2-3 semanas
- **Testes e validação:** 1 semana
- **Rollout gradual:** 2-4 semanas
- **Total:** 5-8 semanas para migração segura

---

## 🔗 Arquivos Relacionados

- Análise completa: `LEGACY_FILES_IMPACT_ANALYSIS.md` (este arquivo)
- Migration tool: `lib/database/migration/hive_to_drift_migration_tool.dart`
- Banco Drift: `lib/database/receituagro_database.dart`
- Documentação: `docs/DRIFT_MIGRATION.md` (TODO)

---

**Status:** 🔴 **MIGRAÇÃO NECESSÁRIA - NÃO REMOVER AINDA**
