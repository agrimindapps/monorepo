# 📚 Referências Arquivadas

Esta pasta contém documentos de análise que foram convertidos em tarefas rastreáveis dentro do sistema de features.

---

## 📄 Arquivos Arquivados

### ANALYSIS_REPORT.md
**Data**: 2025-11-18  
**Convertido para tarefas em**: 11/12/2025  
**Distribuído em**:
- `features/auth/TASKS.md` - Tarefas de migração Riverpod
- `features/plants/TASKS.md` - Tarefas de migração Riverpod  
- `features/tasks/TASKS.md` - Tarefas de migração Riverpod
- `features/settings/TASKS.md` - Tarefas de migração Riverpod
- `features/account/TASKS.md` - Tarefas de migração Riverpod

**Conteúdo**: Relatório de migração de GetIt para Riverpod concluída.

---

### AUTO_LOGIN_IMPLEMENTED.md
**Data**: 2025-11-18  
**Convertido para tarefa em**: 11/12/2025  
**Distribuído em**:
- `features/auth/TASKS.md` - Task PLT-AUTH-008 (Remover auto-login de debug)

**Conteúdo**: Implementação de auto-login para testes. **DEVE SER REMOVIDO EM PRODUÇÃO**.

⚠️ **AÇÃO NECESSÁRIA**: Task PLT-AUTH-008 deve ser completada antes do deploy.

---

### PLANT_DELETION_ANALYSIS.md
**Data**: 2025-11-30  
**Convertido para tarefas em**: 11/12/2025  
**Distribuído em**:
- `features/plants/TASKS.md` - Tasks PLT-PLANTS-007, PLT-PLANTS-008

**Conteúdo**: Análise detalhada do processo de soft delete de plantas (411 linhas).

**Pontos-Chave**:
- ✅ Soft delete implementado em todos os níveis
- ✅ Ordem: Tasks → Comentários → Planta Local → Planta Remota
- ⚠️ Erros em tasks/comentários não bloqueiam exclusão da planta
- ⚠️ Erro remoto não bloqueia (será sincronizado via isDirty)

**Referência Gold Standard**: Este documento contém análise detalhada do fluxo que pode servir de referência para outras features.

---

## 🔄 Como Usar Este Arquivo

1. **Para consultar análises antigas**: Leia os arquivos arquivados aqui
2. **Para trabalhar em melhorias**: Use os TASKS.md das features
3. **Para rastrear progresso**: Use CHANGELOG_QUALITY_FIXES.md

---

## 📊 Estatísticas de Conversão

- **Total de análises convertidas**: 3
- **Total de tarefas criadas**: 20+
- **Features impactadas**: 4 (auth, plants, tasks, premium)
- **Horas estimadas de trabalho**: 280h+

---

**Última atualização**: 11/12/2025 15:30
