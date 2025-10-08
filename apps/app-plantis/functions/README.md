# Cloud Functions - App Plantis

Cloud Functions para gerenciamento server-side do app-plantis.

## 📋 Funções Implementadas

### 1. cleanOrphanImages (GAP-003)
**Tipo:** Scheduled (Pub/Sub)
**Schedule:** Diariamente às 2h AM (horário de Brasília)
**Timeout:** 9 minutos
**Memory:** 512MB

**Descrição:**
Limpa imagens órfãs do Firebase Storage que não estão mais associadas a nenhuma planta.

**Critérios:**
- Imagem existe na pasta `plants/`
- URL não está em nenhum documento de planta (collectionGroup query)
- Imagem tem mais de 7 dias (evita deletar uploads em progresso)

**Logs:**
- Salva resumo em `system_logs` collection
- Inclui: total processado, deletadas, ignoradas, erros

**Exemplo de log:**
```javascript
{
  type: "image_cleanup",
  timestamp: Timestamp,
  summary: {
    totalProcessed: 150,
    deleted: 12,
    skipped: 138,
    errors: 0
  },
  details: {
    deleted: ["plants/abc/image1.jpg", ...],
    skipped: ["plants/def/image2.jpg", ...],
    errors: []
  }
}
```

---

### 2. validateImageUpload (GAP-006)
**Tipo:** Storage Trigger (onFinalize)
**Trigger:** Após upload no Firebase Storage
**Memory:** 256MB

**Descrição:**
Valida uploads de imagem server-side e deleta arquivos inválidos automaticamente.

**Validações:**
- ✅ Content Type: apenas `image/jpeg`, `image/png`, `image/webp`
- ✅ Tamanho: máximo 10MB
- ✅ Extensão: `.jpg`, `.jpeg`, `.png`, `.webp`

**Comportamento:**
- Se **válido**: permite upload
- Se **inválido**: deleta arquivo + lança erro + log em `security_logs`

**Exemplo de log (bloqueio):**
```javascript
{
  type: "invalid_upload_blocked",
  timestamp: Timestamp,
  filePath: "plants/xyz/malicious.exe",
  contentType: "application/x-msdownload",
  size: 5242880,
  errors: [
    "Invalid content type: application/x-msdownload",
    "Invalid extension: .exe"
  ]
}
```

---

### 3. checkUploadRateLimit
**Tipo:** Callable (HTTPS)
**Memory:** 128MB

**Descrição:**
Rate limiting de uploads por usuário (10 uploads/minuto).

**Uso no cliente:**
```dart
// Chamar antes de fazer upload
final callable = FirebaseFunctions.instance.httpsCallable('checkUploadRateLimit');
try {
  final result = await callable.call();
  final remaining = result.data['remaining']; // Uploads restantes

  // Prosseguir com upload
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'resource-exhausted') {
    // Mostrar erro: "Muitos uploads, aguarde"
  }
}
```

**Resposta (sucesso):**
```json
{
  "allowed": true,
  "remaining": 7
}
```

**Resposta (limite excedido):**
```
FirebaseFunctionsException: resource-exhausted
Message: "Too many uploads. Limit: 10 per minute. Please wait."
```

---

### 4. cleanOldLogs
**Tipo:** Scheduled (Pub/Sub)
**Schedule:** Domingos às 3h AM
**Timeout:** 5 minutos
**Memory:** 256MB

**Descrição:**
Limpeza de logs antigos (mais de 30 dias) da collection `upload_logs`.

**Batch:** 500 documentos por execução

---

## 🚀 Setup Local

### 1. Instalar dependências

```bash
cd functions
npm install
```

### 2. Compilar TypeScript

```bash
npm run build
```

### 3. Rodar localmente (Emuladores)

```bash
# Terminal 1: Iniciar emuladores
firebase emulators:start

# Terminal 2: Testar funções
npm run shell
```

**Testar cleanOrphanImages:**
```javascript
cleanOrphanImages({})
```

**Testar checkUploadRateLimit:**
```javascript
checkUploadRateLimit({}, {auth: {uid: 'test-user-123'}})
```

---

## 📦 Deploy

### Deploy de todas as funções

```bash
firebase deploy --only functions
```

### Deploy de função específica

```bash
firebase deploy --only functions:cleanOrphanImages
firebase deploy --only functions:validateImageUpload
```

