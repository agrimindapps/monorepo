# 🔍 Análise - app-termostecnicos: Carregamento de Página Web em Android/iOS

**Data**: 28 de outubro de 2025  
**Status**: ⚠️ **PROBLEMA IDENTIFICADO**

---

## 📋 Resumo do Problema

O app-termostecnicos está carregando conteúdo de web em plataformas móveis (Android/iOS) devido a configurações de web que deveriam estar exclusivas para plataforma web.

---

## 🔴 Problemas Identificados

### 1. **Import e Uso de `flutter_web_plugins` em App Mobile-Only**

**Arquivo**: `lib/main.dart`

```dart
import 'package:flutter_web_plugins/url_strategy.dart';  // ❌ Usado em mobile

void main() async {
  // ...
  usePathUrlStrategy();  // ❌ Executado em Android/iOS também
}
```

**Por que é problema:**
- `flutter_web_plugins` e `usePathUrlStrategy()` são destinados APENAS para web
- Executar em Android/iOS pode causar comportamentos inesperados
- O app-termostecnicos NÃO tem pasta `/web` (não tem suporte web)

### 2. **Pubspec.yaml com Dependência Web**

**Arquivo**: `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_web_plugins:  # ❌ Adicionado para mobile-only app
    sdk: flutter
```

**Por que é problema:**
- Adiciona código web desnecessário ao build mobile
- Pode interferir com o comportamento normal da aplicação

### 3. **Falta de Proteção na Inicialização**

**Arquivo**: `lib/main.dart` (linhas 27-28)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();  // ❌ Executado MESMO que !kIsWeb
```

O `usePathUrlStrategy()` é executado **incondicionalmente**, mas deveria estar protegido por:
```dart
if (kIsWeb) {
  usePathUrlStrategy();
}
```

---

## ✅ Solução Recomendada

### **Passo 1: Remover `flutter_web_plugins` do pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  # REMOVER: flutter_web_plugins
```

### **Passo 2: Corrigir main.dart com proteção condicional**

```dart
import 'package:flutter_web_plugins/url_strategy.dart' if (dart.library.html) as url_strategy;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  if (kIsWeb) {
    url_strategy.usePathUrlStrategy();  // ✅ Apenas em web
  }

  // Resto do código...
}
```

**Ou, de forma mais simples:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    DartPluginRegistrant.ensureInitialized();
  } else {
    // Web-specific initialization
    // usePathUrlStrategy(); // Só chamar em web
  }

  // Resto do código...
}
```

---

## 📊 Análise da Estrutura Atual

| Componente | Status | Observação |
|---|---|---|
| `/lib/main.dart` | ⚠️ Tem web code | `flutter_web_plugins` importado incondicionalmente |
| `/lib/app_page.dart` | ✅ Correto | Proteção `!kIsWeb` em lugar certo |
| `/pubspec.yaml` | ⚠️ Tem web deps | `flutter_web_plugins` presente desnecessariamente |
| `/web` folder | ✅ Não existe | Correto - app é mobile-only |
| Router/Navigation | ✅ Correto | Usa GoRouter nativamente |
| Web URLs | ✅ Apenas links | Apenas para `url_launcher` (abrir browser) |

---

## 🎯 Por Que Pode Estar Carregando Web

1. **`flutter_web_plugins` força compilação de código web**
2. **`usePathUrlStrategy()` sem proteção pode interferir no routing mobile**
3. **Dependência web pode causar fallback para web renderer em certos cenários**
4. **Flutter web pode estar sendo iniciado como fallback em Android/iOS**

---

## 📝 Implementação da Correção

### **Arquivo: `lib/main.dart`**

**Antes:**
```dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) DartPluginRegistrant.ensureInitialized();

  usePathUrlStrategy();

  // resto do código...
}
```

**Depois:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    DartPluginRegistrant.ensureInitialized();
  }

  // Remover: usePathUrlStrategy() - não necessário para mobile

  // resto do código...
}
```

### **Arquivo: `pubspec.yaml`**

**Antes:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_web_plugins:
    sdk: flutter
```

**Depois:**
```yaml
dependencies:
  flutter:
    sdk: flutter
```

---

## 🧪 Verificação Após Correção

1. **Executar `flutter clean`**
2. **Executar `flutter pub get`**
3. **Build e testar em Android**: `flutter build apk`
4. **Build e testar em iOS**: `flutter build ios`
5. **Verificar que a interface móvel carrega corretamente**

---

## ✨ Resultado Esperado

- ✅ App-termostecnicos carrega a interface Flutter nativa em Android/iOS
- ✅ Sem interferência de código web
- ✅ Performance melhorada (menos código compilado)
- ✅ Comportamento consistente entre plataformas mobile

---

## 📚 Referências

- [Flutter Web Official Docs](https://flutter.dev/multi-platform/web)
- [Conditional Imports in Dart](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)
- [Go Router Documentation](https://pub.dev/packages/go_router)
