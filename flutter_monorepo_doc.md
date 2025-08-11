## Configurações Essenciais (Projeto Solo/Privado)

### 🔧 **ESSENCIAL - Environment Config (Sempre implementar)**

```dart
// packages/core/lib/src/shared/config/environment_config.dart
enum Environment { development, production }

class EnvironmentConfig {
  static Environment get environment {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    return env == 'production' ? Environment.production : Environment.development;
  }
  
  static String get firebaseProjectId {
    switch (environment) {
      case Environment.development: return 'plantis-receituagro-dev';
      case Environment.production: return 'plantis-receituagro-prod';
    }
  }
  
  static String get revenueCatApiKey {
    switch (environment) {
      case Environment.development: return 'rc_dev_key_123';
      case Environment.production: return 'rc_prod_key_789';
    }
  }
}
```

### 🔐 **ESSENCIAL - Secrets (Para não commitar API keys)**

```yaml
# .env.example (commitar este exemplo)
FIREBASE_DEV_PROJECT_ID=seu-projeto-dev
FIREBASE_PROD_PROJECT_ID=seu-projeto-prod
REVENUE_CAT_DEV_KEY=rc_dev_xxx
REVENUE_CAT_PROD_KEY=rc_prod_xxx

# .gitignore (CRÍTICO - sempre ter)
.env
**/google-services.json
**/GoogleService-Info.plist
```

### 🧪 **ÚTIL - Testes Básicos (Vale a pena)**

```yaml
# melos.yaml - scripts simples
scripts:
  test:
    run: flutter test
    description: Executa testes
    
  test:coverage:
    run: flutter test --coverage
    description: Executa testes com cobertura
```

### 📝 **OPCIONAL - Documentação Mínima**

```markdown
# README.md

## Setup Rápido
1. `git clone repo && cd projeto`
2. `dart pub global activate melos`
3. `melos bootstrap` 
4. `cp .env.example .env` (e configure suas API keys)
5. `melos run run:plantis` ou `melos run run:receituagro`

## Comandos Úteis
- `melos run run:plantis` - App plantas
- `melos run run:receituagro` - App pragas  
- `melos run build:plantis:android` - Build Plantis
- `melos run test` - Rodar testes
```

---

## ❌ O que PULAR (projeto solo/privado)

### 🚫 **CI/CD Pipeline** 
- **Por quê pular**: Você testa manualmente antes de fazer build
- **Alternativa**: Rodar `melos run test` antes de deploy manual

### 🚫 **Pre-commit Hooks**
- **Por quê pular**: Você já cuida da qualidade do código
- **Alternativa**: Rodar `melos run analyze` quando quiser

### 🚫 **Code Review Checklist**
- **Por quê pular**: Você não faz code review sozinho
- **Alternativa**: Mental checklist próprio

### 🚫 **Branch Strategy Complexa**
- **Por quê pular**: Trabalha direto na main ou com branches simples
- **Alternativa**: `main` para produção, `feature/nome` para features grandes

### 🚫 **Flavors Android Complexos**
- **Por quê pular**: Só precisa de dev e prod, não staging
- **Alternativa**: 
```bash
# Desenvolvimento (padrão)
flutter run

# Produção  
flutter build appbundle --release
```

### 🚫 **Monitoramento Avançado**
- **Por quê pular**: Firebase Analytics básico já resolve
- **Alternativa**: Crashlytics + Analytics básico do Firebase

### 🚫 **Golden Tests**
- **Por quê pular**: Testes visuais são overhead para projeto solo
- **Alternativa**: Testes unitários + testes manuais

---

## ✅ O que MANTER (essencial mesmo solo)

### 🔥 **CRÍTICO**
1. **Environment Config** - Separar dev/prod é fundamental
2. **Secrets no .gitignore** - Nunca commitar API keys  
3. **Core bem definido** - Manter arquitetura limpa
4. **Melos scripts** - Automação básica dos comandos

### 📈 **IMPORTANTE** 
1. **Testes unitários básicos** - Para partes críticas (auth, payments)
2. **Firebase Crashlytics** - Para detectar bugs em produção
3. **Analytics básico** - Para entender uso dos apps

### 🎨 **NICE TO HAVE**
1. **README.md simples** - Para quando você esquecer comandos
2. **Estrutura de pastas organizada** - Para manter sanidade mental

## 🚀 **Comandos Práticos (Versão Solo)**

```bash
# Setup inicial (só uma vez)
git clone seu-repo
cd projeto  
dart pub global activate melos
melos bootstrap
cp .env.example .env  # Configure suas API keys

# Desenvolvimento diário
melos run run:plantis        # Testar Plantis
melos run run:receituagro    # Testar ReceitaAgro

# Deploy (quando pronto)
melos run build:plantis:android      # Plantis → Play Store
melos run build:receituagro:ios      # ReceitaAgro → App Store

# Verificação rápida (quando quiser)
melos run test              # Rodar testes
melos run analyze           # Verificar código
```

## 💡 **Dicas para Projeto Solo**

### 🎯 **Foque no que importa:**
- ✅ Apps funcionando bem
- ✅ Core organizado 
- ✅ Deploy fácil para lojas
- ✅ Secrets seguros
- ❌ Overengineering em processos

### 🔄 **Evolução gradual:**
- **Início**: Core + um app funcionando
- **Meio**: Segundo app + testes básicos  
- **Futuro**: Se crescer, aí adiciona CI/CD

### 🧠 **Mental models:**
- "Está funcionando? Está organizado? Está seguro? Então está bom!"
- "Se precisar de mais complexidade no futuro, adiciono depois"
- "Melhor código simples que funciona do que código complexo que não termina"

**🎯 Core = Firebase + RevenueCat + Hive (Infraestrutura Pura)**

### 🔧 **O que FICA no Core (Essencial Compartilhado)**
- ✅ **Firebase Auth** - Login/logout para ambos apps
- ✅ **Firebase Analytics** - Tracking de eventos (cada app com seus eventos)
- ✅ **Firebase Crashlytics** - Monitoramento de crashes
- ✅ **Firebase Storage** - Upload de imagens (plantas e pragas)
- ✅ **RevenueCat** - Assinaturas/IAP (cada app com seus produtos)
- ✅ **Hive** - Storage local (cada app com suas chaves)
- ✅ **User Entity** - Dados básicos do usuário
- ✅ **Subscription Entity** - Dados de assinatura
- ✅ **Widgets Básicos** - Loading, Error, AppBar, Paywall

### 🚫 **O que NÃO está no Core (Específico de Cada App)**

#### 🌱 **Plantis (Plantas Domésticas)**
- 📱 **Entities**: `PlantEntity`, `CareEntity`, `TaskEntity`
- 🔧 **Services**: Sistema de lembretes, agendamento de tarefas
- 📊 **Analytics**: `plant_care_logged`, `reminder_scheduled`, `plant_photo_updated`
- 💰 **Produtos**: `plantis_premium_monthly`, `plantis_premium_yearly`
- 📁 **Storage**: `plants/{plantId}/photos/`, `user_plants`, `care_history`

#### 🚜 **ReceitaAgro (Pragas Agrícolas)**
- 📱 **Entities**: `PestEntity`, `DefensiveEntity`, `RecipeEntity`
- 🔧 **Services**: Cálculo de dosagens, geração de PDFs, diagnóstico
- 📊 **Analytics**: `recipe_created`, `pest_diagnosed`, `dosage_calculated`
- 💰 **Produtos**: `receituagro_pro_monthly`, `receituagro_pro_yearly`
- 📁 **Storage**: `pests/{pestId}/images/`, `recent_recipes`, `offline_recipes`

### 🚀 **Comandos Práticos**

```bash
# Desenvolvimento diário
melos run run:plantis        # App plantas domésticas
melos run run:receituagro    # App pragas agrícolas

# Deploy para lojas
melos run build:plantis:android      # Plantis → Play Store
melos run build:plantis:ios          # Plantis → App Store
melos run build:receituagro:android  # ReceitaAgro → Play Store
melos run build:receituagro:ios      # ReceitaAgro → App Store

# Análise e testes
melos run analyze
melos run test
melos run format
```

