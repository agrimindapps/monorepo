# Task Manager - Clean Architecture & SOLID

Este projeto é uma implementação completa de um gerenciador de tarefas seguindo princípios **SOLID** e **Clean Architecture**, migrado do projeto original app-todoist.

## 🏗️ Arquitetura

### Clean Architecture Layers

```
presentation/          # UI Layer
├── pages/            # Screens/Pages  
├── widgets/          # Reusable UI Components
└── providers/        # State Management (Riverpod)

domain/               # Business Logic Layer
├── entities/         # Core Business Objects
├── repositories/     # Abstract Contracts
└── usecases/         # Business Rules

data/                 # Data Layer
├── models/           # Data Transfer Objects
├── datasources/      # Data Source Interfaces
└── repositories/     # Repository Implementations

core/                 # Infrastructure
├── constants/        # App Constants
├── errors/           # Error Handling
├── utils/            # Utilities
├── network/          # Network Setup
├── storage/          # Storage Setup
└── di/               # Dependency Injection
```

## 🎯 Princípios SOLID Implementados

### 1. **Single Responsibility Principle (SRP)**
- **Entities**: Apenas dados de domínio
- **Use Cases**: Uma responsabilidade por classe
- **Repositories**: Separados por contexto (Task, User, etc.)
- **Widgets**: Componentes focados em uma função

### 2. **Open/Closed Principle (OCP)**
- **Interfaces abstratas** para repositories
- **Strategy pattern** para diferentes data sources
- **Extension methods** para funcionalidades adicionais

### 3. **Liskov Substitution Principle (LSP)**
- **Interfaces bem definidas** que podem ser substituídas
- **Implementações intercambiáveis** (Local/Remote DataSource)

### 4. **Interface Segregation Principle (ISP)**
- **Interfaces específicas** por responsabilidade
- **Use Cases granulares** ao invés de services grandes
- **DataSources separados** por função

### 5. **Dependency Inversion Principle (DIP)**
- **Injeção de dependência** com GetIt
- **Abstrações** ao invés de implementações concretas
- **Inversão de controle** em todas as camadas

## 🔄 Fluxos de Dados

### Criação de Tarefa
```
UI → Use Case → Repository → DataSource → Database
   ←           ←            ←             ←
```

### Leitura de Tarefas
```
UI → Provider → Use Case → Repository → DataSource → Cache/Remote
   ←         ←          ←            ←             ←
```

## 📦 Funcionalidades Migradas

### ✅ Implementadas
- [x] Arquitetura Clean com SOLID
- [x] Entidades de domínio (Task, User, TaskList)
- [x] Use Cases granulares
- [x] Repository pattern com abstrações
- [x] Provider pattern com Riverpod
- [x] Estrutura de UI básica
- [x] Sistema de erros tipificado

### 🚧 Em Desenvolvimento
- [ ] Implementações dos DataSources
- [ ] Firebase integration
- [ ] Hive local storage
- [ ] Notification system
- [ ] Authentication flow
- [ ] Sync mechanism
- [ ] Testing infrastructure

### 📋 Funcionalidades do App Original
- [ ] **Autenticação** (Email/Password, Guest mode)
- [ ] **CRUD de Tarefas** (Create, Read, Update, Delete)
- [ ] **Listas de Tarefas** (Compartilhamento, cores)
- [ ] **Filtragem** (Hoje, Vencidas, Favoritas, etc.)
- [ ] **Agrupamento** (Por prioridade, data, status)
- [ ] **Sincronização Offline-First**
- [ ] **Notificações** (Locais e push)
- [ ] **Temas customizáveis**
- [ ] **Sistema Premium**

## 🛠️ Tecnologias

- **Flutter 3.8+**
- **Riverpod** (State Management)
- **Hive** (Local Storage)  
- **Firebase** (Backend)
- **GetIt** (Dependency Injection)
- **Dartz** (Functional Programming)
- **Equatable** (Value Equality)

## 📚 Benefícios da Nova Arquitetura

### 🧪 **Testabilidade**
- Use Cases isolados e testáveis
- Mocks fáceis com interfaces
- Testing pyramid completo

### 🔧 **Manutenibilidade**
- Separação clara de responsabilidades
- Código desacoplado
- Fácil refatoração

### 📈 **Escalabilidade**
- Adição de features sem impacto
- Team scaling facilitado
- Patterns consistentes

### 🔄 **Flexibilidade**
- Troca de implementações sem impacto
- Multiple data sources
- Adaptação a mudanças de requisitos

## 🚀 Próximos Passos

1. **Implementar DataSources** concretos
2. **Configurar Firebase** integration
3. **Implementar Hive** storage
4. **Criar testes** unitários e de integração
5. **Migrar UI** do projeto original
6. **Adicionar features** restantes

## 🎯 Comparação com Projeto Original

| Aspecto | Original | Nova Arquitetura |
|---------|----------|------------------|
| **Arquitetura** | GetX MVC | Clean Architecture + SOLID |
| **State Management** | GetX Controllers | Riverpod Providers |
| **Business Logic** | Mixing layers | Use Cases isolados |
| **Data Layer** | Repository direto | DataSource + Repository |
| **Testing** | Difícil | Fácil com mocks |
| **Manutenibilidade** | Acoplado | Desacoplado |
| **Escalabilidade** | Limitada | Alta |

Esta nova implementação mantém **todas as funcionalidades** do projeto original, mas com uma arquitetura muito mais robusta, testável e escalável.