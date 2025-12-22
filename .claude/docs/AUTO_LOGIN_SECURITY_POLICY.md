# Política de Segurança - Auto-Login em Desenvolvimento

**Data**: 2025-12-21
**Escopo**: Todos os apps do monorepo
**Severidade**: 🔴 CRÍTICA

## 📋 Status Atual do Monorepo

### **Apps Auditados** ✅

| App | Auto-Login? | Status | Observações |
|-----|-------------|--------|-------------|
| **app-gasometer** | ✅ Sim | ✅ **CORRIGIDO** | Verificação de localhost em `app.dart` |
| **app-plantis** | ❌ Não | ✅ OK | Sem auto-login |
| **app-nebulalist** | ❌ Não | ✅ OK | Sem auto-login |
| **app-receituagro** | ✅ Sim | ✅ **CORRIGIDO** | Verificação de localhost em `main.dart` (2 locais) |
| **app-petiveti** | ❌ Não | ✅ OK | Sem auto-login |
| **app-agrihurbi** | ❌ Não | ✅ OK | Sem auto-login |
| **app-taskolist** | ❌ Não | ✅ OK | Sem auto-login |
| **app-nutrituti** | ❌ Não | ✅ OK | Sem auto-login |
| **app-minigames** | ❌ Não | ✅ OK | Sem auto-login |

**Resumo**:
- ✅ **2 apps com auto-login** (app-gasometer, app-receituagro) - **AMBOS CORRIGIDOS**
- ✅ **7 apps sem auto-login** - **OK**

## 🔒 Política de Segurança

### **REGRA GERAL: Auto-Login NÃO É RECOMENDADO**

Auto-login com credenciais hardcoded é uma **prática de risco** e deve ser **evitada**. Se absolutamente necessário para testes, seguir as diretrizes abaixo.

## ✅ Diretrizes para Auto-Login (Se Necessário)

### **1. Verificação Obrigatória de Localhost**

```dart
// ✅ CORRETO - Verifica localhost
if (kDebugMode && _isLocalhost()) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _performTestAutoLogin();
  });
}

// ❌ ERRADO - Permite em qualquer lugar
if (kDebugMode) {
  _performTestAutoLogin();
}
```

### **2. Implementação de `_isLocalhost()`**

```dart
/// Verifica se está rodando em localhost (Web apenas)
bool _isLocalhost() {
  if (!kIsWeb) return true; // Mobile/Desktop sempre permite em debug

  try {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  } catch (e) {
    if (kDebugMode) {
      SecureLogger.warning('Failed to check localhost status', error: e);
    }
    return false; // Fail-safe: bloqueia em caso de erro
  }
}
```

### **3. NUNCA Hardcode Credenciais**

```dart
// ❌ ERRADO - Credenciais hardcoded
const testEmail = 'user@example.com';
const testPassword = 'password123';

// ✅ CORRETO - Usar variáveis de ambiente
const testEmail = String.fromEnvironment('TEST_EMAIL');
const testPassword = String.fromEnvironment('TEST_PASSWORD');

// ✅ AINDA MELHOR - Usar .env (não commitado)
final testEmail = dotenv.env['TEST_EMAIL'];
final testPassword = dotenv.env['TEST_PASSWORD'];
```

### **4. Comentários Claros**

```dart
// 🧪 AUTO-LOGIN PARA TESTES (APENAS LOCALHOST)
// ⚠️ REMOVER EM PRODUÇÃO!
if (kDebugMode && _isLocalhost()) {
  _performTestAutoLogin();
}
```

### **5. Logging Apropriado**

```dart
void _performTestAutoLogin() async {
  try {
    SecureLogger.info('🧪 [TEST] Attempting auto-login...');

    // ... login logic ...

    if (result.user != null) {
      SecureLogger.info('🧪 [TEST] Auto-login successful');
    }
  } catch (e) {
    SecureLogger.error('🧪 [TEST] Auto-login error', error: e);
  }
}
```

## 🚫 O Que NÃO Fazer

### **❌ 1. Auto-Login Sem Verificação de Localhost**

```dart
// ❌ PERIGOSO - Executa em qualquer ambiente debug
if (kDebugMode) {
  FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
}
```

