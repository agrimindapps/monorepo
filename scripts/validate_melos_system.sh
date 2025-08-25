#!/bin/bash

# ==============================================================================
# ✅ VALIDADOR DO SISTEMA MELOS - TESTE COMPLETO
# ==============================================================================
# Script para validar se todos os componentes do sistema Melos estão funcionando
# Testa scripts, dependências e configurações
# ==============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Função para logging colorido
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_test() {
    echo -e "${PURPLE}🧪 $1${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Função para executar teste
run_test() {
    local test_name=$1
    local test_command=$2
    local should_fail=${3:-false}
    
    log_test "Testando: $test_name"
    
    if [ "$should_fail" = "true" ]; then
        # Teste deve falhar
        if ! eval "$test_command" &>/dev/null; then
            log_success "$test_name - OK (falhou conforme esperado)"
        else
            log_error "$test_name - FALHA (deveria ter falhado)"
        fi
    else
        # Teste deve passar
        if eval "$test_command" &>/dev/null; then
            log_success "$test_name - OK"
        else
            log_error "$test_name - FALHA"
        fi
    fi
}

# Função principal de validação
main_validation() {
    echo "🚀 VALIDAÇÃO COMPLETA DO SISTEMA MELOS"
    echo "======================================"
    echo ""
    
    # 1. Verificar ambiente básico
    log_info "1️⃣  Verificando ambiente básico..."
    run_test "Flutter SDK instalado" "flutter --version"
    run_test "Dart SDK instalado" "dart --version"
    run_test "Git disponível" "git --version"
    run_test "Melos instalado globalmente" "flutter pub global run melos --version"
    
    echo ""
    
    # 2. Verificar estrutura do monorepo
    log_info "2️⃣  Verificando estrutura do monorepo..."
    run_test "Arquivo melos.yaml existe" "test -f melos.yaml"
    run_test "Diretório apps existe" "test -d apps"
    run_test "Diretório packages existe" "test -d packages"
    run_test "Diretório scripts existe" "test -d scripts"
    run_test "Core package existe" "test -f packages/core/pubspec.yaml"
    
    echo ""
    
    # 3. Verificar scripts customizados
    log_info "3️⃣  Verificando scripts customizados..."
    run_test "version_manager.sh existe" "test -f scripts/version_manager.sh"
    run_test "version_manager.sh é executável" "test -x scripts/version_manager.sh"
    run_test "selective_runner.sh existe" "test -f scripts/selective_runner.sh"
    run_test "selective_runner.sh é executável" "test -x scripts/selective_runner.sh"
    run_test "performance_optimizer.sh existe" "test -f scripts/performance_optimizer.sh"
    run_test "performance_optimizer.sh é executável" "test -x scripts/performance_optimizer.sh"
    
    echo ""
    
    # 4. Verificar apps do monorepo
    log_info "4️⃣  Verificando apps do monorepo..."
    local apps=("app-plantis" "app-receituagro" "app-gasometer" "app_agrihurbi" "app-petiveti" "app_taskolist")
    
    for app in "${apps[@]}"; do
        run_test "App $app existe" "test -d apps/$app"
        run_test "App $app tem pubspec.yaml" "test -f apps/$app/pubspec.yaml"
        run_test "App $app tem diretório lib" "test -d apps/$app/lib"
    done
    
    echo ""
    
    # 5. Testar comandos Melos básicos
    log_info "5️⃣  Testando comandos Melos básicos..."
    run_test "melos list funciona" "flutter pub global run melos list"
    run_test "melos help funciona" "flutter pub global run melos run help"
    run_test "melos version:list funciona" "flutter pub global run melos run version:list"
    
    echo ""
    
    # 6. Testar scripts de versioning
    log_info "6️⃣  Testando scripts de versioning..."
    run_test "version_manager.sh help" "./scripts/version_manager.sh help"
    run_test "version_manager.sh list" "./scripts/version_manager.sh list"
    
    echo ""
    
    # 7. Testar scripts de execução seletiva
    log_info "7️⃣  Testando scripts de execução seletiva..."
    run_test "selective_runner.sh help" "./scripts/selective_runner.sh help"
    run_test "selective_runner.sh list" "./scripts/selective_runner.sh list"
    
    echo ""
    
    # 8. Testar scripts de performance
    log_info "8️⃣  Testando scripts de performance..."
    run_test "performance_optimizer.sh help" "./scripts/performance_optimizer.sh help"
    run_test "performance_optimizer.sh stats" "./scripts/performance_optimizer.sh stats"
    
    echo ""
    
    # 9. Testar comandos de análise básica
    log_info "9️⃣  Testando comandos de análise..."
    run_test "melos analyze (dry-run)" "flutter pub global run melos analyze --dry-run"
    
    echo ""
    
    # 10. Verificar documentação
    log_info "🔟 Verificando documentação..."
    run_test "Documentação principal existe" "test -f MELOS_SCRIPTS_DOCUMENTATION.md"
    run_test "README do monorepo existe" "test -f README.md"
    
    echo ""
    
    # Resultado final
    echo "📊 RESULTADO DA VALIDAÇÃO"
    echo "========================"
    echo "Total de testes: $TOTAL_TESTS"
    echo -e "${GREEN}Testes passou: $PASSED_TESTS${NC}"
    echo -e "${RED}Testes falharam: $FAILED_TESTS${NC}"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Taxa de sucesso: $success_rate%"
    
    echo ""
    
    if [ $success_rate -ge 90 ]; then
        log_success "🎉 Sistema Melos está funcionando perfeitamente!"
        echo ""
        echo "✨ PRÓXIMOS PASSOS RECOMENDADOS:"
        echo "1. Execute: flutter pub global run melos run setup:dev"
        echo "2. Execute: flutter pub global run melos run perf:setup"
        echo "3. Teste um build: flutter pub global run melos run quick:build"
        echo "4. Consulte: MELOS_SCRIPTS_DOCUMENTATION.md para comandos completos"
    elif [ $success_rate -ge 75 ]; then
        log_warning "⚠️ Sistema Melos está funcionando, mas com algumas falhas"
        echo ""
        echo "🔧 AÇÕES RECOMENDADAS:"
        echo "1. Verifique os testes que falharam acima"
        echo "2. Execute: flutter pub global run melos run debug:info"
        echo "3. Execute: flutter pub global run melos run debug:cleanup"
    else
        log_error "❌ Sistema Melos tem problemas significativos"
        echo ""
        echo "🚨 AÇÕES URGENTES:"
        echo "1. Verifique instalação do Flutter/Dart"
        echo "2. Verifique instalação do Melos"
        echo "3. Execute: flutter doctor -v"
        echo "4. Consulte a documentação para troubleshooting"
        return 1
    fi
    
    echo ""
    echo "📚 Para mais informações, consulte:"
    echo "   - MELOS_SCRIPTS_DOCUMENTATION.md (documentação completa)"
    echo "   - flutter pub global run melos run help (comandos disponíveis)"
    echo "   - ./scripts/version_manager.sh help (gerenciamento de versões)"
    echo "   - ./scripts/selective_runner.sh help (execução seletiva)"
    echo "   - ./scripts/performance_optimizer.sh help (otimizações)"
}

# Verificar se estamos na raiz do monorepo
if [ ! -f "melos.yaml" ]; then
    log_error "Execute este script na raiz do monorepo (onde está o melos.yaml)"
    exit 1
fi

# Executar validação
main_validation