### 💡 **Vantagens desta Arquitetura**

#### ✅ **Infraestrutura Compartilhada Inteligente**
- **Auth único**: User faz login uma vez, funciona em ambos apps
- **Analytics consolidado**: Dashboard único para métricas de ambos apps
- **Storage otimizado**: Firebase Storage compartilhado com pastas organizadas
- **RevenueCat centralizado**: Gestão de assinaturas em um só lugar

#### ✅ **Flexibilidade Total**
```dart
// ✅ Cada app usa o core como quiser
// Plantis: fotos de plantas, lembretes de cuidado
await storageRepo.uploadImage(plantPhoto, 'plants/${plantId}/photos/');
await analyticsRepo.logEvent('plant_care_logged', {'care_type': 'watering'});

// ReceitaAgro: fotos de pragas, receitas técnicas  
await storageRepo.uploadImage(pestPhoto, 'pests/${pestId}/images/');
await analyticsRepo.logEvent('recipe_created', {'target_pest': 'lagarta'});
```

#### ✅ **Deploy e Monetização Independentes**
- **Plantis**: Pode ter assinatura de R$ 9,90/mês para plantas ilimitadas
- **ReceitaAgro**: Pode ter assinatura de R$ 29,90/mês para receitas premium
- **Versões independentes**: Plantis v2.1 e ReceitaAgro v1.5 podem coexistir
- **Lojas separadas**: Cada app tem sua página na Play Store/App Store

#### ✅ **Desenvolvimento Eficiente**
- **Core mantido**: Correção no Firebase Auth beneficia ambos apps
- **Features específicas**: Lembretes de rega só no Plantis, PDFs só no ReceitaAgro
- **Time especializado**: Devs podem focar em plantas OU pragas
- **Testes isolados**: Bug no cálculo de dosagem não afeta lembretes de plantas

### 🎯 **Casos de Uso Reais**

#### 🌱 **Usuário do Plantis (Maria, apartamento)**
```dart
// Login compartilhado (Core)
await authRepo.login('maria@email.com', 'senha123');

// Adicionar planta (Plantis específico)
final plant = PlantEntity(
  name: 'Suculenta do escritório',
  species: 'Echeveria elegans',
  location: 'Mesa do home office',
);

// Upload foto (Core + estrutura Plantis)
await storageRepo.uploadImage(plantPhoto, 'plants/${plant.id}/photos/');

// Analytics específico (Core + evento Plantis)
await analyticsRepo.logEvent('plant_added', {
  'species': plant.species,
  'location': plant.location,
  'app': 'plantis'
});
```

#### 🚜 **Usuário do ReceitaAgro (João, agricultor)**
```dart
// Mesmo login compartilhado (Core)
await authRepo.login('joao@fazenda.com', 'senha456');

// Diagnosticar praga (ReceitaAgro específico)
final pest = PestEntity(
  name: 'Lagarta-do-cartucho',
  affectedCrops: ['Milho'],
  symptoms: ['Furos nas folhas'],
);

// Upload foto da praga (Core + estrutura ReceitaAgro)
await storageRepo.uploadImage(pestPhoto, 'pests/${pest.id}/images/');

// Analytics específico (Core + evento ReceitaAgro)
await analyticsRepo.logEvent('pest_diagnosed', {
  'pest_name': pest.name,
  'affected_crop': 'Milho',
  'app': 'receituagro'
});
```

### 🏗️ **Como Extrair um App (quando necessário)**

```bash
# Script de extração automática
./tools/extract_app.sh app-plantis ../plantis-standalone

# O que acontece:
# 1. Copia app-plantis para diretório standalone
# 2. Copia packages/core como dependência local
# 3. Atualiza pubspec.yaml para apontar para core local
# 4. App Plantis vira projeto independente mantendo todos os services do core
```

## ✨ Resumo da Arquitetura Final + Melhorias

**🎯 Core = Firebase + RevenueCat + Hive (Infraestrutura Pura)**

### 🔧 **O que FICA no Core (Essencial Compartilhado)**
- ✅ **Firebase Auth** - Login/logout para ambos apps
- ✅ **Firebase Analytics** - Tracking de eventos (cada app com seus eventos)
- ✅ **Firebase Crashlytics** - Monitoramento de crashes
- ✅ **Firebase Storage** - Upload de imagens (plantas e pragas)
- ✅ **RevenueCat** - Assinaturas/IAP (cada app com seus produtos)
- ✅ **Hive** - Storage local (cada app com suas chaves)
- ✅ **User Entity** - Dados básicos do usuário
- ✅ **Subscription Entity** - Dados de assinatura
- ✅ **Widgets Básicos** - Loading, Error, AppBar, Paywall
- ✅ **Environment Config** - Configuração de ambientes (dev/staging/prod)

### 🚫 **O que NÃO está no Core (Específico de Cada App)**

#### 🌱 **Plantis (Plantas Domésticas)**
- 📱 **Entities**: `PlantEntity`, `CareEntity`, `TaskEntity`
- 🔧 **Services**: Sistema de lembretes, agendamento de tarefas
- 📊 **Analytics**: `plant_care_logged`, `reminder_scheduled`, `plant_photo_updated`
- 💰 **Produtos**: `plantis_premium_monthly`, `plantis_premium_yearly`
- 📁 **Storage**: `plants/{plantId}/photos/`, `user_plants`, `care_history`

#### 🚜 **ReceitaAgro (Pragas Agrícolas)**
- 📱 **Entities**: `PestEntity`, `DefensiveEntity`, `RecipeEntity`
- 🔧 **Services**: Cálculo de dosagens, geração de PDFs, diagnóstico
- 📊 **Analytics**: `recipe_created`, `pest_diagnosed`, `dosage_calculated`
- 💰 **Produtos**: `receituagro_pro_monthly`, `receituagro_pro_yearly`
- 📁 **Storage**: `pests/{pestId}/images/`, `recent_recipes`, `offline_recipes`

### 🚀 **Comandos Práticos Atualizados**

```bash
# Setup inicial (uma vez só)
./tools/setup_project.sh

# Desenvolvimento diário
melos run run:plantis        # App plantas domésticas
melos run run:receituagro    # App pragas agrícolas

# Testes
melos run test:all           # Todos os testes
melos run test:coverage      # Testes com cobertura
melos run test:golden        # Atualizar golden files

# Deploy para lojas
melos run build:plantis:android      # Plantis → Play Store
melos run build:plantis:ios          # Plantis → App Store
melos run build:receituagro:android  # ReceitaAgro → Play Store
melos run build:receituagro:ios      # ReceitaAgro → App Store

# Análise e qualidade
melos run analyze
melos run format
```

### 💡 **Vantagens desta Arquitetura + Melhorias**

#### ✅ **Infraestrutura Compartilhada Inteligente**
- **Auth único**: User faz login uma vez, funciona em ambos apps
- **Analytics consolidado**: Dashboard único para métricas de ambos apps
- **Storage otimizado**: Firebase Storage compartilhado com pastas organizadas
- **RevenueCat centralizado**: Gestão de assinaturas em um só lugar
- **Environments seguros**: Dev/Staging/Prod configurados corretamente

#### ✅ **Qualidade e Segurança**
- **CI/CD automatizado**: Testes automáticos em cada PR
- **Pre-commit hooks**: Código sempre formatado e analisado
- **Environment configs**: Secrets nunca commitados
- **Monitoramento**: Performance e crashes rastreados
- **Testes abrangentes**: Unit, Widget, Integration, Golden

#### ✅ **Developer Experience**
- **Setup automatizado**: `./tools/setup_project.sh` configura tudo
- **Documentação completa**: Guias de desenvolvimento e convenções
- **Scripts úteis**: Comandos melos para todas as tarefas
- **Hot reload**: Funciona perfeitamente em monorepo
- **Debugging**: Cada app pode ser debugado independentemente

### 🎯 **Principais Dicas de Implementação**

#### 🔥 **Prioridade ALTA (implementar primeiro)**
1. **Environment Config** - Separar dev/staging/prod desde o início
2. **CI/CD Pipeline** - Automação evita bugs em produção
3. **Secrets Management** - Nunca committar API keys
4. **Core bem definido** - Resistir à tentação de "enfiar tudo no core"