**Risco**: Credenciais expostas em builds debug hospedados publicamente.

### **❌ 2. Credenciais Hardcoded em Produção**

```dart
// ❌ CRÍTICO - Credenciais commitadas no git
const testEmail = 'admin@company.com';
const testPassword = 'SuperSecretPassword123';
```

**Risco**: Credenciais vazam no controle de versão.

### **❌ 3. Auto-Login em Main.dart**

```dart
// ❌ RUIM - Auto-login no entry point
void main() async {
  await Firebase.initializeApp();

  // ❌ Não fazer isso aqui!
  if (kDebugMode) {
    await FirebaseAuth.instance.signInWithEmailAndPassword(...);
  }

  runApp(MyApp());
}
```

**Risco**: Difícil de controlar e debug.

### **❌ 4. Auto-Login Sem Fail-Safe**

```dart
// ❌ PERIGOSO - Sem proteção contra erros
bool _isLocalhost() {
  final host = Uri.base.host;
  return host == 'localhost'; // Se Uri.base falhar, app quebra
}
```

**Risco**: Crash do app ou comportamento inesperado.

## 🎯 Alternativas Recomendadas

### **Opção 1: Modo Anônimo (Recomendado)**

```dart
// ✅ MELHOR - Usar modo anônimo para testes
if (kDebugMode) {
  await FirebaseAuth.instance.signInAnonymously();
}
```

**Vantagens**:
- Sem credenciais expostas
- Seguro para qualquer ambiente
- Dados de teste isolados

### **Opção 2: Firebase Emulator (Desenvolvimento Local)**

```dart
// ✅ IDEAL - Usar emulador local
if (kDebugMode && _isLocalhost()) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

**Vantagens**:
- Sem dependência de servidor de produção
- Testes isolados
- Dados de teste não poluem produção

### **Opção 3: Feature Flags**

```dart
// ✅ BOM - Usar feature flags
const autoLoginEnabled = bool.fromEnvironment('AUTO_LOGIN_ENABLED');

if (kDebugMode && autoLoginEnabled && _isLocalhost()) {
  _performTestAutoLogin();
}
```

**Uso**:
```bash
# Habilitar apenas quando necessário
flutter run --dart-define=AUTO_LOGIN_ENABLED=true
```

## 📝 Checklist de Segurança

Antes de adicionar auto-login em qualquer app:

- [ ] Auto-login é **realmente necessário**? (considere alternativas)
- [ ] Verificação de `_isLocalhost()` implementada?
- [ ] Credenciais **NÃO** estão hardcoded no código?
- [ ] Credenciais em `.env` ou variáveis de ambiente?
- [ ] `.env` adicionado ao `.gitignore`?
- [ ] Comentários claros sobre remoção em produção?
- [ ] Logging apropriado implementado?
- [ ] Fail-safe em caso de erro (retorna `false`)?
- [ ] Testado em localhost? ✅
- [ ] Testado em domínio público (deve bloquear)? ✅

## 🔄 Processo de Remoção (Futuramente)

Quando remover auto-login de um app:

1. **Remover código de auto-login**:
   ```dart
   // Deletar todo o bloco:
   if (kDebugMode && _isLocalhost()) {
     _performTestAutoLogin();
   }
   ```

2. **Remover método `_performTestAutoLogin()`**

3. **Remover método `_isLocalhost()` (se não usado em outro lugar)**

4. **Remover arquivo `.env` (se existir)**

5. **Atualizar documentação**

6. **Commit com mensagem clara**:
   ```bash
   git commit -m "security: remove auto-login functionality"
   ```

## 📚 Referências

- [AUTO_LOGIN_LOCALHOST_FIX.md](../apps/app-gasometer/docs/AUTO_LOGIN_LOCALHOST_FIX.md) - Correção implementada no app-gasometer
- [OWASP - Hardcoded Credentials](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/basics)

## 🚨 Violações de Segurança

Reportar violações desta política:
1. Criar issue no GitHub com tag `security`
2. Notificar tech lead
3. Corrigir imediatamente (prioridade P0)

---

**Última Atualização**: 2025-12-21
**Responsável**: Tech Lead
**Revisão**: Trimestral
