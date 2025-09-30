#!/bin/bash

# Scripts de Centralização - Core Package Migration
# Data: 30 de Setembro de 2025
# Objetivo: Automatizar substituição de imports diretos por imports do core

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretórios base
MONOREPO_ROOT="/Users/lucineiloch/Documents/deveopment/monorepo"
GASOMETER_DIR="$MONOREPO_ROOT/apps/app-gasometer"
PLANTIS_DIR="$MONOREPO_ROOT/apps/app-plantis"
RECEITUAGRO_DIR="$MONOREPO_ROOT/apps/app-receituagro"
CORE_DIR="$MONOREPO_ROOT/packages/core"

# Funções de utilidade
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Backup antes de modificar
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        cp "$file" "$file.bak"
        print_info "Backup criado: $file.bak"
    fi
}

# Contador de substituições
count_replacements() {
    local app_dir=$1
    local pattern=$2
    local count=$(grep -r "$pattern" --include="*.dart" "$app_dir/lib" 2>/dev/null | wc -l)
    echo $count
}

# ================================================
# FASE 1: QUICK WINS - GASOMETER
# ================================================

phase1_gasometer_firestore() {
    print_header "FASE 1.1 - Substituir cloud_firestore imports (Gasometer)"

    cd "$GASOMETER_DIR"

    # Padrão a substituir
    OLD_IMPORT="^import 'package:cloud_firestore/cloud_firestore.dart';"
    NEW_IMPORT="import 'package:core/core.dart';"

    # Contar ocorrências antes
    BEFORE=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    print_info "Encontrados $BEFORE imports de cloud_firestore"

    # Arquivos alvo (dos 12 identificados na análise)
    FILES=(
        "lib/core/services/gasometer_firebase_service.dart"
        "lib/core/logging/data/datasources/log_remote_data_source.dart"
        "lib/features/expenses/data/datasources/expenses_remote_data_source.dart"
        "lib/features/maintenance/data/datasources/maintenance_remote_data_source.dart"
        "lib/features/auth/data/models/user_model.dart"
        "lib/features/vehicles/data/datasources/vehicle_remote_data_source.dart"
        "lib/features/fuel/data/datasources/fuel_remote_data_source.dart"
        "lib/features/premium/data/datasources/premium_firebase_data_source.dart"
        "lib/features/odometer/data/datasources/odometer_remote_data_source.dart"
        "lib/features/premium/data/datasources/premium_webhook_data_source.dart"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"

            # Substituir import usando sed (macOS compatible)
            sed -i '' "s|import 'package:cloud_firestore/cloud_firestore.dart';|import 'package:core/core.dart';|g" "$file"

            print_success "Atualizado: $file"
        else
            print_warning "Arquivo não encontrado: $file"
        fi
    done

    # Contar ocorrências depois
    AFTER=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    REPLACED=$((BEFORE - AFTER))

    print_success "Substituídos $REPLACED imports de cloud_firestore"
}

phase1_gasometer_hive() {
    print_header "FASE 1.2 - Substituir hive imports (Gasometer)"

    cd "$GASOMETER_DIR"

    # Padrão a substituir
    OLD_IMPORT_1="^import 'package:hive/hive.dart';"
    OLD_IMPORT_2="^import 'package:hive_flutter/hive_flutter.dart';"
    NEW_IMPORT="import 'package:core/core.dart';"

    # Contar ocorrências antes
    BEFORE=$(count_replacements "$GASOMETER_DIR" "package:hive")
    print_info "Encontrados $BEFORE imports de hive/hive_flutter"

    # Arquivos alvo (dos 11 identificados)
    FILES=(
        "lib/core/services/data_cleaner_service.dart"
        "lib/core/storage/hive_service.dart"
        "lib/core/services/local_data_service.dart"
        "lib/core/data/models/category_model.dart"
        "lib/core/logging/entities/log_entry.dart"
        "lib/core/data/models/base_model.dart"
        "lib/core/logging/data/datasources/log_local_data_source.dart"
        "lib/core/logging/config/logging_config.dart"
        "lib/features/expenses/data/repositories/expenses_repository.dart"
        "lib/features/maintenance/data/repositories/maintenance_repository.dart"
        "lib/features/odometer/data/repositories/odometer_repository.dart"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"

            # Substituir ambos os imports
            sed -i '' "s|import 'package:hive/hive.dart';|import 'package:core/core.dart';|g" "$file"
            sed -i '' "s|import 'package:hive_flutter/hive_flutter.dart';|import 'package:core/core.dart';|g" "$file"

            # Remover duplicatas (caso arquivo já tenha import do core)
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

            print_success "Atualizado: $file"
        else
            print_warning "Arquivo não encontrado: $file"
        fi
    done

    # Contar ocorrências depois
    AFTER=$(count_replacements "$GASOMETER_DIR" "package:hive")
    REPLACED=$((BEFORE - AFTER))

    print_success "Substituídos $REPLACED imports de hive"
}

phase1_gasometer_shared_preferences() {
    print_header "FASE 1.3 - Substituir shared_preferences imports (Gasometer)"

    cd "$GASOMETER_DIR"

    # Padrão a substituir
    OLD_IMPORT="^import 'package:shared_preferences/shared_preferences.dart';"
    NEW_IMPORT="import 'package:core/core.dart';"

    BEFORE=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    print_info "Encontrados $BEFORE imports de shared_preferences"

    FILES=(
        "lib/shared/widgets/enhanced_vehicle_selector.dart"
        "lib/core/services/data_cleaner_service.dart"
        "lib/core/services/local_data_service.dart"
        "lib/features/auth/presentation/controllers/login_controller.dart"
        "lib/features/data_export/data/repositories/data_export_repository_impl.dart"
        "lib/features/data_export/domain/services/data_export_service.dart"
        "lib/features/premium/data/datasources/premium_local_data_source.dart"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"
            sed -i '' "s|import 'package:shared_preferences/shared_preferences.dart';|import 'package:core/core.dart';|g" "$file"
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            print_success "Atualizado: $file"
        fi
    done

    AFTER=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    REPLACED=$((BEFORE - AFTER))
    print_success "Substituídos $REPLACED imports de shared_preferences"
}

phase1_gasometer_connectivity() {
    print_header "FASE 1.4 - Substituir connectivity_plus imports (Gasometer)"

    cd "$GASOMETER_DIR"

    OLD_IMPORT="^import 'package:connectivity_plus/connectivity_plus.dart';"

    BEFORE=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    print_info "Encontrados $BEFORE imports de connectivity_plus"

    FILES=(
        "lib/core/services/startup_sync_service.dart"
        "lib/core/logging/data/repositories/log_repository_impl.dart"
        "lib/features/expenses/data/repositories/expenses_repository.dart"
        "lib/features/odometer/data/repositories/odometer_repository.dart"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"
            sed -i '' "s|import 'package:connectivity_plus/connectivity_plus.dart';|import 'package:core/core.dart';|g" "$file"
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            print_success "Atualizado: $file"
        fi
    done

    AFTER=$(count_replacements "$GASOMETER_DIR" "$OLD_IMPORT")
    REPLACED=$((BEFORE - AFTER))
    print_success "Substituídos $REPLACED imports de connectivity_plus"
}

# ================================================
# FASE 2: PLANTIS QUICK FIXES
# ================================================

phase2_plantis_quick_fixes() {
    print_header "FASE 2 - Quick Fixes Plantis (10 imports)"

    cd "$PLANTIS_DIR"

    # Substituir shared_preferences (3 imports)
    FILES_PREFS=(
        "lib/features/settings/presentation/providers/notifications_settings_provider.dart"
        "lib/core/services/offline_sync_queue_service.dart"
        "lib/features/settings/data/datasources/settings_local_datasource.dart"
    )

    for file in "${FILES_PREFS[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"
            sed -i '' "s|import 'package:shared_preferences/shared_preferences.dart';|import 'package:core/core.dart';|g" "$file"
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            print_success "Atualizado: $file"
        fi
    done

    # Substituir outros imports diretos
    declare -A REPLACEMENTS=(
        ["lib/core/sync/sync_queue.dart"]="package:hive/hive.dart"
        ["lib/features/plants/data/datasources/remote/plant_tasks_remote_datasource.dart"]="package:cloud_firestore/cloud_firestore.dart"
        ["lib/core/services/url_launcher_service.dart"]="package:url_launcher/url_launcher.dart"
    )

    for file in "${!REPLACEMENTS[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"
            old_import="${REPLACEMENTS[$file]}"
            sed -i '' "s|import '$old_import';|import 'package:core/core.dart';|g" "$file"
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            print_success "Atualizado: $file"
        fi
    done

    print_success "Plantis quick fixes completos"
}

# ================================================
# FASE 3: RECEITUAGRO FINAL TOUCHES
# ================================================

phase3_receituagro_final() {
    print_header "FASE 3 - Final Touches ReceitaAgro (6 imports)"

    cd "$RECEITUAGRO_DIR"

    FILES=(
        "lib/core/utils/theme_preference_migration.dart"
        "lib/core/providers/theme_provider.dart"
        "lib/core/services/promotional_notification_manager.dart"
        "lib/features/settings/presentation/pages/data_inspector_page.dart"
    )

    for file in "${FILES[@]}"; do
        if [ -f "$file" ]; then
            backup_file "$file"
            sed -i '' "s|import 'package:shared_preferences/shared_preferences.dart';|import 'package:core/core.dart';|g" "$file"
            sed -i '' "s|import 'package:hive_flutter/hive_flutter.dart';|import 'package:core/core.dart';|g" "$file"
            awk '!seen[$0]++' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            print_success "Atualizado: $file"
        fi
    done

    print_success "ReceitaAgro final touches completos"
}

# ================================================
# VALIDAÇÃO E TESTES
# ================================================

validate_changes() {
    print_header "VALIDAÇÃO - Compilação e Análise"

    APPS=("$GASOMETER_DIR" "$PLANTIS_DIR" "$RECEITUAGRO_DIR")
    APP_NAMES=("app-gasometer" "app-plantis" "app-receituagro")

    for i in "${!APPS[@]}"; do
        app_dir="${APPS[$i]}"
        app_name="${APP_NAMES[$i]}"

        print_info "Validando $app_name..."
        cd "$app_dir"

        # Executar flutter analyze
        if flutter analyze --no-fatal-infos; then
            print_success "$app_name: Análise OK"
        else
            print_error "$app_name: Erros encontrados na análise"
            return 1
        fi

        # Contar imports diretos restantes
        DIRECT_IMPORTS=$(grep -r "^import 'package:\(firebase_auth\|cloud_firestore\|hive\|shared_preferences\|connectivity_plus\)" \
            --include="*.dart" lib/ 2>/dev/null | wc -l)

        print_info "$app_name: $DIRECT_IMPORTS imports diretos restantes"
    done

    print_success "Validação completa!"
}

rollback_changes() {
    print_header "ROLLBACK - Restaurando backups"

    APPS=("$GASOMETER_DIR" "$PLANTIS_DIR" "$RECEITUAGRO_DIR")

    for app_dir in "${APPS[@]}"; do
        cd "$app_dir"

        # Encontrar todos os arquivos .bak
        find lib -name "*.dart.bak" | while read backup_file; do
            original_file="${backup_file%.bak}"
            if [ -f "$backup_file" ]; then
                mv "$backup_file" "$original_file"
                print_success "Restaurado: $original_file"
            fi
        done
    done

    print_success "Rollback completo!"
}

cleanup_backups() {
    print_header "LIMPEZA - Removendo backups"

    APPS=("$GASOMETER_DIR" "$PLANTIS_DIR" "$RECEITUAGRO_DIR")

    for app_dir in "${APPS[@]}"; do
        cd "$app_dir"
        find lib -name "*.dart.bak" -delete
        print_success "Backups removidos de $(basename $app_dir)"
    done

    print_success "Limpeza completa!"
}

# ================================================
# RELATÓRIOS
# ================================================

generate_report() {
    print_header "RELATÓRIO DE CENTRALIZAÇÃO"

    REPORT_FILE="$RECEITUAGRO_DIR/relatorio_centralizacao_pos_migracao.txt"

    {
        echo "========================================"
        echo "Relatório de Centralização Pós-Migração"
        echo "Data: $(date)"
        echo "========================================"
        echo ""

        for app in "app-gasometer" "app-plantis" "app-receituagro"; do
            app_dir="$MONOREPO_ROOT/apps/$app"
            echo "--- $app ---"

            # Contar imports do core
            core_imports=$(grep -r "^import 'package:core" --include="*.dart" "$app_dir/lib" 2>/dev/null | wc -l)
            echo "Imports via core: $core_imports"

            # Contar imports diretos restantes
            direct_imports=$(grep -r "^import 'package:\(firebase_auth\|cloud_firestore\|hive\|shared_preferences\|connectivity_plus\|image_picker\|device_info_plus\)" \
                --include="*.dart" "$app_dir/lib" 2>/dev/null | wc -l)
            echo "Imports diretos restantes: $direct_imports"

            # Calcular ratio
            if [ $direct_imports -gt 0 ]; then
                ratio=$((core_imports / direct_imports))
                echo "Ratio Core/Diretos: $ratio:1"
            else
                echo "Ratio Core/Diretos: ∞:1 (perfeito!)"
            fi

            echo ""
        done

        echo "========================================"
        echo "Migração completa!"
        echo "========================================"
    } | tee "$REPORT_FILE"

    print_success "Relatório salvo em: $REPORT_FILE"
}

# ================================================
# MENU PRINCIPAL
# ================================================

show_menu() {
    clear
    print_header "SCRIPTS DE CENTRALIZAÇÃO - CORE PACKAGE"
    echo ""
    echo "1. Fase 1.1 - Gasometer: Firestore (12 imports)"
    echo "2. Fase 1.2 - Gasometer: Hive (11 imports)"
    echo "3. Fase 1.3 - Gasometer: SharedPreferences (9 imports)"
    echo "4. Fase 1.4 - Gasometer: Connectivity (6 imports)"
    echo "5. Fase 1 - Gasometer: TODAS as substituições (38 imports)"
    echo ""
    echo "6. Fase 2 - Plantis: Quick Fixes (10 imports)"
    echo "7. Fase 3 - ReceitaAgro: Final Touches (6 imports)"
    echo ""
    echo "8. EXECUTAR TUDO (Fases 1-3)"
    echo ""
    echo "9. Validar mudanças (flutter analyze)"
    echo "10. Gerar relatório"
    echo "11. Rollback (restaurar backups)"
    echo "12. Cleanup (remover backups)"
    echo ""
    echo "0. Sair"
    echo ""
    read -p "Escolha uma opção: " choice
}

main() {
    while true; do
        show_menu

        case $choice in
            1) phase1_gasometer_firestore ;;
            2) phase1_gasometer_hive ;;
            3) phase1_gasometer_shared_preferences ;;
            4) phase1_gasometer_connectivity ;;
            5)
                phase1_gasometer_firestore
                phase1_gasometer_hive
                phase1_gasometer_shared_preferences
                phase1_gasometer_connectivity
                ;;
            6) phase2_plantis_quick_fixes ;;
            7) phase3_receituagro_final ;;
            8)
                phase1_gasometer_firestore
                phase1_gasometer_hive
                phase1_gasometer_shared_preferences
                phase1_gasometer_connectivity
                phase2_plantis_quick_fixes
                phase3_receituagro_final
                ;;
            9) validate_changes ;;
            10) generate_report ;;
            11) rollback_changes ;;
            12) cleanup_backups ;;
            0)
                print_info "Saindo..."
                exit 0
                ;;
            *)
                print_error "Opção inválida!"
                ;;
        esac

        echo ""
        read -p "Pressione Enter para continuar..."
    done
}

# Executar menu principal se script for executado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main
fi
