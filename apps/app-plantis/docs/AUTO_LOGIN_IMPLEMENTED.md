# 🧪 Auto-Login para Testes - App Plantis

## 🎯 Objetivo
Pular o processo manual de login durante desenvolvimento para testar rapidamente as funcionalidades internas do app.

## ✅ Implementação

### Localização
**Arquivo**: `lib/app.dart` - Método `_performTestAutoLogin()` na classe `_PlantisAppState`

### Credenciais de Teste
- **Email**: `lucineiy@hotmail.com`
- **Senha**: `QWEqwe@123`

## 🔒 Segurança

### ⚠️ IMPORTANTE
- ✅ **Apenas em Debug**: O auto-login só executa quando `kDebugMode == true`
- ✅ **Post-Frame**: Executado após o primeiro frame
- ❌ **REMOVER EM PRODUÇÃO**: Este código deve ser removido antes do deploy

### Como Desabilitar
Comentar as linhas no `initState()` em `lib/app.dart`:

```dart
// COMENTAR ESTAS LINHAS PARA DESABILITAR
// if (kDebugMode) {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _performTestAutoLogin();
//   });
// }
```

## 📝 Logs Esperados

```
🧪 [PLANTIS-TEST] Attempting auto-login...
🧪 [PLANTIS-TEST] Auto-login successful! User: lucineiy@hotmail.com
```

## 🚀 Uso

O auto-login é executado automaticamente ao:
- Iniciar o app (flutter run)
- Hot restart (R)
- Nova compilação

**NÃO** é executado em hot reload (r).

---

**Data**: 2025-11-18  
**Status**: ✅ Implementado
