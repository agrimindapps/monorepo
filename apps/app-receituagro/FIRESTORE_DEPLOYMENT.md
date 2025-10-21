# 🔥 Deployment de Regras do Firestore - ReceitaAgro

## 📋 Resumo

Este guia explica como aplicar as novas regras de segurança do Firestore que **habilitam sincronização em tempo real** entre dispositivos.

**Arquivo:** `firestore.rules`
**Versão:** 2.0 (Sync em Tempo Real)
**Data:** 2025-10-20

---

## 🎯 O Que Mudou

### ✅ **Adicionado:**
- ✅ Regras para `/favoritos/{favoritoId}` - Sync em tempo real
- ✅ Regras para `/comentarios/{comentarioId}` - Sync em tempo real
- ✅ Regras para `/user_settings/{settingId}` - Sync em tempo real
- ✅ Regras para `/user_history/{historyId}` - Sync em tempo real
- ✅ Regras para `/comments/{commentId}` - Compatibilidade (legado)

### 🔐 **Segurança:**
- ✅ **Autenticação obrigatória** em todas as operações
- ✅ **Isolamento por usuário** (`userId == request.auth.uid`)
- ✅ **Validação em create** (impede criar dados para outros usuários)
- ✅ **Deny-by-default** (bloqueia tudo que não foi explicitamente permitido)

---

## 📝 Passo a Passo - Firebase Console

### **1. Acesse o Firebase Console**

```
https://console.firebase.google.com
```

1. Faça login com sua conta Google
2. Selecione o projeto: **"ReceitaAgro"**

### **2. Navegue até Firestore Database**

1. No menu lateral esquerdo, clique em: **Firestore Database**
2. No topo da página, clique na aba: **Regras** (ou **Rules**)

### **3. Copie o Conteúdo do Arquivo**

Abra o arquivo `firestore.rules` e **copie TODO o conteúdo**:

```bash
# No terminal:
cat firestore.rules | pbcopy  # macOS (copia para clipboard)
# OU
cat firestore.rules  # Copie manualmente
```

### **4. Cole no Editor do Firebase**

1. No editor de regras do Firebase Console
2. **Selecione TUDO** (Cmd+A / Ctrl+A)
3. **Cole** o novo conteúdo (Cmd+V / Ctrl+V)

### **5. Publique as Novas Regras**

1. Clique no botão **"Publicar"** (ou **"Publish"**)
2. Aguarde a mensagem de confirmação: ✅ "Regras publicadas com sucesso"

### **6. Valide a Publicação**

Verifique se as regras foram aplicadas:
1. No topo da página, você verá a data/hora da última publicação
2. Deve mostrar: "Publicado agora" ou "Publicado há poucos segundos"

---

## 🧪 Teste as Regras (Opcional mas Recomendado)

### **Teste 1: Criar Favorito Próprio (DEVE PERMITIR)**

1. No Firebase Console, clique em **"Rules Playground"** (ao lado de "Regras")
2. Configure:
   - **Operation:** `create`
   - **Location:** `/favoritos/fav_test_123`
   - **Authenticated:** ✅ **Sim**
   - **Provider UID:** `user123` (qualquer ID)

3. No campo "Data to write", cole:
   ```json
   {
     "userId": "user123",
     "tipo": "defensivo",
     "itemId": "def_456",
     "adicionadoEm": "2025-10-20T00:00:00Z"
   }
   ```

4. Clique em **"Run"**
5. **Resultado esperado:** ✅ **Allowed** (verde)

### **Teste 2: Ler Favorito de Outro Usuário (DEVE BLOQUEAR)**

1. Configure:
   - **Operation:** `read`
   - **Location:** `/favoritos/fav_test_999`
   - **Authenticated:** ✅ **Sim**
   - **Provider UID:** `user123`

2. No campo "Simulated read data", cole:
   ```json
   {
     "userId": "user456",
     "tipo": "defensivo",
     "itemId": "def_789"
   }
   ```

3. Clique em **"Run"**
4. **Resultado esperado:** ❌ **Denied** (vermelho)

### **Teste 3: Criar Sem Autenticação (DEVE BLOQUEAR)**

1. Configure:
   - **Operation:** `create`
   - **Location:** `/favoritos/fav_test_456`
   - **Authenticated:** ❌ **Não** (desmarque)

2. No campo "Data to write", cole:
   ```json
   {
     "userId": "user123",
     "tipo": "defensivo",
     "itemId": "def_456"
   }
   ```

3. Clique em **"Run"**
4. **Resultado esperado:** ❌ **Denied** (vermelho)

---

## 🚀 Após a Publicação

### **1. Teste no App**

