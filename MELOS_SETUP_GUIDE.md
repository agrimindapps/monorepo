# 🚀 GUIA DE SETUP RÁPIDO - SISTEMA MELOS OTIMIZADO

## 📋 Pré-requisitos

Certifique-se de ter instalado:

- ✅ **Flutter SDK** (3.10.0 ou superior)
- ✅ **Dart SDK** (3.7.2 ou superior)  
- ✅ **Git** (para controle de versão)
- ✅ **Melos** (instalado globalmente)

## 🚀 Setup Inicial (5 minutos)

### 1. Instalar Melos Globalmente
```bash
flutter pub global activate melos
```

### 2. Clone e Setup do Projeto
```bash
git clone <repository_url>
cd monorepo
```

### 3. Setup Automatizado Completo
```bash
# Executa setup completo para novos desenvolvedores
flutter pub global run melos run setup:dev
```

### 4. Configurar Otimizações de Performance
```bash
# Configura cache inteligente e otimizações
flutter pub global run melos run perf:setup
```

### 5. Validar Sistema
```bash
# Valida se tudo está funcionando
flutter pub global run melos run validate:system
```

## ✅ Verificação Rápida

Após o setup, teste os comandos básicos:

```bash
# Listar todos os packages
flutter pub global run melos list

# Ver comandos disponíveis
flutter pub global run melos run help

# Verificar versões dos apps
flutter pub global run melos run version:list

# Executar análise rápida
flutter pub global run melos run quick:check
```

## 🎯 Comandos Mais Utilizados

### Desenvolvimento Diário
```bash
# Análise estática rápida
flutter pub global run melos run quick:check

# Executar testes
flutter pub global run melos test

# Build rápido para teste
flutter pub global run melos run quick:build

# Executar app específico
flutter pub global run melos run run:plantis
```

### CI/CD Otimizado
```bash
# Pipeline seletivo (apenas packages modificados)
flutter pub global run melos run selective:ci

# Builds paralelos otimizados
flutter pub global run melos run perf:build:parallel

# Testes paralelos
flutter pub global run melos run perf:test:parallel
```

### Gerenciamento de Versões
```bash
# Listar versões atuais
flutter pub global run melos run version:list

# Increment patch version
flutter pub global run melos run version:bump:patch

# Increment minor version com git tag
flutter pub global run melos run version:tag:minor
```

## 🏗️ Builds de Produção

### Android (APK + App Bundle)
```bash
# APK para todos os apps
flutter pub global run melos run build:all:apk

# App Bundles para Play Store
flutter pub global run melos run build:all:android:release
```

### iOS (somente macOS)
```bash
# IPAs para App Store
flutter pub global run melos run build:all:ios:release
```

### Matrix Builds (CI/CD)
```bash
# Matrix completo Android
flutter pub global run melos run ci:matrix:android

# Matrix completo iOS (macOS only)
flutter pub global run melos run ci:matrix:ios
```

## 🧹 Limpeza e Manutenção

```bash
# Limpeza básica
flutter pub global run melos clean

# Limpeza profunda (resolve a maioria dos problemas)
flutter pub global run melos run clean:deep

# Limpeza de cache de performance
flutter pub global run melos run perf:cache:clean

# Reset completo para troubleshooting
flutter pub global run melos run debug:cleanup
```

## 📊 Monitoramento e Análise

```bash
# Estatísticas do projeto
flutter pub global run melos run analyze:metrics

# Estatísticas de performance
flutter pub global run melos run perf:stats

# Benchmark de performance
flutter pub global run melos run perf:benchmark

# Análise de segurança
flutter pub global run melos run analyze:security
```

## 🎯 Execução Seletiva (Otimização de CI/CD)

O sistema detecta automaticamente packages modificados e executa ações apenas onde necessário:

```bash
# Listar packages modificados
flutter pub global run melos run selective:list

# Análise apenas em mudanças
flutter pub global run melos run selective:analyze

# Testes apenas em mudanças
flutter pub global run melos run selective:test

# Pipeline CI completo seletivo
flutter pub global run melos run selective:ci
```

## 🛠️ Troubleshooting

### Problema: Comando não encontrado
**Solução:**
```bash
# Verificar se Melos está instalado
flutter pub global list | grep melos

# Reinstalar se necessário
flutter pub global activate melos
```

