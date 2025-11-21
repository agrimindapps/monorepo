# 📋 Task Manager - Gerenciador de Tarefas Pessoal

Um aplicativo Flutter moderno para gerenciamento de tarefas pessoais, seguindo princípios de Clean Architecture e design minimalista.

## 🎯 Visão do Produto

### Propósito
**Aplicativo monousuário** focado em **produtividade pessoal**, permitindo organizar tarefas por contextos/categorias sem complexidade colaborativa desnecessária.

### Público-Alvo
- **Profissionais** que precisam organizar trabalho e vida pessoal
- **Estudantes** gerenciando múltiplas disciplinas e projetos
- **Pessoas organizadas** que preferem simplicidade à complexidade

### Diferencial
- **Simplicidade sobre funcionalidades** - foco no essencial
- **Offline-first** - funciona sem internet
- **Performance** - interface rápida e responsiva
- **Privacidade** - dados apenas locais, sem tracking

## 🏗️ Arquitetura

### Clean Architecture + SOLID
```
📱 Presentation (UI)
├── Pages (Telas)
├── Widgets (Componentes)
└── Providers (Estado - Riverpod)

🎯 Domain (Regras de Negócio)
├── Entities (Modelos de Domínio)
├── Use Cases (Casos de Uso)
└── Repositories (Contratos)

💾 Data (Dados)
├── Models (Serialização)
├── DataSources (Local/Remote)
└── Repositories (Implementações)

🔧 Core (Infraestrutura)
├── DI (Injeção de Dependência)
├── Database (Drift Config)
└── Utils (Utilitários)
```

### Stack Tecnológica
- **Flutter 3.24+** - Framework UI
- **Riverpod** - Gerenciamento de estado
- **Drift** - Database local (SQLite)
- **Dartz** - Programação funcional
- **GetIt** - Injeção de dependência
- **UUID** - Geração de IDs únicos

## ✅ Status Atual (v1.0 - MVP)

### 🎉 Implementado
- ✅ **Autenticação** - Login/registro local
- ✅ **CRUD de Tasks** - Criar, editar, excluir tarefas
- ✅ **Estados** - Pendente, em progresso, concluída
- ✅ **Prioridades** - Baixa, média, alta, urgente
- ✅ **Favoritos** - Marcar tasks importantes
- ✅ **Filtros** - Por status (pendente, progresso, concluída)
- ✅ **Persistência** - Armazenamento local com Drift (SQLite)
- ✅ **Offline** - Funciona completamente offline
- ✅ **UI Responsiva** - Estados de loading/erro/dados

### 🏗️ Arquitetura Implementada
- ✅ **Clean Architecture** completa
- ✅ **Dependency Injection** configurado
- ✅ **Error Handling** tipificado
- ✅ **Use Cases** granulares
- ✅ **Repository Pattern** implementado
- ✅ **TypeAdapters** Drift configurados

## 🚀 Roadmap

### 📋 Fase 2: Gestão de Listas (Próxima)
**Objetivo:** Organizar tasks em contextos diferentes

#### Funcionalidades Planejadas:
- 📁 **Múltiplas Listas** - "Trabalho", "Casa", "Estudos"
- 🎨 **Personalização** - Cores e ícones por lista
- 📊 **Contadores** - Tasks por lista
- 📤 **Export/Share** - Compartilhar lista como texto
- 📋 **Templates** - Listas pré-definidas ("Projeto", "Viagem")
- 🗃️ **Arquivamento** - Listas concluídas

#### Estrutura Técnica:
```dart
TaskListEntity:
├── id, name, description
├── color, icon, position
├── createdAt, updatedAt
└── taskCount, completedCount

TaskEntity (Atualizada):
├── listId (referência à lista)
└── demais campos mantidos
```

### 🔔 Fase 3: Notificações e Lembretes
- 📱 **Notificações Locais** - Lembretes por task
- ⏰ **Agendamento** - Data/hora específica
- 🔄 **Recorrência** - Tasks repetitivas
- ⚙️ **Configurações** - Personalizar notificações

### 📊 Fase 4: Produtividade e Insights
- 📈 **Estatísticas** - Tasks concluídas por período
- 🎯 **Metas** - Objetivos diários/semanais
- 📅 **Visualizações** - Calendário, timeline
- 🏆 **Gamificação** - Streaks, conquistas

