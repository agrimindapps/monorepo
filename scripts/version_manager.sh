#!/bin/bash

# ==============================================================================
# 🔢 SCRIPT DE GERENCIAMENTO DE VERSÕES AUTOMATIZADO
# ==============================================================================
# Script para automatizar o bump de versões em todos os apps do monorepo
# Suporta semantic versioning (major.minor.patch+build)
# ==============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Função para extrair versão atual do pubspec.yaml
get_current_version() {
    local pubspec_path=$1
    grep "version:" "$pubspec_path" | sed 's/version: *//' | tr -d ' '
}

# Função para fazer bump da versão
bump_version() {
    local current_version=$1
    local bump_type=$2
    
    # Separar versão e build number
    local version_part=$(echo "$current_version" | cut -d'+' -f1)
    local build_part=$(echo "$current_version" | cut -d'+' -f2)
    
    # Se não tem build number, assumir 1
    if [ "$version_part" = "$build_part" ]; then
        build_part="1"
    fi
    
    # Separar major, minor, patch
    local major=$(echo "$version_part" | cut -d'.' -f1)
    local minor=$(echo "$version_part" | cut -d'.' -f2)
    local patch=$(echo "$version_part" | cut -d'.' -f3)
    
    # Fazer bump baseado no tipo
    case $bump_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            build_part=$((build_part + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            build_part=$((build_part + 1))
            ;;
        "patch")
            patch=$((patch + 1))
            build_part=$((build_part + 1))
            ;;
        "build")
            build_part=$((build_part + 1))
            ;;
        *)
            log_error "Tipo de bump inválido: $bump_type"
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch+$build_part"
}

# Função para atualizar versão no pubspec.yaml
update_version_in_pubspec() {
    local pubspec_path=$1
    local new_version=$2
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/version: .*/version: $new_version/" "$pubspec_path"
    else
        # Linux
        sed -i "s/version: .*/version: $new_version/" "$pubspec_path"
    fi
}

# Função para listar todos os apps
list_apps() {
    find apps/ -name "pubspec.yaml" -type f | while read -r pubspec; do
        local app_dir=$(dirname "$pubspec")
        local app_name=$(basename "$app_dir")
        local current_version=$(get_current_version "$pubspec")
        echo "$app_name ($current_version)"
    done
}

# Função principal para bump de versão
do_version_bump() {
    local bump_type=$1
    local target_app=$2
    
    log_info "Iniciando bump de versão ($bump_type)..."
    
    local updated_count=0
    
    find apps/ -name "pubspec.yaml" -type f | while read -r pubspec; do
        local app_dir=$(dirname "$pubspec")
        local app_name=$(basename "$app_dir")
        
        # Se especificado um app específico, pular outros
        if [ -n "$target_app" ] && [ "$app_name" != "$target_app" ]; then
            continue
        fi
        
        local current_version=$(get_current_version "$pubspec")
        local new_version=$(bump_version "$current_version" "$bump_type")
        
        log_info "Atualizando $app_name: $current_version → $new_version"
        
        # Fazer backup
        cp "$pubspec" "$pubspec.bak"
        
        # Atualizar versão
        update_version_in_pubspec "$pubspec" "$new_version"
        
        # Verificar se a atualização funcionou
        local updated_version=$(get_current_version "$pubspec")
        if [ "$updated_version" = "$new_version" ]; then
            log_success "$app_name atualizado com sucesso"
            rm "$pubspec.bak"
            updated_count=$((updated_count + 1))
        else
            log_error "Falha ao atualizar $app_name"
            mv "$pubspec.bak" "$pubspec"
        fi
    done
    
    if [ $updated_count -gt 0 ]; then
        log_success "$updated_count app(s) atualizado(s) com sucesso!"
    else
        log_warning "Nenhum app foi atualizado"
    fi
}

# Função para criar tag git
create_git_tag() {
    local version=$1
    local message=$2
    
    log_info "Criando tag git: v$version"
    
    git add .
    git commit -m "$message" || log_warning "Nada para commitar"
    git tag -a "v$version" -m "$message"
    
    log_success "Tag v$version criada!"
    log_info "Para enviar: git push origin v$version"
}

# Função para exibir help
show_help() {
    cat << EOF
🔢 GERENCIADOR DE VERSÕES DO MONOREPO

USO:
    ./version_manager.sh [COMANDO] [OPÇÕES]

COMANDOS:
    major                 Incrementa versão major (x.0.0)
    minor                 Incrementa versão minor (0.x.0)
    patch                 Incrementa versão patch (0.0.x)
    build                 Incrementa apenas build number
    list                  Lista versões atuais de todos os apps
    help                  Exibe esta ajuda

OPÇÕES:
    --app APP_NAME       Atualiza apenas o app especificado
    --tag                Cria tag git após o bump
    --message "MSG"      Mensagem personalizada para commit/tag

EXEMPLOS:
    ./version_manager.sh patch                    # Bump patch em todos os apps
    ./version_manager.sh minor --app app-plantis  # Bump minor apenas no Plantis
    ./version_manager.sh major --tag              # Bump major e criar tag
    ./version_manager.sh list                     # Listar versões atuais

ESTRUTURA DE VERSÃO:
    MAJOR.MINOR.PATCH+BUILD
    
    MAJOR: Mudanças incompatíveis na API
    MINOR: Funcionalidades adicionadas (compatível)
    PATCH: Correções de bugs (compatível)
    BUILD: Número de build (incrementado automaticamente)

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

# Verificar se há argumentos
if [ $# -eq 0 ]; then
    log_warning "Nenhum comando especificado"
    show_help
    exit 1
fi

# Parsing de argumentos
COMMAND=$1
TARGET_APP=""
CREATE_TAG=false
COMMIT_MESSAGE=""

shift # Remove o primeiro argumento (comando)

while [[ $# -gt 0 ]]; do
    case $1 in
        --app)
            TARGET_APP="$2"
            shift 2
            ;;
        --tag)
            CREATE_TAG=true
            shift
            ;;
        --message)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        *)
            log_error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Executar comando
case $COMMAND in
    "major"|"minor"|"patch"|"build")
        log_info "Executando bump de versão: $COMMAND"
        
        if [ -n "$TARGET_APP" ]; then
            log_info "App alvo: $TARGET_APP"
        else
            log_info "Atualizando todos os apps"
        fi
        
        # Fazer backup do estado atual
        log_info "Fazendo backup do estado atual..."
        git stash push -m "backup before version bump" 2>/dev/null || true
        
        # Executar bump
        do_version_bump "$COMMAND" "$TARGET_APP"
        
        # Criar tag se solicitado
        if [ "$CREATE_TAG" = true ]; then
            if [ -z "$COMMIT_MESSAGE" ]; then
                COMMIT_MESSAGE="chore: bump version ($COMMAND)"
            fi
            
            # Obter primeira versão atualizada para a tag
            local first_version=$(find apps/ -name "pubspec.yaml" -type f | head -1 | xargs -I {} sh -c 'grep "version:" "$1" | sed "s/version: *//" | tr -d " "' _ {})
            create_git_tag "$first_version" "$COMMIT_MESSAGE"
        fi
        
        log_success "Bump de versão concluído!"
        ;;
    "list")
        log_info "Versões atuais dos apps:"
        echo ""
        list_apps
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        log_error "Comando desconhecido: $COMMAND"
        show_help
        exit 1
        ;;
esac

log_success "Operação concluída!"