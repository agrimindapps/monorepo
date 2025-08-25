#!/bin/bash

# =============================================================================
# AGRIMIND SOLUÇÕES - MONOREPO ANALYZER SCRIPT
# =============================================================================
# Script para análise estática de todo o monorepo Flutter
# Versão: 2025.08.22
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONOREPO_ROOT="$(dirname "$SCRIPT_DIR")"
APPS_DIR="$MONOREPO_ROOT/apps"
PACKAGES_DIR="$MONOREPO_ROOT/packages"

# Options
SHOW_INFOS=true
FATAL_WARNINGS=false
APPS_ONLY=false
PACKAGES_ONLY=false
SPECIFIC_APP=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-infos)
      SHOW_INFOS=false
      shift
      ;;
    --fatal-warnings)
      FATAL_WARNINGS=true
      shift
      ;;
    --apps-only)
      APPS_ONLY=true
      shift
      ;;
    --packages-only)
      PACKAGES_ONLY=true
      shift
      ;;
    --app)
      SPECIFIC_APP="$2"
      shift
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --no-infos         Suppress info-level messages (focus on warnings/errors)"
      echo "  --fatal-warnings   Treat warnings as errors (for CI/CD)"
      echo "  --apps-only        Analyze only apps (skip packages)"
      echo "  --packages-only    Analyze only packages (skip apps)"
      echo "  --app NAME         Analyze specific app only"
      echo "  --help             Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                           # Analyze everything"
      echo "  $0 --no-infos              # Focus on warnings/errors"
      echo "  $0 --apps-only --no-infos  # Quick app analysis"
      echo "  $0 --app app-gasometer     # Analyze specific app"
      echo "  $0 --fatal-warnings        # CI/CD mode"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Build flutter analyze command
build_analyze_command() {
  local cmd="flutter analyze"
  
  if [[ "$SHOW_INFOS" == false ]]; then
    cmd="$cmd --no-fatal-infos"
  fi
  
  if [[ "$FATAL_WARNINGS" == true ]]; then
    cmd="$cmd --fatal-warnings"
  fi
  
  echo "$cmd"
}

# Analyze single directory
analyze_directory() {
  local dir_path="$1"
  local dir_name="$2"
  local category="$3"
  
  if [[ ! -d "$dir_path" ]]; then
    echo -e "${RED}❌ Directory not found: $dir_path${NC}"
    return 1
  fi
  
  if [[ ! -f "$dir_path/pubspec.yaml" ]]; then
    echo -e "${YELLOW}⚠️  Skipping $dir_name (no pubspec.yaml)${NC}"
    return 0
  fi
  
  echo -e "${BLUE}🔍 Analyzing $category: $dir_name${NC}"
  echo "   Path: $dir_path"
  
  local analyze_cmd=$(build_analyze_command)
  
  cd "$dir_path"
  
  # Run analysis and capture result
  local start_time=$(date +%s)
  if eval "$analyze_cmd"; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo -e "${GREEN}✅ $dir_name completed successfully (${duration}s)${NC}"
    echo ""
    return 0
  else
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo -e "${RED}❌ $dir_name found issues (${duration}s)${NC}"
    echo ""
    return 1
  fi
}

# Print header
print_header() {
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}🔍 AGRIMIND MONOREPO STATIC ANALYSIS${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo "Monorepo: $MONOREPO_ROOT"
  echo "Command: $(build_analyze_command)"
  echo "Timestamp: $(date)"
  echo ""
}

# Main execution
main() {
  print_header
  
  local total_analyzed=0
  local successful=0
  local failed=0
  
  # Analyze specific app if requested
  if [[ -n "$SPECIFIC_APP" ]]; then
    local app_path="$APPS_DIR/$SPECIFIC_APP"
    if analyze_directory "$app_path" "$SPECIFIC_APP" "APP"; then
      successful=$((successful + 1))
    else
      failed=$((failed + 1))
    fi
    total_analyzed=1
  else
    # Analyze packages first (if not apps-only)
    if [[ "$APPS_ONLY" == false ]]; then
      echo -e "${YELLOW}📦 ANALYZING PACKAGES${NC}"
      echo ""
      
      for package_dir in "$PACKAGES_DIR"/*; do
        if [[ -d "$package_dir" ]]; then
          package_name=$(basename "$package_dir")
          total_analyzed=$((total_analyzed + 1))
          
          if analyze_directory "$package_dir" "$package_name" "PACKAGE"; then
            successful=$((successful + 1))
          else
            failed=$((failed + 1))
          fi
        fi
      done
    fi
    
    # Analyze apps (if not packages-only)
    if [[ "$PACKAGES_ONLY" == false ]]; then
      echo -e "${YELLOW}📱 ANALYZING APPS${NC}"
      echo ""
      
      for app_dir in "$APPS_DIR"/*; do
        if [[ -d "$app_dir" ]]; then
          app_name=$(basename "$app_dir")
          total_analyzed=$((total_analyzed + 1))
          
          if analyze_directory "$app_dir" "$app_name" "APP"; then
            successful=$((successful + 1))
          else
            failed=$((failed + 1))
          fi
        fi
      done
    fi
  fi
  
  # Print summary
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}📊 ANALYSIS SUMMARY${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo "Total analyzed: $total_analyzed"
  echo -e "Successful: ${GREEN}$successful${NC}"
  
  if [[ $failed -gt 0 ]]; then
    echo -e "With issues: ${RED}$failed${NC}"
    echo ""
    echo -e "${YELLOW}💡 TIP: Use --no-infos to focus on warnings/errors only${NC}"
    echo -e "${YELLOW}💡 TIP: Fix issues gradually, starting with errors${NC}"
    exit 1
  else
    echo -e "With issues: ${GREEN}0${NC}"
    echo ""
    echo -e "${GREEN}🎉 All components passed static analysis!${NC}"
    exit 0
  fi
}

# Check if we're in a Flutter monorepo
if [[ ! -f "$MONOREPO_ROOT/analysis_options.yaml" ]]; then
  echo -e "${RED}❌ This doesn't appear to be a Flutter monorepo with analysis_options.yaml${NC}"
  echo "Expected file: $MONOREPO_ROOT/analysis_options.yaml"
  exit 1
fi

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}❌ Flutter command not found in PATH${NC}"
  echo "Please install Flutter or add it to your PATH"
  exit 1
fi

# Run main function
main