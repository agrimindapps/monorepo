# Sistema de Assinaturas

Este documento detalha a implementação do sistema de assinaturas compartilhado entre os aplicativos do monorepo.

## Visão Geral

O sistema de assinaturas é projetado para ser robusto, seguro e funcionar offline. Ele utiliza o **RevenueCat** como fonte da verdade para compras e assinaturas, mas mantém um cache local criptografado para garantir o acesso às funcionalidades premium mesmo sem conexão com a internet.

## Componentes

### 1. RevenueCat (Remote Source)
Utilizamos o SDK `purchases_flutter` para gerenciar o ciclo de vida das assinaturas nas lojas (Google Play e App Store).
*   **Configuração**: Chaves de API configuradas por plataforma.
*   **Entitlements**: Mapeamento de produtos para níveis de acesso (ex: "premium").

### 2. MockSubscriptionService (Dev/Test)
Para facilitar o desenvolvimento e testes (especialmente em Web/Localhost), implementamos um serviço de mock.
*   **Ativação**: Automática em ambiente de debug ou web localhost.
*   **Funcionalidade**: Simula compra, restauração e verificação de status sem conectar ao RevenueCat.
*   **Persistência**: Simula persistência em memória ou local storage simples.

### 3. SubscriptionLocalRepository (Local Cache)
Responsável por armazenar o status da assinatura localmente no banco de dados Drift.
*   **Tabela**: `UserSubscriptions` (armazena userId, status, data de expiração, etc).
*   **Criptografia**: Dados sensíveis são criptografados antes de serem salvos usando `StorageEncryptionService`.
*   **Objetivo**: Permitir verificação de acesso premium offline.

### 4. SubscriptionDriftSyncAdapter
Adaptador que converte objetos do RevenueCat (CustomerInfo) para Entidades de Domínio e DTOs do banco de dados.

### 5. PremiumService (Orquestrador)
Serviço que coordena a verificação de status.
*   **Lógica**:
    1.  Tenta buscar status atualizado do RevenueCat.
    2.  Se sucesso, atualiza o cache local.
    3.  Se falha (sem internet), busca do cache local.
    4.  Notifica listeners sobre mudanças de status.

## Fluxo de Dados

1.  **Inicialização**: O app inicia e o `PremiumService` verifica o cache local imediatamente para liberar acesso rápido. Em paralelo, tenta sincronizar com RevenueCat.
2.  **Compra**: Usuário realiza compra -> RevenueCat processa -> Sucesso -> `PremiumService` atualiza cache local -> UI é atualizada.
3.  **Offline**: Usuário abre o app sem internet -> `PremiumService` lê do Drift (`UserSubscriptions`) -> Acesso concedido se a data de expiração for válida.

## Segurança

*   **Criptografia**: O status da assinatura e datas são armazenados criptografados no banco de dados local para dificultar manipulação direta do arquivo de banco de dados.
*   **Validação**: A validação final de recibos é feita pelo RevenueCat.

## Como Implementar em um Novo App

1.  Adicione a tabela `UserSubscriptions` ao banco de dados Drift do app.
2.  Registre o `SubscriptionLocalRepository` e `SubscriptionDriftSyncAdapter` nos providers.
3.  Configure o `PremiumService` (ou equivalente) para usar o repositório local.
4.  Utilize o `MockSubscriptionService` para testes locais.
