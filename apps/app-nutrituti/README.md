# 🥗 Nutrituti - Nutrition & Health Management

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?style=for-the-badge&logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet?style=for-the-badge)

**Aplicativo completo de nutrição com calculadoras, rastreamento de refeições e dicas personalizadas**

[Características](#-características) •
[Funcionalidades](#-funcionalidades) •
[Arquitetura](#-arquitetura) •
[Como Usar](#-como-usar)

</div>

---

## 🌟 Visão Geral

**Nutrituti** é uma plataforma completa de saúde e nutrição que ajuda usuários a monitorar sua alimentação, calcular necessidades nutricionais e alcançar objetivos de saúde com base em ciência e dados.

### 🎯 Objetivos

- **Educação Nutricional**: Informações baseadas em evidências
- **Rastreamento Inteligente**: Diário alimentar simplificado
- **Metas Personalizadas**: Calorias e macros individualizados
- **Saúde Sustentável**: Foco em hábitos, não dietas restritivas

---

## ✨ Características

### 🧮 **Calculadoras Nutricionais**

1. **IMC (Índice de Massa Corporal)**
   - Cálculo de IMC padrão
   - Classificação OMS
   - Peso ideal estimado

2. **TMB (Taxa Metabólica Basal)**
   - Fórmulas: Harris-Benedict, Mifflin-St Jeor
   - Cálculo de calorias diárias
   - Ajuste por nível de atividade

3. **Macronutrientes**
   - Distribuição de proteínas, carboidratos, gorduras
   - Cálculo por objetivo (perda, manutenção, ganho)
   - Recomendações personalizadas

4. **Hidratação**
   - Necessidade diária de água
   - Ajuste por clima e atividade
   - Lembretes de hidratação

5. **Calorias de Atividades**
   - Gasto calórico por exercício
   - Base de 100+ atividades
   - Integração com diário

6. **Percentual de Gordura**
   - Método de dobras cutâneas
   - Bioimpedância estimada
   - Evolução temporal

### 📊 **Rastreamento e Diário**

- **Diário Alimentar**
  - Registro de refeições (café, almoço, jantar, lanches)
  - Base de alimentos TACO
  - Scanner de código de barras
  - Favoritos e refeições recorrentes

- **Calendário de Refeições** (table_calendar)
  - Visualização mensal
  - Marcação de dias com registro completo
  - Histórico de consumo

- **Dashboard Nutricional**
  - Calorias consumidas vs. meta
  - Gráficos de macros (fl_chart)
  - Progresso semanal/mensal
  - Insights automáticos

### 🎯 **Metas e Objetivos**

- Perda de peso saudável
- Ganho de massa muscular
- Manutenção de peso
- Melhoria de performance atlética
- Controle de condições (diabetes, hipertensão)

### 💡 **Dicas e Conteúdo**

- Artigos de nutrição
- Receitas saudáveis
- Dicas de substituição
- Mitos e verdades
- Conteúdo científico

### 🔔 **Notificações e Lembretes**

- Lembretes de refeições
- Hidratação
- Pesagem semanal
- Atualizações de metas

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod (Migração em Andamento)

```
lib/
├── core/
│   ├── di/                   # Dependency Injection (GetIt + Injectable)
│   ├── router/               # GoRouter + navigation
│   ├── theme/                # Material Design theming
│   ├── database/             # Hive + Supabase setup
│   └── utils/                # Helpers e utilities
│
├── features/
│   ├── calculators/          # Calculadoras nutricionais
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── food_diary/           # Diário alimentar
│   ├── meal_tracker/         # Rastreamento de refeições
│   ├── goals/                # Metas e objetivos
│   ├── dashboard/            # Dashboard principal
│   ├── nutrition_tips/       # Dicas e artigos
│   ├── auth/                 # Autenticação
│   ├── premium/              # Recursos Premium
│   └── settings/             # Configurações
│
└── shared/
    ├── widgets/              # Componentes reutilizáveis
    └── models/               # Modelos compartilhados
```

### 🎯 Stack Tecnológica

```yaml
# State Management
flutter_riverpod: ^2.6.1      # State management (migração GetX → Riverpod)
riverpod_annotation: ^2.6.1   # Code generation

# Backend & Database
supabase_flutter: ^2.9.1      # Backend as a Service
hive: any                     # Cache local
cloud_firestore: any          # Firebase Firestore

# UI Components
table_calendar: ^3.1.2        # Calendário
fl_chart: any                 # Gráficos
skeletonizer: ^2.1.0          # Loading skeletons
flutter_staggered_grid_view: ^0.7.0  # Grid layouts

# Navigation
go_router: ^16.2.4            # Roteamento declarativo

# Monetization
google_mobile_ads: any        # AdMob
purchases_flutter: any        # RevenueCat

# Utilities
mask_text_input_formatter: any  # Input masks
timezone: any                 # Timezone handling
flutter_local_notifications: any  # Notificações
```

---

## 🚀 Como Usar

### Pré-requisitos

```bash
Flutter SDK: >=3.24.0
Dart SDK: >=3.5.0
```

### Instalação

```bash
# 1. Navegar até o diretório
cd apps/app-nutrituti

# 2. Instalar dependências
flutter pub get

# 3. Gerar código
dart run build_runner build --delete-conflicting-outputs

# 4. Configurar Supabase
# - Criar projeto em supabase.com
# - Adicionar credenciais em .env

# 5. Executar
flutter run
```

### Configuração

#### Supabase Setup
```dart
// lib/core/config/supabase_config.dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

#### Firebase (opcional para Analytics)
- Adicionar `google-services.json` (Android)
- Adicionar `GoogleService-Info.plist` (iOS)

---

## 📊 Funcionalidades Premium

### 🌟 **Plano Free**
- 5 calculadoras básicas
- Diário alimentar (7 dias de histórico)
- 100 alimentos favoritos
- Anúncios

### 💎 **Plano Premium**
- Todas as calculadoras
- Diário alimentar ilimitado
- Alimentos favoritos ilimitados
- Receitas exclusivas
- Análises avançadas
- Sem anúncios
- Suporte prioritário

---

## 🧪 Testes

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📈 Performance

### Otimizações

- **Lazy Loading**: Conteúdo carregado sob demanda
- **Image Caching**: Cache de imagens de alimentos
- **Database Indexing**: Queries otimizadas
- **Code Splitting**: Redução de bundle

### Métricas

| Métrica | Valor | Status |
|---------|-------|--------|
| App Size | ~18MB | ✅ |
| Memory Usage | <90MB | ✅ |
| Startup Time | <2.5s | ✅ |
| Database Queries | <100ms | ✅ |

---

## 🔐 Privacidade e Segurança

- **LGPD Compliant**: Dados protegidos conforme legislação
- **Criptografia**: Dados sensíveis criptografados
- **Anonimização**: Analytics anonimizados
- **Controle de Dados**: Usuário controla seus dados
- **Backup**: Sincronização segura em nuvem

---

## 📱 Plataformas Suportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- 🔲 **Web** (Planejado)

---

## 🤝 Contribuição

Este é um projeto do monorepo. Para contribuir:

1. Seguir padrões do CLAUDE.md
2. Migração para Riverpod em andamento
3. Clean Architecture obrigatória
4. Testes para novas features

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções**.

---

## 📞 Suporte

- **Email**: suporte@nutrituti.com
- **Documentação**: Monorepo `/CLAUDE.md`

---

<div align="center">

**🥗 Nutrituti - Sua saúde começa com nutrição inteligente 🥗**

![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)
![Migration](https://img.shields.io/badge/Migration-GetX%20→%20Riverpod-orange?style=flat-square)

</div>