#### 📈 **Prioridade MÉDIA (implementar depois)**
1. **Golden Tests** - Para widgets complexos
2. **Performance Monitoring** - Firebase Performance
3. **Crash Reporting** - Crashlytics bem configurado
4. **A/B Testing** - Firebase Remote Config

#### 🎨 **Prioridade BAIXA (nice to have)**
1. **Custom Lint Rules** - Para enforçar padrões específicos
2. **Code Generation** - Para reduzir boilerplate
3. **Internationalization** - Se planeja expandir para outros países

**🎉 Resultado Final:** Dois apps com domínios completamente diferentes (plantas domésticas vs pragas agrícolas) compartilhando uma infraestrutura robusta, segura e bem organizada. Pronto para escalar! 🚀

### 📚 **Próximos Passos Recomendados**
1. Implementar setup básico com environments
2. Configurar CI/CD pipeline
3. Desenvolver core com Firebase + RevenueCat
4. Criar primeiro app (Plantis ou ReceitaAgro)
5. Expandir para o segundo app reutilizando core
6. Otimizar baseado em métricas reais# Arquitetura Monorepo Flutter - Plantis & ReceitaAgro

## Visão Geral dos Aplicativos

### 🌱 **App Plantis** 
**Aplicativo para plantas de apartamento**
- Registro de plantas domésticas
- Gerenciamento de cuidados (rega, poda, fertilização)
- Sistema de tarefas/lembretes automáticos
- Histórico de cuidados
- Público: Pessoas que têm plantas em casa

### 🚜 **App ReceitaAgro**
**Compêndio de pragas para agricultura brasileira**
- Catálogo de pragas agrícolas
- Informações sobre defensivos
- Diagnóstico de pragas
- Cálculo de dosagens
- Receitas agronômicas
- Público: Produtores rurais e técnicos agrícolas

### 🔧 **Services Compartilhados (Core)**
Ambos apps utilizam:
- **Firebase Analytics** - Tracking de eventos
- **Firebase Auth** - Autenticação de usuários
- **Firebase Crashlytics** - Monitoramento de crashes
- **Firebase Storage** - Armazenamento de imagens
- **RevenueCat** - Gerenciamento de assinaturas/IAP
- **Hive** - Banco de dados local

## Estrutura do Projeto Ajustada

```
plantis_receituagro_monorepo/
├── apps/
│   ├── app-plantis/
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── features/
│   │   │   │   ├── plant_management/
│   │   │   │   │   ├── add_plant_page.dart
│   │   │   │   │   ├── plant_detail_page.dart
│   │   │   │   │   └── plant_list_page.dart
│   │   │   │   ├── care_tracking/
│   │   │   │   │   ├── care_history_page.dart
│   │   │   │   │   └── add_care_page.dart
│   │   │   │   ├── task_management/
│   │   │   │   │   ├── task_list_page.dart
│   │   │   │   │   └── task_scheduler.dart
│   │   │   │   └── shared/
│   │   │   │       └── plantis_widgets/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── plant_entity.dart
│   │   │   │   │   ├── care_entity.dart
│   │   │   │   │   └── task_entity.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── i_plant_repository.dart
│   │   │   │       └── i_task_repository.dart
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       └── repositories/
│   │   ├── pubspec.yaml
│   │   └── assets/
│   │       ├── images/plants/
│   │       └── icons/plantis/
│   ├── app-receituagro/
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── features/
│   │   │   │   ├── pest_catalog/
│   │   │   │   │   ├── pest_list_page.dart
│   │   │   │   │   └── pest_detail_page.dart
│   │   │   │   ├── diagnosis/
│   │   │   │   │   ├── symptom_checker.dart
│   │   │   │   │   └── diagnosis_result.dart
│   │   │   │   ├── recipe_management/
│   │   │   │   │   ├── recipe_calculator.dart
│   │   │   │   │   └── dosage_calculator.dart
│   │   │   │   ├── defensive_catalog/
│   │   │   │   │   └── defensive_list.dart
│   │   │   │   └── shared/
│   │   │   │       └── receituagro_widgets/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── pest_entity.dart
│   │   │   │   │   ├── defensive_entity.dart
│   │   │   │   │   ├── recipe_entity.dart
│   │   │   │   │   └── dosage_entity.dart
│   │   │   │   └── repositories/
│   │   │   │       ├── i_pest_repository.dart
│   │   │   │       └── i_recipe_repository.dart
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       └── repositories/
│   │   ├── pubspec.yaml
│   │   └── assets/
│   │       ├── images/pests/
│   │       ├── images/defensives/
│   │       └── icons/receituagro/
├── packages/
│   └── core/
│       ├── lib/
│       │   ├── src/
│       │   │   ├── domain/
│       │   │   │   ├── entities/
│       │   │   │   │   ├── user_entity.dart           # ✅ Ambos têm usuários
│       │   │   │   │   ├── subscription_entity.dart   # ✅ Ambos têm assinaturas
│       │   │   │   │   └── base_entity.dart
│       │   │   │   ├── repositories/
│       │   │   │   │   ├── i_auth_repository.dart     # ✅ Firebase Auth
│       │   │   │   │   ├── i_analytics_repository.dart # ✅ Firebase Analytics
│       │   │   │   │   ├── i_subscription_repository.dart # ✅ RevenueCat
│       │   │   │   │   ├── i_storage_repository.dart   # ✅ Firebase Storage
│       │   │   │   │   ├── i_crashlytics_repository.dart # ✅ Crashlytics
│       │   │   │   │   └── i_local_storage_repository.dart # ✅ Hive
│       │   │   │   └── usecases/
│       │   │   │       ├── auth/
│       │   │   │       ├── subscription/
│       │   │   │       └── analytics/
│       │   │   ├── infrastructure/
│       │   │   │   └── services/
│       │   │   │       ├── firebase_auth_service.dart
│       │   │   │       ├── firebase_analytics_service.dart
│       │   │   │       ├── firebase_crashlytics_service.dart
│       │   │   │       ├── firebase_storage_service.dart
│       │   │   │       ├── revenue_cat_service.dart
│       │   │   │       └── hive_storage_service.dart
│       │   │   ├── presentation/
│       │   │   │   └── widgets/
│       │   │   │       ├── custom_app_bar.dart
│       │   │   │       ├── loading_widget.dart
│       │   │   │       ├── error_widget.dart
│       │   │   │       ├── subscription_paywall.dart  # ✅ Paywall comum
│       │   │   │       └── image_upload_widget.dart   # ✅ Upload para Firebase Storage
│       │   │   └── shared/
│       │   │       ├── constants/
│       │   │       ├── utils/
│       │   │       └── di/
│       │   └── core.dart
│       └── pubspec.yaml
├── tools/
├── docs/
├── pubspec.yaml (root)
├── melos.yaml
└── README.md
```

## Configuração do Workspace

### 1. Pubspec.yaml (Root)

```yaml
name: plantis_receituagro_monorepo
description: Monorepo contendo apps Plantis (plantas domésticas) e ReceitaAgro (pragas agrícolas)

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dev_dependencies:
  flutter_test:
    sdk: flutter
  melos: ^3.0.0

# Workspace configuration
workspace:
  name: plantis_receituagro_monorepo
  
dependency_overrides:
  # Força uso das versões locais dos packages
  core:
    path: packages/core
```

### 2. Melos.yaml (Gerenciamento do Monorepo)

