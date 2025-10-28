# Firebase Deploy Guide - app-taskolist

Guia completo para fazer deploy das Firestore Rules e configurações no Firebase.

## 🚀 Quick Start

Se você já tem Firebase configurado:

```bash
# 1. Instale Firebase CLI (se não tiver)
npm install -g firebase-tools

# 2. Faça login no Firebase
firebase login

# 3. Inicialize o projeto Firebase (na raiz do monorepo ou no app)
firebase init firestore

# 4. Deploy das regras
firebase deploy --only firestore:rules
```

## 📦 Pré-requisitos

### Software Necessário

```bash
# Node.js (v14 ou superior)
node --version

# NPM (vem com Node.js)
npm --version

# Firebase CLI
npm install -g firebase-tools
firebase --version
```

### Permissões Necessárias

- Acesso ao projeto Firebase (Editor ou Admin)
- Acesso ao Google Cloud Console
- Conta Google associada ao projeto Firebase

## 🔧 Configuração do Projeto

### 1. Inicializar Firebase no Seu Projeto

```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-taskolist

# Iniciar Firebase (cria firebase.json e .firebaserc)
firebase init
```

Durante a inicialização, escolha:
- **Which Firebase features do you want to set up?** → Firestore
- **Which project do you want to use?** → Seu projeto
- **What file should be used for Firestore Rules?** → `firebase_firestore.rules`
- **What file should be used for Firestore indexes?** → `firestore.indexes.json` (ou padrão)

### 2. Estrutura de Diretórios Esperada

```
app-taskolist/
├── firebase.json                    # Configuração Firebase
├── .firebaserc                      # Dados do projeto
├── firebase_firestore.rules         # Regras de segurança
├── firestore.indexes.json          # Índices do Firestore
└── ...
```

## 📋 Arquivo firebase.json

Crie/atualize o arquivo `firebase.json`:

```json
{
  "firestore": {
    "rules": "firebase_firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

## 📋 Arquivo .firebaserc

Crie/atualize o arquivo `.firebaserc`:

```json
{
  "projects": {
    "default": "seu-projeto-id"
  }
}
```

Substitua `seu-projeto-id` pelo ID real do seu projeto Firebase.

## 🔐 Autenticação com Firebase CLI

### Login com Google

```bash
# Primeiro login (abre navegador)
firebase login

# Verificar login atual
firebase auth:list

# Se tiver múltiplas contas, usar uma específica
firebase login:use seu-email@gmail.com
```

### Login com Token (CI/CD)

Para ambientes automatizados (GitHub Actions, etc):

```bash
# Gerar token
firebase login:ci

# Usar token
firebase deploy --token seu_token_aqui
```

## 🚀 Deploy das Regras

### Opção 1: Deploy Completo

```bash
# Deploy de todas as configurações
firebase deploy
```

### Opção 2: Deploy Apenas de Regras

```bash
# Deploy apenas das Firestore Rules
firebase deploy --only firestore:rules
```

### Opção 3: Deploy Apenas de Índices

```bash
# Deploy apenas dos índices Firestore
firebase deploy --only firestore:indexes
```

### Verificar Status do Deploy

```bash
# Ver histórico de deploys
firebase firestore:delete

# Ver regras atuais
firebase firestore:describe-rules
```

## 🧪 Testar Antes de Fazer Deploy

### 1. Usar Firestore Emulator

```bash
# Instalar Firestore Emulator
npm install -g @firebase/cli

# Iniciar emulator
firebase emulators:start

