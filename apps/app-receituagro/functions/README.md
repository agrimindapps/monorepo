# ReceitaAgro Cloud Functions - Sprint 3

Este diretório contém as Cloud Functions do Firebase para sincronização avançada do ReceitaAgro.

## 🏗️ Estrutura das Functions

### **1. Device Management Functions**
- `validateDevice` - Valida e registra dispositivos (limite de 3 por usuário)
- `revokeDevice` - Remove acesso de dispositivo específico
- `cleanupOldSessions` - Limpeza automática de sessões antigas (cron diário)

### **2. Subscription Webhook Functions**
- `revenuecatWebhook` - Processa webhooks do RevenueCat
- `syncSubscriptionStatus` - Sincronização manual de assinaturas

### **3. Data Sync Functions**
- `syncUserData` - Sincronização bidirecional de dados
- `batchSyncUserData` - Sincronização em lote para grandes volumes
- `resolveConflicts` - Sistema avançado de resolução de conflitos

## 🚀 Deployment

### **Pré-requisitos**
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login no Firebase
firebase login

# Instalar dependências
cd functions
npm install
```

### **Configuração**
```bash
# Inicializar projeto Firebase (se necessário)
firebase init functions

# Selecionar projeto
firebase use <project-id>

# Configurar variáveis de ambiente
firebase functions:config:set revenuecat.webhook_secret="YOUR_WEBHOOK_SECRET"
firebase functions:config:set app.max_devices="3"
```

### **Build e Deploy**
```bash
# Build TypeScript
npm run build

# Deploy todas as functions
npm run deploy

# Deploy function específica
firebase deploy --only functions:validateDevice

# Deploy com debug
firebase deploy --only functions --debug
```

### **Deploy Escalonado (Recomendado)**
```bash
# 1. Deploy device management primeiro
firebase deploy --only functions:validateDevice,functions:revokeDevice

# 2. Deploy subscription functions
firebase deploy --only functions:revenuecatWebhook,functions:syncSubscriptionStatus  

# 3. Deploy data sync functions
firebase deploy --only functions:syncUserData,functions:batchSyncUserData,functions:resolveConflicts

# 4. Deploy cleanup function (cron)
firebase deploy --only functions:cleanupOldSessions
```

## 🔧 Configuração Firebase

### **Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Device subcollection
      match /devices/{deviceId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Sync queue (apenas functions podem escrever)
    match /sync_queue/{docId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false; // Apenas Cloud Functions
    }
    
    // Conflict resolution
    match /sync_conflicts/{docId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### **Firebase Functions Configuration**
```json
{
  "functions": {
    "source": "functions",
    "runtime": "nodejs18",
    "memory": "512MB",
    "timeout": "60s"
  }
}
```

### **Environment Variables**
```bash
# RevenueCat Configuration
firebase functions:config:set revenuecat.api_key="rc_..."
firebase functions:config:set revenuecat.webhook_secret="..."

# App Configuration  
firebase functions:config:set app.max_devices="3"
firebase functions:config:set app.max_conflicts_per_user="10"
firebase functions:config:set app.cleanup_days="30"

# Sync Configuration
firebase functions:config:set sync.batch_size="500"
firebase functions:config:set sync.timeout_seconds="30"
firebase functions:config:set sync.max_retries="3"
```

## 🧪 Testing

### **Emulador Local**
```bash
# Iniciar emuladores
firebase emulators:start --only functions,firestore

# URL do emulador
# Functions: http://localhost:5001/PROJECT_ID/us-central1/FUNCTION_NAME
# Firestore: http://localhost:8080
```

### **Teste de Functions**
```bash
# Teste de device validation
curl -X POST \
  http://localhost:5001/PROJECT_ID/us-central1/validateDevice \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "deviceUuid": "test-device-123",
    "deviceInfo": {
      "name": "iPhone Test",
      "platform": "ios",
      "model": "iPhone 14",
      "appVersion": "1.0.0"
    }
  }'