```yaml
name: plantis_receituagro_monorepo
repository: https://github.com/seu-usuario/plantis-receituagro-monorepo

packages:
  - apps/*
  - packages/*

command:
  bootstrap:
    environment:
      sdk: ">=3.0.0 <4.0.0"
      flutter: ">=3.10.0"
    
  clean:
    hooks:
      pre: |
        echo "Limpando workspace Plantis & ReceitaAgro..."
    
scripts:
  # Comandos úteis para desenvolvimento
  analyze:
    run: flutter analyze
    description: Executa análise estática em todos os packages
    
  format:
    run: dart format --set-exit-if-changed .
    description: Formata código em todos os packages
    
  test:
    run: flutter test
    description: Executa testes em todos os packages
    
  # Builds para produção (individual por app)
  build:plantis:android:
    run: flutter build appbundle --release
    description: Build App Bundle para Play Store - Plantis (Plantas Domésticas)
    packageFilters:
      scope: "app-plantis"
      
  build:plantis:ios:
    run: flutter build ipa --release
    description: Build IPA para App Store - Plantis (Plantas Domésticas)
    packageFilters:
      scope: "app-plantis"
      
  build:receituagro:android:
    run: flutter build appbundle --release
    description: Build App Bundle para Play Store - ReceitaAgro (Pragas Agrícolas)
    packageFilters:
      scope: "app-receituagro"
      
  build:receituagro:ios:
    run: flutter build ipa --release
    description: Build IPA para App Store - ReceitaAgro (Pragas Agrícolas)
    packageFilters:
      scope: "app-receituagro"
      
  # Scripts específicos por app
  run:plantis:
    run: flutter run
    description: Executa app Plantis (Plantas de Apartamento)
    packageFilters:
      scope: "app-plantis"
      
  run:receituagro:
    run: flutter run
    description: Executa app ReceitaAgro (Compêndio de Pragas)
    packageFilters:
      scope: "app-receituagro"
      
  # Comandos específicos para desenvolvimento
  icons:plantis:
    run: flutter packages pub run flutter_launcher_icons:main -f flutter_launcher_icons-plantis.yaml
    description: Gera ícones para Plantis
    packageFilters:
      scope: "app-plantis"
      
  icons:receituagro:
    run: flutter packages pub run flutter_launcher_icons:main -f flutter_launcher_icons-receituagro.yaml
    description: Gera ícones para ReceitaAgro
    packageFilters:
      scope: "app-receituagro"
```
```

## Configuração dos Packages

### Vantagens dessa Abordagem Corrigida

#### ✅ **Core Enxuto e Focado**
- Apenas services de **infraestrutura compartilhada**
- Sem entities específicas de domínio
- Cada app define suas próprias regras de negócio

#### ✅ **Flexibilidade Total**
```dart
// Plantis precisa de dados diferentes do ReceitaAgro
// Plantis Weather: temperatura, humidade, UV para plantas
// ReceitaAgro Weather: vento, chuva, temperatura para aplicação

// Ambos usam o mesmo HttpService do core, mas implementam 
// suas próprias entities e repositories específicos
```

#### ✅ **Sem Acoplamento Desnecessário**
- Plantis não carrega código de receitas agronômicas
- ReceitaAgro não carrega código de plantas
- Core não força contratos que só um app usa

#### ✅ **Reutilização Inteligente**
```dart
// ✅ Reutilização inteligente no core
final location = await getIt<GetLocationUseCase>().call();  // GPS compartilhado
await getIt<LogEventUseCase>().call('weather_check');       // Analytics compartilhado

// ✅ Cada app implementa como precisa
final plantisWeather = await plantisWeatherService.getWeatherForPlantCare(location);
final receitaWeather = await receitaWeatherService.getWeatherForApplication(location);
```

### Exemplo Prático da Diferença

#### ❌ Como estava (Core "gordo"):
```dart
// Core tinha WeatherEntity que tentava servir ambos apps
class WeatherEntity {
  final double temperature;    // ✅ Plantis usa
  final double humidity;       // ✅ Plantis usa  
  final double windSpeed;      // ❌ Só ReceitaAgro usa
  final double uvIndex;        // ❌ Só Plantis usa
  final double precipitation;  // ❌ Só ReceitaAgro usa
}
```

#### ✅ Como fica agora (Core focado):
```dart
// Core só tem infraestrutura
class LocationEntity {  // ✅ Ambos apps precisam de localização
  final double latitude;
  final double longitude;
  final String address;
}

// Cada app define sua WeatherEntity específica
// Plantis: foca em temperatura, humidade, UV
// ReceitaAgro: foca em vento, chuva, temperatura
```

### Core Package Atualizado (Só o Essencial)

```yaml
# packages/core/pubspec.yaml
name: core
description: Services de infraestrutura compartilhados - Firebase, Auth, GPS, HTTP
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase (infraestrutura compartilhada)
  firebase_core: ^2.15.1
  firebase_analytics: ^10.4.5
  firebase_auth: ^4.7.3
  firebase_messaging: ^14.6.7
  
  # Geolocation (infraestrutura compartilhada)
  geolocator: ^9.0.2
  geocoding: ^2.1.0
  
  # Storage & HTTP (infraestrutura compartilhada)
  flutter_secure_storage: ^9.0.0
  dio: ^5.3.2
  
  # State Management & Utils
  flutter_bloc: ^8.1.3
  get_it: ^7.6.0
  injectable: ^2.1.2
  dartz: ^0.10.1
  equatable: ^2.0.5
```

### Checklist do Core Ideal

**✅ O que DEVE estar no Core:**
- [ ] Firebase Auth, Analytics, Push
- [ ] HTTP Service (Dio)
- [ ] Geolocation Service
- [ ] Secure Storage
- [ ] Widgets básicos (Loading, Error, AppBar)
- [ ] Utils comuns (Validators, Extensions)
- [ ] User Entity (ambos apps têm usuários)

**❌ O que NÃO deve estar no Core:**
- [ ] Plant/Recipe entities específicas
- [ ] Weather entities específicas  
- [ ] Farm entities (só Plantis usa)
- [ ] Services de domínio específico
- [ ] Widgets específicos de um app

### 3. App Plantis (apps/app-plantis/pubspec.yaml)

```yaml
name: app_plantis
description: Aplicativo para cuidado de plantas domésticas - registro, tarefas e lembretes
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Dependência do core local (Firebase, RevenueCat, etc.)
  core:
    path: ../../packages/core
    
  # Dependências específicas do Plantis
  cupertino_icons: ^1.0.2
  image_picker: ^1.0.1         # Para fotos das plantas
  flutter_local_notifications: ^15.1.0+1  # Para lembretes de cuidados
  timezone: ^0.9.2             # Para agendar tarefas
  camera: ^0.10.5+2            # Para câmera integrada
  permission_handler: ^11.0.1  # Para permissões
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.13.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/plants/
    - assets/icons/plantis/
    - assets/data/plant_species.json  # Database de espécies de plantas

# Configuração de ícones específica do Plantis (tema verde/natureza)
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/plantis/app_icon_plantis.png"
  min_sdk_android: 21
  adaptive_icon_background: "#4CAF50"  # Verde
  adaptive_icon_foreground: "assets/icons/plantis/foreground.png"
```

### 4. App ReceitaAgro (apps/app-receituagro/pubspec.yaml)

```yaml
name: app_receituagro
description: Compêndio de pragas agrícolas - diagnóstico, defensivos e receitas
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Dependência do core local (Firebase, RevenueCat, etc.)
  core:
    path: ../../packages/core
    
  # Dependências específicas do ReceitaAgro
  cupertino_icons: ^1.0.2
  pdf: ^3.10.4                 # Para geração de relatórios/receitas
  printing: ^5.11.0           # Para impressão de receitas
  qr_flutter: ^4.1.0          # Para QR codes de receitas
  image_picker: ^1.0.1        # Para fotos de pragas/sintomas
  flutter_html: ^3.0.0-beta.2 # Para exibir conteúdo rico sobre pragas
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.13.1

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/pests/        # Fotos de pragas
    - assets/images/defensives/   # Fotos de defensivos
    - assets/icons/receituagro/
    - assets/data/pests_database.json      # Database de pragas
    - assets/data/defensives_database.json # Database de defensivos

# Configuração de ícones específica do ReceitaAgro (tema técnico/profissional)
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/receituagro/app_icon_receituagro.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FF5722"  # Laranja técnico
  adaptive_icon_foreground: "assets/icons/receituagro/foreground.png"
```

## Core Focado - Apenas Services Compartilhados

### Core Library (packages/core/lib/core.dart)

```dart
library core;

