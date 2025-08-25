#!/bin/bash

# ==============================================================================
# 🎯 SELECTIVE RUNNER - EXECUÇÃO INTELIGENTE BASEADA EM MUDANÇAS
# ==============================================================================
# Script para executar ações apenas em packages/apps que foram modificados
# Otimiza CI/CD executando apenas o necessário baseado em git diff
# ==============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Função para logging colorido
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_action() {
    echo -e "${PURPLE}🚀 $1${NC}"
}

# Função para detectar packages modificados
detect_changed_packages() {
    local base_branch=${1:-"main"}
    local changed_files
    
    # Verificar se estamos em um repositório git
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Não estamos em um repositório Git"
        exit 1
    fi
    
    # Obter arquivos modificados
    if git rev-parse --verify "$base_branch" > /dev/null 2>&1; then
        changed_files=$(git diff --name-only "$base_branch"...HEAD)
    else
        # Se não tem base branch, usar staged files
        changed_files=$(git diff --cached --name-only)
        if [ -z "$changed_files" ]; then
            # Se não tem staged files, usar working directory
            changed_files=$(git diff --name-only HEAD)
        fi
    fi
    
    # Se ainda não tem arquivos, usar todos
    if [ -z "$changed_files" ]; then
        log_warning "Nenhuma mudança detectada, processando todos os packages"
        find . -name "pubspec.yaml" -not -path "./pubspec.yaml" | sed 's|/pubspec.yaml||' | sed 's|./||' | sort
        return
    fi
    
    # Detectar packages afetados
    local affected_packages=()
    
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            # Determinar qual package foi afetado
            local package_dir=$(echo "$file" | cut -d'/' -f1-2)
            
            # Verificar se é um package válido
            if [ -f "$package_dir/pubspec.yaml" ] && [[ "$package_dir" == apps/* || "$package_dir" == packages/* ]]; then
                # Adicionar à lista se ainda não está lá
                if [[ ! " ${affected_packages[@]} " =~ " ${package_dir} " ]]; then
                    affected_packages+=("$package_dir")
                fi
            fi
        fi
    done <<< "$changed_files"
    
    # Se core package foi modificado, incluir todos os apps
    if echo "$changed_files" | grep -q "packages/core/"; then
        log_info "Core package modificado, incluindo todos os apps"
        find apps/ -maxdepth 1 -type d -not -path apps/ | while read -r app; do
            if [ -f "$app/pubspec.yaml" ]; then
                affected_packages+=("$app")
            fi
        done
    fi
    
    # Remover duplicatas e retornar
    printf '%s\n' "${affected_packages[@]}" | sort -u
}

# Função para executar ação em packages específicos
run_action_on_packages() {
    local action=$1
    shift
    local packages=("$@")
    
    if [ ${#packages[@]} -eq 0 ]; then
        log_warning "Nenhum package especificado"
        return 0
    fi
    
    log_info "Executando '$action' em ${#packages[@]} package(s)"
    
    local success_count=0
    local total_count=${#packages[@]}
    
    for package in "${packages[@]}"; do
        if [ ! -d "$package" ]; then
            log_warning "Package não encontrado: $package"
            continue
        fi
        
        log_action "Processando $package..."
        
        cd "$package"
        
        case $action in
            "analyze")
                if flutter analyze; then
                    log_success "$package - análise OK"
                    success_count=$((success_count + 1))
                else
                    log_error "$package - análise falhou"
                fi
                ;;
            "test")
                if [ -d "test" ] && [ "$(find test -name "*.dart" | wc -l)" -gt 0 ]; then
                    if flutter test; then
                        log_success "$package - testes OK"
                        success_count=$((success_count + 1))
                    else
                        log_error "$package - testes falharam"
                    fi
                else
                    log_info "$package - sem testes"
                    success_count=$((success_count + 1))
                fi
                ;;
            "build:debug")
                if flutter build apk --debug; then
                    log_success "$package - build debug OK"
                    success_count=$((success_count + 1))
                else
                    log_error "$package - build debug falhou"
                fi
                ;;
            "build:release")
                if flutter build apk --release; then
                    log_success "$package - build release OK"
                    success_count=$((success_count + 1))
                else
                    log_error "$package - build release falhou"
                fi
                ;;
            "codegen")
                if [ -f "build.yaml" ]; then
                    if flutter packages pub run build_runner build --delete-conflicting-outputs; then
                        log_success "$package - codegen OK"
                        success_count=$((success_count + 1))
                    else
                        log_error "$package - codegen falhou"
                    fi
                else
                    log_info "$package - sem build.yaml"
                    success_count=$((success_count + 1))
                fi
                ;;
            "format")
                if dart format --set-exit-if-changed .; then
                    log_success "$package - formatação OK"
                    success_count=$((success_count + 1))
                else
                    log_warning "$package - formatação aplicada"
                    dart format .
                    success_count=$((success_count + 1))
                fi
                ;;
            *)
                log_error "Ação desconhecida: $action"
                ;;
        esac
        
        cd - > /dev/null
    done
    
    log_info "Resultado: $success_count/$total_count packages processados com sucesso"
    
    if [ $success_count -ne $total_count ]; then
        log_error "Alguns packages falharam"
        return 1
    else
        log_success "Todos os packages processados com sucesso!"
        return 0
    fi
}

# Função para exibir estatísticas
show_stats() {
    local packages=("$@")
    
    echo "📊 ESTATÍSTICAS DOS PACKAGES SELECIONADOS:"
    echo ""
    
    local total_dart_files=0
    local total_test_files=0
    local total_lines=0
    
    for package in "${packages[@]}"; do
        if [ ! -d "$package" ]; then
            continue
        fi
        
        local package_name=$(basename "$package")
        local dart_files=$(find "$package" -name "*.dart" | wc -l)
        local test_files=$(find "$package/test" -name "*.dart" 2>/dev/null | wc -l)
        local lines=$(find "$package" -name "*.dart" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)
        
        echo "  📦 $package_name:"
        echo "    📄 Arquivos Dart: $dart_files"
        echo "    🧪 Arquivos de Teste: $test_files"
        echo "    📏 Linhas de Código: $lines"
        echo ""
        
        total_dart_files=$((total_dart_files + dart_files))
        total_test_files=$((total_test_files + test_files))
        total_lines=$((total_lines + lines))
    done
    
    echo "  📊 TOTAIS:"
    echo "    📦 Packages: ${#packages[@]}"
    echo "    📄 Total Dart: $total_dart_files"
    echo "    🧪 Total Testes: $total_test_files"
    echo "    📏 Total Linhas: $total_lines"
}

# Função para exibir help
show_help() {
    cat << EOF
🎯 SELECTIVE RUNNER - EXECUÇÃO INTELIGENTE

DESCRIÇÃO:
    Executa ações apenas em packages/apps que foram modificados,
    otimizando tempo de CI/CD e desenvolvimento.

USO:
    ./selective_runner.sh [AÇÃO] [OPÇÕES]

AÇÕES:
    analyze              Executa flutter analyze nos packages modificados
    test                 Executa flutter test nos packages modificados
    build:debug          Executa build debug nos packages modificados
    build:release        Executa build release nos packages modificados
    codegen              Executa build_runner nos packages modificados
    format               Executa dart format nos packages modificados
    list                 Lista packages modificados
    stats                Exibe estatísticas dos packages modificados
    ci                   Executa pipeline completo (analyze + test + build)

OPÇÕES:
    --base BRANCH        Branch base para comparação (padrão: main)
    --all                Processar todos os packages (ignorar mudanças)
    --packages LIST      Lista específica de packages (separados por vírgula)
    --dry-run            Apenas mostrar o que seria executado

EXEMPLOS:
    # Executar análise apenas nos packages modificados
    ./selective_runner.sh analyze

    # Executar testes comparando com develop branch
    ./selective_runner.sh test --base develop

    # Processar todos os packages
    ./selective_runner.sh build:debug --all

    # Pipeline completo em packages específicos
    ./selective_runner.sh ci --packages "apps/app-plantis,packages/core"

    # Ver o que seria executado
    ./selective_runner.sh analyze --dry-run

DETECÇÃO DE MUDANÇAS:
    - Compara com branch especificada (padrão: main)
    - Se core package modificado, inclui todos os apps automaticamente
    - Se nenhuma mudança detectada, processa todos os packages
    - Suporta staged files e working directory changes

EOF
}

# ==============================================================================
# MAIN SCRIPT
# ==============================================================================

# Verificar se estamos na raiz do monorepo
if [ ! -f "melos.yaml" ]; then
    log_error "Execute este script na raiz do monorepo (onde está o melos.yaml)"
    exit 1
fi

# Parsing de argumentos
ACTION=""
BASE_BRANCH="main"
PROCESS_ALL=false
SPECIFIC_PACKAGES=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --all)
            PROCESS_ALL=true
            shift
            ;;
        --packages)
            SPECIFIC_PACKAGES="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$ACTION" ]; then
                ACTION="$1"
            else
                log_error "Argumento desconhecido: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Verificar se ação foi especificada
if [ -z "$ACTION" ]; then
    log_error "Nenhuma ação especificada"
    show_help
    exit 1
fi

# Determinar packages a processar
if [ -n "$SPECIFIC_PACKAGES" ]; then
    # Usar packages específicos
    IFS=',' read -ra PACKAGES <<< "$SPECIFIC_PACKAGES"
elif [ "$PROCESS_ALL" = true ]; then
    # Processar todos os packages
    log_info "Processando todos os packages"
    PACKAGES=($(find . -name "pubspec.yaml" -not -path "./pubspec.yaml" | sed 's|/pubspec.yaml||' | sed 's|./||'))
else
    # Detectar packages modificados
    log_info "Detectando packages modificados (base: $BASE_BRANCH)"
    PACKAGES=($(detect_changed_packages "$BASE_BRANCH"))
fi

# Verificar se há packages para processar
if [ ${#PACKAGES[@]} -eq 0 ]; then
    log_warning "Nenhum package encontrado para processar"
    exit 0
fi

log_info "Packages selecionados: ${PACKAGES[*]}"

# Dry run
if [ "$DRY_RUN" = true ]; then
    log_info "🧪 DRY RUN - O que seria executado:"
    echo "  Ação: $ACTION"
    echo "  Packages: ${#PACKAGES[@]}"
    for package in "${PACKAGES[@]}"; do
        echo "    - $package"
    done
    exit 0
fi

# Executar ação
case $ACTION in
    "list")
        echo "📦 Packages modificados:"
        for package in "${PACKAGES[@]}"; do
            echo "  - $package"
        done
        ;;
    "stats")
        show_stats "${PACKAGES[@]}"
        ;;
    "ci")
        log_action "Executando pipeline completo de CI"
        run_action_on_packages "analyze" "${PACKAGES[@]}" && \
        run_action_on_packages "test" "${PACKAGES[@]}" && \
        run_action_on_packages "build:debug" "${PACKAGES[@]}"
        ;;
    "analyze"|"test"|"build:debug"|"build:release"|"codegen"|"format")
        run_action_on_packages "$ACTION" "${PACKAGES[@]}"
        ;;
    *)
        log_error "Ação desconhecida: $ACTION"
        show_help
        exit 1
        ;;
esac

log_success "Selective runner concluído!"