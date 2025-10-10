#!/bin/bash

# Flutter App Setup Script
# Creates a new app from the scaffold template
# Usage: ./setup_new_app.sh <app_name> <bundle_id> <display_name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validate arguments
if [ $# -ne 3 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <app_name> <bundle_id> <display_name>"
    echo "Example: $0 my_awesome_app com.company.myapp \"My Awesome App\""
    exit 1
fi

APP_NAME=$1
BUNDLE_ID=$2
DISPLAY_NAME=$3

# Validate app_name (should be snake_case)
if [[ ! $APP_NAME =~ ^[a-z][a-z0-9_]*$ ]]; then
    print_error "App name must be lowercase snake_case (e.g., my_awesome_app)"
    exit 1
fi

# Validate bundle_id (should be reverse domain notation)
if [[ ! $BUNDLE_ID =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    print_error "Bundle ID must be reverse domain notation (e.g., com.company.app)"
    exit 1
fi

# Get paths
SCAFFOLD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONOREPO_ROOT="$(cd "$SCAFFOLD_DIR/.." && pwd)"
TARGET_DIR="$MONOREPO_ROOT/apps/$APP_NAME"

print_info "Creating new Flutter app: $DISPLAY_NAME"
print_info "App name: $APP_NAME"
print_info "Bundle ID: $BUNDLE_ID"
print_info "Target directory: $TARGET_DIR"

# Check if target directory already exists
if [ -d "$TARGET_DIR" ]; then
    print_error "Directory $TARGET_DIR already exists!"
    exit 1
fi

# Step 1: Create Flutter app
print_info "Step 1/6: Creating Flutter app structure..."
cd "$MONOREPO_ROOT/apps"
flutter create --org "$BUNDLE_ID" --project-name "$APP_NAME" "$APP_NAME"
print_success "Flutter app created"

# Step 2: Copy scaffold structure
print_info "Step 2/6: Copying scaffold structure..."
cd "$TARGET_DIR"

# Remove default files
rm -rf lib test

# Copy scaffold structure
cp -r "$SCAFFOLD_DIR/lib" .
cp -r "$SCAFFOLD_DIR/test" .
cp "$SCAFFOLD_DIR/analysis_options.yaml" .
cp "$SCAFFOLD_DIR/.gitignore" .

print_success "Scaffold structure copied"

# Step 3: Configure pubspec.yaml
print_info "Step 3/6: Configuring pubspec.yaml..."
sed -e "s/{{APP_NAME}}/$APP_NAME/g" \
    -e "s/{{BUNDLE_ID}}/$BUNDLE_ID/g" \
    -e "s/{{APP_DESCRIPTION}}/A new Flutter application/g" \
    -e "s/{{APP_DISPLAY_NAME}}/$DISPLAY_NAME/g" \
    "$SCAFFOLD_DIR/pubspec.yaml.template" > pubspec.yaml

print_success "pubspec.yaml configured"

# Step 4: Process template files
print_info "Step 4/6: Processing template files..."

# Find all .template files and process them
find lib -name "*.template" | while read template_file; do
    output_file="${template_file%.template}"
    sed -e "s/{{APP_NAME}}/$APP_NAME/g" \
        -e "s/{{BUNDLE_ID}}/$BUNDLE_ID/g" \
        -e "s/{{APP_DISPLAY_NAME}}/$DISPLAY_NAME/g" \
        "$template_file" > "$output_file"
    rm "$template_file"
done

print_success "Template files processed"

# Step 5: Install dependencies
print_info "Step 5/6: Installing dependencies..."
flutter pub get
print_success "Dependencies installed"

# Step 6: Generate code
print_info "Step 6/6: Generating code (Hive, Injectable, Riverpod)..."
dart run build_runner build --delete-conflicting-outputs
print_success "Code generation completed"

# Final message
echo ""
print_success "======================="
print_success "App created successfully!"
print_success "======================="
echo ""
print_info "Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Configure Firebase (add google-services.json and GoogleService-Info.plist)"
echo "  3. Update lib/core/config/app_config.dart.template with your settings"
echo "  4. Run: flutter run"
echo ""
print_info "To generate a new feature:"
echo "  ./scripts/generate_feature.sh <feature_name>"
echo ""
print_info "Documentation:"
echo "  - Architecture: docs/ARCHITECTURE.md"
echo "  - Patterns: docs/PATTERNS.md"
echo "  - Testing: docs/TESTING.md"
echo ""
print_success "Happy coding! 🚀"