// ========== DOMAIN LAYER ==========
// Entities realmente compartilhadas
export 'src/domain/entities/user_entity.dart';          # ✅ Ambos têm usuários
export 'src/domain/entities/subscription_entity.dart';  # ✅ Ambos têm assinaturas
export 'src/domain/entities/base_entity.dart';

// Repositories para infraestrutura compartilhada
export 'src/domain/repositories/i_auth_repository.dart';         # ✅ Firebase Auth
export 'src/domain/repositories/i_analytics_repository.dart';    # ✅ Firebase Analytics
export 'src/domain/repositories/i_subscription_repository.dart'; # ✅ RevenueCat
export 'src/domain/repositories/i_storage_repository.dart';      # ✅ Firebase Storage
export 'src/domain/repositories/i_crashlytics_repository.dart';  # ✅ Crashlytics
export 'src/domain/repositories/i_local_storage_repository.dart'; # ✅ Hive

// Use Cases básicos compartilhados
export 'src/domain/usecases/auth/login_usecase.dart';
export 'src/domain/usecases/auth/logout_usecase.dart';
export 'src/domain/usecases/auth/signup_usecase.dart';
export 'src/domain/usecases/subscription/get_subscription_status_usecase.dart';
export 'src/domain/usecases/subscription/purchase_subscription_usecase.dart';
export 'src/domain/usecases/analytics/log_event_usecase.dart';
export 'src/domain/usecases/storage/upload_image_usecase.dart';

// ========== INFRASTRUCTURE SERVICES ==========
// Implementações Firebase
export 'src/infrastructure/services/firebase_auth_service.dart';
export 'src/infrastructure/services/firebase_analytics_service.dart';
export 'src/infrastructure/services/firebase_crashlytics_service.dart';
export 'src/infrastructure/services/firebase_storage_service.dart';

// RevenueCat
export 'src/infrastructure/services/revenue_cat_service.dart';

// Hive (Local Storage)
export 'src/infrastructure/services/hive_storage_service.dart';

// HTTP Client
export 'src/infrastructure/services/http_service.dart';

// ========== SHARED WIDGETS ==========
// Widgets realmente reutilizáveis
export 'src/presentation/widgets/custom_app_bar.dart';
export 'src/presentation/widgets/loading_widget.dart';
export 'src/presentation/widgets/error_widget.dart';
export 'src/presentation/widgets/subscription_paywall.dart';    # ✅ Paywall comum
export 'src/presentation/widgets/image_upload_widget.dart';     # ✅ Upload Firebase Storage

// ========== SHARED UTILITIES ==========
export 'src/shared/constants/app_constants.dart';
export 'src/shared/utils/validators.dart';
export 'src/shared/utils/formatters.dart';
export 'src/shared/utils/extensions.dart';
export 'src/shared/di/injection_container.dart';
```

### Core Package (packages/core/pubspec.yaml)

```yaml
name: core
description: Services de infraestrutura compartilhados - Firebase, RevenueCat, Hive
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Stack
  firebase_core: ^2.15.1
  firebase_auth: ^4.7.3
  firebase_analytics: ^10.4.5
  firebase_crashlytics: ^3.3.5
  firebase_storage: ^11.2.6
  
  # RevenueCat para assinaturas
  purchases_flutter: ^6.8.0
  
  # Hive para storage local
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # HTTP Client
  dio: ^5.3.2
  
  # State Management & Utils
  flutter_bloc: ^8.1.3
  get_it: ^7.6.0
  injectable: ^2.1.2
  dartz: ^0.10.1
  equatable: ^2.0.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.6
  injectable_generator: ^2.1.6
  hive_generator: ^2.0.0
  
  # Testing
  mockito: ^5.4.2
  bloc_test: ^9.1.4
```

## Entities Específicas de Cada App

### 🌱 App Plantis - Entities Específicas

```dart
// apps/app-plantis/lib/domain/entities/plant_entity.dart
class PlantEntity extends BaseEntity {  // ✅ Herda do core
  final String name;                    // "Suculenta", "Samambaia"
  final String species;                 // "Echeveria elegans"
  final String location;                // "Sala de estar", "Varanda"
  final DateTime acquiredDate;
  final String? photoUrl;               // Foto da planta
  final List<String> careInstructions;  // ["Regar 2x semana", "Sol indireto"]

  const PlantEntity({
    required String id,
    required this.name,
    required this.species,
    required this.location,
    required this.acquiredDate,
    this.photoUrl,
    required this.careInstructions,
  }) : super(id: id);
}

// apps/app-plantis/lib/domain/entities/care_entity.dart
class CareEntity extends BaseEntity {
  final String plantId;
  final CareType type;                  // WATERING, PRUNING, FERTILIZING
  final DateTime performedAt;
  final String? notes;                  // "Folhas estavam murchas"
  final String? photoUrl;               // Foto do cuidado

  const CareEntity({
    required String id,
    required this.plantId,
    required this.type,
    required this.performedAt,
    this.notes,
    this.photoUrl,
  }) : super(id: id);
}

// apps/app-plantis/lib/domain/entities/task_entity.dart
class TaskEntity extends BaseEntity {
  final String plantId;
  final CareType careType;
  final DateTime scheduledDate;
  final bool isCompleted;
  final bool isRecurring;
  final Duration? recurringInterval;    // Duration(days: 7) para semanal

  const TaskEntity({
    required String id,
    required this.plantId,
    required this.careType,
    required this.scheduledDate,
    required this.isCompleted,
    required this.isRecurring,
    this.recurringInterval,
  }) : super(id: id);
}

enum CareType { watering, pruning, fertilizing, repotting, cleaning }
```

### 🚜 App ReceitaAgro - Entities Específicas

```dart
// apps/app-receituagro/lib/domain/entities/pest_entity.dart
class PestEntity extends BaseEntity {
  final String name;                    // "Lagarta-do-cartucho"
  final String scientificName;          // "Spodoptera frugiperda"
  final PestType type;                  // INSECT, FUNGUS, WEED, VIRUS
  final List<String> affectedCrops;     // ["Milho", "Sorgo", "Algodão"]
  final List<String> symptoms;          // ["Furos nas folhas", "Fezes escuras"]
  final List<String> imageUrls;         // Fotos da praga
  final String description;
  final DamageLevel damageLevel;        // LOW, MEDIUM, HIGH, CRITICAL

  const PestEntity({
    required String id,
    required this.name,
    required this.scientificName,
    required this.type,
    required this.affectedCrops,
    required this.symptoms,
    required this.imageUrls,
    required this.description,
    required this.damageLevel,
  }) : super(id: id);
}

// apps/app-receituagro/lib/domain/entities/defensive_entity.dart
class DefensiveEntity extends BaseEntity {
  final String name;                    // "Ampligo"
  final String activeIngredient;        // "Clorantraniliprole + Lambda-cialotrina"
  final DefensiveType type;             // INSECTICIDE, FUNGICIDE, HERBICIDE
  final String manufacturer;           // "Syngenta"
  final List<String> targetPests;      // Lista de pragas que controla
  final double concentrationPercentage; // 20.0 (%)
  final int gracePeriod;               // 7 (dias)
  final List<ApplicationMethod> applicationMethods; // SPRAYING, DUSTING
  final String? imageUrl;

  const DefensiveEntity({
    required String id,
    required this.name,
    required this.activeIngredient,
    required this.type,
    required this.manufacturer,
    required this.targetPests,
    required this.concentrationPercentage,
    required this.gracePeriod,
    required this.applicationMethods,
    this.imageUrl,
  }) : super(id: id);
}

// apps/app-receituagro/lib/domain/entities/recipe_entity.dart
class RecipeEntity extends BaseEntity {
  final String name;                    // "Controle de Lagarta-do-cartucho"
  final String targetPest;
  final String targetCrop;              // "Milho"
  final List<RecipeIngredient> ingredients;
  final double dosagePerHectare;        // 0.5 (L/ha)
  final double waterVolumePerHectare;   // 200.0 (L/ha)
  final ApplicationMethod applicationMethod;
  final List<String> instructions;     // ["Aplicar no início da manhã"]
  final int gracePeriod;
  final DateTime createdAt;
  final String? createdBy;              // User ID