### 🎨 Fase 5: Melhorias de UX
- 🌙 **Tema Escuro** - Alternância de temas
- 🎭 **Customização** - Cores, fontes, layouts
- ⚡ **Gestos** - Swipe actions, shortcuts
- 📱 **Widgets** - Shortcuts na tela inicial

## 🚫 Fora do Escopo

### Não Implementaremos:
- ❌ **Múltiplos Usuários** - Foco monousuário
- ❌ **Sincronização Cloud** - Offline-first
- ❌ **Colaboração** - Sem compartilhamento online
- ❌ **Chat/Comentários** - Sem interação social
- ❌ **Integrações** - Sem APIs externas
- ❌ **Assinatura** - App gratuito

### Compartilhamento Simples:
- ✅ **Export de texto** - Copiar lista como texto
- ✅ **Share nativo** - WhatsApp, email, etc.
- ✅ **Formato markdown** - Para desenvolvedores

## 🔧 Desenvolvimento

### Configuração do Ambiente
```bash
# Clone o repositório
git clone [repo-url]
cd monorepo/apps/app_task_manager

# Instalar dependências
flutter pub get

# Gerar código (tables, serialização)
dart run build_runner build --delete-conflicting-outputs

# Executar
flutter run
```

### Estrutura de Pastas
```
lib/
├── core/                 # Infraestrutura
│   ├── database/        # Configuração Hive
│   ├── di/              # Injeção de Dependência
│   ├── errors/          # Error handling
│   └── utils/           # Utilitários
├── data/                # Camada de Dados
│   ├── datasources/     # Fontes de dados
│   ├── models/          # Modelos de dados
│   └── repositories/    # Implementações
├── domain/              # Regras de Negócio
│   ├── entities/        # Entidades
│   ├── repositories/    # Contratos
│   └── usecases/        # Casos de uso
└── presentation/        # Interface
    ├── pages/           # Telas
    ├── providers/       # Estado (Riverpod)
    └── widgets/         # Componentes
```

### Comandos Úteis
```bash
# Análise de código
flutter analyze

# Gerar código Drift/JSON
dart run build_runner build

# Limpar cache de build
flutter clean && flutter pub get

# Executar testes
flutter test
```

## 🎨 Design System

### Princípios de UI/UX
- **Minimalismo** - Interface limpa, sem distrações
- **Consistência** - Padrões visuais uniformes
- **Performance** - Transições fluidas, carregamento rápido
- **Acessibilidade** - Suporte a diferentes necessidades

### Paleta de Cores
- **Primary:** Blue (#2196F3) - Ações principais
- **Success:** Green (#4CAF50) - Tasks concluídas
- **Warning:** Orange (#FF9800) - Prioridade alta
- **Error:** Red (#F44336) - Erros e exclusões
- **Surface:** White/Dark - Backgrounds

## 📱 Casos de Uso

### Profissional
```
📊 Trabalho
├── ✅ Code review PR #123
├── 🔄 Implementar autenticação
├── 📝 Documentar API endpoints
└── 📧 Responder emails importantes

💼 Pessoal
├── 📞 Agendar consulta médica
├── 🛒 Comprar presente aniversário
└── 💳 Pagar conta de luz
```

### Estudante
```
📚 Matemática
├── ✅ Resolver exercícios cap. 5
├── 📝 Estudar para prova
└── 🎯 Revisar derivadas

🔬 Química
├── 🧪 Relatório experimento
├── 📖 Ler artigo sobre átomos
└── ✏️ Fazer lista de exercícios
```

## 🤝 Contribuição

### Como Contribuir
1. **Fork** o projeto
2. **Crie** uma branch (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. **Push** para a branch (`git push origin feature/nova-funcionalidade`)
5. **Abra** um Pull Request

### Padrões de Código
- **Clean Architecture** - Separação clara de responsabilidades
- **SOLID Principles** - Código maintível e extensível
- **Flutter Best Practices** - Seguir convenções da comunidade
- **Testes** - Cobertura mínima de 80% em use cases

## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🎯 Contato

- **Desenvolvedor:** [Seu Nome]
- **Email:** [seu.email@exemplo.com]
- **GitHub:** [seu-usuario]

---

> 💡 **Filosofia do Projeto:** "Simplicidade é a sofisticação suprema" - Leonardo da Vinci

> 🎯 **Objetivo:** Criar uma ferramenta que ajude as pessoas a serem mais produtivas sem adicionar complexidade desnecessária às suas vidas.