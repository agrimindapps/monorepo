# FVM Configuration - Flutter Monorepo

Este documento explica como o monorepo está configurado para usar Flutter Version Manager (FVM) com Flutter 3.29.2.

## 📋 Status da Configuração

✅ **FVM instalado globalmente**  
✅ **Flutter 3.29.2 instalado via FVM**  
✅ **Configurado para monorepo root**  
✅ **Configurado para todos os apps:**
- app-gasometer
- app-petiveti  
- app-plantis
- app-receituagro
- app_agrihurbi
- app_taskolist

✅ **Melos atualizado para usar Flutter 3.29.2**  
✅ **.gitignore configurado para FVM**

## 🚀 Como Usar

### Comandos FVM Básicos

```bash
# Verificar versão do FVM
fvm --version

# Verificar versão do Flutter ativa
fvm flutter --version

# Listar versões Flutter instaladas
fvm list

# Ver qual versão está ativa no projeto atual
fvm flutter --version
```

### Executar Comandos Flutter

Em vez de usar `flutter` diretamente, use `fvm flutter`:

```bash
# Análise de código
fvm flutter analyze

# Executar app
fvm flutter run

# Build APK
fvm flutter build apk

# Testes
fvm flutter test

# Pub get
fvm flutter pub get
```

### Usando com Melos

O Melos está configurado para usar Flutter 3.29.2. Você pode usar normalmente:

```bash
# Bootstrap do workspace
melos bootstrap

# Executar análise em todos os packages
melos analyze

# Build de todos os apps
melos build:all:apk:debug
```

## ⚙️ Configuração do Editor

### VS Code

1. **Opção 1: Extensão FVM (Recomendado)**
   - Instale a extensão "FVM" no VS Code
   - A extensão detectará automaticamente a configuração

2. **Opção 2: Configuração Manual**
   ```json
   // settings.json
   {
     "dart.flutterSdkPath": "/Users/lucineiloch/fvm/versions/3.29.2"
   }
   ```

### Android Studio

1. Vá em **File > Settings > Languages & Frameworks > Flutter**
2. Defina Flutter SDK path para: `/Users/lucineiloch/fvm/versions/3.29.2`

## 📁 Estrutura de Arquivos FVM

```
monorepo/
├── .fvmrc                    # Configuração global (Flutter 3.29.2)
├── apps/
│   ├── app-gasometer/
│   │   └── .fvmrc           # Configuração local (Flutter 3.29.2)
│   ├── app-petiveti/
│   │   └── .fvmrc           # Configuração local (Flutter 3.29.2)
│   └── ...                  # Todos os apps têm .fvmrc
└── .gitignore               # Configurado para ignorar .fvm/
```

## 🛠️ Scripts de Automação

Execute o script de setup para configurar FVM:

```bash
# Execute uma vez para configurar tudo
./scripts/fvm-setup.sh
```

## ⚠️ Considerações Importantes

### Problemas de Dependências

Como Flutter 3.29.2 usa Dart 3.7.2, algumas dependências podem precisar de ajuste:

```yaml
# pubspec.yaml - Ajustar se necessário
dev_dependencies:
  flutter_lints: ^5.0.0  # Em vez de ^6.0.0 para compatibilidade
```

### PATH Configuration

Adicione FVM ao seu PATH permanentemente:

```bash
# Para bash (~/.bashrc ou ~/.bash_profile)
echo 'export PATH="$PATH:$HOME/.fvm_flutter/bin"' >> ~/.bashrc

# Para zsh (~/.zshrc) 
echo 'export PATH="$PATH:$HOME/.fvm_flutter/bin"' >> ~/.zshrc

# Para fish (~/.config/fish/config.fish)
echo 'set -gx PATH $PATH $HOME/.fvm_flutter/bin' >> ~/.config/fish/config.fish
```

Depois execute: `source ~/.bashrc` ou `source ~/.zshrc`

### CI/CD

Para CI/CD, certifique-se de que o ambiente use FVM:

```yaml
# Exemplo GitHub Actions
- name: Setup FVM
  run: |
    curl -fsSL https://fvm.app/install.sh | bash
    fvm install 3.29.2
    fvm use 3.29.2

- name: Run Flutter commands
  run: |
    fvm flutter pub get
    fvm flutter analyze
    fvm flutter test
```

## 🔍 Verificação

Para verificar se tudo está funcionando corretamente:

```bash
# 1. Verificar FVM
fvm --version

# 2. Verificar Flutter version
fvm flutter --version

# 3. Verificar que está usando a versão correta
fvm flutter --version | grep "3.29.2"

# 4. Testar em um app específico
cd apps/app-gasometer
fvm flutter --version

# 5. Executar doctor
fvm flutter doctor
```

## 🐛 Troubleshooting

### Problema: "No active package fvm"
**Solução:** Adicionar FVM ao PATH ou usar caminho completo:
```bash
~/.fvm_flutter/bin/fvm flutter --version
```

### Problema: Dependências incompatíveis
**Solução:** Downgrade de dependências que requerem Dart > 3.7.2:
```bash
fvm flutter pub add dev:flutter_lints:^5.0.0
```

### Problema: Editor não reconhece SDK
**Solução:** Configurar path manual ou instalar extensão FVM

## 📚 Referências

- [FVM Documentation](https://fvm.app/)
- [Flutter Version Management Best Practices](https://docs.flutter.dev/development/tools/sdk/releases)
- [Melos Documentation](https://melos.invertase.dev/)