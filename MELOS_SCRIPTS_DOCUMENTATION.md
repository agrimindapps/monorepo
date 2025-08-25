# 🚀 DOCUMENTAÇÃO COMPLETA DOS SCRIPTS MELOS

## Visão Geral

Este monorepo Flutter conta com um sistema completo e otimizado de scripts Melos para automação de desenvolvimento, teste e deployment. O sistema foi projetado para maximizar produtividade, performance e qualidade do código.

## 📋 Índice

- [🚀 Setup e Desenvolvimento](#-setup-e-desenvolvimento)
- [🔍 Qualidade e Análise](#-qualidade-e-análise)
- [🧪 Testes](#-testes)
- [🏗️ Builds](#️-builds)
- [🧹 Limpeza e Manutenção](#-limpeza-e-manutenção)
- [⚙️ Geração de Código](#️-geração-de-código)
- [📱 Scripts por App](#-scripts-por-app)
- [🎨 Assets e Ícones](#-assets-e-ícones)
- [🚀 CI/CD e Deployment](#-cicd-e-deployment)
- [🔢 Gerenciamento de Versões](#-gerenciamento-de-versões)
- [📊 Análise e Relatórios](#-análise-e-relatórios)
- [⚡ Otimização de Performance](#-otimização-de-performance)
- [🎯 Execução Seletiva](#-execução-seletiva)
- [🛠️ Debug e Troubleshooting](#️-debug-e-troubleshooting)
- [🎯 Scripts de Conveniência](#-scripts-de-conveniência)

---

## 🚀 Setup e Desenvolvimento

### `melos setup:dev`
**Descrição:** Setup completo para novos desenvolvedores  
**Uso:** Primeira vez configurando o ambiente  
**Inclui:**
- Verificação do Flutter Doctor
- Instalação de ferramentas globais (fvm, flutterfire_cli)
- Bootstrap do workspace
- Configuração inicial

```bash
melos setup:dev
```

### `melos deps:sync`
**Descrição:** Sincroniza dependências em todos os packages  
**Uso:** Após mudanças no pubspec.yaml  

```bash
melos deps:sync
```

### `melos deps:upgrade`
**Descrição:** Atualiza dependências em todos os packages  
**Uso:** Atualização periódica de dependências  

```bash
melos deps:upgrade
```

### `melos deps:outdated`
**Descrição:** Lista dependências desatualizadas  
**Uso:** Auditoria de dependências  

```bash
melos deps:outdated
```

---

## 🔍 Qualidade e Análise

### `melos analyze`
**Descrição:** Análise estática básica em todos os packages  
**Uso:** Verificação contínua durante desenvolvimento  

```bash
melos analyze
```

### `melos analyze:strict`
**Descrição:** Análise estática rigorosa (falha em warnings)  
**Uso:** CI/CD e verificação pré-commit  

```bash
melos analyze:strict
```

### `melos format`
**Descrição:** Formata código em todos os packages  
**Uso:** Padronização de estilo  

```bash
melos format
```

### `melos format:fix`
**Descrição:** Formata e aplica correções automáticas  
**Uso:** Correção de problemas de lint automaticamente  

```bash
melos format:fix
```

### `melos lint:check`
**Descrição:** Verificação completa de qualidade do código  
**Uso:** Verificação pré-deploy  
**Inclui:**
- Análise estática
- Verificação de formatação
- Verificação de imports

```bash
melos lint:check
```

---

## 🧪 Testes

### `melos test`
**Descrição:** Executa testes unitários em todos os packages  
**Uso:** Execução básica de testes  

```bash
melos test
```

### `melos test:unit`
**Descrição:** Executa apenas testes unitários  
**Uso:** Testes focados em lógica de negócio  

```bash
melos test:unit
```

### `melos test:widget`
**Descrição:** Executa apenas testes de widget  
**Uso:** Testes de componentes UI  

```bash
melos test:widget
```

### `melos test:integration`
**Descrição:** Executa testes de integração  
**Uso:** Testes end-to-end  

```bash
melos test:integration
```

### `melos test:coverage`
**Descrição:** Executa testes e gera relatório de coverage  
**Uso:** Análise de cobertura de testes  
**Output:** `coverage/html/index.html`

```bash
melos test:coverage
```

### `melos test:watch`
**Descrição:** Executa testes em modo watch para desenvolvimento  
**Uso:** Desenvolvimento com feedback contínuo  

```bash
melos test:watch
```

---

## 🏗️ Builds

### Builds APK (Todos os Apps)

#### `melos build:all:apk`
**Descrição:** Build APK RELEASE para todos os apps com split-per-abi  
**Uso:** Builds de produção otimizados  
**Features:**
- Split por arquitetura (ARM64, ARM, x86)
- Contagem de sucessos/falhas
- Logs detalhados

```bash
melos build:all:apk
```

#### `melos build:all:apk:debug`
**Descrição:** Build APK DEBUG para todos os apps  
**Uso:** Builds de desenvolvimento  

```bash
melos build:all:apk:debug
```

#### `melos build:all:apk:profile`
**Descrição:** Build APK PROFILE para todos os apps  
**Uso:** Análise de performance  

```bash
melos build:all:apk:profile
```

### Builds para Produção

#### `melos build:all:android:release`
**Descrição:** Build App Bundle para Play Store - Todos os apps  
**Uso:** Deploy na Play Store  

```bash
melos build:all:android:release
```

#### `melos build:all:ios:release`
**Descrição:** Build IPA para App Store - Todos os apps  
**Uso:** Deploy na App Store (somente macOS)  

```bash
melos build:all:ios:release
```

#### `melos build:all:web:release`
**Descrição:** Build Web para todos os apps  
**Uso:** Deploy web com renderer HTML  

```bash
melos build:all:web:release
```

### Builds por Plataforma (CI/CD)

#### `melos ci:matrix:android`
**Descrição:** Matrix build para Android (debug, profile, release, bundle)  
**Uso:** CI/CD para Android  
**Inclui:**
- Build debug
- Build profile
- Build release com split-per-abi
- App Bundle

```bash
melos ci:matrix:android
```

#### `melos ci:matrix:ios`
**Descrição:** Matrix build para iOS (debug, profile, release, ipa)  
**Uso:** CI/CD para iOS (somente macOS)  

```bash
melos ci:matrix:ios
```

---

## 🧹 Limpeza e Manutenção

### `melos clean`
**Descrição:** Limpa builds e caches básicos  
**Uso:** Limpeza rápida  

```bash
melos clean
```

### `melos clean:deep`
**Descrição:** Limpeza profunda incluindo caches e temporários  
**Uso:** Resolução de problemas ou limpeza completa  
**Remove:**
- Builds do Flutter
- Pub cache
- node_modules
- Arquivos temporários (.DS_Store, *.lock)

```bash
melos clean:deep
```

### `melos clean:builds`
**Descrição:** Remove apenas diretórios de build  
**Uso:** Limpeza focada em builds  

```bash
melos clean:builds
```

---

## ⚙️ Geração de Código

### `melos codegen`
**Descrição:** Executa build_runner em todos os packages  
**Uso:** Geração de código após mudanças em modelos  

```bash
melos codegen
```

### `melos codegen:watch`
**Descrição:** Executa build_runner em modo watch  
**Uso:** Desenvolvimento com geração automática  

```bash
melos codegen:watch
```

### `melos codegen:clean`
**Descrição:** Limpa e regenera todos os arquivos de código  
**Uso:** Reset completo da geração de código  

```bash
melos codegen:clean
```

---

## 📱 Scripts por App

### Plantis
```bash
melos run:plantis              # Executa com hot reload
melos build:plantis:android    # App Bundle para Play Store
melos build:plantis:ios        # IPA para App Store
```

### ReceitaAgro
```bash
melos run:receituagro          # Executa com hot reload
melos build:receituagro:android # App Bundle para Play Store
melos build:receituagro:ios     # IPA para App Store
```

### Gasometer
```bash
melos run:gasometer            # Executa com hot reload
melos build:gasometer:android  # App Bundle para Play Store
melos build:gasometer:ios      # IPA para App Store
```

### Task Manager
```bash
melos run:taskmanager          # Executa com hot reload
melos build:taskmanager:android # App Bundle para Play Store
```

### Agrihurbi
```bash
melos run:agrihurbi            # Executa com hot reload
melos build:agrihurbi:android  # App Bundle para Play Store
```

### Petiveti
```bash
melos run:petiveti             # Executa com hot reload
melos build:petiveti:android   # App Bundle para Play Store
```

---

## 🎨 Assets e Ícones

### `melos icons:generate`
**Descrição:** Gera ícones para todos os apps automaticamente  
**Uso:** Atualização de ícones em massa  

```bash
melos icons:generate
```

### Icons por App
```bash
melos icons:plantis       # Gera ícones para Plantis
melos icons:receituagro   # Gera ícones para ReceitaAgro  
melos icons:gasometer     # Gera ícones para Gasometer
```

---

## 🚀 CI/CD e Deployment

### `melos ci:check`
**Descrição:** Pipeline completo de verificações para CI  
**Uso:** Verificação automática em CI/CD  
**Inclui:**
1. Análise estática rigorosa
2. Verificação de formatação
3. Execução de testes
4. Build de teste
5. Verificação de dependências

```bash
melos ci:check
```

### `melos full:pipeline`
**Descrição:** Pipeline completo de desenvolvimento  
**Uso:** Verificação manual completa  
**Etapas:**
1. Limpeza
2. Sincronização de dependências
3. Análise estática
4. Formatação
5. Testes
6. Build release

```bash
melos full:pipeline
```

---

## 🔢 Gerenciamento de Versões

O sistema de versões utiliza semantic versioning (MAJOR.MINOR.PATCH+BUILD) com automação completa.

### Bump de Versões
```bash
melos version:bump:patch    # Incrementa versão patch
melos version:bump:minor    # Incrementa versão minor
melos version:bump:major    # Incrementa versão major
```

### Bump com Git Tags
```bash
melos version:tag:patch     # Bump patch + git tag
melos version:tag:minor     # Bump minor + git tag
melos version:tag:major     # Bump major + git tag
```

### Consulta de Versões
```bash
melos version:list          # Lista versões atuais
```

### Script Avançado de Versões
O script `scripts/version_manager.sh` oferece funcionalidades avançadas:

```bash
# Exemplos de uso direto do script
./scripts/version_manager.sh patch --app app-plantis  # Bump apenas no Plantis
./scripts/version_manager.sh minor --tag             # Bump minor e criar tag
./scripts/version_manager.sh list                    # Listar versões
./scripts/version_manager.sh help                    # Ajuda completa
```

---

## 📊 Análise e Relatórios

### `melos analyze:metrics`
**Descrição:** Coleta métricas básicas do projeto  
**Uso:** Análise de estrutura e tamanho do projeto  
**Métricas:**
- Contagem de arquivos Dart
- Linhas de código
- Estrutura de packages

```bash
melos analyze:metrics
```

### `melos analyze:dependencies`
**Descrição:** Analisa dependências de todo o monorepo  
**Uso:** Auditoria de dependências  
**Output:** `deps_analysis.json`

```bash
melos analyze:dependencies
```

### `melos analyze:security`
**Descrição:** Análise básica de segurança do código  
**Uso:** Verificação de segurança automatizada  
**Verifica:**
- Hardcoded secrets
- Imports inseguros
- Padrões de risco

```bash
melos analyze:security
```

---

## ⚡ Otimização de Performance

O sistema inclui scripts avançados de otimização de performance através do `performance_optimizer.sh`.

### `melos perf:setup`
**Descrição:** Configura sistema de cache e otimizações  
**Uso:** Setup inicial de otimizações  
**Inclui:**
- Cache inteligente
- Otimizações do Gradle
- Configurações de performance

```bash
melos perf:setup
```

### `melos perf:build:parallel`
**Descrição:** Builds paralelos otimizados para release  
**Uso:** Builds de produção de alta performance  

```bash
melos perf:build:parallel
```

### `melos perf:test:parallel`
**Descrição:** Testes paralelos otimizados  
**Uso:** Execução rápida de testes  

```bash
melos perf:test:parallel
```

### `melos perf:analyze`
**Descrição:** Análise estática otimizada com cache  
**Uso:** Análise rápida com cache inteligente  

```bash
melos perf:analyze
```

### `melos perf:stats`
**Descrição:** Estatísticas de performance do monorepo  
**Uso:** Monitoramento de performance  

```bash
melos perf:stats
```

### `melos perf:benchmark`
**Descrição:** Benchmark completo de performance  
**Uso:** Medição e otimização de performance  

```bash
melos perf:benchmark
```

### `melos perf:cache:clean`
**Descrição:** Limpa todo o cache de performance  
**Uso:** Reset do sistema de cache  

```bash
melos perf:cache:clean
```

---

## 🎯 Execução Seletiva

Sistema inteligente de execução baseada apenas nos packages modificados, otimizando tempo de CI/CD.

### `melos selective:analyze`
**Descrição:** Análise apenas nos packages modificados  
**Uso:** CI/CD otimizado - análise seletiva  

```bash
melos selective:analyze
```

### `melos selective:test`
**Descrição:** Testes apenas nos packages modificados  
**Uso:** CI/CD otimizado - testes seletivos  

```bash
melos selective:test
```

### `melos selective:build`
**Descrição:** Builds apenas nos packages modificados  
**Uso:** CI/CD otimizado - builds seletivos  

```bash
melos selective:build
```

### `melos selective:ci`
**Descrição:** Pipeline de CI apenas nos packages modificados  
**Uso:** CI/CD completo otimizado  

```bash
melos selective:ci
```

### `melos selective:list`
**Descrição:** Lista packages modificados desde main  
**Uso:** Verificação de escopo de mudanças  

```bash
melos selective:list
```

### `melos selective:stats`
**Descrição:** Estatísticas dos packages modificados  
**Uso:** Análise de impacto das mudanças  

```bash
melos selective:stats
```

### Script Avançado de Execução Seletiva
```bash
# Exemplos de uso direto do script
./scripts/selective_runner.sh analyze --base develop    # Comparar com develop
./scripts/selective_runner.sh test --all              # Processar todos
./scripts/selective_runner.sh ci --dry-run            # Ver o que seria executado
```

---

## 🛠️ Debug e Troubleshooting

### `melos debug:info`
**Descrição:** Exibe informações completas para debug  
**Uso:** Diagnóstico de problemas  
**Inclui:**
- Flutter Doctor
- Informações do Melos
- Packages do workspace
- Ferramentas globais

```bash
melos debug:info
```

### `melos debug:cleanup`
**Descrição:** Limpeza completa para resolver problemas  
**Uso:** Reset quando há problemas persistentes  

```bash
melos debug:cleanup
```

---

## 🎯 Scripts de Conveniência

### `melos quick:check`
**Descrição:** Verificação rápida de análise e formatação  
**Uso:** Check rápido durante desenvolvimento  

```bash
melos quick:check
```

### `melos quick:build`
**Descrição:** Build debug rápido para teste  
**Uso:** Verificação rápida de build  

```bash
melos quick:build
```

### `melos help`
**Descrição:** Exibe ajuda com todos os comandos disponíveis  
**Uso:** Referência rápida dos comandos  

```bash
melos help
```

---

## 🔧 Configurações Avançadas

### Variáveis de Ambiente

O sistema suporta várias variáveis de ambiente para customização:

```bash
# Cache customizado
export MONOREPO_CACHE_DIR="$HOME/custom_cache"

# Jobs paralelos
export PARALLEL_JOBS=8

# Flutter customizado
export FLUTTER_ROOT="/custom/flutter/path"
```

### Hooks do Melos

O sistema inclui hooks automáticos:

#### Bootstrap
- **Post-hook:** Exibe estatísticas do workspace
- **Pré-requisitos:** SDK versions, Flutter version

#### Clean
- **Pre-hook:** Aviso de limpeza
- **Post-hook:** Confirmação de sucesso

---

## 📈 Workflow Recomendado

### Desenvolvimento Diário
```bash
1. melos setup:dev          # (apenas uma vez)
2. melos deps:sync         # ao modificar pubspec.yaml
3. melos quick:check       # verificação rápida
4. melos test              # executar testes
5. melos run:app_name      # executar app específico
```

### Pré-Commit
```bash
1. melos lint:check        # verificação completa
2. melos test              # testes completos
3. melos selective:ci      # CI seletivo
```

### CI/CD Pipeline
```bash
1. melos perf:setup        # configurar otimizações
2. melos selective:ci      # pipeline seletivo otimizado
3. melos ci:matrix:android # builds de matriz (se necessário)
4. melos version:tag:patch # bump e tag (em releases)
```

### Release Workflow
```bash
1. melos full:pipeline           # pipeline completo
2. melos version:bump:minor      # bump de versão
3. melos build:all:android:release # builds de produção
4. melos build:all:ios:release   # builds iOS
5. git push origin v1.2.3       # push da tag
```

---

## 🚀 Scripts Customizados

### Estrutura dos Scripts

```
scripts/
├── version_manager.sh       # Gerenciamento de versões automatizado
├── selective_runner.sh      # Execução seletiva baseada em mudanças
└── performance_optimizer.sh # Otimizações de performance
```

Todos os scripts incluem:
- ✅ Help detalhado (`script.sh help`)
- ✅ Logging colorido e estruturado
- ✅ Tratamento de erros robusto
- ✅ Dry-run mode para teste
- ✅ Configuração via parâmetros
- ✅ Compatibilidade macOS/Linux

---

## 🎯 Casos de Uso Específicos

### Para Novos Desenvolvedores
```bash
# Setup inicial completo
git clone <repository>
cd monorepo
melos setup:dev
melos perf:setup
```

### Para CI/CD
```bash
# Pipeline otimizado
melos perf:setup
melos selective:ci
melos ci:matrix:android  # se necessário
```

### Para Release
```bash
# Processo de release
melos full:pipeline
melos version:tag:minor
melos build:all:android:release
melos build:all:ios:release
```

### Para Debug de Problemas
```bash
# Diagnóstico completo
melos debug:info
melos debug:cleanup
melos perf:benchmark
```

---

## 📊 Métricas e Monitoramento

O sistema oferece várias formas de monitoramento:

### Métricas de Performance
- ⏱️ Tempo de builds
- 📊 Tamanho de cache
- 🔄 Jobs paralelos utilizados
- 📈 Cobertura de testes

### Métricas de Qualidade
- 🔍 Issues de análise estática
- 🧪 Taxa de sucesso dos testes
- 📏 Linhas de código
- 📦 Número de dependências

### Métricas de CI/CD
- ⚡ Tempo de pipeline
- 🎯 Packages modificados
- 📱 Sucesso de builds por plataforma
- 🔢 Frequência de releases

---

## 🔮 Futuras Melhorias

### Roadmap
- [ ] Integração com Docker para builds consistentes
- [ ] Suporte a Flutter Web com PWA
- [ ] Análise automática de bundle size
- [ ] Integração com ferramentas de monitoramento (Sentry, Firebase)
- [ ] Cache distribuído para CI/CD
- [ ] Automação de changelogs
- [ ] Integração com stores (Play Store, App Store) via API

### Contribuições

Para contribuir com melhorias nos scripts:

1. Fork o repositório
2. Crie branch para feature (`git checkout -b feature/nova-feature`)
3. Teste extensively com `melos debug:info`
4. Commit com conventional commits
5. Abra Pull Request

---

## 📞 Suporte

### Troubleshooting Comum

#### Problema: Build falha com "Execution failed for task"
**Solução:**
```bash
melos clean:deep
melos perf:setup
melos debug:cleanup
```

#### Problema: Testes lentos
**Solução:**
```bash
melos perf:test:parallel  # usar testes paralelos
melos perf:benchmark      # verificar performance
```

#### Problema: Cache corrompido
**Solução:**
```bash
melos perf:cache:clean
melos clean:deep
melos setup:dev
```

### Contato

Para suporte adicional:
- 📧 Issues no GitHub
- 📚 Documentação nos READMEs dos apps
- 🛠️ `melos help` para referência rápida

---

**💡 Dica:** Use `melos help` para uma referência rápida de todos os comandos disponíveis durante o desenvolvimento!

---

*Documentação atualizada em: $(date) - Versão do sistema: 2.0*