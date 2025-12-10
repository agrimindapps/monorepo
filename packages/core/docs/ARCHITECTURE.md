# Arquitetura do Monorepo

Este documento descreve a arquitetura geral utilizada nos aplicativos do monorepo, focando nos padrões e tecnologias compartilhadas através do pacote `core`.

## Visão Geral

Utilizamos uma arquitetura baseada em **Clean Architecture** combinada com **Riverpod** para gerenciamento de estado. O objetivo é manter o código desacoplado, testável e fácil de manter.

### Camadas (Clean Architecture)

1.  **Presentation (Apresentação)**:
    *   Contém Widgets, Pages e Notifiers (Riverpod).
    *   Responsável por exibir dados e capturar interações do usuário.
    *   Não contém lógica de negócios complexa.

2.  **Domain (Domínio)**:
    *   Contém Entidades, Casos de Uso (UseCases) e Interfaces de Repositórios.
    *   É a camada mais interna e não deve depender de bibliotecas externas (exceto utilitários puros).
    *   Define *o que* o sistema faz.

3.  **Data (Dados)**:
    *   Contém Implementações de Repositórios, Data Sources (Remotos e Locais) e Models (DTOs).
    *   Responsável por buscar e persistir dados.
    *   Define *como* o sistema faz.

## Tecnologias Principais

### Gerenciamento de Estado: Riverpod
Utilizamos o `flutter_riverpod` com geração de código (`@riverpod`) para injeção de dependência e gerenciamento de estado.
*   **Providers**: Encapsulam lógica e estado.
*   **Notifiers**: Gerenciam estados mutáveis.
*   **Code Generation**: Reduz boilerplate e melhora a segurança de tipos.

### Persistência Local: Drift
Utilizamos o `drift` para banco de dados SQLite local.
*   **Tabelas**: Definidas em Dart.
*   **DAOs**: Acesso a dados tipado.
*   **Migrações**: Gerenciamento de versões do banco de dados.
*   **Web Support**: Suporte a WASM via `sqlite3_web`.

### Assinaturas: RevenueCat
Utilizamos o `purchases_flutter` para gerenciar assinaturas in-app.
*   **Abstração**: `ISubscriptionRepository` e `SubscriptionService`.
*   **Cache Local**: Sincronização de status premium para acesso offline.

### Autenticação: Firebase Auth
Utilizamos o `firebase_auth` para autenticação de usuários.
*   **Providers**: Google, Apple, Email/Senha.
*   **Integração**: `AuthNotifier` gerencia o estado de autenticação globalmente.

### Segurança: Encryption
Utilizamos o `encrypt` para criptografar dados sensíveis armazenados localmente.
*   **StorageEncryptionService**: Serviço utilitário para criptografar/descriptografar strings.

## Padrões de Projeto

*   **Repository Pattern**: Abstrai a fonte de dados (API, Banco Local, etc).
*   **Adapter Pattern**: Adapta dados de bibliotecas externas para entidades do domínio.
*   **Dependency Injection**: Via Riverpod.
*   **Offline-First**: Prioriza o funcionamento offline com sincronização posterior (implementado via Drift e SyncAdapters).
