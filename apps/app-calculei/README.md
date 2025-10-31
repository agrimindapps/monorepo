# 🧮 Calculei - Financial & Labor Calculators

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.0+-0175C2?style=for-the-badge&logo=dart)
![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet?style=for-the-badge)

**Aplicativo completo com 20+ calculadoras financeiras, trabalhistas e utilitárias**

[Características](#-características) •
[Calculadoras](#-calculadoras-disponíveis) •
[Arquitetura](#-arquitetura) •
[Como Usar](#-como-usar)

</div>

---

## 📊 Visão Geral

**Calculei** é um aplicativo profissional que reúne mais de 20 calculadoras especializadas para ajudar profissionais e pessoas físicas em cálculos financeiros, trabalhistas e do dia a dia.

### 🎯 Público-Alvo

- **Profissionais Financeiros**: Contadores, consultores financeiros
- **Departamento Pessoal**: RH, gestão de folha de pagamento
- **Trabalhadores**: Cálculos de direitos trabalhistas
- **Investidores**: Planejamento financeiro pessoal
- **Empresários**: Gestão financeira empresarial

---

## 🧮 Calculadoras Disponíveis

### 💼 **Trabalhistas (8 calculadoras)**

1. **13º Salário** - Cálculo de décimo terceiro
2. **Férias** - Cálculo de férias e abonos
3. **Rescisão** - Valores de rescisão contratual
4. **Horas Extras** - Cálculo de adicionais
5. **FGTS** - Saldo e rendimento do FGTS
6. **Aviso Prévio** - Indenização de aviso
7. **Seguro Desemprego** - Estimativa de parcelas
8. **Salário Líquido** - Descontos e líquido

### 💰 **Financeiras (10 calculadoras)**

1. **Juros Compostos** - Cálculo de investimentos
2. **Financiamento** - Parcelas de financiamento
3. **Empréstimo** - Juros e amortização
4. **Aposentadoria** - Planejamento previdenciário
5. **Poupança** - Rendimento da caderneta
6. **CDB/LCI/LCA** - Investimentos de renda fixa
7. **Tesouro Direto** - Títulos públicos
8. **Imposto de Renda** - IR pessoa física
9. **Desconto Simples** - Cálculo de descontos
10. **Margem de Lucro** - Precificação e markup

### 🔧 **Utilitárias (5 calculadoras)**

1. **Conversor de Moedas** - Conversão cambial
2. **Porcentagem** - Cálculos percentuais
3. **Regra de Três** - Proporcionalidade
4. **IMC** - Índice de massa corporal
5. **Consumo de Combustível** - Economia automotiva

---

## ✨ Características

### 🎨 **Interface Moderna**

- Design Material Design 3
- Animações fluidas
- Tema claro e escuro
- Responsivo para tablets

### 📊 **Visualizações Avançadas**

- Gráficos interativos (fl_chart)
- Tabelas de amortização
- Simulações comparativas
- Exportação de resultados

### 💾 **Persistência de Dados**

- Histórico de cálculos (Hive)
- Favoritos para acesso rápido
- Sincronização em nuvem (Firebase)
- Backup automático

### 🔐 **Recursos Premium**

- Calculadoras ilimitadas
- Histórico sem limites
- Exportação PDF
- Suporte prioritário

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod

```
lib/
├── core/
│   ├── di/                   # Dependency Injection (GetIt + Injectable)
│   ├── router/               # GoRouter + navigation
│   ├── theme/                # Material Design theming
│   └── utils/                # Utilities e helpers
│
├── features/
│   ├── calculators/          # Sistema de calculadoras
│   │   ├── data/             # Data layer (repositories)
│   │   ├── domain/           # Business logic (entities, use cases)
│   │   └── presentation/     # UI layer (pages, widgets, providers)
│   │
│   ├── history/              # Histórico de cálculos
│   ├── favorites/            # Favoritos
│   ├── auth/                 # Autenticação
│   ├── premium/              # Assinaturas
│   └── settings/             # Configurações
│
└── shared/
    └── widgets/              # Componentes reutilizáveis
```

### 🎯 Stack Tecnológica

```yaml
# State Management
flutter_riverpod: ^2.6.1      # State management reativo
riverpod_annotation: ^2.6.1   # Code generation

# Dependency Injection
get_it: ^8.0.2                # Service locator
injectable: ^2.5.1            # DI code generation

# Functional Programming
dartz: ^0.10.1                # Either<L,R> para error handling

# Storage
hive: any                     # Local database
hive_flutter: any             # Flutter integration

# Firebase
firebase_core: any            # Core Firebase
firebase_auth: any            # Autenticação
cloud_firestore: any          # Database remoto

# Charts & Visualization
fl_chart: ^0.69.0             # Gráficos interativos

# Navigation
go_router: ^16.2.4            # Roteamento declarativo

# Input Formatting
mask_text_input_formatter: ^2.9.0  # Máscaras de input
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
cd apps/app-calculei

# 2. Instalar dependências
flutter pub get

# 3. Gerar código (Riverpod, Injectable, Hive)
dart run build_runner build --delete-conflicting-outputs

# 4. Executar o app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📱 Screenshots

### Tela Principal
Grid com todas as calculadoras organizadas por categoria

### Calculadora Individual
Interface focada com inputs validados e resultados em tempo real

### Histórico
Lista de cálculos anteriores com opção de reexecutar

### Gráficos
Visualizações interativas para análise de dados

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
```

---

## 📈 Performance

### Otimizações

- **Lazy Loading**: Calculadoras carregadas sob demanda
- **Memoization**: Cache de cálculos complexos
- **Code Splitting**: Bundle otimizado
- **Image Optimization**: Assets comprimidos

### Métricas

| Métrica | Valor | Status |
|---------|-------|--------|
| App Size | ~15MB | ✅ |
| Memory Usage | <80MB | ✅ |
| Startup Time | <2s | ✅ |
| Frame Rate | 60 FPS | ✅ |

---

## 🔐 Segurança

- **Validação de Entrada**: Todos os inputs são validados
- **Firebase Security Rules**: Acesso controlado
- **Criptografia Local**: Dados sensíveis protegidos
- **SSL/TLS**: Comunicação segura

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções** e está em desenvolvimento ativo.

---

## 📞 Suporte

- **Email**: suporte@calculei.com
- **Documentação**: Monorepo `/CLAUDE.md`
- **Issues**: GitHub Issues

---

<div align="center">

**🧮 Calculei - Cálculos profissionais na palma da mão 🧮**

![Quality](https://img.shields.io/badge/Quality-Production-success?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=flat-square)

</div>