# Teste de webhook RevenueCat
curl -X POST \
  http://localhost:5001/PROJECT_ID/us-central1/revenuecatWebhook \
  -H "Content-Type: application/json" \
  -d '{
    "api_version": "1.0",
    "event": {
      "type": "INITIAL_PURCHASE",
      "app_user_id": "test_user",
      "product_id": "premium_monthly",
      "purchased_at_ms": 1699123456789,
      "store": "app_store"
    }
  }'
```

## 📊 Monitoring

### **Firebase Console**
- Functions Logs: https://console.firebase.google.com/project/PROJECT_ID/functions/logs
- Performance: https://console.firebase.google.com/project/PROJECT_ID/functions/usage
- Firestore: https://console.firebase.google.com/project/PROJECT_ID/firestore

### **Alertas Recomendados**
```bash
# Criar alertas para:
# - Error rate > 5%
# - Function timeout > 80% dos casos
# - Memory usage > 80%
# - Cold start latency > 3s
```

### **Custom Metrics**
```javascript
// Exemplo de custom metric no código da function
const { increment } = require('@google-cloud/monitoring');

// Incrementar métrica customizada
await increment('sync_operations_total', {
  operation_type: 'device_validation',
  success: true
});
```

## 🔐 Security

### **Webhook Security**
```javascript
// Validação de webhook signature
const crypto = require('crypto');

function validateWebhookSignature(payload, signature, secret) {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex');
  
  return crypto.timingSafeEqual(
    Buffer.from(signature, 'hex'),
    Buffer.from(expectedSignature, 'hex')
  );
}
```

### **CORS Configuration**
```javascript
const cors = require('cors')({
  origin: [
    'https://your-domain.com',
    /\.your-domain\.com$/
  ],
  credentials: true
});
```

## 🚨 Troubleshooting

### **Erros Comuns**

**1. "Function deployment failed"**
```bash
# Verificar logs
firebase functions:log --only validateDevice

# Verificar quota
firebase projects:list
```

**2. "CORS errors"**
```javascript
// Adicionar CORS middleware
const cors = require('cors')({ origin: true });
exports.myFunction = functions.https.onRequest((req, res) => {
  return cors(req, res, () => {
    // Function logic here
  });
});
```

**3. "Cold start timeouts"**
```javascript
// Configurar keep-alive
exports.myFunction = functions
  .runWith({ 
    memory: '1GB',
    timeoutSeconds: 60,
    minInstances: 1 // Evita cold starts
  })
  .https.onRequest(handler);
```

### **Performance Tips**

**1. Otimizar Cold Starts**
```javascript
// Lazy loading de dependências
let admin;
const getAdmin = () => {
  if (!admin) {
    admin = require('firebase-admin');
    admin.initializeApp();
  }
  return admin;
};
```

**2. Connection Pooling**
```javascript
// Reutilizar conexões Firestore
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// Configurar pool de conexões
db.settings({
  cacheSizeBytes: 40000000, // 40 MB
  merge: true
});
```

**3. Batch Operations**
```javascript
// Usar batch writes quando possível
const batch = db.batch();
operations.forEach(op => {
  batch.set(db.collection('users').doc(op.id), op.data);
});
await batch.commit();
```

## 📈 Monitoring Dashboard

### **Key Metrics**
- Device registration rate
- Sync operation latency
- Conflict resolution rate  
- Webhook processing time
- Error rates por function

### **Grafana Queries** (se usando)
```promql
# Function invocation rate
firebase_functions_invocations_total{function_name="validateDevice"}

# Error rate
rate(firebase_functions_invocations_total{status!="ok"}[5m])

# P95 latency
histogram_quantile(0.95, firebase_functions_duration_seconds_bucket)
```

## 🔄 Maintenance

### **Updates**
```bash
# Update dependencies
npm update

# Security audit
npm audit

# Deploy with staging
firebase deploy --only functions --project staging
firebase deploy --only functions --project production
```

### **Rollback**
```bash
# Rollback específico
firebase functions:delete functionName --force
firebase deploy --only functions:functionName

# Rollback completo (se necessário)
git checkout PREVIOUS_COMMIT
firebase deploy --only functions
```

## 📚 Resources

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [RevenueCat Webhooks](https://docs.revenuecat.com/docs/webhooks)  
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [TypeScript Support](https://firebase.google.com/docs/functions/typescript)