### Deploy com projeto específico

```bash
firebase use production
firebase deploy --only functions
```

---

## 🧪 Testes

### Testar limpeza de órfãs (manual)

1. Fazer upload de imagem no Storage
2. **NÃO** adicionar URL em nenhuma planta
3. Aguardar 7 dias (ou mudar lógica temporariamente)
4. Executar função manualmente:

```bash
# Via emulador
npm run shell
> cleanOrphanImages({})

# Via Firebase Console
# Functions → cleanOrphanImages → Testing → Run
```

### Testar validação de upload

```bash
# Upload válido
gsutil cp valid_image.jpg gs://your-bucket/plants/test/image.jpg

# Upload inválido (será deletado)
gsutil cp malicious.exe gs://your-bucket/plants/test/file.exe
```

### Testar rate limiting

```dart
// Em um loop, chamar 11 vezes
for (int i = 0; i < 11; i++) {
  try {
    final result = await callable.call();
    print('Upload $i: OK (${result.data['remaining']} remaining)');
  } catch (e) {
    print('Upload $i: BLOCKED - $e');
  }
}
```

---

## 📊 Monitoramento

### Logs em tempo real

```bash
firebase functions:log
```

### Logs de função específica

```bash
firebase functions:log --only cleanOrphanImages
```

### Firebase Console

1. Acesse: https://console.firebase.google.com
2. Functions → Logs
3. Filtrar por função ou erro

---

## ⚙️ Configuração de Ambiente

### Variáveis de ambiente (se necessário)

```bash
firebase functions:config:set cleanup.max_age_days=7
firebase functions:config:set ratelimit.max_per_minute=10
```

**Uso no código:**
```typescript
const maxAgeDays = functions.config().cleanup?.max_age_days || 7;
```

---

## 🔒 Segurança

### Firestore Security Rules

Adicionar em `firestore.rules`:

```javascript
// Apenas Cloud Functions podem escrever em system_logs
match /system_logs/{logId} {
  allow read: if request.auth != null && request.auth.token.admin == true;
  allow write: if false; // Apenas via Cloud Functions
}

// Apenas Cloud Functions podem escrever em security_logs
match /security_logs/{logId} {
  allow read: if request.auth != null && request.auth.token.admin == true;
  allow write: if false;
}

// upload_logs é gerenciado por Cloud Functions
match /upload_logs/{logId} {
  allow read, write: if false; // Apenas Cloud Functions
}
```

### Storage Security Rules

Adicionar em `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /plants/{userId}/{plantId}/{imageId} {
      // Validações básicas (Cloud Function faz validação completa)
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 15 * 1024 * 1024; // 15MB margem

      allow read: if request.auth != null;
    }
  }
}
```

---

## 📈 Custos

### Estimativa mensal (uso moderado)

**cleanOrphanImages:**
- Execuções: 30/mês (diário)
- Duração média: 30s
- Custo: ~$0.01

**validateImageUpload:**
- Execuções: ~1000/mês (uploads)
- Duração média: 100ms
- Custo: ~$0.05

**checkUploadRateLimit:**
- Execuções: ~1000/mês
- Duração média: 50ms
- Custo: ~$0.02

**cleanOldLogs:**
- Execuções: 4/mês (semanal)
- Duração média: 10s
- Custo: ~$0.001

**Total estimado: ~$0.08/mês** (bem abaixo do free tier)

---

## 🐛 Troubleshooting

### Erro: "Cannot find module 'firebase-admin'"

```bash
cd functions
npm install
```

### Erro: "tsc not found"

```bash
npm install -g typescript
# ou
npm install --save-dev typescript
```

### Erro: "Permission denied" no deploy

```bash
firebase login
firebase use --add
```

### Função não executa no schedule

1. Verificar timezone: `America/Sao_Paulo`
2. Verificar formato cron: `0 2 * * *`
3. Logs: `firebase functions:log --only cleanOrphanImages`

---

## 📚 Referências

- [Firebase Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Scheduled Functions](https://firebase.google.com/docs/functions/schedule-functions)
- [Storage Triggers](https://firebase.google.com/docs/functions/gcp-storage-events)
- [Callable Functions](https://firebase.google.com/docs/functions/callable)

---

**Versão:** 1.0
**Data:** 07/10/2025
**Responsável:** Time Plantis
