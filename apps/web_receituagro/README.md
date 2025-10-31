# 🌐 ReceitaAgro Web - Agricultural Diagnosis Platform

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4.0+-0175C2?style=for-the-badge&logo=dart)
![Status](https://img.shields.io/badge/Status-Production-success?style=for-the-badge)

**Plataforma web profissional para diagnóstico agrícola e recomendações de defensivos**

[Características](#-características) •
[Arquitetura](#-arquitetura) •
[Tecnologias](#-tecnologias) •
[Como Usar](#-como-usar)

</div>

---

## 📱 Visão Geral

**ReceitaAgro Web** é a versão web do aplicativo ReceitaAgro, oferecendo acesso completo ao compêndio de pragas agrícolas, diagnósticos e recomendações de defensivos através do navegador.

### 🎯 Funcionalidades Principais

- **🔍 Diagnóstico de Pragas**: Sistema completo de identificação de pragas por cultura
- **🌾 Base de Culturas**: Mais de 210 culturas catalogadas
- **🛡️ Defensivos**: Base com +3.000 produtos fitossanitários
- **📊 Dashboard**: Estatísticas e análises de uso
- **💬 Sistema de Comentários**: Compartilhamento de experiências
- **🔐 Autenticação**: Firebase Auth com múltiplos provedores
- **💳 Assinaturas**: Integração com sistema de pagamentos
- **🌓 Temas**: Suporte a tema claro e escuro

---

## 🏗️ Arquitetura

### Clean Architecture + Riverpod

```
lib/
├── core/
│   ├── config/           # Configurações da aplicação
│   ├── di/               # Dependency Injection (GetIt + Injectable)
│   ├── error/            # Error handling centralizado
│   ├── router/           # GoRouter + navigation
│   └── theme/            # Material Design theming
│
├── features/             # Features organizadas por domínio
│   ├── diagnostico/      # Sistema de diagnóstico
│   ├── culturas/         # Gestão de culturas
│   ├── defensivos/       # Produtos fitossanitários
│   ├── auth/             # Autenticação
│   ├── subscription/     # Assinaturas Premium
│   └── settings/         # Configurações
│
└── shared/               # Componentes compartilhados
    └── widgets/          # UI components reutilizáveis
```

### 🎯 Princípios SOLID

- ✅ **Clean Architecture** rigorosamente implementada
- ✅ **Repository Pattern** (Local + Remote)
- ✅ **Dependency Injection** (Injectable + GetIt)
- ✅ **State Management** (Riverpod)
- ✅ **Error Handling** (Either<Failure, T>)
- ✅ **Responsive Design** (Mobile, Tablet, Desktop)

---

## 🔧 Tecnologias

### Core Stack

```yaml
# State Management
flutter_riverpod: ^2.5.1        # State management reativo
riverpod_annotation: ^2.3.5     # Code generation

# Dependency Injection
get_it: ^8.2.0                  # Service locator
injectable: ^2.4.4              # DI code generation

# Functional Programming
dartz: ^0.10.1                  # Either<L,R> para error handling

# Firebase Suite
firebase_core: ^4.1.1           # Core Firebase
firebase_analytics: ^12.0.2     # Analytics
cloud_firestore: ^6.0.2         # Database remoto

# Database
supabase_flutter: ^2.9.1        # Alternative backend

# Navigation
go_router: ^14.0.0              # Roteamento declarativo

# UI Components
google_fonts: ^6.2.1            # Fontes personalizadas
carousel_slider: ^5.1.1         # Carrosséis de imagens
skeletonizer: ^2.1.0            # Loading skeletons
```

---

## 🚀 Como Usar

### Pré-requisitos

```bash
Flutter SDK: >=3.24.0
Dart SDK: >=3.4.0
```

### Instalação

```bash
# 1. Navegar até o diretório
cd apps/web_receituagro

# 2. Instalar dependências
flutter pub get

# 3. Gerar código (DI, Riverpod, Freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Rodar no navegador
flutter run -d chrome

# Ou para web server
flutter run -d web-server --web-port=8080
```

### Build para Produção

```bash
# Web build otimizado
flutter build web --release

# Build com source maps (debug)
flutter build web --profile --source-maps
```

### Configuração Firebase

1. Criar projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicionar app Web
3. Copiar configuração para `web/index.html`
4. Habilitar Authentication, Firestore e Analytics

---

## 📊 Funcionalidades Detalhadas

### 🔍 Sistema de Diagnóstico

- Busca por cultura, praga ou sintoma
- Filtros avançados (tipo de praga, região, época)
- Identificação visual com galeria de imagens
- Recomendações de tratamento

### 🌾 Gestão de Culturas

- Catálogo com 210+ culturas
- Informações técnicas detalhadas
- Pragas específicas por cultura
- Calendário agrícola

### 🛡️ Base de Defensivos

- 3.000+ produtos fitossanitários
- Dosagens e aplicações
- Classificações toxicológicas
- Comparador de produtos

### 💳 Sistema Premium

- Planos de assinatura
- Diagnósticos ilimitados
- Exportação de relatórios
- Suporte prioritário

---

## 🎨 Design System

### Paleta de Cores

- **Primary:** Green (#4CAF50) - Agricultura
- **Secondary:** Brown (#795548) - Terra
- **Accent:** Amber (#FFC107) - Colheita
- **Surface:** White/Dark - Backgrounds

### Responsive Breakpoints

```dart
// Mobile
<600px: Single column, mobile menu

// Tablet  
600-900px: 2 columns, drawer menu

// Desktop
>900px: 3 columns, sidebar navigation
```

---

## 📈 Performance

### Otimizações Implementadas

- **Code Splitting**: Lazy loading de features
- **Image Optimization**: WebP format + lazy loading
- **Caching**: Service worker para offline
- **Bundle Size**: <2MB gzipped
- **First Paint**: <2s em conexão 3G

### Métricas

| Métrica | Valor | Status |
|---------|-------|--------|
| First Contentful Paint | <2s | ✅ |
| Time to Interactive | <3s | ✅ |
| Bundle Size | 1.8MB | ✅ |
| Lighthouse Score | 90+ | ✅ |

---

## 🧪 Testes

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# E2E tests
flutter drive --target=test_driver/app.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📱 Plataformas Suportadas

- ✅ **Web** (Chrome, Safari, Firefox, Edge)
- ✅ **PWA** (Progressive Web App installable)
- ✅ **Responsive** (Mobile, Tablet, Desktop)

---

## 🔐 Segurança

- **HTTPS Only**: Enforced em produção
- **CSP Headers**: Content Security Policy configurado
- **Firebase Rules**: Validação server-side
- **Input Sanitization**: XSS protection
- **CORS**: Configurado para domínios permitidos

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções** e está sob desenvolvimento ativo.

---

## 📞 Suporte

- **Email**: suporte@receituagro.com
- **Site**: [receituagro.com](https://receituagro.com)
- **Documentação**: [docs.receituagro.com](https://docs.receituagro.com)

---

<div align="center">

**🌾 ReceitaAgro Web - Tecnologia para o Agronegócio 🌾**

![Quality](https://img.shields.io/badge/Quality-Production-success?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Clean-blue?style=flat-square)

</div>
