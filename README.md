# 🌱🚜 Monorepo Plantis & ReceitaAgro

Monorepo Flutter contendo seis aplicativos: **AgriHurbi**, **Gasometer**, **Petiveti**, **Plantis**, **ReceitaAgro**, e **ReceituAgro Web**, compartilhando uma infraestrutura comum através do package **Core**.

## 📱 Aplicativos

### 🌱 **Plantis** - Plantas Domésticas
- Registro de plantas de apartamento
- Gerenciamento de cuidados (rega, poda, fertilização)
- Sistema de tarefas e lembretes automáticos
- Histórico de cuidados e estatísticas

### 🚜 **ReceitaAgro** - Compêndio de Pragas
- Catálogo de pragas agrícolas brasileiras
- Diagnóstico de pragas por sintomas
- Cálculo de dosagens e receitas agronômicas
- Geração de PDFs técnicos

## 🏗️ Arquitetura

```
plantis_receituagro_monorepo/
├── apps/
│   ├── app-plantis/          # App Plantis (plantas domésticas)
│   └── app-receituagro/      # App ReceitaAgro (pragas agrícolas)
├── packages/
│   └── core/                 # Services compartilhados
├── tools/                    # Scripts utilitários
├── docs/                     # Documentação
└── melos.yaml               # Configuração do workspace
```

### 🔧 **Core Package - Infraestrutura Compartilhada**
- **Firebase**: Auth, Analytics, Storage, Crashlytics
- **RevenueCat**: Gerenciamento de assinaturas/IAP
- **Hive**: Storage local
- **Widgets Base**: Loading, Error, AppBar, Paywall
- **Environment Config**: Configuração de ambientes

## 🚀 Setup Rápido

### 1. Pré-requisitos
```bash
flutter --version  # >= 3.10.0
dart --version     # >= 3.7.2
```

### 2. Configuração Inicial
```bash
# Clonar e entrar no diretório
git clone <seu-repo>
cd plantis_receituagro_monorepo

# Instalar Melos
dart pub global activate melos

# Bootstrap do workspace
melos bootstrap
```

### 3. Configuração de Ambiente
```bash
# Copiar e configurar arquivo de ambiente
cp .env.example .env
# Edite .env com suas API keys do Firebase e RevenueCat
```

## 🔨 Comandos de Desenvolvimento

### Executar Apps
```bash
# Executar Plantis
melos run run:plantis

# Executar ReceitaAgro
melos run run:receituagro
```

### Desenvolvimento
```bash
# Análise de código
melos run analyze

# Formatação
melos run format

# Testes
melos run test

# Limpar workspace
melos clean
```

### Build para Produção
```bash
# Plantis
melos run build:plantis:android    # Play Store
melos run build:plantis:ios        # App Store

# ReceitaAgro
melos run build:receituagro:android # Play Store  
melos run build:receituagro:ios     # App Store
```

## 📦 Dependencies

### Core Package
- Firebase Suite (Auth, Analytics, Storage, Crashlytics)
- RevenueCat para subscriptions
- Hive para storage local
- GetIt + Injectable para DI
- Dartz para programação funcional

### Plantis Específicas
- Flutter Local Notifications (lembretes)
- Image Picker (fotos das plantas)
- Camera (integração com câmera)

### ReceitaAgro Específicas
- PDF (geração de receitas)
- QR Flutter (QR codes)
- Flutter HTML (conteúdo rico)

## 🌟 Features Implementadas

### ✅ **Fase 1: Setup Inicial**
- [x] Estrutura do monorepo criada
- [x] Melos configurado e funcionando
- [x] Flutter 3.35.0 configurado
- [x] Apps base criados
- [x] Environment config implementado

### ⏳ **Próximas Fases**
- [ ] Fase 2: Core Package (Firebase, RevenueCat, Hive)
- [ ] Fase 3: App Plantis (Gerenciamento plantas + tarefas)
- [ ] Fase 4: App ReceitaAgro (Catálogo pragas + receitas)
- [ ] Fase 5: Testes e integração
- [ ] Fase 6: Deploy para lojas

## 📊 Progresso do Desenvolvimento

Para acompanhar o progresso detalhado, consulte:
- [Documento de Desenvolvimento](flutter_monorepo_desenvolvimento.md)

## 🔐 Configuração de Secrets

### Firebase
1. Criar projetos no Firebase Console (dev/prod)
2. Baixar arquivos de configuração:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
3. Adicionar ao `.gitignore` (já configurado)

### RevenueCat
1. Criar conta e projetos no RevenueCat
2. Obter API keys para dev/prod
3. Configurar produtos de subscription
4. Adicionar keys no arquivo `.env`

## 🧪 Testes

```bash
# Executar todos os testes
melos run test

# Testar package específico
cd packages/core && flutter test

# Testar app específico
cd apps/app-plantis && flutter test
```

## 📚 Documentação

### Sistema de Gestão por Feature
Cada app possui documentação organizada por feature em `apps/{app}/docs/`:

| App | Features | Status |
|-----|----------|--------|
| [app-receituagro](apps/app-receituagro/docs/) | 19 | ✅ Completo |
| [app-plantis](apps/app-plantis/docs/) | 12 | ✅ Estrutura criada |
| [app-gasometer](apps/app-gasometer/docs/) | 21 | ✅ Estrutura criada |
| [app-nebulalist](apps/app-nebulalist/docs/) | 6 | ✅ Estrutura criada |
| [app-taskolist](apps/app-taskolist/docs/) | 6 | ✅ Estrutura criada |
| [app-petiveti](apps/app-petiveti/docs/) | 22 | ✅ Estrutura criada |
| [app-agrihurbi](apps/app-agrihurbi/docs/) | 11 | ✅ Estrutura criada |
| [app-calculei](apps/app-calculei/docs/) | 10 | ✅ Estrutura criada |
| [app-minigames](apps/app-minigames/docs/) | 28 | ✅ Estrutura criada |
| [web_receituagro](apps/web_receituagro/docs/) | 6 | ✅ Estrutura criada |

**Total: 141 features documentadas**

### Estrutura de Docs por App
```
apps/{app}/docs/
├── README.md          # Índice principal
├── STATUS.md          # Dashboard e métricas
├── features/          # Documentação por feature
│   ├── {feature}/
│   │   ├── README.md  # Regras de negócio
│   │   └── TASKS.md   # Backlog e histórico
├── backlog/           # Tarefas globais
└── guides/            # Guias de desenvolvimento
```

### Documentação Adicional
- [CLAUDE.md](CLAUDE.md) - Padrões e configurações do monorepo
- [Documento Original](flutter_monorepo_doc.md) - Análise arquitetural inicial
- [Documento de Desenvolvimento](flutter_monorepo_desenvolvimento.md) - Plano detalhado

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Comandos Úteis

```bash
# Verificar saúde do projeto
melos list

# Executar comando em todos os packages
melos exec "flutter pub get"

# Executar comando em package específico
melos exec --scope="core" "flutter analyze"

# Ver dependências
melos deps

# Bootstrap forçado
melos bootstrap --force
```

## 🚨 Troubleshooting

### Problema com Melos
```bash
# Limpar e rebootstrap
melos clean
melos bootstrap
```

### Problema com Dependencies
```bash
# Limpar caches
flutter clean
flutter pub cache clean
melos bootstrap
```

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

**Última Atualização:** Dezembro 2025  
**Status:** 🔄 Em Desenvolvimento - Migração Riverpod  
**Apps Documentados:** 10 apps, 141 features