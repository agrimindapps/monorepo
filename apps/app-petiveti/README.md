# PetiVeti - Plataforma Veterinária Completa

<div align="center">

![PetiVeti](https://img.shields.io/badge/PetiVeti-v2.0-6A1B9A?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-00B4AB?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-FF9800?style=for-the-badge)

**Plataforma completa para gestão veterinária com 15+ calculadoras especializadas**

</div>

---

## 📱 Visão Geral

**PetiVeti** é uma plataforma veterinária moderna desenvolvida em **Flutter** com **Clean Architecture**, oferecendo ferramentas profissionais para veterinários e tutores de pets.

### 🎯 Funcionalidades Principais

| Feature | Status | Descrição |
|---------|--------|-----------|
| **🐾 Gestão de Pets** | ✅ **Completa** | CRUD completo com interface moderna |
| **🧮 Calculadoras Veterinárias** | 🟡 **4/13 Funcionais** | Sistema base + 4 calculadoras implementadas |
| **📅 Consultas Veterinárias** | 🟡 **Parcial** | Estrutura completa, interface básica |
| **💉 Controle de Vacinas** | 🟡 **Parcial** | Domain robusto, UI em desenvolvimento |
| **💊 Gestão de Medicamentos** | 🟡 **Parcial** | CRUD básico implementado |
| **⚖️ Controle de Peso** | 🟡 **Parcial** | Widgets avançados, interface completa |
| **🔔 Sistema de Lembretes** | 🟡 **Parcial** | Funcionalidade básica |
| **💰 Controle de Despesas** | 🟡 **Parcial** | Sistema completo, interface básica |
| **🔐 Autenticação** | ✅ **Implementada** | Firebase Auth + mocks para debug |
| **💳 Assinaturas** | ✅ **Implementada** | RevenueCat integrado |

---

## 🏗️ Arquitetura

### 📐 Padrões Arquiteturais

- ✅ **Clean Architecture** (Domain → Data → Presentation)
- ✅ **SOLID Principles** aplicados consistentemente  
- ✅ **Dependency Injection** (GetIt + Injectable)
- ✅ **State Management** (Pure Riverpod 2.6.1 - ~99% migrado)
- ✅ **Repository Pattern** (Local + Remote)
- ✅ **Use Cases Pattern** implementado
- ✅ **GoRouter** para navegação avançada
- ✅ **Code Generation** (@riverpod annotations)

### 🗂️ Estrutura do Projeto

```
apps/app-petiveti/
├── 📱 Platform Support
│   ├── android/                 ✅ Configuração Android nativa
│   ├── ios/                     ✅ Configuração iOS nativa  
│   └── web/                     ✅ Suporte Web
│
├── 🎯 Core Architecture
│   ├── core/
│   │   ├── di/                  ✅ Dependency Injection
│   │   ├── error/               ✅ Error Handling
│   │   ├── router/              ✅ GoRouter + Navigation
│   │   └── theme/               ✅ Tema Unificado + Cores
│   │
├── 🌟 Features (Clean Architecture)
│   ├── animals/                 ✅ PETS - Funcionalidade Completa
│   ├── calculators/             🟡 CALCULADORAS - 4/13 Funcionais
│   ├── appointments/            🟡 Consultas (estrutura completa)
│   ├── vaccines/                🟡 Vacinas (domain robusto)
│   ├── medications/             🟡 Medicamentos (CRUD básico)
│   ├── weight/                  🟡 Peso (widgets avançados)
│   ├── reminders/               🟡 Lembretes (funcional)
│   ├── expenses/                🟡 Despesas (sistema completo)
│   ├── auth/                    ✅ Autenticação Firebase
│   └── subscription/            ✅ Assinaturas RevenueCat
│
├── 🎨 Shared Components
│   ├── shared/
│   │   ├── constants/           ✅ Cores + Constantes
│   │   ├── widgets/             ✅ Componentes Reutilizáveis
│   │   └── dialogs/             ✅ Sistema de Dialogs
│
└── 🧪 Testing
    └── test/                    ❌ Testes não implementados
```

---

## 🧮 Sistema de Calculadoras

### ✅ **Calculadoras Funcionais (4/13)**

| Calculadora | Interface | Funcionalidade | Validação |
|-------------|-----------|----------------|-----------|
| **Body Condition Score** | ✅ Moderna | ✅ Algoritmo completo | ✅ Validações robustas |
| **Cálculo Calórico** | ✅ Wizard multi-step | ✅ Fórmulas científicas | ✅ Validação completa |
| **Dosagem de Medicamentos** | ✅ Base de dados | ✅ Sistema de alertas | ✅ Doses seguras |
| **Idade do Animal** | ✅ Conversão dupla | ✅ Algoritmo preciso | ✅ Faixas etárias |

### 🚧 **Em Desenvolvimento (3/13)**

- **Peso Ideal** - Estrutura pronta, interface simples
- **Fluidoterapia** - Rota definida, cálculos básicos
- **Hidratação** - Sistema base implementado

### ❌ **Pendentes (6/13)**

- Anestesia Calculator
- Diabetes Insulin Calculator  
- Pregnancy Calculator
- Advanced Diet Calculator
- Unit Conversion Calculator
- Others

---

## 🎨 Sistema de Design

### 🌈 Paleta de Cores Unificada

```dart
// Cores Principais
AppColors.primary         // #6A1B9A (Roxo Veterinário)
AppColors.secondary       // #03A9F4 (Azul Accent)
AppColors.primaryGradient // Gradiente Roxo (Headers)

// Cores por Feature
AppColors.petProfilesColor    // Roxo (Perfis)
AppColors.vaccinesColor       // Vermelho (Vacinas) 
AppColors.medicationsColor    // Verde (Medicamentos)
AppColors.appointmentsColor   // Azul (Consultas)
```

### 🎯 Sistema de Tema

- ✅ **Material Design 3** implementation completa
- ✅ **Light + Dark Mode** suportados
- ✅ **Componentes temáticos** (botões, cards, inputs)
- ✅ **Sistema unificado** em toda aplicação
- ✅ **Gradientes consistentes** em headers e dialogs

---

## 🚀 Funcionalidades Implementadas

### 🐾 **Gestão de Pets - COMPLETA**
- ✅ **CRUD Completo**: Criar, listar, editar, excluir pets
- ✅ **Interface Moderna**: Cards responsivos + dialogs
- ✅ **Validação Robusta**: Formulários com validação em tempo real  
- ✅ **Persistência Local**: Sistema Hive para cache
- ✅ **Integração Híbrida**: Local + Firebase preparado

### 🧮 **Calculadoras Veterinárias - PARCIAL**
- ✅ **4 Calculadoras Funcionais** com interfaces completas
- ✅ **Sistema de Navegação** entre calculadoras  
- ✅ **Validação de Entrada** em todas as calculadoras
- ✅ **Design Consistente** com tema da aplicação
- 🚧 **9 Calculadoras Restantes** em desenvolvimento

### 📱 **Navegação e UX**
- ✅ **Bottom Navigation** customizada com 5 tabs
- ✅ **Rotas Avançadas** com GoRouter
- ✅ **Sistema Shell** para mostrar/esconder navegação
- ✅ **Transições Suaves** entre telas
- ✅ **Interface Responsiva** para diferentes tamanhos

---

## ⚙️ Dependências e Tecnologias

### 🔧 **Core Technologies**

```yaml
# State Management
flutter_riverpod: 2.6.1         # Pure Riverpod - State management reativo
riverpod_annotation: 2.6.1      # Code generation (@riverpod)
riverpod_generator: 2.6.1       # Build runner integration
  
# Dependency Injection  
get_it: ^7.7.0                  # Service locator
injectable: ^2.5.1              # Code generation para DI

# Local Storage
hive: ^2.2.3                    # Database NoSQL local
hive_flutter: ^1.1.0            # Flutter integration

# Navigation
go_router: ^10.2.0              # Roteamento avançado declarativo

# Firebase Suite
firebase_core: ^2.32.0          # Core Firebase
cloud_firestore: ^4.17.5        # Database remoto
firebase_auth: ^4.20.0          # Autenticação

# Subscription
purchases_flutter: ^6.29.4      # RevenueCat para assinaturas

# UI/UX
flutter_svg: ^2.0.13           # Suporte SVG
connectivity_plus: ^6.0.5       # Status de conectividade

# Functional Programming
dartz: any                      # Either<Failure, T> pattern
```

### 📊 **Status das Dependências**
- ✅ **Instaladas e Configuradas**: 23/25 dependências
- ⚠️ **Issues de Build**: NDK version + Core desugaring
- ✅ **Code Generation**: build_runner configurado

---

## 🧪 Qualidade e Testes

### 📈 **Métricas de Qualidade**

| Métrica | Valor | Status |
|---------|-------|--------|
| **Total Dart Files** | 789 | ✅ |
| **Riverpod Providers** | 312 (@riverpod) | ✅ |
| **Arquitetura** | 9/10 | ✅ Excelente Clean Architecture |
| **Riverpod Migration** | ~99% | ✅ Pure Riverpod |
| **Features Core** | 7/10 | 🟡 Funcionais mas incompletas |
| **UI/UX Design** | 8/10 | ✅ Moderna e consistente |
| **Code Quality** | 7/10 | 🟡 Boa estrutura |
| **State Management** | Riverpod 2.6.1 | ✅ |

**📊 Score Geral: 7.5/10**

### 🔍 **Status de Desenvolvimento**
- ✅ **Clean Architecture** - Estrutura sólida implementada
- ✅ **Riverpod Migration** - ~99% completo (312 providers)
- 🟡 **Calculadoras** - 4/13 funcionais, base robusta
- 🟡 **Testes** - Em desenvolvimento

---

## 🚀 Execução e Desenvolvimento

### 💻 **Comandos Principais**

```bash
# 1. Navegar para o projeto
cd apps/app-petiveti

# 2. Instalar dependências
flutter pub get

# 3. Code generation (se necessário)
flutter packages pub run build_runner build

# 4. Executar aplicativo
flutter run

# 5. Análise de código
flutter analyze

# 6. Testes (quando implementados)
flutter test
```

### ⚠️ **Issues Conhecidos**

1. **Build Android**: NDK version conflict (precisa 27.0.12077973)
2. **Core Library Desugaring**: Não habilitado
3. **Firebase Web**: Mocks implementados para desenvolvimento
4. **Testes**: Totalmente ausentes

---

## 🎯 Roadmap de Desenvolvimento

### 🔥 **Prioridade Alta (Próximos Sprints)**

#### Sprint 1: Correções Técnicas
- [ ] **Corrigir build issues** (NDK + desugaring)
- [ ] **Limpar warnings** do Flutter analyze
- [ ] **Implementar testes básicos**

#### Sprint 2: Calculadoras Restantes  
- [ ] **Implementar 9 calculadoras** restantes
- [ ] **Interfaces consistentes** para todas
- [ ] **Validações robustas** em todas as calculadoras

#### Sprint 3: Features Pendentes
- [ ] **Completar Appointments** - Interface completa
- [ ] **Finalizar Vaccines** - Sistema completo
- [ ] **Expandir Weight Control** - Gráficos e análises

### 🎨 **Prioridade Média**

#### Sprint 4: UX/UI Melhorias
- [ ] **Dashboard avançado** com estatísticas
- [ ] **Sistema de notificações** push
- [ ] **Modo offline** robusto

#### Sprint 5: Integração Firebase
- [ ] **Sync automático** local ↔ remoto
- [ ] **Backup de dados** automático  
- [ ] **Multi-device sync**

---

## 🏆 Conquistas Técnicas

### ✅ **Implementações de Destaque**

1. **🏗️ Clean Architecture Sólida**
   - Separação perfeita de responsabilidades
   - Domain layer rico e testável
   - Data layer híbrido (local + remoto)

2. **🎨 Sistema de Design Unificado**
   - Paleta de cores consistente
   - Tema claro/escuro completo
   - Componentes reutilizáveis

3. **🧮 Base de Calculadoras Robusta**
   - Sistema extensível para novas calculadoras
   - Validações científicas implementadas
   - Interface consistente entre calculadoras

4. **📱 UX Moderna e Responsiva**
   - Material Design 3 implementation
   - Navegação intuitiva
   - Loading states e error handling

---

## 🤝 Contribuição

### 📋 **Guidelines para Desenvolvimento**

1. **Seguir Clean Architecture** estabelecida
2. **Usar sistema de cores** AppColors
3. **Implementar testes** para novas features
4. **Validar com Flutter analyze** antes de commits
5. **Documentar APIs** e interfaces públicas

### 🔧 **Setup para Desenvolvimento**

```bash
# 1. Clone do monorepo
git clone [repository-url]

# 2. Setup Flutter
flutter doctor

# 3. Dependências do projeto
cd apps/app-petiveti
flutter pub get

# 4. Code generation
flutter packages pub run build_runner build --delete-conflicting-outputs

# 5. Ready to develop! 🚀
flutter run
```

---

## 📄 Licença

Este projeto é propriedade de **Agrimind Soluções** e está sob desenvolvimento ativo.

---

<div align="center">

**🚀 PetiVeti - Revolucionando o Cuidado Veterinário**

![Developed](https://img.shields.io/badge/Desenvolvido%20por-Agrimind%20Soluções-6A1B9A?style=for-the-badge)

</div>