#!/bin/bash

# ==============================================================================
# ⚡ PERFORMANCE OPTIMIZER - OTIMIZADOR DE PERFORMANCE DO MONOREPO
# ==============================================================================
# Script para otimizar performance de builds, testes e desenvolvimento
# Inclui cache management, parallel execution e build optimization
# ==============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_optimize() {
    echo -e "${PURPLE}⚡ $1${NC}"
}

log_cache() {
    echo -e "${CYAN}💾 $1${NC}"
}

# Configurações
CACHE_DIR="$HOME/.monorepo_cache"
PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Função para configurar cache inteligente
setup_cache() {
    log_cache "Configurando sistema de cache..."
    
    # Criar diretório de cache se não existir
    mkdir -p "$CACHE_DIR"
    mkdir -p "$CACHE_DIR/builds"
    mkdir -p "$CACHE_DIR/deps"
    mkdir -p "$CACHE_DIR/analysis"
    
    # Cache de dependências pub
    export PUB_CACHE="$CACHE_DIR/pub_cache"
    mkdir -p "$PUB_CACHE"
    
    # Cache do Flutter
    if [ -n "$FLUTTER_ROOT" ]; then
        export FLUTTER_CACHE_DIR="$CACHE_DIR/flutter_cache"
        mkdir -p "$FLUTTER_CACHE_DIR"
    fi
    
    log_success "Cache configurado em: $CACHE_DIR"
}

# Função para otimizar configurações do Gradle (Android)
optimize_gradle() {
    log_optimize "Otimizando configurações do Gradle..."
    
    local gradle_props="$HOME/.gradle/gradle.properties"
    mkdir -p "$(dirname "$gradle_props")"
    
    # Configurações de otimização do Gradle
    cat > "$gradle_props" << EOF
# Otimizações de performance do Gradle para Flutter
org.gradle.jvmargs=-Xmx4g -XX:MaxPermSize=2g -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.daemon=true
org.gradle.caching=true
android.useAndroidX=true
android.enableJetifier=true
android.enableR8.fullMode=true
android.bundle.enableUncompressedNativeLibs=false
EOF
    
    log_success "Gradle otimizado com configurações de performance"
}

# Função para executar builds em paralelo
parallel_build() {
    local build_type=$1
    local apps_dir="apps"
    
    log_optimize "Executando builds paralelos ($build_type)..."
    
    # Encontrar todos os apps
    local apps=()
    while IFS= read -r -d '' app; do
        if [ -f "$app/pubspec.yaml" ]; then
            apps+=("$app")
        fi
    done < <(find "$apps_dir" -mindepth 1 -maxdepth 1 -type d -print0)
    
    if [ ${#apps[@]} -eq 0 ]; then
        log_warning "Nenhum app encontrado para build"
        return 0
    fi
    
    log_info "Encontrados ${#apps[@]} apps para build paralelo"
    
    # Função para build individual
    build_single_app() {
        local app_path=$1
        local app_name=$(basename "$app_path")
        
        log_info "🚀 Iniciando build de $app_name..."
        
        cd "$app_path"
        
        case $build_type in
            "debug")
                if flutter build apk --debug --target-platform android-arm64; then
                    log_success "✅ $app_name - build debug concluído"
                    return 0
                else
                    log_error "❌ $app_name - build debug falhou"
                    return 1
                fi
                ;;
            "release")
                if flutter build apk --release --split-per-abi --target-platform android-arm64; then
                    log_success "✅ $app_name - build release concluído"
                    return 0
                else
                    log_error "❌ $app_name - build release falhou"
                    return 1
                fi
                ;;
            "bundle")
                if flutter build appbundle --release; then
                    log_success "✅ $app_name - app bundle concluído"
                    return 0
                else
                    log_error "❌ $app_name - app bundle falhou"
                    return 1
                fi
                ;;
        esac
        
        cd - > /dev/null
    }
    
    export -f build_single_app
    export -f log_info log_success log_error
    export build_type
    export RED GREEN YELLOW BLUE NC
    
    # Executar builds em paralelo usando xargs
    printf '%s\n' "${apps[@]}" | xargs -n 1 -P "$PARALLEL_JOBS" -I {} bash -c 'build_single_app "$@"' _ {}
    
    log_success "Builds paralelos concluídos!"
}

