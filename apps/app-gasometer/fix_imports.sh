#!/bin/bash

# Files that need flutter_riverpod and go_router
UI_FILES=(
    "lib/features/settings/presentation/pages/settings_page.dart"
    "lib/features/fuel/presentation/pages/fuel_page.dart"
    "lib/features/expenses/presentation/pages/expenses_page.dart"
    "lib/features/vehicles/presentation/pages/vehicles_page.dart"
    "lib/features/vehicles/presentation/widgets/enhanced_vehicles_page.dart"
    "lib/features/maintenance/presentation/pages/maintenance_page.dart"
    "lib/features/odometer/presentation/pages/odometer_page.dart"
    "lib/features/promo/presentation/pages/promo_page.dart"
    "lib/features/promo/presentation/pages/account_deletion_page.dart"
    "lib/features/reports/presentation/pages/reports_page.dart"
    "lib/shared/widgets/financial_conflict_dialog.dart"
    "lib/shared/widgets/enhanced_vehicle_selector.dart"
    "lib/shared/widgets/sync/simple_sync_loading.dart"
    "lib/shared/widgets/pending_uploads_indicator.dart"
    "lib/main.dart"
)

for file in "${UI_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Fixing $file"
        # Replace the core import with specific imports
        sed -i '' '1s/import '\''package:core\/core\.dart'\'';/import '\''package:flutter_riverpod\/flutter_riverpod\.dart'\'';\nimport '\''package:go_router\/go_router\.dart'\'';/' "$file"
    fi
done

echo "Import fixes completed"
