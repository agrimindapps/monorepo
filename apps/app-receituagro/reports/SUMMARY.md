# 📊 Resumo da Auditoria de Comentários

**Data**: 2025-11-21 17:22:03
**App**: app-receituagro

## 📈 Estatísticas Gerais

- **Total de arquivos**: 871 arquivos .dart
- **Total de linhas**: 160229 linhas
- **Total de comentários**: 14305 comentários //

## 🚨 Problemas Encontrados

### Críticos
- **@deprecated**: 27 ocorrências
- **@Deprecated**: 240 ocorrências

### Altos
- **TODO**: 135 ocorrências
- **FIXME**: 0 ocorrências

### Migrações Pendentes
- **MIGRATION TODO**: 3 ocorrências
- **Hive references**: 104 ocorrências

### Implementações Temporárias
- **Placeholders**: 15 ocorrências
- **Mocks**: 41 ocorrências

## 📂 Relatórios Detalhados

1. [Código Deprecated](./01_deprecated_report.md)
2. [TODOs Pendentes](./02_todos_report.md)
3. [Migration TODOs](./03_migration_report.md)
4. [Placeholders](./04_placeholders_report.md)

## 🎯 Recomendações

1. **Prioridade CRÍTICA**: Resolver ou remover código @deprecated
2. **Prioridade ALTA**: Implementar ou remover TODOs com mais de 6 meses
3. **Prioridade MÉDIA**: Finalizar migrações Hive→Drift e GetX→Riverpod
4. **Prioridade BAIXA**: Remover comentários redundantes

## 🔗 Links Úteis

- [Guia de Migração Riverpod](./.claude/guides/MIGRATION_PROVIDER_TO_RIVERPOD.md)
- [CLAUDE.md - Padrões](./CLAUDE.md)
- [Relatório Completo](./COMMENT_AUDIT_REPORT.md)
