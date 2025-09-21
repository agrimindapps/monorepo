# ReceitaAgro - Compêndio de Pragas Agrícolas

[![Flutter](https://img.shields.io/badge/Flutter-3.10.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)

**ReceitaAgro** é um aplicativo mobile abrangente para diagnóstico de pragas agrícolas, recomendação de defensivos e gestão de receitas agronômicas. Desenvolvido em Flutter com arquitetura Clean Architecture e integração com Firebase.

## 📱 Funcionalidades Principais

### 🔍 **Diagnóstico de Pragas**
- Banco de dados extenso com mais de 117.000 diagnósticos
- Identificação visual de pragas através de imagens
- Diagnósticos específicos por cultura agrícola
- Sistema de busca avançada com filtros

### 🌾 **Gestão de Culturas**
- Mais de 210 culturas catalogadas
- Informações detalhadas por cultura
- Pragas específicas por tipo de cultura
- Histórico de cultivos

### 🛡️ **Defensivos e Fitossanitários**
- Base de dados com +3.000 produtos fitossanitários
- Recomendações baseadas no diagnóstico
- Detalhes técnicos dos produtos
- Dosagens e aplicações recomendadas

### 📊 **Recursos Premium**
- Diagnósticos ilimitados
- Funcionalidades offline
- Exportação de relatórios
- Sincronização multi-dispositivo
- Suporte prioritário

### 💬 **Sistema de Comentários**
- Comentários por praga/cultura
- Sincronização em tempo real
- Histórico de anotações
- Compartilhamento de experiências

## 🏗️ Arquitetura Técnica

### **Clean Architecture + Provider Pattern**
```
lib/
├── core/                    # Infraestrutura e serviços compartilhados
│   ├── di/                 # Dependency Injection (GetIt)
│   ├── providers/          # State Management (Provider)
│   ├── services/           # Serviços de negócio
│   ├── repositories/       # Data Layer (Hive + Firebase)
│   └── sync/              # Sistema de sincronização
├── features/               # Funcionalidades por domínio
│   ├── diagnosticos/      # Diagnóstico de pragas
│   ├── culturas/          # Gestão de culturas
│   ├── defensivos/        # Produtos fitossanitários
│   ├── favoritos/         # Sistema de favoritos
│   ├── comentarios/       # Sistema de comentários
│   ├── auth/              # Autenticação
│   ├── subscription/      # Assinaturas Premium
│   └── settings/          # Configurações
└── assets/                # Recursos estáticos
    ├── database/json/     # Base de dados local
    └── imagens/           # Imagens de pragas/culturas
```

### **Stack Tecnológica**

#### **Frontend**
- **Flutter 3.10.0+** - Framework UI multiplataforma
- **Dart 3.7.2+** - Linguagem de programação
- **Provider 6.1.2** - Gerenciamento de estado
- **Riverpod 2.6.1** - State management alternativo
- **Material Design** - Design system

#### **Backend & Dados**
- **Firebase Suite**:
  - 🔐 **Authentication** - Autenticação de usuários
  - 📱 **Firestore** - Banco de dados NoSQL
  - 📊 **Analytics** - Métricas de uso
  - 💥 **Crashlytics** - Monitoramento de erros
  - 🔧 **Remote Config** - Configuração remota
  - 📬 **Messaging** - Push notifications

#### **Armazenamento Local**
- **Hive 2.2.3** - Banco de dados local NoSQL
- **Shared Preferences** - Configurações simples
- **Flutter Secure Storage** - Dados sensíveis

#### **Funcionalidades Específicas**
- **RevenueCat** - Gestão de assinaturas
- **Dartz** - Programação funcional
- **GetIt** - Dependency Injection
- **Equatable** - Comparação de objetos

## 🚀 Configuração do Ambiente

### **Pré-requisitos**
```bash
# Flutter SDK
flutter --version  # >=3.10.0

# Dart SDK  
dart --version     # >=3.7.2

# Android Studio / Xcode (para desenvolvimento mobile)
```

### **Instalação**
```bash
# 1. Clone o monorepo
git clone <repository-url>
cd monorepo/apps/app-receituagro

# 2. Instale as dependências
flutter pub get

# 3. Configure Firebase
# - Coloque google-services.json (Android) em android/app/
# - Coloque GoogleService-Info.plist (iOS) em ios/Runner/

# 4. Gere código necessário
flutter packages pub run build_runner build

# 5. Execute o app
flutter run
```

### **Configuração Firebase**
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. Configure Authentication, Firestore, Analytics e Crashlytics
3. Baixe os arquivos de configuração para iOS/Android
4. Configure Remote Config com as chaves necessárias

## 📊 Base de Dados

### **Dados Locais (JSON)**
```
assets/database/json/
├── tbculturas/           # 210+ culturas
├── tbdiagnostico/        # 117.000+ diagnósticos  
├── tbfitossanitarios/    # 3.000+ produtos
├── tbpragas/             # 1.000+ pragas
├── tbplantasinf/         # Informações de plantas
└── tbpragasinf/          # Informações de pragas
```

### **Sincronização**
- **Modo Offline**: Todos os dados essenciais disponíveis localmente
- **Sync Bidirecional**: Favoritos, comentários e configurações
- **Conflict Resolution**: Estratégia timestamp-based
- **Background Sync**: Sincronização automática quando conectado

## 🔧 Comandos Úteis

```bash
# Desenvolvimento
flutter run -d chrome          # Executar na web
flutter run --release         # Build de produção
flutter analyze              # Análise estática
flutter test                 # Executar testes

# Build & Deploy
flutter build apk            # Android APK
flutter build ios            # iOS build
flutter build web            # Web build

# Manutenção
flutter clean                # Limpar cache
flutter pub upgrade          # Atualizar dependências
dart run build_runner build  # Gerar código
```

## 🧪 Testes

```bash
# Unit Tests
flutter test

# Integration Tests  
flutter test integration_test/

# Widget Tests
flutter test test/widget_test.dart

# Análise de código
flutter analyze --no-fatal-infos
```

## 📱 Plataformas Suportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+) 
- ✅ **Web** (Chrome, Safari, Firefox)
- 🔲 **Desktop** (Futuro)

## 🔐 Recursos de Segurança

- **Autenticação Firebase** com múltiplos provedores
- **Armazenamento seguro** para dados sensíveis
- **Criptografia local** via Flutter Secure Storage
- **Validação de entrada** em todos os formulários
- **Rate limiting** para APIs
- **Logs de auditoria** para ações críticas

## 📈 Performance

### **Otimizações Implementadas**
- **Lazy Loading** de imagens e dados
- **Virtualização** de listas longas
- **Cache inteligente** com TTL
- **Compressão de imagens**
- **Bundle splitting** para web
- **Background sync** otimizado

### **Métricas de Performance**
- **Tempo de inicialização**: <3s
- **Uso de memória**: <150MB
- **Tamanho do APK**: ~50MB
- **Cache local**: ~100MB (dados essenciais)

## 🤝 Contribuição

### **Estrutura de Desenvolvimento**
```bash
# 1. Feature Branch
git checkout -b feature/nova-funcionalidade

# 2. Implementação
# Siga os padrões de Clean Architecture
# Mantenha cobertura de testes >80%

# 3. Code Review
# Análise de código obrigatória
# Testes automatizados devem passar

# 4. Deploy
# CI/CD automatizado via GitHub Actions
```

### **Padrões de Código**
- **Clean Architecture** com separação clara de responsabilidades
- **SOLID Principles** aplicados consistentemente
- **Provider Pattern** para gerenciamento de estado
- **Repository Pattern** para acesso a dados
- **Dependency Injection** via GetIt

## 📄 Licença

Este projeto está sob licença proprietária. Todos os direitos reservados.

## 📞 Suporte

- **Email**: suporte@receituagro.com
- **Documentação**: [docs.receituagro.com](https://docs.receituagro.com)
- **Issues**: [GitHub Issues](https://github.com/organization/monorepo/issues)

---

**Desenvolvido com 💚 para o agronegócio brasileiro**