  const RecipeEntity({
    required String id,
    required this.name,
    required this.targetPest,
    required this.targetCrop,
    required this.ingredients,
    required this.dosagePerHectare,
    required this.waterVolumePerHectare,
    required this.applicationMethod,
    required this.instructions,
    required this.gracePeriod,
    required this.createdAt,
    this.createdBy,
  }) : super(id: id);
}

// apps/app-receituagro/lib/domain/entities/recipe_ingredient.dart
class RecipeIngredient {
  final String defensiveId;
  final double dosage;                  // 0.25 (L/ha)
  final String unit;                    // "L/ha", "kg/ha", "mL/ha"

  const RecipeIngredient({
    required this.defensiveId,
    required this.dosage,
    required this.unit,
  });
}

enum PestType { insect, fungus, weed, virus, bacteria }
enum DefensiveType { insecticide, fungicide, herbicide, bactericide }
enum DamageLevel { low, medium, high, critical }
enum ApplicationMethod { spraying, dusting, injection, granular }
```

## Exemplos de Uso dos Services Compartilhados

### 🌱 Plantis - Usando Services do Core

```dart
// apps/app-plantis/lib/features/plant_management/plant_detail_bloc.dart
class PlantDetailBloc extends Bloc<PlantDetailEvent, PlantDetailState> {
  final IPlantRepository _plantRepository;        // ✅ Específico do Plantis
  final IAnalyticsRepository _analyticsRepo;      // ✅ Do Core
  final IStorageRepository _storageRepo;          // ✅ Do Core (Firebase Storage)
  final ISubscriptionRepository _subscriptionRepo; // ✅ Do Core (RevenueCat)

  PlantDetailBloc(
    this._plantRepository,
    this._analyticsRepo,
    this._storageRepo,
    this._subscriptionRepo,
  ) : super(PlantDetailInitial()) {
    on<UpdatePlantPhotoEvent>(_onUpdatePlantPhoto);
    on<LogPlantCareEvent>(_onLogPlantCare);
  }

  Future<void> _onUpdatePlantPhoto(
    UpdatePlantPhotoEvent event,
    Emitter<PlantDetailState> emit,
  ) async {
    try {
      emit(PlantDetailLoading());

      // ✅ Verificar se usuário tem assinatura (RevenueCat do Core)
      final hasSubscription = await _subscriptionRepo.hasActiveSubscription();
      if (!hasSubscription) {
        emit(PlantDetailSubscriptionRequired());
        return;
      }

      // ✅ Upload da foto (Firebase Storage do Core)
      final photoUrl = await _storageRepo.uploadImage(
        event.imageFile,
        'plants/${event.plantId}/photos',
      );

      // ✅ Salvar no repositório específico do Plantis
      final updatedPlant = await _plantRepository.updatePlantPhoto(
        event.plantId,
        photoUrl,
      );

      // ✅ Log analytics (Firebase Analytics do Core)
      await _analyticsRepo.logEvent('plant_photo_updated', parameters: {
        'plant_id': event.plantId,
        'app': 'plantis',
      });

      emit(PlantDetailSuccess(updatedPlant));
    } catch (e) {
      emit(PlantDetailError(e.toString()));
    }
  }

  Future<void> _onLogPlantCare(
    LogPlantCareEvent event,
    Emitter<PlantDetailState> emit,
  ) async {
    // ✅ Log específico do Plantis usando analytics do core
    await _analyticsRepo.logEvent('plant_care_logged', parameters: {
      'plant_id': event.plantId,
      'care_type': event.careType.name,
      'app': 'plantis',
      'recurring': event.isRecurring,
    });
  }
}
```

### 🚜 ReceitaAgro - Usando Services do Core

```dart
// apps/app-receituagro/lib/features/recipe_management/create_recipe_bloc.dart
class CreateRecipeBloc extends Bloc<CreateRecipeEvent, CreateRecipeState> {
  final IRecipeRepository _recipeRepository;      // ✅ Específico do ReceitaAgro
  final IAnalyticsRepository _analyticsRepo;      // ✅ Do Core
  final IAuthRepository _authRepo;                // ✅ Do Core (Firebase Auth)
  final ISubscriptionRepository _subscriptionRepo; // ✅ Do Core (RevenueCat)
  final ILocalStorageRepository _localStorage;     // ✅ Do Core (Hive)

  CreateRecipeBloc(
    this._recipeRepository,
    this._analyticsRepo,
    this._authRepo,
    this._subscriptionRepo,
    this._localStorage,
  ) : super(CreateRecipeInitial()) {
    on<CreateRecipeEvent>(_onCreateRecipe);
    on<SaveRecipeOfflineEvent>(_onSaveRecipeOffline);
  }

  Future<void> _onCreateRecipe(
    CreateRecipeEvent event,
    Emitter<CreateRecipeState> emit,
  ) async {
    try {
      emit(CreateRecipeLoading());

      // ✅ Verificar autenticação (Firebase Auth do Core)
      final currentUser = await _authRepo.getCurrentUser();
      if (currentUser == null) {
        emit(CreateRecipeAuthRequired());
        return;
      }

      // ✅ Verificar limite da assinatura (RevenueCat do Core)
      final subscriptionInfo = await _subscriptionRepo.getSubscriptionInfo();
      final canCreateRecipe = await _checkRecipeLimit(subscriptionInfo);
      
      if (!canCreateRecipe) {
        emit(CreateRecipeSubscriptionRequired());
        return;
      }

      // ✅ Criar receita (repositório específico do ReceitaAgro)
      final recipe = await _recipeRepository.createRecipe(
        event.recipeData.copyWith(createdBy: currentUser.id),
      );

      // ✅ Salvar localmente para acesso offline (Hive do Core)
      await _localStorage.saveData('recent_recipes', [recipe.toJson()]);

      // ✅ Log analytics específico do ReceitaAgro
      await _analyticsRepo.logEvent('recipe_created', parameters: {
        'recipe_id': recipe.id,
        'target_pest': recipe.targetPest,
        'target_crop': recipe.targetCrop,
        'ingredients_count': recipe.ingredients.length,
        'app': 'receituagro',
        'user_subscription': subscriptionInfo.tier,
      });

      emit(CreateRecipeSuccess(recipe));
    } catch (e) {
      emit(CreateRecipeError(e.toString()));
    }
  }

  Future<void> _onSaveRecipeOffline(
    SaveRecipeOfflineEvent event,
    Emitter<CreateRecipeState> emit,
  ) async {
    // ✅ Usar Hive do core para salvar receita offline
    await _localStorage.saveData(
      'offline_recipes',
      [event.recipe.toJson()],
    );

    // ✅ Log que receita foi salva offline
    await _analyticsRepo.logEvent('recipe_saved_offline', parameters: {
      'recipe_id': event.recipe.id,
      'app': 'receituagro',
    });
  }

  Future<bool> _checkRecipeLimit(SubscriptionInfo subscription) async {
    // Lógica específica do ReceitaAgro para verificar limites
    if (subscription.tier == SubscriptionTier.free) {
      final recipesCount = await _recipeRepository.getUserRecipesCount();
      return recipesCount < 5; // Limite de 5 receitas para usuários gratuitos
    }
    return true; // Sem limite para usuários premium
  }
}
```

### 🔗 Services do Core em Ação

```dart
// Ambos apps usam os mesmos services do core, mas para propósitos diferentes

// ✅ Firebase Analytics - Eventos específicos de cada app
// Plantis: 'plant_care_logged', 'plant_photo_updated', 'reminder_scheduled'
// ReceitaAgro: 'recipe_created', 'pest_diagnosed', 'dosage_calculated'

// ✅ Firebase Storage - Estruturas de pastas diferentes
// Plantis: 'plants/{plantId}/photos/', 'users/{userId}/plant_avatars/'
// ReceitaAgro: 'pests/{pestId}/images/', 'recipes/{recipeId}/attachments/'

// ✅ RevenueCat - Produtos diferentes
// Plantis: 'plantis_premium_monthly', 'plantis_premium_yearly'
// ReceitaAgro: 'receituagro_pro_monthly', 'receituagro_pro_yearly'

