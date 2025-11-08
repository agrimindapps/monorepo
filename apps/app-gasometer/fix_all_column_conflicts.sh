#!/bin/bash

# Script para corrigir TODOS os conflitos de Column entre Drift e Flutter

echo "🔍 Buscando arquivos com conflito potencial de Column..."

# Encontra todos os arquivos que importam core/core.dart E flutter
files=$(grep -rl "import 'package:core/core.dart'" lib/ | xargs grep -l "package:flutter" | grep -v ".config.dart")

count=0
fixed=0
skipped=0

for file in $files; do
  count=$((count + 1))

  # Verifica se já tem hide Column, as core, ou show
  if grep -q "hide.*Column" "$file"; then
    echo "✅ $file (já tem hide Column)"
    skipped=$((skipped + 1))
  elif grep -q "as core" "$file"; then
    echo "⏭️  $file (usa alias 'as core')"
    skipped=$((skipped + 1))
  elif grep -q "show.*GetIt\|show.*Hive\|show.*Box\|show.*ConnectivityService\|show.*InjectionContainer" "$file"; then
    echo "⏭️  $file (usa 'show' específico)"
    skipped=$((skipped + 1))
  else
    # Adiciona hide Column
    sed -i '' "s|import 'package:core/core.dart';|import 'package:core/core.dart' hide Column;|g" "$file"
    echo "🔧 Fixed: $file"
    fixed=$((fixed + 1))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumo:"
echo "  Total arquivos analisados: $count"
echo "  ✅ Corrigidos: $fixed"
echo "  ⏭️  Pulados (já ok): $skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
