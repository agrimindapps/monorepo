# 🧪 Auto-Login para Testes - App ReceitaAgro

## 🎯 Objetivo
Pular o processo manual de login durante desenvolvimento para testar rapidamente as funcionalidades internas do app.

## ✅ Implementação

### Localização
**Arquivo**: `lib/main.dart` - Método `_performTestAutoLogin()` na classe `_ReceitaAgroAppState`

### Credenciais de Teste
- **Email**: `lucineiy@hotmail.com`
- **Senha**: `QWEqwe@123`

## 🔒 Segurança

### ⚠️ IMPORTANTE
- ✅ **Apenas em Debug**: O auto-login só executa quando `kDebugMode == true`
- ✅ **Post-Frame**: Executado após o primeiro frame
- ✅ **Smart Check**: Não faz login se já estiver autenticado (não-anônimo)
- ❌ **REMOVER EM PRODUÇÃO**: Este código deve ser removido antes do deploy

### Comportamento Especial
O ReceitaAgro faz login anônimo por padrão no `main()`. O auto-login:
1. Verifica se já existe um usuário logado
2. Se for anônimo, faz login com credenciais de teste
3. Se já estiver autenticado, pula o auto-login

### Como Desabilitar
Comentar as linhas no `initState()` em `lib/main.dart`:

```dart
// COMENTAR ESTAS LINHAS PARA DESABILITAR
// if (kDebugMode) {
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     _performTestAutoLogin();
//   });
// }
```

## 📝 Logs Esperados

Caso 1 - Novo login:
```
🧪 [RECEITUAGRO-TEST] Attempting auto-login...
🧪 [RECEITUAGRO-TEST] Auto-login successful! User: lucineiy@hotmail.com
```

Caso 2 - Já autenticado:
```
🧪 [RECEITUAGRO-TEST] Attempting auto-login...
🧪 [RECEITUAGRO-TEST] Already logged in as: lucineiy@hotmail.com
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
