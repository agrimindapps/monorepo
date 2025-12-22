# Auto-Login para Desenvolvimento - Nebulalist

## 📋 Descrição

O Nebulalist possui um sistema de **auto-login** para facilitar o desenvolvimento e testes, eliminando a necessidade de digitar credenciais manualmente a cada vez que o app é executado em modo debug.

## 🔧 Como Funciona

### Ativação Automática

O auto-login é **ativado automaticamente** quando:
- ✅ App está rodando em **modo debug** (`kDebugMode`)
- ✅ **NÃO** está rodando na web (`!kIsWeb`)
- ✅ Flag `enableAutoLogin` está `true` em `DevConfig`

### Comportamento

1. **Usuário já autenticado**: Não faz nada, mantém a sessão
2. **Primeiro login**: Tenta autenticar com credenciais de teste
3. **Falha no login**: Usa login anônimo como fallback (se habilitado)

## ⚙️ Configuração

Edite o arquivo `lib/core/config/dev_config.dart`:

```dart
class DevConfig {
  /// Habilita/desabilita auto-login
  static const bool enableAutoLogin = true; // ou false

  /// Email de teste (crie no Firebase Console)
  static const String testEmail = 'seu-email@teste.com';

  /// Senha de teste
  static const String testPassword = 'sua-senha-123';

  /// Usa login anônimo se falhar
  static const bool useAnonymousFallback = true;

  /// Exibe logs detalhados
  static const bool verboseLogs = true;
}
```

## 🎯 Como Usar

### 1. Criar Usuário de Teste

No Firebase Console:
1. Acesse **Authentication** → **Users**
2. Clique em **Add user**
3. Adicione email: `teste@nebulalist.com`
4. Senha: `teste123`

### 2. Atualizar DevConfig

```dart
static const String testEmail = 'teste@nebulalist.com';
static const String testPassword = 'teste123';
static const bool enableAutoLogin = true;
```

### 3. Executar o App

```bash
flutter run
```

**Logs esperados:**
```
🧪 [NEBULALIST-AUTO-LOGIN] Iniciando auto-login...
✅ [NEBULALIST-AUTO-LOGIN] Login automático bem-sucedido! Usuário: teste@nebulalist.com
```

## 🔒 Segurança

### ⚠️ IMPORTANTE

- ❌ **NÃO** commite credenciais reais no repositório
- ❌ **NÃO** use credenciais de produção
- ✅ Use **apenas** credenciais de teste/desenvolvimento
- ✅ Auto-login **NUNCA** funciona em builds de release
- ✅ Auto-login **NUNCA** funciona na web

### Desabilitar Auto-Login

Para desabilitar temporariamente:

```dart
static const bool enableAutoLogin = false;
```

## 🐛 Troubleshooting

### Auto-login não funciona

**Verifique:**
1. ✅ App está em modo debug (`flutter run` sem `--release`)
2. ✅ `enableAutoLogin = true` em `DevConfig`
3. ✅ Email/senha existem no Firebase Authentication
4. ✅ Não está rodando na web

### Login falha mas app continua

Isso é **esperado**! O sistema usa login anônimo como fallback:
```
❌ [NEBULALIST-AUTO-LOGIN] Falha no auto-login: [firebase_auth/user-not-found]
⚠️ [NEBULALIST-AUTO-LOGIN] Fallback para login anônimo
```

**Solução**: Crie o usuário no Firebase ou desabilite fallback:
```dart
static const bool useAnonymousFallback = false;
```

## 📊 Logs de Debug

### Níveis de Logging

- **Mínimo** (`verboseLogs = false`):
  ```
  ✅ [NEBULALIST-AUTO-LOGIN] Login automático bem-sucedido!
  ```

- **Detalhado** (`verboseLogs = true`):
  ```
  ✅ Firebase initialized for mobile platform
  🧪 [NEBULALIST-AUTO-LOGIN] Iniciando auto-login...
  ✅ [NEBULALIST-AUTO-LOGIN] Login automático bem-sucedido! Usuário: teste@nebulalist.com
  ```

## 🎨 Customização

### Múltiplos Ambientes

Você pode criar múltiplas configurações:

```dart
class DevConfig {
  // Ambiente LOCAL
  static const String testEmailLocal = 'dev@local.com';
  static const String testPasswordLocal = 'dev123';

  // Ambiente STAGING
  static const String testEmailStaging = 'dev@staging.com';
  static const String testPasswordStaging = 'staging123';

  // Ambiente ativo
  static const String testEmail = testEmailLocal;
  static const String testPassword = testPasswordLocal;
}
```

## ✅ Checklist de Implementação

- [x] Auto-login criado em `main.dart`
- [x] Configurações em `DevConfig`
- [x] Fallback para login anônimo
- [x] Logs informativos
- [x] Apenas em debug mode
- [x] Desabilitado para web
- [x] Verificação de usuário já logado
- [x] Tratamento de erros

## 📚 Referências

Baseado na implementação do **app-taskolist**:
- `apps/app-taskolist/lib/main.dart`
- Função `_performAutoLogin()`

---

**Desenvolvido para facilitar testes durante o desenvolvimento do Nebulalist** 🚀
