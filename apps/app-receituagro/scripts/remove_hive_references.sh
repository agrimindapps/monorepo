#!/bin/bash

# Script para remover todas as referências Hive (sistema migrado para Drift)
# Autor: Sistema de Limpeza de Código
# Data: 2025-11-21

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🗑️  Iniciando Remoção de Referências Hive"
echo "📂 Base: $BASEDIR"
echo ""

# Backup antes de deletar
BACKUP_DIR="$BASEDIR/backup_hive_removal_$(date +%Y%m%d_%H%M%S)"
echo "💾 Criando backup em: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$BASEDIR/lib" "$BACKUP_DIR/"
echo "✅ Backup criado"
echo ""

# Verificar modo
DRY_RUN=true
if [ "$1" = "--apply" ]; then
    DRY_RUN=false
    echo "⚠️  MODO APLICAÇÃO ATIVO - Arquivos serão deletados"
    echo ""
else
    echo "ℹ️  Modo DRY-RUN - apenas visualizando"
    echo "   Execute com --apply para deletar arquivos"
    echo ""
fi

echo "=== ANÁLISE: Arquivos Hive para Remover ==="
echo ""

# Encontrar todos os arquivos Hive
hive_files=$(find "$BASEDIR/lib" -name "*hive*.dart" -type f)
file_count=$(echo "$hive_files" | grep -c . || echo "0")

echo "📊 Encontrados $file_count arquivos Hive:"
echo ""

if [ "$file_count" -eq "0" ]; then
    echo "   ℹ️  Nenhum arquivo Hive encontrado"
    echo ""
    exit 0
fi

# Listar arquivos
echo "$hive_files" | while IFS= read -r file; do
    size=$(wc -l < "$file" 2>/dev/null || echo "0")
    echo "   📄 ${file#$BASEDIR/} ($size linhas)"
done
echo ""

# Encontrar referências em comentários
echo "=== ANÁLISE: Referências Hive em Comentários ==="
echo ""

comment_refs=$(grep -r "Hive" "$BASEDIR/lib" --include="*.dart" -n | grep -v ".g.dart" | grep -E "//|///|\*" || true)
comment_count=$(echo "$comment_refs" | grep -c . || echo "0")

echo "📊 Encontradas $comment_count referências em comentários:"
echo ""

if [ "$comment_count" -gt "0" ]; then
    echo "$comment_refs" | head -10 | while IFS=: read -r file line content; do
        echo "   ${file#$BASEDIR/}:$line"
        echo "   └─ $(echo "$content" | xargs)"
        echo ""
    done
    
    if [ "$comment_count" -gt "10" ]; then
        echo "   ... e mais $((comment_count - 10)) referências"
        echo ""
    fi
fi

# Encontrar código comentado com Hive
echo "=== ANÁLISE: Código Comentado (Hive) ==="
echo ""

commented_code=$(grep -r "//.*Hive" "$BASEDIR/lib" --include="*.dart" -n | grep -v ".g.dart" || true)
commented_count=$(echo "$commented_code" | grep -c . || echo "0")

echo "📊 Encontradas $commented_count linhas de código comentado:"
echo ""

if [ "$commented_count" -gt "0" ]; then
    echo "$commented_code" | head -5 | while IFS=: read -r file line content; do
        echo "   ${file#$BASEDIR/}:$line"
        echo "   └─ $(echo "$content" | xargs)"
        echo ""
    done
fi

# Executar remoção se aprovado
if [ "$DRY_RUN" = "false" ]; then
    echo "=== EXECUTANDO: Remoção de Arquivos Hive ==="
    echo ""
    
    deleted_count=0
    deleted_size=0
    
    echo "$hive_files" | while IFS= read -r file; do
        if [ -f "$file" ]; then
            size=$(wc -l < "$file" 2>/dev/null || echo "0")
            echo "   🗑️  Deletando: ${file#$BASEDIR/} ($size linhas)"
            rm "$file"
            deleted_count=$((deleted_count + 1))
            deleted_size=$((deleted_size + size))
        fi
    done
    
    echo ""
    echo "✅ $file_count arquivos deletados"
    echo ""
    
    # Remover comentários com referências Hive
    echo "=== EXECUTANDO: Remoção de Comentários Hive ==="
    echo ""
    
    # Remover linhas comentadas que mencionam Hive
    find "$BASEDIR/lib" -name "*.dart" -type f ! -name "*.g.dart" -exec sed -i '' '/^[[:space:]]*\/\/.*Hive/d' {} \;
    
    echo "✅ Comentários Hive removidos"
    echo ""
    
    # Remover linhas vazias duplicadas criadas pela remoção
    find "$BASEDIR/lib" -name "*.dart" -type f ! -name "*.g.dart" -exec sed -i '' '/^$/N;/^\n$/D' {} \;
    
    echo "✅ Linhas vazias limpas"
    echo ""
fi

echo "=== RELATÓRIO FINAL ==="
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo "📊 Modo DRY-RUN - Nenhuma mudança foi aplicada"
    echo ""
    echo "🎯 Ações propostas:"
    echo "   • Deletar $file_count arquivos Hive (.g.dart gerados)"
    echo "   • Remover $comment_count comentários com 'Hive'"
    echo "   • Limpar código comentado obsoleto"
    echo ""
    total_lines=$(echo "$hive_files" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
    echo "📉 Redução estimada: ~$total_lines linhas"
    echo ""
    echo "🚀 Para aplicar mudanças, execute:"
    echo "   ./scripts/remove_hive_references.sh --apply"
else
    echo "✅ Remoção concluída com sucesso!"
    echo ""
    echo "📊 Estatísticas:"
    echo "   • Arquivos deletados: $file_count"
    echo "   • Comentários removidos: ~$comment_count"
    echo "   • Backup salvo em: $BACKUP_DIR"
    echo ""
    echo "🎯 Próximos passos:"
    echo "   1. Verificar mudanças: git status"
    echo "   2. Revisar diffs: git diff"
    echo "   3. Executar analyzer: flutter analyze"
    echo "   4. Testar build: flutter build apk --debug"
    echo "   5. Commit: git add -A && git commit -m 'chore: remove Hive legacy files'"
    echo ""
    echo "⚠️  Verificações necessárias:"
    echo "   • Nenhum import de package:hive restante"
    echo "   • Nenhuma referência a HiveBox/HiveAdapter"
    echo "   • Drift é o único sistema de DB ativo"
fi

echo ""
echo "📚 Contexto:"
echo "   • Sistema migrado: Hive → Drift"
echo "   • Arquivos .g.dart são gerados automaticamente (podem ser deletados)"
echo "   • Database atual: Drift (receituagro_database.dart)"
echo ""
echo "✨ Hive Legacy Cleanup Script Finalizado!"
