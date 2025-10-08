# Configuração CORS para Firebase Storage - App Plantis

**Versão:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Produção

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Por que CORS é necessário?](#por-que-cors-é-necessário)
3. [Configuração Rápida](#configuração-rápida)
4. [Configuração Detalhada](#configuração-detalhada)
5. [Troubleshooting](#troubleshooting)
6. [Segurança](#segurança)

---

## 🎯 Visão Geral

Cross-Origin Resource Sharing (CORS) é necessário para permitir que a versão **web** do app Plantis faça upload e download de imagens do Firebase Storage.

### Quando configurar?

- ✅ **Obrigatório** se você vai rodar o app na web (`flutter run -d chrome`)
- ✅ **Obrigatório** para deploy em produção (hosting web)
- ⚠️ **Opcional** para apps mobile (iOS/Android não precisam de CORS)

### Sintomas de CORS não configurado

```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...'
from origin 'http://localhost:5000' has been blocked by CORS policy
```

---

## ⚡ Configuração Rápida

### Pré-requisitos

- Google Cloud SDK instalado: https://cloud.google.com/sdk/docs/install
- Autenticação configurada: `gcloud auth login`

### Passo 1: Criar arquivo cors.json

Crie um arquivo `cors.json` na raiz do projeto (`/apps/app-plantis/cors.json`):

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
```

**⚠️ Atenção:** Esta configuração permite **qualquer origem** (`"*"`). Veja [Segurança](#segurança) para restringir.

### Passo 2: Aplicar configuração

```bash
# Substituir YOUR_BUCKET_NAME pelo nome do seu bucket
# Geralmente: plantis-XXXXX.appspot.com

gsutil cors set cors.json gs://YOUR_BUCKET_NAME
```

**Exemplo:**

```bash
gsutil cors set cors.json gs://plantis-app-prod.appspot.com
```

### Passo 3: Verificar configuração

```bash
gsutil cors get gs://YOUR_BUCKET_NAME
```

**Saída esperada:**

```json
[
  {
    "maxAgeSeconds": 3600,
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "origin": ["*"],
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
```

---

## 🔧 Configuração Detalhada

### Encontrar o nome do bucket

**Opção 1: Firebase Console**

1. Acesse: https://console.firebase.google.com
2. Selecione projeto "Plantis"
3. Menu lateral → Storage
4. Nome aparece no topo: `gs://plantis-XXXXX.appspot.com`

**Opção 2: Código do app**

Verifique em `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  // ...
  storageBucket: 'plantis-XXXXX.appspot.com', // ← Este é o nome
);
```

### Configuração de Produção (Restrita)

Para ambiente de produção, **restrinja as origens**:

```json
[
  {
    "origin": [
      "https://plantis.app",
      "https://www.plantis.app",
      "http://localhost:5000",
      "http://localhost:8080"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
```

**Explicação:**

- `origin`: Lista de domínios permitidos
  - `https://plantis.app` - Domínio principal
  - `https://www.plantis.app` - Subdomínio www
  - `http://localhost:*` - Desenvolvimento local
- `method`: Métodos HTTP permitidos
  - `GET` - Download de imagens
  - `POST`, `PUT` - Upload de imagens
  - `DELETE` - Remoção de imagens
  - `HEAD` - Verificação de existência
- `maxAgeSeconds`: Cache do preflight (1 hora = 3600s)
- `responseHeader`: Headers que o browser pode acessar

### Configuração por Ambiente

**Desenvolvimento:**

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 300
  }
]
```

**Staging:**

```json
[
  {
    "origin": [
      "https://staging.plantis.app",
      "http://localhost:5000"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 1800
  }
]
```

**Produção:**

```json
[
  {
    "origin": [
      "https://plantis.app",
      "https://www.plantis.app"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD"],
    "maxAgeSeconds": 3600
  }
]
```

---

## 🐛 Troubleshooting

### Erro: "gsutil: command not found"

**Solução:** Instalar Google Cloud SDK

```bash
# macOS (Homebrew)
brew install --cask google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash

# Windows
# Baixar instalador: https://cloud.google.com/sdk/docs/install
```

Após instalação:

```bash
gcloud init
gcloud auth login
```

### Erro: "Access Denied"

**Solução:** Autenticar com conta que tem permissões no projeto Firebase

```bash
gcloud auth login

# Selecionar projeto correto
gcloud config set project plantis-XXXXX
```

### Erro: "CORS policy" ainda aparece após configurar

**Possíveis causas:**

1. **Cache do browser** - Limpar cache ou usar aba anônima
2. **Configuração não aplicada** - Verificar com `gsutil cors get`
3. **Bucket errado** - Verificar nome do bucket
4. **Origem não permitida** - Adicionar origem específica

**Verificação passo a passo:**

```bash
# 1. Confirmar bucket correto
gsutil ls

# 2. Verificar CORS aplicado
gsutil cors get gs://YOUR_BUCKET_NAME

# 3. Limpar cache do browser (Chrome)
# DevTools → Application → Storage → Clear site data

# 4. Testar novamente
```

### Upload funciona no mobile mas não no web

**Causa:** CORS não está configurado (mobile não precisa de CORS)

**Solução:** Aplicar configuração CORS conforme [Configuração Rápida](#configuração-rápida)

---

## 🔒 Segurança

### ⚠️ Não use "*" em produção

A configuração `"origin": ["*"]` permite **qualquer site** fazer upload/download.

**Riscos:**

- ❌ Sites maliciosos podem fazer upload de arquivos
- ❌ Vazamento de URLs privadas
- ❌ Custo excessivo de bandwidth

### ✅ Melhores práticas

1. **Liste domínios específicos:**

```json
{
  "origin": ["https://plantis.app", "https://www.plantis.app"]
}
```

2. **Combine com Firebase Security Rules:**

```javascript
// firestore.rules ou storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /plants/{plantId}/{allPaths=**} {
      // Apenas usuários autenticados
      allow read, write: if request.auth != null;

      // Validar tamanho do arquivo (10MB)
      allow write: if request.resource.size < 10 * 1024 * 1024;

      // Validar tipo de conteúdo
      allow write: if request.resource.contentType.matches('image/.*');
    }
  }
}
```

3. **Rate limiting** (recomendado para produção):

```javascript
// Cloud Function para limitar uploads por usuário
exports.rateLimit = functions.storage.object().onFinalize(async (object) => {
  const userId = object.metadata?.userId;
  const uploads = await getRecentUploads(userId);

  if (uploads.length > 10) {
    await deleteFile(object.name);
    throw new Error('Rate limit exceeded');
  }
});
```

### Configuração Segura Completa

**cors.json (Produção):**

```json
[
  {
    "origin": ["https://plantis.app", "https://www.plantis.app"],
    "method": ["GET", "HEAD"],
    "maxAgeSeconds": 3600
  },
  {
    "origin": ["https://plantis.app"],
    "method": ["POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type"]
  }
]
```

**storage.rules:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /plants/{userId}/{plantId}/{imageId} {
      // Apenas dono da planta pode fazer upload
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024
                   && request.resource.contentType.matches('image/(jpeg|png|webp)');

      // Qualquer usuário autenticado pode visualizar
      allow read: if request.auth != null;
    }
  }
}
```

---

## 📚 Referências

### Documentação Oficial

- [Firebase Storage CORS](https://firebase.google.com/docs/storage/web/download-files#cors_configuration)
- [Google Cloud CORS](https://cloud.google.com/storage/docs/configuring-cors)
- [CORS Specification](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

### Comandos úteis

```bash
# Listar buckets do projeto
gsutil ls

# Ver configuração CORS atual
gsutil cors get gs://YOUR_BUCKET_NAME

# Aplicar configuração CORS
gsutil cors set cors.json gs://YOUR_BUCKET_NAME

# Remover configuração CORS
gsutil cors set /dev/null gs://YOUR_BUCKET_NAME

# Verificar permissões
gsutil iam get gs://YOUR_BUCKET_NAME
```

### Script de automação (opcional)

Criar `scripts/setup-cors.sh`:

```bash
#!/bin/bash

# Configuração CORS automática para Firebase Storage
# Uso: ./scripts/setup-cors.sh [dev|staging|prod]

ENV=${1:-dev}
PROJECT_ID="plantis-app-${ENV}"
BUCKET_NAME="${PROJECT_ID}.appspot.com"

echo "🔧 Configurando CORS para ${ENV}..."
echo "📦 Bucket: gs://${BUCKET_NAME}"

# Selecionar projeto
gcloud config set project "${PROJECT_ID}"

# Aplicar CORS
gsutil cors set "cors-${ENV}.json" "gs://${BUCKET_NAME}"

# Verificar
echo "✅ Verificando configuração..."
gsutil cors get "gs://${BUCKET_NAME}"

echo "✅ CORS configurado com sucesso!"
```

Uso:

```bash
chmod +x scripts/setup-cors.sh
./scripts/setup-cors.sh dev
./scripts/setup-cors.sh prod
```

---

**Documento Vivo:** Este documento será atualizado conforme necessário.
**Última Atualização:** 07/10/2025
**Próxima Revisão:** 14/10/2025
**Responsável:** Time Plantis
