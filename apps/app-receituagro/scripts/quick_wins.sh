#!/bin/bash

# Script para Quick Wins - Limpeza rápida de comentários
# Executa ações de baixo risco com alto impacto

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Iniciando Quick Wins - Limpeza de Comentários"
echo "📂 Base: $BASEDIR"
echo ""

# Backup antes de modificar
BACKUP_DIR="$BASEDIR/backup_$(date +%Y%m%d_%H%M%S)"
echo "💾 Criando backup em: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$BASEDIR/lib" "$BACKUP_DIR/"
echo "✅ Backup criado"
echo ""

# Contador de mudanças
CHANGES=0

# Função para aplicar mudanças com dry-run
apply_fix() {
    local description="$1"
    local search_pattern="$2"
    local replace_pattern="$3"
    local dry_run="${4:-true}"
    
    echo "🔍 Analisando: $description"
    
    files=$(grep -rl "$search_pattern" "$BASEDIR/lib" --include="*.dart" 2>/dev/null || true)
    count=$(echo "$files" | grep -c . || echo "0")
    
    if [ "$count" -eq "0" ]; then
        echo "   ℹ️  Nenhuma ocorrência encontrada"
        echo ""
        return
    fi
    
    echo "   📊 Encontradas $count ocorrências"
    
    if [ "$dry_run" = "true" ]; then
        echo "   🔒 Modo DRY-RUN - não aplicando mudanças"
        echo "   Para aplicar: execute com --apply"
    else
        echo "   ✏️  Aplicando mudanças..."
        # Usar sed de forma segura
        find "$BASEDIR/lib" -name "*.dart" -type f -exec sed -i '' "s/$search_pattern/$replace_pattern/g" {} \;
        CHANGES=$((CHANGES + count))
        echo "   ✅ Mudanças aplicadas"
    fi
    
    echo ""
}

# Verificar modo
DRY_RUN=true
if [ "$1" = "--apply" ]; then
    DRY_RUN=false
    echo "⚠️  MODO APLICAÇÃO ATIVO - Mudanças serão feitas"
    echo ""
else
    echo "ℹ️  Modo DRY-RUN - apenas visualizando"
    echo "   Execute com --apply para aplicar mudanças"
    echo ""
fi

echo "=== QUICK WIN 1: Remover comentários redundantes ==="
echo ""

# 1.1. Comentários "Busca todos"
apply_fix \
    "Comentários 'Busca todos'" \
    "  \/\/\/ Busca todos os.*" \
    "" \
    "$DRY_RUN"

# 1.2. Comentários "Limpa todos"
apply_fix \
    "Comentários 'Limpa todos'" \
    "  \/\/\/ Limpa todos os.*" \
    "" \
    "$DRY_RUN"

# 1.3. Comentários "Remove todos"
apply_fix \
    "Comentários 'Remove todos'" \
    "  \/\/\/ Remove todos os.*" \
    "" \
    "$DRY_RUN"

echo "=== QUICK WIN 2: Padronizar @deprecated ==="
echo ""

# 2.1. Converter @deprecated lowercase para @Deprecated
echo "🔍 Analisando: @deprecated → @Deprecated"
deprecated_lower=$(grep -r "@deprecated" "$BASEDIR/lib" --include="*.dart" | grep -v "@Deprecated" | wc -l | xargs)
echo "   📊 Encontradas $deprecated_lower ocorrências de @deprecated (lowercase)"

if [ "$deprecated_lower" -gt "0" ]; then
    if [ "$DRY_RUN" = "false" ]; then
        echo "   ✏️  Convertendo para @Deprecated..."
        find "$BASEDIR/lib" -name "*.dart" -type f -exec sed -i '' 's/@deprecated/@Deprecated("Deprecated - use alternative")/g' {} \;
        CHANGES=$((CHANGES + deprecated_lower))
        echo "   ✅ Conversões aplicadas"
    else
        echo "   🔒 Modo DRY-RUN"
    fi
fi
echo ""

echo "=== QUICK WIN 3: Adicionar contexto em TODOs simples ==="
echo ""

# 3.1. Identificar TODOs sem contexto
echo "🔍 Analisando: TODOs sem contexto adequado"
todos_simple=$(grep -r "// TODO:" "$BASEDIR/lib" --include="*.dart" | grep -v "TODO(" | wc -l | xargs)
echo "   📊 Encontrados $todos_simple TODOs sem formato (username, date)"
echo "   ℹ️  Formato recomendado: // TODO(username, YYYY-MM-DD): descrição"
echo "   ⚠️  Ação manual necessária - script não pode inferir responsável"
echo ""

echo "=== QUICK WIN 4: Marcar Hive references para migração ==="
echo ""

# 4.1. Adicionar comentário em imports Hive
echo "🔍 Analisando: Imports de Hive (deveria ser Drift)"
hive_imports=$(grep -r "import.*hive" "$BASEDIR/lib" --include="*.dart" | wc -l | xargs)
echo "   📊 Encontrados $hive_imports imports de Hive"
echo "   ℹ️  Estes devem ser migrados para Drift"
echo "   ⚠️  Ação manual necessária - verificar se já existe alternativa Drift"
echo ""

echo "=== RELATÓRIO FINAL ==="
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo "📊 Modo DRY-RUN - Nenhuma mudança foi aplicada"
    echo ""
    echo "🎯 Mudanças propostas:"
    echo "   • Comentários redundantes: ~$(grep -r "/// Busca todos\|/// Limpa todos\|/// Remove todos" "$BASEDIR/lib" --include="*.dart" 2>/dev/null | wc -l | xargs) remoções"
    echo "   • @deprecated → @Deprecated: $deprecated_lower conversões"
    echo "   • TODOs para revisar: $todos_simple items"
    echo "   • Hive imports para migrar: $hive_imports items"
    echo ""
    echo "🚀 Para aplicar mudanças, execute:"
    echo "   ./scripts/quick_wins.sh --apply"
else
    echo "✅ Mudanças aplicadas com sucesso!"
    echo ""
    echo "📊 Estatísticas:"
    echo "   • Total de mudanças: $CHANGES"
    echo "   • Backup salvo em: $BACKUP_DIR"
    echo ""
    echo "🎯 Próximos passos:"
    echo "   1. Revisar mudanças: git diff"
    echo "   2. Testar aplicação: flutter test"
    echo "   3. Executar analyzer: flutter analyze"
    echo "   4. Commit: git add -A && git commit -m 'chore: quick wins - cleanup comments'"
    echo ""
    echo "⚠️  Itens que precisam ação manual:"
    echo "   • $todos_simple TODOs sem formato adequado"
    echo "   • $hive_imports Hive imports para migrar"
fi

echo ""
echo "📚 Recursos:"
echo "   • Plano completo: ./CLEANUP_ACTION_PLAN.md"
echo "   • Relatórios: ./reports/"
echo "   • Guidelines: ./docs/COMMENTING_GUIDELINES.md (a criar)"
