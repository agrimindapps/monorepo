#!/bin/bash

# Script de build otimizado para ReceitaAgro
# Reduz tamanho do APK/IPA automaticamente durante o build

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="$APP_DIR/assets"
BUILD_DIR="$APP_DIR/build"
TEMP_DIR="$APP_DIR/.temp_build"

echo -e "${BLUE}🚀 Build Otimizado ReceitaAgro${NC}"
echo -e "${BLUE}================================${NC}"
echo "📁 App Directory: $APP_DIR"

# Função para formatar tamanho
format_size() {
    local size=$1
    if [ $size -gt 1073741824 ]; then
        echo "$(echo "scale=1; $size/1073741824" | bc)GB"
    elif [ $size -gt 1048576 ]; then
        echo "$(echo "scale=1; $size/1048576" | bc)MB"
    elif [ $size -gt 1024 ]; then
        echo "$(echo "scale=1; $size/1024" | bc)KB"
    else
        echo "${size}B"
    fi
}

# Função para otimizar imagens
optimize_images() {
    echo -e "\n${YELLOW}🖼️  Otimizando imagens...${NC}"
    
    local images_dir="$ASSETS_DIR/imagens/bigsize"
    local optimized_count=0
    local total_saved=0
    
    if [ ! -d "$images_dir" ]; then
        echo -e "${RED}❌ Diretório de imagens não encontrado: $images_dir${NC}"
        return 1
    fi
    
    # Cria diretório temporário
    mkdir -p "$TEMP_DIR/images"
    
    # Processa cada imagem JPG
    for img in "$images_dir"/*.jpg; do
        if [ -f "$img" ]; then
            local filename=$(basename "$img")
            local original_size=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)
            
            # Imagens críticas mantém como JPG otimizado
            if [[ "$filename" == "a.jpg" || "$filename" == "Nao classificado.jpg" ]]; then
                # Otimiza JPG mantendo qualidade
                if command -v convert >/dev/null 2>&1; then
                    convert "$img" -quality 90 -strip -interlace Plane "$TEMP_DIR/images/$filename"
                else
                    cp "$img" "$TEMP_DIR/images/$filename"
                fi
            else
                # Converte para WebP
                local webp_file="$TEMP_DIR/images/${filename%.jpg}.webp"
                if command -v cwebp >/dev/null 2>&1; then
                    cwebp -q 85 -m 6 -pass 10 "$img" -o "$webp_file" >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        local new_size=$(stat -f%z "$webp_file" 2>/dev/null || stat -c%s "$webp_file" 2>/dev/null)
                        local saved=$((original_size - new_size))
                        total_saved=$((total_saved + saved))
                        optimized_count=$((optimized_count + 1))
                        
                        if [ $saved -gt $((original_size / 10)) ]; then
                            echo "  ✅ $filename: $(format_size $original_size) → $(format_size $new_size) (-$(echo "scale=1; $saved*100/$original_size" | bc)%)"
                        fi
                    else
                        # Fallback para JPG otimizado
                        if command -v convert >/dev/null 2>&1; then
                            convert "$img" -quality 85 -strip "$TEMP_DIR/images/$filename"
                        else
                            cp "$img" "$TEMP_DIR/images/$filename"
                        fi
                    fi
                else
                    # WebP não disponível, otimiza JPG
                    if command -v convert >/dev/null 2>&1; then
                        convert "$img" -quality 85 -strip "$TEMP_DIR/images/$filename"
                    else
                        cp "$img" "$TEMP_DIR/images/$filename"
                    fi
                fi
            fi
        fi
    done
    
    # Substitui imagens originais
    if [ $optimized_count -gt 0 ]; then
        rsync -av "$TEMP_DIR/images/" "$images_dir/"
        echo -e "  ${GREEN}✅ $optimized_count imagens otimizadas, $(format_size $total_saved) economizados${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Nenhuma otimização aplicada${NC}"
    fi
}

# Função para comprimir JSONs
optimize_json() {
    echo -e "\n${YELLOW}📄 Otimizando arquivos JSON...${NC}"
    
    local json_dir="$ASSETS_DIR/database"
    local optimized_count=0
    local total_saved=0
    
    if [ ! -d "$json_dir" ]; then
        echo -e "${RED}❌ Diretório JSON não encontrado: $json_dir${NC}"
        return 1
    fi
    
    # Processa cada arquivo JSON
    find "$json_dir" -name "*.json" -type f | while read json_file; do
        local original_size=$(stat -f%z "$json_file" 2>/dev/null || stat -c%s "$json_file" 2>/dev/null)
        
        # Minifica JSON
        if command -v jq >/dev/null 2>&1; then
            jq -c . "$json_file" > "$json_file.min" && mv "$json_file.min" "$json_file"
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "import json,sys; json.dump(json.load(open('$json_file')), open('$json_file.min','w'), separators=(',',':'), ensure_ascii=False)" && mv "$json_file.min" "$json_file"
        fi
        
        local new_size=$(stat -f%z "$json_file" 2>/dev/null || stat -c%s "$json_file" 2>/dev/null)
        local saved=$((original_size - new_size))
        
        if [ $saved -gt 1024 ]; then
            echo "  ✅ $(basename "$json_file"): $(format_size $original_size) → $(format_size $new_size)"
            optimized_count=$((optimized_count + 1))
            total_saved=$((total_saved + saved))
        fi
    done
    
    echo -e "  ${GREEN}✅ JSONs otimizados, $(format_size $total_saved) economizados${NC}"
}

# Função para build Flutter otimizado
build_flutter() {
    echo -e "\n${YELLOW}🔨 Executando build Flutter...${NC}"
    
    local platform=${1:-"android"}
    local build_mode=${2:-"release"}
    
    cd "$APP_DIR"
    
    # Limpa build anterior
    flutter clean
    flutter pub get
    
    # Parâmetros de otimização
    local flutter_args=(
        "--$build_mode"
        "--dart-define=OPTIMIZE_ASSETS=true"
        "--tree-shake-icons"
        "--split-debug-info=build/debug-info"
    )
    
    if [ "$platform" = "android" ]; then
        flutter_args+=(
            "--target-platform=android-arm64"
            "--shrink"
        )
        
        echo -e "  🤖 Building Android APK..."
        flutter build apk "${flutter_args[@]}"
        
        # Mostra tamanho do APK
        local apk_file="$BUILD_DIR/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$apk_file" ]; then
            local apk_size=$(stat -f%z "$apk_file" 2>/dev/null || stat -c%s "$apk_file" 2>/dev/null)
            echo -e "  📱 APK Size: ${GREEN}$(format_size $apk_size)${NC}"
            
            # Verifica se atingiu objetivo de 20MB
            local target_size=$((20 * 1024 * 1024))
            if [ $apk_size -le $target_size ]; then
                echo -e "  ${GREEN}🎯 OBJETIVO ATINGIDO! APK <= 20MB${NC}"
            else
                local excess=$((apk_size - target_size))
                echo -e "  ${YELLOW}⚠️  APK ainda ${RED}$(format_size $excess)${YELLOW} acima do objetivo${NC}"
            fi
        fi
        
    elif [ "$platform" = "ios" ]; then
        echo -e "  🍎 Building iOS IPA..."
        flutter build ios "${flutter_args[@]}"
        
    else
        echo -e "${RED}❌ Platform não suportada: $platform${NC}"
        return 1
    fi
}

# Função para análise final
analyze_build() {
    echo -e "\n${BLUE}📊 Análise do Build${NC}"
    echo -e "${BLUE}==================${NC}"
    
    # Tamanho dos assets
    local assets_size=$(du -sb "$ASSETS_DIR" 2>/dev/null | cut -f1 || echo "0")
    echo -e "📁 Assets Size: $(format_size $assets_size)"
    
    # Breakdown por tipo
    local images_size=$(du -sb "$ASSETS_DIR/imagens" 2>/dev/null | cut -f1 || echo "0")
    local database_size=$(du -sb "$ASSETS_DIR/database" 2>/dev/null | cut -f1 || echo "0")
    
    echo -e "  🖼️  Imagens: $(format_size $images_size)"
    echo -e "  📄 Database: $(format_size $database_size)"
    
    # Contadores
    local jpg_count=$(find "$ASSETS_DIR/imagens" -name "*.jpg" 2>/dev/null | wc -l)
    local webp_count=$(find "$ASSETS_DIR/imagens" -name "*.webp" 2>/dev/null | wc -l)
    local json_count=$(find "$ASSETS_DIR/database" -name "*.json" 2>/dev/null | wc -l)
    
    echo -e "  📸 JPG Files: $jpg_count"
    echo -e "  🌐 WebP Files: $webp_count"
    echo -e "  📋 JSON Files: $json_count"
    
    # Sugestões de otimização
    echo -e "\n${YELLOW}💡 Sugestões de Otimização:${NC}"
    
    if [ $assets_size -gt $((20 * 1024 * 1024)) ]; then
        echo -e "  • Implementar assets remotos para reduzir APK"
        echo -e "  • Considerar lazy loading de JSONs"
        echo -e "  • Reduzir qualidade WebP para 75%"
    fi
    
    if [ $jpg_count -gt 10 ]; then
        echo -e "  • Converter mais JPGs para WebP"
    fi
    
    if [ $database_size -gt $((50 * 1024 * 1024)) ]; then
        echo -e "  • Comprimir database com gzip"
        echo -e "  • Implementar carregamento sob demanda"
    fi
}

# Main execution
main() {
    local platform=${1:-"android"}
    local build_mode=${2:-"release"}
    local skip_optimization=${3:-false}
    
    echo -e "📋 Platform: ${GREEN}$platform${NC}"
    echo -e "📋 Build Mode: ${GREEN}$build_mode${NC}"
    
    # Verifica ferramentas necessárias
    echo -e "\n${YELLOW}🔧 Verificando ferramentas...${NC}"
    
    if ! command -v flutter >/dev/null 2>&1; then
        echo -e "${RED}❌ Flutter não encontrado${NC}"
        exit 1
    fi
    echo -e "  ✅ Flutter: $(flutter --version | head -n1)"
    
    if command -v cwebp >/dev/null 2>&1; then
        echo -e "  ✅ WebP: $(cwebp -version 2>&1 | head -n1)"
    else
        echo -e "  ⚠️  WebP não encontrado (otimização limitada)"
    fi
    
    if command -v convert >/dev/null 2>&1; then
        echo -e "  ✅ ImageMagick: disponível"
    else
        echo -e "  ⚠️  ImageMagick não encontrado"
    fi
    
    # Cria backup se não existe
    if [ ! -d "$APP_DIR/assets_backup" ] && [ "$skip_optimization" != "true" ]; then
        echo -e "\n${YELLOW}💾 Criando backup dos assets...${NC}"
        cp -r "$ASSETS_DIR" "$APP_DIR/assets_backup"
        echo -e "  ✅ Backup criado"
    fi
    
    # Executa otimizações
    if [ "$skip_optimization" != "true" ]; then
        optimize_images
        optimize_json
    else
        echo -e "\n${YELLOW}⏭️  Pulando otimizações (--skip-optimization)${NC}"
    fi
    
    # Build Flutter
    build_flutter "$platform" "$build_mode"
    
    # Análise final
    analyze_build
    
    # Cleanup
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    echo -e "\n${GREEN}✅ Build otimizado concluído!${NC}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        --skip-optimization)
            SKIP_OPT="true"
            shift
            ;;
        --help)
            echo "Uso: $0 [opções]"
            echo ""
            echo "Opções:"
            echo "  --platform PLATFORM    Platform de build (android|ios) [default: android]"
            echo "  --mode MODE            Build mode (debug|profile|release) [default: release]"
            echo "  --skip-optimization    Pula otimizações de assets"
            echo "  --help                 Mostra esta ajuda"
            exit 0
            ;;
        *)
            echo "Opção desconhecida: $1"
            echo "Use --help para ver opções disponíveis"
            exit 1
            ;;
    esac
done

# Execute main function
main "${PLATFORM:-android}" "${BUILD_MODE:-release}" "${SKIP_OPT:-false}"