#!/bin/bash

# Script para corrigir conflitos de Column entre Drift e Flutter

echo "Corrigindo imports de Column..."

# Lista de arquivos que precisam ser corrigidos
files=(
  "lib/core/widgets/user_avatar_widget.dart"
  "lib/features/auth/presentation/pages/login_page.dart"
  "lib/features/auth/presentation/pages/web_login_page.dart"
  "lib/features/auth/presentation/widgets/enhanced_login_form.dart"
  "lib/features/auth/presentation/widgets/social_login_buttons_widget.dart"
  "lib/features/data_migration/data/services/firestore_data_collector.dart"
  "lib/features/data_migration/data/services/gasometer_data_migration_service.dart"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Verifica se já tem hide ou show
    if ! grep -q "hide.*Column" "$file" && ! grep -q "as core" "$file" && ! grep -q "show " "$file"; then
      # Substitui o import
      sed -i '' "s|import 'package:core/core.dart';|import 'package:core/core.dart' hide Column;|g" "$file"
      echo "✅ Fixed: $file"
    else
      echo "⏭️  Skipped (já tem modificador): $file"
    fi
  else
    echo "⚠️  File not found: $file"
  fi
done

echo ""
echo "✅ Concluído!"
