#!/bin/bash

# FVM Setup Script for Flutter Monorepo
# This script configures all apps to use FVM with Flutter 3.29.2

set -e

FLUTTER_VERSION="3.29.2"
FVM_PATH="$HOME/.fvm_flutter/bin/fvm"

echo "🚀 Configurando FVM $FLUTTER_VERSION para o monorepo..."

# Check if FVM is installed
if [ ! -f "$FVM_PATH" ]; then
    echo "❌ FVM não encontrado. Instalando..."
    curl -fsSL https://fvm.app/install.sh | bash
fi

# Verify FVM installation
if [ ! -f "$FVM_PATH" ]; then
    echo "❌ Erro: FVM não foi instalado corretamente"
    exit 1
fi

echo "✅ FVM encontrado: $("$FVM_PATH" --version)"

# Install Flutter version if not already installed
echo "📦 Verificando Flutter $FLUTTER_VERSION..."
if ! "$FVM_PATH" list | grep -q "$FLUTTER_VERSION"; then
    echo "📥 Instalando Flutter $FLUTTER_VERSION..."
    "$FVM_PATH" install "$FLUTTER_VERSION"
else
    echo "✅ Flutter $FLUTTER_VERSION já está instalado"
fi

# Configure FVM for monorepo root
echo "🔧 Configurando FVM no diretório raiz..."
"$FVM_PATH" use "$FLUTTER_VERSION" --force

# Configure FVM for all apps
echo "📱 Configurando FVM para todos os apps..."
for app_dir in apps/*/; do
    if [ -d "$app_dir" ] && [ -f "$app_dir/pubspec.yaml" ]; then
        app_name=$(basename "$app_dir")
        echo "  🔧 Configurando $app_name..."
        cd "$app_dir"
        "$FVM_PATH" use "$FLUTTER_VERSION" --force
        cd - > /dev/null
    fi
done

# Add FVM binary to PATH instructions
echo "
⚙️  CONFIGURAÇÃO MANUAL NECESSÁRIA:

1. Adicione o FVM ao seu PATH permanentemente:
   - Para bash (~/.bashrc ou ~/.bash_profile):
     echo 'export PATH=\"\$PATH:\$HOME/.fvm_flutter/bin\"' >> ~/.bashrc
   
   - Para zsh (~/.zshrc):
     echo 'export PATH=\"\$PATH:\$HOME/.fvm_flutter/bin\"' >> ~/.zshrc

   - Para fish (~/.config/fish/config.fish):
     echo 'set -gx PATH \$PATH \$HOME/.fvm_flutter/bin' >> ~/.config/fish/config.fish

2. Reinicie seu terminal ou execute:
   source ~/.bashrc    # ou ~/.zshrc

3. Configure seu editor (VS Code):
   - Instale a extensão \"FVM\"
   - Ou configure o Flutter SDK path para: \$HOME/fvm/versions/$FLUTTER_VERSION

✅ FVM configurado com sucesso para Flutter $FLUTTER_VERSION!

🚀 Próximos passos:
   - Execute: fvm flutter doctor
   - Para usar commands: fvm flutter [command] ou configure o PATH
   - Para builds: fvm flutter build [target]
"