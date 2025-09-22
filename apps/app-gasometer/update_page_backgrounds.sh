#!/bin/bash

# Script para atualizar todas as páginas do app-gasometer com o novo fundo padrão

# Arquivos a serem atualizados
FILES=(
  "lib/features/profile/presentation/pages/profile_page.dart"
  "lib/features/reports/presentation/pages/reports_page.dart"
  "lib/features/expenses/presentation/pages/expenses_page.dart"
  "lib/features/fuel/presentation/pages/fuel_page.dart"
  "lib/core/presentation/forms/base_form_page.dart"
  "lib/features/odometer/presentation/pages/odometer_page.dart"
  "lib/features/maintenance/presentation/pages/maintenance_page.dart"
  "lib/features/vehicles/presentation/widgets/enhanced_vehicles_page.dart"
  "lib/features/vehicles/presentation/pages/vehicles_page.dart"
)

echo "=== Atualizando backgrounds das páginas do app-gasometer ==="

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Atualizando: $file"

    # Adicionar import do GasometerColors se não existir
    if ! grep -q "gasometer_colors.dart" "$file"; then
      # Encontrar a linha dos imports do core/theme e adicionar depois
      sed -i '' '/import.*core\/theme\/design_tokens.dart/a\
import '\''../../../../core/theme/gasometer_colors.dart'\'';
' "$file"
    fi

    # Substituir backgroundColor
    sed -i '' 's/backgroundColor: Theme\.of(context)\.colorScheme\.surfaceContainerLowest,/backgroundColor: GasometerColors.getPageBackgroundColor(context),/g' "$file"

    echo "✅ $file atualizado"
  else
    echo "⚠️  Arquivo não encontrado: $file"
  fi
done

echo "=== Concluído! ==="