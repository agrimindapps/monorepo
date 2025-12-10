# Segurança e Criptografia

Este documento descreve as práticas de segurança e criptografia implementadas no pacote `core`.

## StorageEncryptionService

O `StorageEncryptionService` é um serviço utilitário projetado para criptografar dados sensíveis antes de serem armazenados localmente (no Drift ou SharedPreferences).

### Implementação

Utilizamos o pacote `encrypt` com o algoritmo **AES** (Advanced Encryption Standard).

*   **Chave (Key)**: Uma chave segura deve ser gerada e gerenciada. Em implementações simples, pode ser uma chave fixa ofuscada no código, mas idealmente deve ser derivada de segredos do usuário ou gerenciada via `flutter_secure_storage`.
*   **IV (Initialization Vector)**: Um vetor de inicialização é usado para garantir que o mesmo texto plano não gere sempre o mesmo texto cifrado.

### Uso

```dart
final encryptionService = StorageEncryptionService();

// Criptografar
final encryptedText = encryptionService.encrypt('meu_dado_sensivel');

// Descriptografar
final decryptedText = encryptionService.decrypt(encryptedText);
```

### Aplicação no Sistema de Assinaturas

Para evitar que usuários com acesso root ou conhecimento técnico manipulem o banco de dados SQLite para liberar acesso premium indevidamente, os campos críticos da tabela `UserSubscriptions` são criptografados:

*   `status` (ex: "active", "expired")
*   `expirationDate`

Dessa forma, mesmo que o usuário altere o valor no banco, a aplicação falhará ao tentar descriptografar ou lerá um valor inválido, negando o acesso.

## Boas Práticas

1.  **Não commitar chaves reais**: Chaves de API de produção e chaves de criptografia não devem estar hardcoded no repositório se possível. Use variáveis de ambiente ou injeção em tempo de build.
2.  **HTTPS**: Toda comunicação com Firebase e RevenueCat é feita via HTTPS.
3.  **Regras de Segurança (Firebase)**: As regras de segurança do Firestore e Storage devem ser configuradas para permitir acesso apenas a usuários autenticados e aos seus próprios dados.