# Função para executar testes em paralelo
parallel_test() {
    log_optimize "Executando testes paralelos..."
    
    # Encontrar packages com testes
    local packages_with_tests=()
    
    while IFS= read -r pubspec; do
        local package_dir=$(dirname "$pubspec")
        if [ -d "$package_dir/test" ] && [ "$(find "$package_dir/test" -name "*.dart" | wc -l)" -gt 0 ]; then
            packages_with_tests+=("$package_dir")
        fi
    done < <(find . -name "pubspec.yaml" -not -path "./pubspec.yaml")
    
    if [ ${#packages_with_tests[@]} -eq 0 ]; then
        log_warning "Nenhum package com testes encontrado"
        return 0
    fi
    
    log_info "Encontrados ${#packages_with_tests[@]} packages com testes"
    
    # Função para teste individual
    test_single_package() {
        local package_path=$1
        local package_name=$(basename "$package_path")
        
        log_info "🧪 Testando $package_name..."
        
        cd "$package_path"
        
        if flutter test --coverage --reporter=expanded; then
            log_success "✅ $package_name - testes OK"
            return 0
        else
            log_error "❌ $package_name - testes falharam"
            return 1
        fi
        
        cd - > /dev/null
    }
    
    export -f test_single_package
    export -f log_info log_success log_error
    export RED GREEN YELLOW BLUE NC
    
    # Executar testes em paralelo
    printf '%s\n' "${packages_with_tests[@]}" | xargs -n 1 -P "$PARALLEL_JOBS" -I {} bash -c 'test_single_package "$@"' _ {}
    
    log_success "Testes paralelos concluídos!"
}

# Função para otimizar análise estática
optimize_analysis() {
    log_optimize "Otimizando análise estática..."
    
    # Cache de análise por hash de arquivos
    local analysis_cache="$CACHE_DIR/analysis"
    local current_hash=$(find . -name "*.dart" -exec md5sum {} \; 2>/dev/null | md5sum | cut -d' ' -f1)
    local cache_file="$analysis_cache/analysis_$current_hash.cache"
    
    if [ -f "$cache_file" ]; then
        log_cache "Cache de análise encontrado, pulando..."
        cat "$cache_file"
        return 0
    fi
    
    log_info "Executando análise estática (sem cache)..."
    
    if flutter analyze --no-fatal-infos > "$cache_file" 2>&1; then
        log_success "Análise concluída e cacheada"
        cat "$cache_file"
    else
        log_error "Análise falhou"
        rm -f "$cache_file"
        return 1
    fi
}

# Função para limpar cache seletivamente
clean_cache() {
    local cache_type=${1:-"all"}
    
    case $cache_type in
        "builds")
            log_cache "Limpando cache de builds..."
            rm -rf "$CACHE_DIR/builds"/*
            ;;
        "deps")
            log_cache "Limpando cache de dependências..."
            rm -rf "$CACHE_DIR/deps"/*
            rm -rf "$CACHE_DIR/pub_cache"/*
            ;;
        "analysis")
            log_cache "Limpando cache de análise..."
            rm -rf "$CACHE_DIR/analysis"/*
            ;;
        "flutter")
            log_cache "Limpando cache do Flutter..."
            flutter clean
            rm -rf "$CACHE_DIR/flutter_cache"/*
            ;;
        "all")
            log_cache "Limpando todo o cache..."
            rm -rf "$CACHE_DIR"
            flutter clean
            flutter pub cache clean --force
            ;;
        *)
            log_error "Tipo de cache desconhecido: $cache_type"
            return 1
            ;;
    esac
    
    log_success "Cache limpo: $cache_type"
}

# Função para mostrar estatísticas de performance
show_performance_stats() {
    log_info "📊 Estatísticas de Performance"
    echo ""
    
    # Estatísticas do cache
    if [ -d "$CACHE_DIR" ]; then
        local cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
        echo "💾 Cache total: $cache_size"
        
        # Detalhamento por tipo
        for subdir in builds deps analysis pub_cache flutter_cache; do
            if [ -d "$CACHE_DIR/$subdir" ]; then
                local size=$(du -sh "$CACHE_DIR/$subdir" 2>/dev/null | cut -f1)
                echo "   📁 $subdir: $size"
            fi
        done
    else
        echo "💾 Cache não configurado"
    fi
    
    echo ""
    
    # Estatísticas de jobs paralelos
    echo "🔄 Configuração paralela:"
    echo "   👷 Jobs simultâneos: $PARALLEL_JOBS"
    echo "   🖥️  CPU cores: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "N/A")"
    echo ""
    
    # Estatísticas de build
    echo "📱 Builds disponíveis:"
    find . -name "*.apk" -o -name "*.aab" -o -name "*.ipa" 2>/dev/null | while read -r build; do
        local size=$(ls -lh "$build" 2>/dev/null | awk '{print $5}')
        echo "   📦 $build ($size)"
    done
    
    echo ""
    
    # Estatísticas de dependências
    echo "📦 Dependências:"
    local total_deps=$(find . -name "pubspec.yaml" -exec grep -c "^[[:space:]]*[^#]*:" {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
    echo "   📊 Total de dependências: ${total_deps:-0}"
}

# Função para benchmark de performance
run_benchmark() {
    log_optimize "🏁 Executando benchmark de performance..."
    
    local start_time=$(date +%s)
    
    # Benchmark de análise
    log_info "Benchmark: Análise estática..."
    local analysis_start=$(date +%s)
    flutter analyze --no-fatal-infos > /dev/null 2>&1 || true
    local analysis_end=$(date +%s)
    local analysis_time=$((analysis_end - analysis_start))
    
    # Benchmark de teste (apenas um package)
    log_info "Benchmark: Teste unitário..."
    local test_start=$(date +%s)
    local test_package=$(find . -name "pubspec.yaml" -not -path "./pubspec.yaml" | head -1)
    if [ -n "$test_package" ]; then
        local test_dir=$(dirname "$test_package")
        cd "$test_dir"
        flutter test > /dev/null 2>&1 || true
        cd - > /dev/null
    fi
    local test_end=$(date +%s)
    local test_time=$((test_end - test_start))
    
    # Benchmark de build debug (um app)
    log_info "Benchmark: Build debug..."
    local build_start=$(date +%s)
    local first_app=$(find apps/ -name "pubspec.yaml" | head -1)
    if [ -n "$first_app" ]; then
        local app_dir=$(dirname "$first_app")
        cd "$app_dir"
        flutter build apk --debug > /dev/null 2>&1 || true
        cd - > /dev/null
    fi
    local build_end=$(date +%s)
    local build_time=$((build_end - build_start))
    
    local total_time=$(date +%s)
    total_time=$((total_time - start_time))
    
    # Resultados do benchmark
    echo ""
    echo "🏁 RESULTADOS DO BENCHMARK:"
    echo "   📊 Análise estática: ${analysis_time}s"
    echo "   🧪 Teste unitário: ${test_time}s"
    echo "   📱 Build debug: ${build_time}s"
    echo "   ⏱️  Tempo total: ${total_time}s"
    echo ""
    
    # Recomendações baseadas nos resultados
    if [ $analysis_time -gt 30 ]; then
        log_warning "Análise lenta detectada - considere usar cache de análise"
    fi
    
    if [ $test_time -gt 60 ]; then
        log_warning "Testes lentos detectados - considere execução paralela"
    fi
    
    if [ $build_time -gt 300 ]; then
        log_warning "Builds lentos detectados - considere otimizações do Gradle"
    fi
}

# Função para exibir help
show_help() {
    cat << EOF
⚡ PERFORMANCE OPTIMIZER - OTIMIZADOR DE PERFORMANCE

DESCRIÇÃO:
    Otimiza performance de builds, testes e desenvolvimento no monorepo
    através de cache inteligente, execução paralela e configurações otimizadas.

USO:
    ./performance_optimizer.sh [COMANDO] [OPÇÕES]

COMANDOS:
    setup                Configura sistema de cache e otimizações
    build:parallel TYPE  Executa builds paralelos (debug|release|bundle)
    test:parallel        Executa testes paralelos
    analyze:optimized    Análise estática com cache
    cache:clean [TYPE]   Limpa cache (builds|deps|analysis|flutter|all)
    gradle:optimize      Otimiza configurações do Gradle
    stats               Exibe estatísticas de performance
    benchmark           Executa benchmark de performance
    help                Exibe esta ajuda

OPÇÕES:
    --jobs N            Número de jobs paralelos (padrão: número de CPUs)
    --cache-dir DIR     Diretório de cache customizado

EXEMPLOS:
    # Setup inicial completo
    ./performance_optimizer.sh setup

    # Builds paralelos otimizados
    ./performance_optimizer.sh build:parallel release

    # Testes paralelos
    ./performance_optimizer.sh test:parallel

    # Análise com cache
    ./performance_optimizer.sh analyze:optimized

    # Limpeza seletiva
    ./performance_optimizer.sh cache:clean builds

    # Benchmark de performance
    ./performance_optimizer.sh benchmark

OTIMIZAÇÕES INCLUÍDAS:
    🚀 Cache inteligente para análise e dependências
    🔄 Execução paralela de builds e testes
    ⚙️  Otimizações do Gradle para Android
    📊 Monitoramento de performance
    🧹 Limpeza seletiva de cache

REQUISITOS:
    - Flutter SDK instalado
    - xargs com suporte a -P (execução paralela)
    - Bash 4.0 ou superior

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
COMMAND=""
CUSTOM_JOBS=""
CUSTOM_CACHE_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --jobs)
            CUSTOM_JOBS="$2"
            shift 2
            ;;
        --cache-dir)
            CUSTOM_CACHE_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$COMMAND" ]; then
                COMMAND="$1"
            else
                COMMAND="$COMMAND $1"
            fi
            shift
            ;;
    esac
done

# Aplicar configurações customizadas
if [ -n "$CUSTOM_JOBS" ]; then
    PARALLEL_JOBS="$CUSTOM_JOBS"
fi

if [ -n "$CUSTOM_CACHE_DIR" ]; then
    CACHE_DIR="$CUSTOM_CACHE_DIR"
fi

# Verificar se comando foi especificado
if [ -z "$COMMAND" ]; then
    log_error "Nenhum comando especificado"
    show_help
    exit 1
fi

log_info "🚀 Performance Optimizer iniciado"
log_info "📁 Cache dir: $CACHE_DIR"
log_info "👷 Parallel jobs: $PARALLEL_JOBS"

# Executar comando
case $COMMAND in
    "setup")
        setup_cache
        optimize_gradle
        log_success "Setup de otimização concluído!"
        ;;
    "build:parallel debug"|"build:parallel release"|"build:parallel bundle")
        setup_cache
        BUILD_TYPE=$(echo "$COMMAND" | cut -d' ' -f2)
        parallel_build "$BUILD_TYPE"
        ;;
    "test:parallel")
        setup_cache
        parallel_test
        ;;
    "analyze:optimized")
        setup_cache
        optimize_analysis
        ;;
    "cache:clean"*)
        CACHE_TYPE=$(echo "$COMMAND" | cut -d' ' -f2)
        clean_cache "$CACHE_TYPE"
        ;;
    "gradle:optimize")
        optimize_gradle
        ;;
    "stats")
        show_performance_stats
        ;;
    "benchmark")
        setup_cache
        run_benchmark
        ;;
    "help")
        show_help
        ;;
    *)
        log_error "Comando desconhecido: $COMMAND"
        show_help
        exit 1
        ;;
esac

log_success "Performance Optimizer concluído!"