# Seu app conectará em: localhost:8080
```

### 2. Validar Sintaxe das Regras

```bash
# Validar arquivo de regras
firebase firestore:describe-rules --project seu-projeto-id
```

### 3. Testar Regras Localmente

```dart
// No seu código Flutter, conecte ao emulator em development:
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  if (kDebugMode) {
    // Conectar ao emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  runApp(const MyApp());
}
```

## 📊 Arquivo firestore.indexes.json

Para consultas complexas, você pode precisar criar índices. Exemplo:

```json
{
  "indexes": [
    {
      "collectionGroup": "task_lists",
      "queryScope": "Collection",
      "fields": [
        {"fieldPath": "ownerId", "order": "Ascending"},
        {"fieldPath": "createdAt", "order": "Descending"}
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "Collection",
      "fields": [
        {"fieldPath": "listId", "order": "Ascending"},
        {"fieldPath": "status", "order": "Ascending"},
        {"fieldPath": "createdAt", "order": "Descending"}
      ]
    }
  ],
  "fieldOverrides": []
}
```

**Nota**: O Firebase Console criará índices automaticamente quando você fizer suas primeiras consultas. Você pode exportá-los depois.

## 🔄 Workflow de Deploy Recomendado

### 1. Desenvolvimento Local

```bash
# Inicie o emulator
firebase emulators:start

# Teste suas mudanças localmente
# Rode seus testes/app
```

### 2. Validação

```bash
# Verifique a sintaxe das regras
firebase deploy --dry-run
```

### 3. Deploy para Staging (Opcional)

Se tiver um projeto Firebase de staging:

```bash
firebase deploy --project seu-projeto-staging
```

### 4. Deploy para Produção

```bash
# Deploy final
firebase deploy --only firestore:rules

# Verifique o deploy
firebase firestore:describe-rules
```

## 📱 Integração com CI/CD (GitHub Actions)

### Exemplo: GitHub Actions Workflow

Crie `.github/workflows/firebase-deploy.yml`:

```yaml
name: Firebase Deploy

on:
  push:
    branches:
      - main
    paths:
      - 'apps/app-taskolist/firebase_firestore.rules'
      - 'apps/app-taskolist/firestore.indexes.json'
      - '.github/workflows/firebase-deploy.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Deploy Firestore Rules
        run: |
          cd apps/app-taskolist
          firebase deploy --only firestore:rules --token ${{ secrets.FIREBASE_TOKEN }}
```

Para usar isso:

1. Gere um token: `firebase login:ci`
2. Adicione como secret no GitHub: Settings → Secrets → `FIREBASE_TOKEN`

## 🆘 Troubleshooting

### Erro: "Permission denied"

```bash
# Verifique permissões do projeto
firebase projects:list

# Verifique se está no projeto correto
cat .firebaserc
```

### Erro: "Invalid rules"

```bash
# Valide a sintaxe
firebase deploy --dry-run

# Veja erros mais detalhados
firebase deploy --debug
```

### Erro: "Authentication required"

```bash
# Faça login novamente
firebase logout
firebase login

# Ou use token
firebase login:ci
```

### Emulator não inicia

```bash
# Verifique portas em uso
lsof -i :8080
lsof -i :9099

# Mate processos se necessário
kill -9 <PID>

# Inicie novamente
firebase emulators:start --import=./emulator-data
```

## 📚 Comandos Úteis

```bash
# Listar todos os projetos Firebase
firebase projects:list

# Descrever regras atuais
firebase firestore:describe-rules

# Exportar dados
firebase firestore:export ./backup

# Importar dados
firebase firestore:import ./backup

# Deletar dados (CUIDADO!)
firebase firestore:delete --recursive

# Ver logs do emulator
firebase emulators:start --inspect-functions

# Parar emulators
firebase emulators:stop
```

## ✅ Checklist de Deploy

- [ ] Testes locais passam com emulator
- [ ] Regras validadas com `firebase deploy --dry-run`
- [ ] Índices criados (se necessário)
- [ ] Dados de teste importados (se aplicável)
- [ ] Backup feito antes de deploy
- [ ] Token/credenciais estão seguros (não commitadas)
- [ ] Cronograma de deploy aprovado
- [ ] Plano de rollback preparado

## 🔄 Rollback de Regras

Se algo der errado após o deploy:

```bash
# Ver histórico
firebase firestore:describe-rules

# Reverter para versão anterior (manual)
# 1. Abra Firebase Console
# 2. Vá para Firestore → Rules
# 3. Clique em "History"
# 4. Selecione versão anterior
# 5. Publish
```

Ou via código:

```bash
# Reverter arquivo e redeploy
git checkout firebase_firestore.rules
firebase deploy --only firestore:rules
```

## 📖 Referências

- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Firestore Rules Documentation](https://firebase.google.com/docs/firestore/security/start)
- [Firestore Emulator Guide](https://firebase.google.com/docs/emulator-suite)
- [GitHub Actions Firebase Deploy](https://github.com/FirebaseExtended/action-hosting-deploy)

---

**Suporte**: Para dúvidas, consulte a documentação oficial do Firebase ou entre em contato com o time de DevOps.
