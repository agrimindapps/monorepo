# Persistência Offline de Assinaturas

## 🎯 Objetivo
Garantir que o status da assinatura do usuário (Premium/Free) esteja disponível mesmo quando o dispositivo estiver offline, mantendo a segurança dos dados através de criptografia.

## 🏗 Arquitetura Implementada

### 1. Camada de Dados (Drift)
Foi criada uma nova tabela `UserSubscriptions` no banco de dados local (Drift) para armazenar os dados da assinatura.

**Campos:**
- `userId`: Identificador do usuário (PK).
- `isPremium`: Status da assinatura (criptografado).
- `entitlements`: Lista de benefícios (criptografado).
- `latestExpirationDate`: Data de expiração (criptografado).
- `lastCheck`: Data da última sincronização.

### 2. Segurança (Criptografia)
Utilizamos o `StorageEncryptionService` do pacote `core` para criptografar os dados sensíveis antes de salvar no banco de dados local. Isso garante que, mesmo que o banco de dados seja acessado externamente, os dados da assinatura não possam ser facilmente adulterados.

### 3. Sincronização (Adapter)
Implementamos o `SubscriptionDriftSyncAdapter` que atua como uma ponte entre o serviço de assinatura (RevenueCat) e o banco de dados local.

**Fluxo de Sincronização:**
1. **Inicialização**: O app tenta carregar os dados locais decriptografados.
2. **Online**: Se houver conexão, consulta o RevenueCat.
3. **Atualização**: Se houver mudanças no RevenueCat, os dados são criptografados e salvos no Drift.
4. **Offline**: Se não houver conexão, o app utiliza os dados cacheados no Drift.

### 4. Repositório Local
O `SubscriptionLocalRepository` gerencia as operações de CRUD no banco de dados local, abstraindo a complexidade da criptografia/descriptografia para o restante da aplicação.

## 🔄 Fluxo de Uso

1. O `ReceitaAgroPremiumService` é inicializado.
2. Ele tenta recuperar a assinatura salva localmente via `SubscriptionLocalRepository`.
3. Se encontrar, atualiza o estado do app imediatamente (permitindo acesso offline).
4. Em paralelo, verifica o status atualizado no RevenueCat.
5. Qualquer alteração no status da assinatura é automaticamente persistida localmente.

## 🛠 Arquivos Principais
- `lib/core/database/receituagro_tables.dart`: Definição da tabela.
- `lib/core/repositories/subscription_local_repository.dart`: Repositório local.
- `lib/core/services/premium_service.dart`: Serviço principal atualizado.
