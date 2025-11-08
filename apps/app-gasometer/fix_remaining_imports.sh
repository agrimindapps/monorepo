#!/bin/bash

echo "🔧 Corrigindo imports faltantes..."

# 1. Adicionar Riverpod em arquivos que precisam
files_need_riverpod=(
  "lib/features/profile/presentation/widgets/devices_section_widget.dart"
  "lib/features/settings/presentation/dialogs/feedback_dialog.dart"
  "lib/features/vehicles/presentation/widgets/enhanced_vehicles_page.dart"
)

for file in "${files_need_riverpod[@]}"; do
  if [ -f "$file" ]; then
    if ! grep -q "import 'package:flutter_riverpod/flutter_riverpod.dart';" "$file"; then
      sed -i '' "/import 'package:flutter\/material.dart';/a\\
import 'package:flutter_riverpod/flutter_riverpod.dart';\\
" "$file"
      echo "✅ Added Riverpod: $file"
    fi
  fi
done

# 2. Adicionar GoRouter (context.go) em arquivos que precisam
files_need_gorouter=(
  "lib/features/profile/presentation/widgets/devices_section_widget.dart"
  "lib/features/profile/presentation/widgets/profile_dialogs.dart"
)

for file in "${files_need_gorouter[@]}"; do
  if [ -f "$file" ]; then
    if ! grep -q "import 'package:go_router/go_router.dart';" "$file"; then
      sed -i '' "/import 'package:flutter\/material.dart';/a\\
import 'package:go_router/go_router.dart';\\
" "$file"
      echo "✅ Added GoRouter: $file"
    fi
  fi
done

# 3. Adicionar intl (DateFormat) em arquivos que precisam
files_need_intl=(
  "lib/features/device_management/presentation/widgets/device_actions_dialog.dart"
  "lib/features/device_management/presentation/widgets/device_card_widget.dart"
)

for file in "${files_need_intl[@]}"; do
  if [ -f "$file" ]; then
    if ! grep -q "import 'package:intl/intl.dart';" "$file"; then
      sed -i '' "/import 'package:flutter\/material.dart';/a\\
import 'package:intl/intl.dart';\\
" "$file"
      echo "✅ Added intl: $file"
    fi
  fi
done

echo ""
echo "✅ Correção de imports concluída!"