// ✅ Hive - Chaves de storage diferentes
// Plantis: 'user_plants', 'care_history', 'scheduled_tasks'
// ReceitaAgro: 'recent_recipes', 'favorite_pests', 'offline_recipes'
```

## Scripts de Desenvolvimento

## Comandos Práticos para Plantis e ReceitaAgro

```bash
# Configuração inicial
melos bootstrap

# Executar apps específicos
melos run run:plantis
melos run run:receituagro

# Build para produção
melos run build:plantis:android    # Plantis para Play Store
melos run build:plantis:ios        # Plantis para App Store
melos run build:receituagro:android # ReceitaAgro para Play Store
melos run build:receituagro:ios     # ReceitaAgro para App Store

# Análise e formatação
melos run analyze
melos run format

# Testes
melos run test

# Gerar ícones específicos
melos run icons:plantis
melos run icons:receituagro

# Limpar workspace
melos clean
```

### Scripts de Build Específicos

```bash
# Build Plantis para produção
cd apps/app-plantis
flutter build appbundle --release
# Arquivo: build/app/outputs/bundle/release/app-release.aab

# Build ReceitaAgro para produção  
cd apps/app-receituagro
flutter build ipa --release
# Arquivo: build/ios/ipa/app_receituagro.ipa

# Usando script automatizado
./tools/deploy_app.sh app-plantis android
./tools/deploy_app.sh app-receituagro ios
```

### 7. Script de Extração de App (tools/extract_app.sh)

```bash
#!/bin/bash

APP_NAME=$1
TARGET_DIR=$2

if [ -z "$APP_NAME" ] || [ -z "$TARGET_DIR" ]; then
    echo "Uso: ./extract_app.sh <nome_do_app> <diretório_destino>"
    exit 1
fi

echo "Extraindo $APP_NAME para $TARGET_DIR..."