```bash
# Nos 2 iPhones, faça um hot restart:
# Pressione: R (no terminal do flutter run)
# OU
# Stop e execute novamente:
flutter run
```

### **2. Teste de Sync em Tempo Real**

**iPhone 1:**
1. Abra o app → Defensivos
2. Marque "Abamectin 72 EC" como favorito ⭐
3. Observe o console:
   ```
   ✅ FavoritosSync: Create bem-sucedido: favorite_defensivo_abc123
   ```

**iPhone 2 (simultaneamente):**
1. Já esteja na tela de Favoritos
2. Veja o favorito aparecer **AUTOMATICAMENTE** (< 2 segundos)
3. Observe o console:
   ```
   ✅ SyncService: Item remoto mesclado com sucesso
   ```

### **3. Verifique no Firebase Console**

1. Firestore Database → Data
2. Veja a coleção `/favoritos` aparecer
3. Clique nela e veja os documentos criados:
   ```
   /favoritos/favorite_defensivo_abc123
     ├─ userId: "XYZ..."
     ├─ tipo: "defensivo"
     ├─ itemId: "abc123"
     ├─ itemData: {...}
     └─ adicionadoEm: Timestamp
   ```

---

## 🔧 Deployment via CLI (Alternativo)

Se preferir usar Firebase CLI:

```bash
# 1. Certifique-se de ter Firebase CLI instalado
firebase --version

# 2. Faça login (se necessário)
firebase login

# 3. Navegue até o diretório do projeto
cd /Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-receituagro

# 4. Deploy apenas das regras
firebase deploy --only firestore:rules

# 5. Aguarde confirmação
# ✅ Firestore rules released successfully
```

---

## ⚠️ Troubleshooting

### **Problema: "Permission denied" ao criar favorito**

**Causa:** Regras ainda não foram publicadas ou app não reiniciou

**Solução:**
1. Verifique se as regras foram publicadas (Firebase Console → Regras)
2. Faça **hot restart** no app (não apenas hot reload)
3. Verifique se o usuário está autenticado (`FirebaseAuth.instance.currentUser != null`)

### **Problema: Favorito não sincroniza entre dispositivos**

**Causa:** Realtime service não inicializou

**Solução:**
1. Verifique logs do console:
   ```
   ✅ ReceitaAgroRealtimeService inicializado
   ✅ Real-time sync ativado
   ```
2. Se não ver esses logs, faça rebuild do app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### **Problema: Dados aparecem no Firestore mas não sincronizam**

**Causa:** Listeners não estão ativos

**Solução:**
1. Verifique se `enableRealtimeSync: true` em `receituagro_sync_config.dart`
2. Verifique se `ReceitaAgroRealtimeService` está inicializado no `main.dart`
3. Force sync manual:
   ```dart
   await ReceitaAgroRealtimeService.instance.forceSync();
   ```

---

## 📊 Estrutura de Coleções

```
firestore/
├── favoritos/                ← NOVO (Sync ativo)
│   └── favorite_{tipo}_{id}
│       ├── userId: String
│       ├── tipo: String
│       ├── itemId: String
│       ├── itemData: Map
│       └── adicionadoEm: Timestamp
│
├── comentarios/              ← NOVO (Sync ativo)
│   └── comment_{id}
│       ├── userId: String
│       ├── titulo: String
│       ├── conteudo: String
│       ├── pkIdentificador: String
│       └── ferramenta: String
│
├── user_settings/            ← NOVO (Sync ativo)
│   └── settings_{id}
│       ├── userId: String
│       └── ... (configurações)
│
├── user_history/             ← NOVO (Sync ativo)
│   └── history_{id}
│       ├── userId: String
│       └── ... (histórico)
│
└── comments/                 ← LEGADO (Compatibilidade)
    └── {commentId}
        ├── userId: String
        └── ...
```

---

## ✅ Checklist de Deployment

- [ ] Regras copiadas do arquivo `firestore.rules`
- [ ] Regras coladas no Firebase Console
- [ ] Botão "Publicar" clicado
- [ ] Confirmação de publicação recebida
- [ ] Teste 1 (criar próprio) passou ✅
- [ ] Teste 2 (ler outro) bloqueou ❌
- [ ] Teste 3 (sem auth) bloqueou ❌
- [ ] Hot restart nos 2 iPhones
- [ ] Favorito sincronizou entre dispositivos
- [ ] Documentos aparecem no Firestore Console

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique logs do console Flutter
2. Verifique Firebase Console → Firestore → Usage → Errors
3. Consulte a documentação: https://firebase.google.com/docs/firestore/security/get-started

---

**Última atualização:** 2025-10-20
**Versão das regras:** 2.0 (Sync em Tempo Real)
