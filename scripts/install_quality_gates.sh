#!/bin/bash

# Quality Gates Installation Script
# Sets up comprehensive quality gates system for Flutter monorepo

set -e

echo "🚦 Installing Quality Gates System..."
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v dart &> /dev/null; then
    print_error "Dart/Flutter not found. Please install Flutter SDK first."
    exit 1
fi

if ! command -v git &> /dev/null; then
    print_error "Git not found. Please install Git first."
    exit 1
fi

print_status "Prerequisites satisfied"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a Git repository. Please run from monorepo root."
    exit 1
fi

# Get the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

print_info "Repository root: $REPO_ROOT"

# Make scripts executable
echo "🔧 Setting up script permissions..."
chmod +x scripts/quality_gates.dart
chmod +x scripts/pre_commit_quality_gates.sh
chmod +x scripts/quality_dashboard.dart
print_status "Script permissions configured"

# Install Git hooks
echo "🪝 Installing Git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
if [ -f .git/hooks/pre-commit ]; then
    print_warning "Existing pre-commit hook found. Creating backup..."
    cp .git/hooks/pre-commit .git/hooks/pre-commit.backup
fi

cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Quality Gates Pre-commit Hook

# Run the quality gates pre-commit script
exec "$(git rev-parse --show-toplevel)/scripts/pre_commit_quality_gates.sh" "$@"
EOF

chmod +x .git/hooks/pre-commit
print_status "Pre-commit hook installed"

# Create VS Code settings for better integration
echo "⚙️  Configuring IDE integration..."

mkdir -p .vscode

# VS Code settings
cat > .vscode/settings.json << 'EOF'
{
  "dart.analysisExcludedFolders": [
    "**/build/**",
    "**/.*/**",
    "**/coverage/**"
  ],
  "dart.lineLength": 120,
  "dart.showTodos": true,
  "dart.warnWhenEditingFilesOutsideWorkspace": false,
  "files.associations": {
    "*.dart": "dart"
  },
  "editor.rulers": [80, 120],
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "files.watcherExclude": {
    "**/build/**": true,
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true
  }
}
EOF

# VS Code tasks
cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Quality Gates - All",
      "type": "shell",
      "command": "dart",
      "args": ["scripts/quality_gates.dart", "--app=all", "--check=all"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "Quality Gates - File Size",
      "type": "shell",
      "command": "dart",
      "args": ["scripts/quality_gates.dart", "--check=file_size"],
      "group": "test"
    },
    {
      "label": "Generate Quality Dashboard",
      "type": "shell",
      "command": "dart",
      "args": ["scripts/quality_dashboard.dart"],
      "group": "build"
    },
    {
      "label": "Quality Gates - Current App",
      "type": "shell",
      "command": "dart",
      "args": ["scripts/quality_gates.dart", "--app=${workspaceFolderBasename}"],
      "group": "test"
    }
  ]
}
EOF

print_status "VS Code integration configured"

# Update analysis_options.yaml if it exists
echo "📊 Updating analysis options..."

if [ -f analysis_options.yaml ]; then
    print_info "Found existing analysis_options.yaml"
    
    # Add quality gates specific rules if not already present
    if ! grep -q "quality_gates" analysis_options.yaml; then
        cat >> analysis_options.yaml << 'EOF'

# Quality Gates Integration
analyzer:
  plugins:
    - dart_code_metrics

dart_code_metrics:
  rules:
    - avoid-long-files:
        max-file-length: 500
    - avoid-long-methods:
        max-method-length: 50
    - cyclomatic-complexity:
        max-complexity: 15
  metrics:
    cyclomatic-complexity: 15
    lines-of-executable-code: 50
    number-of-parameters: 5
    source-lines-of-code: 500
EOF
        print_status "Updated analysis_options.yaml with quality gates rules"
    else
        print_info "Quality gates rules already present in analysis_options.yaml"
    fi
else
    print_warning "No analysis_options.yaml found. Consider creating one for better integration."
fi

# Create GitHub Actions workflow directory if using GitHub
if [ -d .git ] && git remote get-url origin 2>/dev/null | grep -q "github"; then
    print_info "GitHub repository detected"
    
    if [ ! -d .github/workflows ]; then
        mkdir -p .github/workflows
        print_info "Created .github/workflows directory"
    fi
    
    if [ ! -f .github/workflows/quality_gates.yml ]; then
        print_warning "GitHub Actions workflow already exists at .github/workflows/quality_gates.yml"
        print_info "Manual review recommended for integration"
    else
        print_status "GitHub Actions workflow ready for use"
    fi
fi

# Test installation
echo "🧪 Testing installation..."

print_info "Running quick quality check..."
if dart scripts/quality_gates.dart --app=app-receituagro --check=file_size --report=console; then
    print_status "Quality gates test completed successfully"
else
    print_error "Quality gates test failed. Check the output above for issues."
    exit 1
fi

# Generate initial dashboard
echo "📊 Generating initial quality dashboard..."
if dart scripts/quality_dashboard.dart; then
    print_status "Quality dashboard generated successfully"
    print_info "Open quality_dashboard.html in your browser to view the report"
else
    print_warning "Dashboard generation failed. Check Dart installation and permissions."
fi

# Display installation summary
echo ""
echo "🎉 Quality Gates Installation Complete!"
echo "====================================="
echo ""
echo "What's been installed:"
echo "✅ Quality gates analyzer script"
echo "✅ Pre-commit Git hook"
echo "✅ Quality dashboard generator"
echo "✅ GitHub Actions workflow (if applicable)"
echo "✅ VS Code integration"
echo ""
echo "Usage:"
echo "📝 Run all checks: dart scripts/quality_gates.dart --app=all --check=all"
echo "📊 Generate dashboard: dart scripts/quality_dashboard.dart"
echo "🔍 Check specific app: dart scripts/quality_gates.dart --app=app-receituagro"
echo "⚙️  CI mode: dart scripts/quality_gates.dart --ci"
echo ""
echo "Files created/modified:"
echo "• scripts/quality_gates.dart - Main analyzer"
echo "• scripts/quality_dashboard.dart - Dashboard generator"  
echo "• scripts/pre_commit_quality_gates.sh - Git hook"
echo "• scripts/quality_gates_config.yaml - Configuration"
echo "• .git/hooks/pre-commit - Git pre-commit hook"
echo "• .vscode/settings.json - IDE settings"
echo "• .vscode/tasks.json - IDE tasks"
echo "• .github/workflows/quality_gates.yml - CI workflow"
echo ""
echo "Next steps:"
echo "1. Review configuration in scripts/quality_gates_config.yaml"
echo "2. Run: dart scripts/quality_gates.dart --app=all --check=all"
echo "3. Open quality_dashboard.html to view current quality status"
echo "4. Commit changes to activate pre-commit hooks"
echo ""
print_status "Quality Gates system is now active and monitoring your codebase!"

exit 0