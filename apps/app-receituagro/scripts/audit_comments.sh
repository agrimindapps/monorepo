#!/bin/bash

# Script para auditar comentários no app-receituagro
# Autor: Sistema de Análise de Código
# Data: 2024-01-21

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$BASEDIR/reports"
mkdir -p "$OUTPUT_DIR"

echo "🔍 Iniciando auditoria de comentários..."
echo "📂 Base: $BASEDIR"
echo ""

# Cores para output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para contar ocorrências
count_pattern() {
    local pattern="$1"
    local description="$2"
    local color="$3"
    
    count=$(grep -r "$pattern" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs)
    echo -e "${color}${description}: ${count}${NC}"
    
    if [ "$count" -gt 0 ]; then
        grep -rn "$pattern" "$BASEDIR/lib" --include="*.dart" 2>/dev/null > "$OUTPUT_DIR/${description// /_}.txt" || true
    fi
}

# Função para criar relatório detalhado
create_report() {
    local pattern="$1"
    local title="$2"
    local output_file="$3"
    
    echo "## $title" > "$output_file"
    echo "" >> "$output_file"
    echo "Encontradas $(grep -r "$pattern" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências" >> "$output_file"
    echo "" >> "$output_file"
    
    grep -rn "$pattern" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | while IFS=: read -r file line content; do
        echo "**Arquivo**: \`${file#$BASEDIR/}\`" >> "$output_file"
        echo "**Linha**: $line" >> "$output_file"
        echo "\`\`\`dart" >> "$output_file"
        echo "$content" >> "$output_file"
        echo "\`\`\`" >> "$output_file"
        echo "" >> "$output_file"
    done || true
}

echo "📊 === ANÁLISE DE COMENTÁRIOS PROBLEMÁTICOS ==="
echo ""

# 1. Deprecated code
echo -e "${RED}🚨 CRÍTICO${NC}"
count_pattern "@deprecated" "Deprecated annotations" "$RED"
count_pattern "@Deprecated" "Deprecated decorators" "$RED"
count_pattern "DEPRECATED" "Deprecated comments" "$RED"
echo ""

# 2. TODOs
echo -e "${YELLOW}⚠️  ALTO${NC}"
count_pattern "TODO:" "TODO comments" "$YELLOW"
count_pattern "FIXME:" "FIXME comments" "$YELLOW"
count_pattern "XXX:" "XXX comments" "$YELLOW"
count_pattern "HACK:" "HACK comments" "$YELLOW"
echo ""

# 3. Migrations
echo -e "${BLUE}📦 MIGRAÇÃO${NC}"
count_pattern "MIGRATION TODO" "Migration TODOs" "$BLUE"
count_pattern "Hive" "Hive references (should be Drift)" "$BLUE"
count_pattern "GetX" "GetX references (should be Riverpod)" "$BLUE"
echo ""

# 4. Placeholders
echo -e "${YELLOW}🔧 IMPLEMENTAÇÃO${NC}"
count_pattern "placeholder" "Placeholder implementations" "$YELLOW"
count_pattern "mock" "Mock implementations" "$YELLOW"
count_pattern "stub" "Stub implementations" "$YELLOW"
echo ""

# 5. Refactoring markers
echo "📝 REFACTORING"
count_pattern "REFACTORED" "Refactored markers" "$GREEN"
count_pattern "OLD:" "Old code markers" "$YELLOW"
count_pattern "LEGACY" "Legacy code markers" "$YELLOW"
echo ""

# Criar relatórios detalhados
echo "📄 Gerando relatórios detalhados..."

create_report "@[Dd]eprecated" "Código Deprecated" "$OUTPUT_DIR/01_deprecated_report.md"
create_report "TODO:" "TODOs Pendentes" "$OUTPUT_DIR/02_todos_report.md"
create_report "MIGRATION TODO" "Migration TODOs" "$OUTPUT_DIR/03_migration_report.md"
create_report "placeholder\|mock\|stub" "Placeholders" "$OUTPUT_DIR/04_placeholders_report.md"

# Análise de imports problemáticos
echo ""
echo "📦 === ANÁLISE DE IMPORTS ==="
echo ""

count_pattern "package:get/" "GetX imports (should migrate to Riverpod)" "$YELLOW"
count_pattern "package:hive/" "Hive imports (should migrate to Drift)" "$YELLOW"
count_pattern "package:provider/" "Provider imports (should migrate to Riverpod)" "$YELLOW"

# Estatísticas gerais
echo ""
echo "📈 === ESTATÍSTICAS GERAIS ==="
echo ""

total_dart_files=$(find "$BASEDIR/lib" -name "*.dart" | wc -l | xargs)
total_lines=$(find "$BASEDIR/lib" -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
total_comments=$(grep -r "^\s*//" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs)

echo "📁 Total de arquivos .dart: $total_dart_files"
echo "📝 Total de linhas: $total_lines"
echo "💬 Total de comentários (//): $total_comments"
echo ""

# Summary report
cat > "$OUTPUT_DIR/SUMMARY.md" << EOF
# 📊 Resumo da Auditoria de Comentários

**Data**: $(date +"%Y-%m-%d %H:%M:%S")
**App**: app-receituagro

## 📈 Estatísticas Gerais

- **Total de arquivos**: $total_dart_files arquivos .dart
- **Total de linhas**: $total_lines linhas
- **Total de comentários**: $total_comments comentários //

## 🚨 Problemas Encontrados

### Críticos
- **@deprecated**: $(grep -r "@deprecated" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências
- **@Deprecated**: $(grep -r "@Deprecated" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências

### Altos
- **TODO**: $(grep -r "TODO:" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências
- **FIXME**: $(grep -r "FIXME:" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências

### Migrações Pendentes
- **MIGRATION TODO**: $(grep -r "MIGRATION TODO" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências
- **Hive references**: $(grep -r "Hive" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências

### Implementações Temporárias
- **Placeholders**: $(grep -r "placeholder" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências
- **Mocks**: $(grep -r "mock" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) ocorrências

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
EOF

echo "✅ Auditoria concluída!"
echo ""
echo "📂 Relatórios salvos em: $OUTPUT_DIR"
echo ""
echo "📄 Arquivos gerados:"
ls -lh "$OUTPUT_DIR" | tail -n +2
echo ""
echo "🎯 Próximos passos:"
echo "   1. Revisar $OUTPUT_DIR/SUMMARY.md"
echo "   2. Priorizar items críticos"
echo "   3. Criar issues no GitHub/Jira"
echo "   4. Planejar sprints de limpeza"