### Problema: Builds falhando
**Solução:**
```bash
# Limpeza profunda
flutter pub global run melos run clean:deep

# Reconfigurar otimizações
flutter pub global run melos run perf:setup

# Diagnóstico completo
flutter pub global run melos run debug:info
```

### Problema: Performance lenta
**Solução:**
```bash
# Configurar otimizações de performance
flutter pub global run melos run perf:setup

# Usar execução paralela
flutter pub global run melos run perf:test:parallel

# Usar execução seletiva
flutter pub global run melos run selective:ci
```

### Problema: Cache corrompido
**Solução:**
```bash
# Limpar todos os caches
flutter pub global run melos run perf:cache:clean
flutter pub global run melos run clean:deep
flutter pub cache clean --force

# Reconfigurar
flutter pub global run melos run setup:dev
```

## 📱 Apps do Monorepo

Este monorepo contém os seguintes apps:

1. **🌱 Plantis** (`app-plantis`) - App para plantas domésticas
2. **🌾 ReceitaAgro** (`app-receituagro`) - Compêndio de pragas agrícolas
3. **⛽ Gasometer** (`app-gasometer`) - Controle de combustível
4. **📋 Task Manager** (`app_taskolist`) - Gerenciador de tarefas
5. **🚜 Agrihurbi** (`app_agrihurbi`) - Ferramentas agrícolas
6. **🐕 Petiveti** (`app-petiveti`) - App veterinário

### Comandos por App
```bash
# Executar app específico
flutter pub global run melos run run:plantis
flutter pub global run melos run run:receituagro
flutter pub global run melos run run:gasometer

# Build específico
flutter pub global run melos run build:plantis:android
flutter pub global run melos run build:receituagro:ios
```

## 🔧 Scripts Avançados

O sistema inclui scripts bash avançados em `scripts/`:

### Version Manager
```bash
./scripts/version_manager.sh help
./scripts/version_manager.sh list
./scripts/version_manager.sh patch --app app-plantis --tag
```

### Selective Runner
```bash
./scripts/selective_runner.sh help
./scripts/selective_runner.sh ci --base develop
./scripts/selective_runner.sh test --dry-run
```

### Performance Optimizer
```bash
./scripts/performance_optimizer.sh help
./scripts/performance_optimizer.sh setup
./scripts/performance_optimizer.sh benchmark
```

## 📚 Documentação Completa

Para documentação completa de todos os comandos e funcionalidades:

📖 **[MELOS_SCRIPTS_DOCUMENTATION.md](MELOS_SCRIPTS_DOCUMENTATION.md)**

## 🚀 Workflow Recomendado para Equipes

### Setup Inicial (Uma vez por desenvolvedor)
```bash
1. Clone do repositório
2. flutter pub global run melos run setup:dev
3. flutter pub global run melos run perf:setup
4. flutter pub global run melos run validate:system
```

### Desenvolvimento Diário
```bash
1. git pull origin main
2. flutter pub global run melos run deps:sync
3. flutter pub global run melos run quick:check
4. # Desenvolvimento normal
5. flutter pub global run melos run selective:ci  # antes do commit
```

### Release Process
```bash
1. flutter pub global run melos run full:pipeline
2. flutter pub global run melos run version:bump:minor
3. flutter pub global run melos run build:all:android:release
4. flutter pub global run melos run build:all:ios:release
5. git push origin --tags
```

## 💡 Dicas de Produtividade

1. **Use aliases** para comandos frequentes:
   ```bash
   alias melos="flutter pub global run melos"
   alias mc="melos run quick:check"
   alias mt="melos test"
   alias mb="melos run quick:build"
   ```

2. **Configure IDE** para executar comandos Melos como tasks

3. **Use execução seletiva** em CI/CD para economizar tempo e recursos

4. **Configure cache** adequadamente para melhor performance

5. **Use builds paralelos** para máximo throughput

## 🎯 Próximos Passos

Após o setup inicial:

1. ✅ Execute `flutter pub global run melos run validate:system`
2. ✅ Leia `MELOS_SCRIPTS_DOCUMENTATION.md`
3. ✅ Configure aliases conforme sua preferência
4. ✅ Teste um build: `flutter pub global run melos run quick:build`
5. ✅ Configure seu IDE com tasks Melos
6. ✅ Teste o workflow de desenvolvimento completo

---

**🎉 Parabéns! Seu sistema Melos otimizado está pronto para uso!**

Para suporte adicional, consulte a documentação completa ou abra uma issue no repositório.