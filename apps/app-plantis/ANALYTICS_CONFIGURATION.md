# 📊 Configuração do Analytics e Crashlytics por Ambiente

Este documento explica como o Firebase Analytics e Crashlytics funcionam em diferentes ambientes no app Plantis.

## 🌍 Ambientes Disponíveis

### Development (Desenvolvimento)
- **ENV**: `development` (padrão)
- **Analytics**: ❌ **DESABILITADO** - Apenas logs locais
- **Crashlytics**: ❌ **DESABILITADO** - Apenas logs locais
- **Comportamento**: Todos os eventos são logados apenas no console do Flutter

### Staging (Homologação)
- **ENV**: `staging`
- **Analytics**: ✅ **HABILITADO** - Dados enviados para Firebase
- **Crashlytics**: ✅ **HABILITADO** - Erros enviados para Firebase
- **Comportamento**: Funciona como produção para testes

### Production (Produção)
- **ENV**: `production`
- **Analytics**: ✅ **HABILITADO** - Dados enviados para Firebase
- **Crashlytics**: ✅ **HABILITADO** - Erros enviados para Firebase
- **Comportamento**: Coleta completa de dados e erros

---

## ⚙️ Como Configurar o Ambiente

### 1. Durante o Build
```bash
# Development (padrão)
flutter build apk

# Staging
flutter build apk --dart-define=ENV=staging

# Production
flutter build apk --dart-define=ENV=production --release
```

### 2. Durante o Run (Desenvolvimento)
```bash
# Development (padrão)
flutter run

# Testar como Staging
flutter run --dart-define=ENV=staging

# Testar como Production
flutter run --dart-define=ENV=production
```

---

## 📱 Comportamento por Ambiente

### 🧪 Development Mode
```dart
// Em development, você verá logs como:
📊 [DEV] Analytics: Screen view - home_page
📊 [DEV] Analytics: Login - email
🔥 [DEV] Crashlytics: Error - Exception: Test error
📝 [DEV] Crashlytics: Log - User completed action
```

**O que acontece:**
- ❌ Nenhum dado enviado para Firebase
- ✅ Logs visíveis no console
- ✅ Performance otimizada (sem calls de rede)
- ✅ Ideal para desenvolvimento

### 🔬 Staging/Production Mode
```dart
// Em staging/production, você verá logs como:
📊 Analytics: Screen view logged - home_page
📊 Analytics: Event logged - user_login
🔥 Crashlytics: Error recorded - Exception: Network timeout
```

**O que acontece:**
- ✅ Dados enviados para Firebase Analytics
- ✅ Crashes enviados para Firebase Crashlytics
- ✅ User properties e custom keys configuradas
- ✅ Monitoramento completo ativo

---

## 🔧 Configuração Técnica

### EnvironmentConfig
```dart
// Configuração automática baseada no ambiente
static bool get enableAnalytics {
  return environment == Environment.production || 
         environment == Environment.staging;
}

static bool get enableLogging {
  return environment != Environment.production;
}
```

### AnalyticsProvider
```dart
// Verificação automática antes de enviar dados
bool get _isAnalyticsEnabled => EnvironmentConfig.enableAnalytics;
bool get _isDebugMode => EnvironmentConfig.isDebugMode;

Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
  // Em development, apenas log local
  if (!_isAnalyticsEnabled) {
    if (_isDebugMode) {
      debugPrint('📊 [DEV] Analytics: Event - $eventName');
    }
    return;
  }
  
  // Em staging/production, envia para Firebase
  await _analyticsRepository.logEvent(eventName, parameters: parameters);
}
```

---

## 🧪 Como Testar

### 1. Testar Logs em Development
```bash
flutter run
# Faça login no app
# Você verá: 📊 [DEV] Analytics: Login - email
```

### 2. Testar Envio em Staging
```bash
flutter run --dart-define=ENV=staging
# Faça login no app
# Dados serão enviados para Firebase
# Verifique no Firebase Console → Analytics
```

### 3. Verificar Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Selecione o projeto **plantis-72458**
3. Vá para **Analytics → Events** (tempo real)
4. Vá para **Crashlytics** (para ver erros)

---

## 📋 Logs de Debug Disponíveis

### Analytics Events
- `📊 [DEV] Analytics: Screen view - screen_name`
- `📊 [DEV] Analytics: Event - event_name`
- `📊 [DEV] Analytics: Login - method`
- `👤 [DEV] Analytics: User properties - {...}`

### Crashlytics Events
- `🔥 [DEV] Crashlytics: Error - error_message`
- `⚠️ [DEV] Crashlytics: Non-fatal error - error_message`
- `📝 [DEV] Crashlytics: Log - message`
- `🔑 [DEV] Crashlytics: Custom key - key: value`

---

## ⚠️ Importante

### Privacy & LGPD
- ❌ Em **development**, nenhum dado pessoal é enviado
- ✅ Em **staging/production**, dados são enviados apenas com consentimento
- ✅ Analytics configurado para respeitar privacidade do usuário

### Performance
- ⚡ Development: Performance otimizada (sem network calls)
- ⚡ Staging/Production: Envio assíncrono sem bloquear UI

### Debugging
- 🐛 Development: Logs detalhados no console
- 🐛 Staging/Production: Logs mínimos + Firebase reporting

---

## 🚀 Deploy Configuration

### Android
```bash
# Development
flutter build apk --debug

# Staging  
flutter build apk --dart-define=ENV=staging --profile

# Production
flutter build appbundle --dart-define=ENV=production --release
```

### iOS
```bash
# Development
flutter build ios --debug

# Staging
flutter build ios --dart-define=ENV=staging --profile  

# Production
flutter build ios --dart-define=ENV=production --release
```

---

## 📚 Referências

- [EnvironmentConfig](/packages/core/lib/src/shared/config/environment_config.dart)
- [AnalyticsProvider](/lib/core/providers/analytics_provider.dart)
- [Firebase Console](https://console.firebase.google.com/project/plantis-72458)
- [Flutter Build Modes](https://flutter.dev/docs/testing/build-modes)