# Criar estrutura do novo projeto
mkdir -p $TARGET_DIR
cp -r apps/$APP_NAME/* $TARGET_DIR/

# Copiar core como package local
mkdir -p $TARGET_DIR/packages
cp -r packages/core $TARGET_DIR/packages/

# Atualizar pubspec.yaml para usar core local
sed -i 's|path: ../../packages/core|path: packages/core|g' $TARGET_DIR/pubspec.yaml

echo "App $APP_NAME extraído com sucesso para $TARGET_DIR"
echo "Execute 'flutter pub get' no diretório de destino"
```

## Vantagens desta Arquitetura

### ✅ Desenvolvimento
- **Manutenção Centralizada**: Correções no core se propagam para todos os apps
- **Desenvolvimento Paralelo**: Múltiplos apps podem ser desenvolvidos simultaneamente
- **Reutilização de Código**: Widgets, services e modelos compartilhados
- **Testes Unificados**: Testes do core beneficiam todos os apps
- **SOLID Principles**: Código limpo, testável e de fácil manutenção
- **Clean Architecture**: Separação clara de responsabilidades por camadas
- **Dependency Injection**: Baixo acoplamento e alta testabilidade

### ✅ Deployment
- **Build Independente**: Cada app pode ser buildado separadamente
- **Versionamento Flexível**: Apps podem usar versões diferentes do core se necessário
- **Extração Simples**: Apps podem ser extraídos facilmente para repositórios separados

### ✅ Gestão
- **Dependências Unificadas**: Atualizações de dependências em um só lugar
- **Padrões Consistentes**: Arquitetura e padrões de código unificados
- **Documentação Central**: Documentação compartilhada para toda a equipe
- **Fácil Onboarding**: Novos desenvolvedores seguem padrões bem definidos

### ✅ Qualidade de Código
- **Single Responsibility**: Cada classe tem uma responsabilidade específica
- **Testabilidade**: Injeção de dependência facilita testes unitários
- **Flexibilidade**: Fácil para adicionar novas funcionalidades
- **Manutenibilidade**: Mudanças isoladas não afetam outras partes do sistema

### Vantagens desta Abordagem para Firebase Services

#### ✅ **Testabilidade**
```dart
// Fácil de testar com mocks
class MockAnalyticsRepository extends Mock implements IAnalyticsRepository {}

void main() {
  late LoginBloc loginBloc;
  late MockAnalyticsRepository mockAnalytics;

  setUp(() {
    mockAnalytics = MockAnalyticsRepository();
    loginBloc = LoginBloc(mockLoginUseCase, LogLoginEventUseCase(mockAnalytics));
  });

  test('should log analytics event on successful login', () async {
    // Arrange
    when(() => mockAnalytics.logEvent(any(), parameters: any()))
        .thenAnswer((_) async {});

    // Act
    loginBloc.add(LoginRequested('test@email.com', 'password'));

    // Assert
    verify(() => mockAnalytics.logEvent('login', parameters: any()));
  });
}
```

#### ✅ **Flexibilidade**
```dart
// Pode trocar Firebase por outro provider facilmente
class MixpanelAnalyticsService implements IAnalyticsRepository {
  // Implementação com Mixpanel ao invés de Firebase
}

// Ou usar múltiplos providers
class MultiAnalyticsService implements IAnalyticsRepository {
  final List<IAnalyticsRepository> _providers;

  MultiAnalyticsService(this._providers);

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    // Envia para todos os providers
    await Future.wait(
      _providers.map((provider) => provider.logEvent(eventName, parameters: parameters))
    );
  }
}
```

#### ✅ **Configuração por App**
```dart
// apps/app_modulo1/lib/main.dart - App com Firebase completo
void main() async {
  await Firebase.initializeApp();
  configureDependencies();
  runApp(MyApp());
}

// apps/app_modulo2/lib/main.dart - App sem analytics
@module
abstract class AppModule {
  @singleton
  IAnalyticsRepository get analyticsRepository => NoOpAnalyticsService(); // Implementação vazia
}
```

### Core Package Atualizado com Firebase

```yaml
# packages/core/pubspec.yaml
dependencies:
  # Firebase
  firebase_core: ^2.15.1
  firebase_analytics: ^10.4.5
  firebase_messaging: ^14.6.7
  firebase_crashlytics: ^3.3.5
  firebase_remote_config: ^4.2.5
  
  # Outros packages...
```

#### Configuração do App com SOLID

```dart
// apps/app_modulo1/lib/main.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar injeção de dependência
  configureDependencies();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Módulo 1',
      home: BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: LoginPage(),
      ),
    );
  }
}
```

## Builds para Produção e Deploy nas Lojas

#### Entity (Domain Layer)
```dart
// packages/core/lib/src/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, createdAt];
}
```

#### Repository Interface (Domain Layer)
```dart
// packages/core/lib/src/domain/repositories/i_user_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../shared/utils/failure.dart';

abstract class IUserRepository {
  Future<Either<Failure, UserEntity>> getUser(String id);
  Future<Either<Failure, List<UserEntity>>> getUsers();
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  Future<Either<Failure, void>> deleteUser(String id);
}
```

#### Use Case (Domain Layer)
```dart
// packages/core/lib/src/domain/usecases/auth/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../base_usecase.dart';
import '../repositories/i_user_repository.dart';
import '../entities/user_entity.dart';
import '../../shared/utils/failure.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final IUserRepository _userRepository;

  LoginUseCase(this._userRepository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // Validações de negócio aqui
    if (params.email.isEmpty || params.password.isEmpty) {
      return Left(ValidationFailure('Email e senha são obrigatórios'));
    }

    return await _userRepository.authenticate(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
```

#### Repository Implementation (Data Layer)
```dart
// packages/core/lib/src/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../shared/utils/failure.dart';
import '../datasources/i_remote_datasource.dart';
import '../datasources/i_local_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final IRemoteDataSource _remoteDataSource;
  final ILocalDataSource _localDataSource;

  UserRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, UserEntity>> getUser(String id) async {
    try {
      // Tentar buscar localmente primeiro
      final localUser = await _localDataSource.getUser(id);
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Se não encontrar localmente, buscar remotamente
      final remoteUser = await _remoteDataSource.getUser(id);
      await _localDataSource.saveUser(remoteUser);
      
      return Right(remoteUser.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Outros métodos...
}
```

#### Dependency Injection (Infrastructure)
```dart
// packages/core/lib/src/shared/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/i_user_repository.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/datasources/i_remote_datasource.dart';
import '../../data/datasources/remote_datasource_impl.dart';
import '../../domain/usecases/auth/login_usecase.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @singleton
  Dio get dio => Dio();

  @singleton
  IRemoteDataSource get remoteDataSource => RemoteDataSourceImpl(getIt());

  @singleton
  IUserRepository get userRepository => UserRepositoryImpl(getIt(), getIt());

  @factory
  LoginUseCase get loginUseCase => LoginUseCase(getIt());
}
```

### Configuração para Deploy

Cada app precisa ter suas configurações específicas para as lojas:

#### Android (Play Store)
Cada app em `apps/app_moduloX/android/app/build.gradle`:

```gradle
android {
    namespace "com.suaempresa.app_modulo1"  // Único para cada app
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.suaempresa.app_modulo1"  // Único para cada app
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### iOS (App Store)
Cada app em `apps/app_moduloX/ios/Runner/Info.plist`:

```xml
<key>CFBundleIdentifier</key>
<string>com.suaempresa.appModulo1</string>  <!-- Único para cada app -->
<key>CFBundleName</key>
<string>App Modulo 1</string>
<key>CFBundleDisplayName</key>
<string>Meu App 1</string>
```

### Scripts de Build para Produção

#### Build Individual por App

```bash
# App Modulo 1 - Android (Play Store)
cd apps/app_modulo1
flutter build appbundle --release
# Arquivo gerado: build/app/outputs/bundle/release/app-release.aab

# App Modulo 1 - iOS (App Store)
cd apps/app_modulo1
flutter build ipa --release
# Arquivo gerado: build/ios/ipa/app_modulo1.ipa

# App Modulo 2 - Android
cd apps/app_modulo2
flutter build appbundle --release

# App Modulo 2 - iOS
cd apps/app_modulo2
flutter build ipa --release
```

#### Usando Melos (Comandos Centralizados)

```bash
# Build específico por app usando melos
melos run build:app1:android  # App Bundle para Play Store
melos run build:app1:ios      # IPA para App Store
melos run build:app2:android
melos run build:app2:ios
```

### Script Automatizado de Deploy

Crie `tools/deploy_app.sh`:

```bash
#!/bin/bash

APP_NAME=$1
PLATFORM=$2
ENVIRONMENT=${3:-release}

if [ -z "$APP_NAME" ] || [ -z "$PLATFORM" ]; then
    echo "Uso: ./deploy_app.sh <app_name> <android|ios> [environment]"
    echo "Exemplo: ./deploy_app.sh app_modulo1 android release"
    exit 1
fi

echo "🚀 Iniciando build de $APP_NAME para $PLATFORM..."

cd apps/$APP_NAME

# Limpar builds anteriores
flutter clean
flutter pub get

if [ "$PLATFORM" = "android" ]; then
    echo "📱 Gerando App Bundle para Play Store..."
    flutter build appbundle --release
    
    echo "✅ Build Android concluído!"
    echo "📁 Arquivo: build/app/outputs/bundle/release/app-release.aab"
    
elif [ "$PLATFORM" = "ios" ]; then
    echo "🍎 Gerando IPA para App Store..."
    flutter build ipa --release
    
    echo "✅ Build iOS concluído!"
    echo "📁 Arquivo: build/ios/ipa/$APP_NAME.ipa"
    
else
    echo "❌ Plataforma inválida. Use 'android' ou 'ios'"
    exit 1
fi

echo "🎉 Deploy de $APP_NAME concluído com sucesso!"
```

### Configurações Específicas por App

#### Flavors (Opcional)
Se quiser diferentes versões (dev, staging, prod), configure flavors:

`apps/app_modulo1/android/app/build.gradle`:
```gradle
android {
    flavorDimensions "environment"
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        production {
            dimension "environment"
        }
    }
}
```

### Comandos Completos para Deploy

```bash
# 1. Build para Play Store
./tools/deploy_app.sh app_modulo1 android

# 2. Build para App Store  
./tools/deploy_app.sh app_modulo1 ios

# 3. Upload para Play Store (usando fastlane - opcional)
cd apps/app_modulo1/android
fastlane supply --aab build/app/outputs/bundle/release/app-release.aab

# 4. Upload para App Store (usando fastlane - opcional)
cd apps/app_modulo1/ios  
fastlane pilot upload --ipa build/ios/ipa/app_modulo1.ipa
```

## Comandos de Início Rápido

```bash
# 1. Clonar/criar o repositório
git clone <seu-repo> && cd meu_monorepo_flutter

# 2. Configurar workspace
dart pub global activate melos
melos bootstrap

# 3. Executar um app
melos run run:app1

# 4. Extrair um app (quando necessário)
./tools/extract_app.sh app_modulo1 ../app_modulo1_standalone
```

## Comandos de Início Rápido

```bash
# 1. Clonar/criar o repositório
git clone <seu-repo> && cd meu_monorepo_flutter

# 2. Configurar workspace
dart pub global activate melos
melos bootstrap

# 3. Executar um app específico
melos run run:app1

# 4. Build para produção
./tools/deploy_app.sh app_modulo1 android  # Play Store
./tools/deploy_app.sh app_modulo1 ios      # App Store

# 5. Extrair um app (quando necessário)
./tools/extract_app.sh app_modulo1 ../app_modulo1_standalone
```

---

## ✨ Resumo da Arquitetura Corrigida

**🎯 Core = Apenas Infraestrutura Compartilhada**

### 🔧 **O que FICA no Core (Essencial)**
- ✅ **Firebase Services** - Auth, Analytics, Push (infraestrutura)
- ✅ **HTTP Service** - Cliente Dio para APIs (infraestrutura)  
- ✅ **Geolocation Service** - GPS e endereços (ambos apps usam)
- ✅ **Secure Storage** - Armazenamento seguro (infraestrutura)
- ✅ **Base Widgets** - Loading, Error, AppBar (UI básica)
- ✅ **User Entity** - Dados do usuário (ambos apps têm usuários)
- ✅ **Utils Comuns** - Validators, Extensions, Formatters

### 🚫 **O que SAI do Core (Vai para cada app)**
- ❌ **Farm Entity** → apenas **Plantis** usa fazendas
- ❌ **Weather Entity** → cada app define diferente (plantas vs aplicação)
- ❌ **Plant/Recipe Entities** → específicos de cada domínio  
- ❌ **Weather API Service** → cada app implementa como precisa
- ❌ **Widgets Específicos** → cada app tem suas telas

### 🏗️ **Como Ficam os Apps**

#### 🌱 **Plantis (Independente)**
```dart
// Suas próprias entities
PlantEntity, FarmEntity, PlantisWeatherEntity

// Seus próprios services  
PlantisWeatherService, PlantDiseaseService

// Usa infraestrutura do core
getIt<HttpService>(), getIt<GeolocationService>()
```

#### 🧪 **ReceitaAgro (Independente)**  
```dart
// Suas próprias entities
RecipeEntity, IngredientEntity, ReceitaAgroWeatherEntity

// Seus próprios services
ReceitaAgroWeatherService, PDFGenerationService

// Usa infraestrutura do core  
getIt<HttpService>(), getIt<GeolocationService>()
```

**🚀 Comandos Práticos:**

```bash
# Core focado = build mais rápido
melos run run:plantis      # Só carrega o que Plantis precisa
melos run run:receituagro  # Só carrega o que ReceitaAgro precisa

# Deploy independente mantido
melos run build:plantis:android
melos run build:receituagro:ios
```

**✅ Principais Benefícios:**

- 🎯 **Core Enxuto** - Só o que é realmente compartilhado
- ⚡ **Performance** - Apps não carregam código desnecessário  
- 🔄 **Flexibilidade** - Cada app evolui suas entities independentemente
- 🛠️ **Manutenção** - Mudanças específicas não afetam o core
- 📦 **Reutilização Inteligente** - Infraestrutura compartilhada, lógica específica

**🎯 Resumo:** Core virou um "toolkit de infraestrutura" ao invés de um "framework que tenta adivinhar o que cada app precisa". Muito melhor! 👏