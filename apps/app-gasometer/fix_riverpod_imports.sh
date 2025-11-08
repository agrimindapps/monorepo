#!/bin/bash

# Arquivos que precisam de Riverpod
files=(
  "lib/features/auth/presentation/widgets/login_form_widget.dart"
  "lib/features/auth/presentation/widgets/recovery_form_widget.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Verifica se já tem import do riverpod
    if ! grep -q "import 'package:flutter_riverpod/flutter_riverpod.dart';" "$file"; then
      # Adiciona após o primeiro import do flutter
      sed -i '' "/import 'package:flutter\/material.dart';/a\\
import 'package:flutter_riverpod/flutter_riverpod.dart';\\
" "$file"
      echo "✅ Added Riverpod import: $file"
    else
      echo "⏭️  Skipped (already has Riverpod): $file"
    fi
  else
    echo "⚠️  File not found: $file"
  fi
done

echo ""
echo "✅ Concluído!"
