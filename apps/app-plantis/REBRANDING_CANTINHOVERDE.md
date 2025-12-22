# 🌱 Rebranding: Plantis → CantinhoVerde

## 📋 Resumo da Mudança

Renomeação completa da identidade visual do aplicativo de **Plantis** para **CantinhoVerde**.

**Novo Nome:** CantinhoVerde
**Tagline:** "Seu jardim de apartamento sempre vivo"

---

## ✅ O que foi alterado

### 1. **Textos Visíveis ao Usuário** (✅ SEGURO)

#### **Configuração do App**
- `pubspec.yaml` - Description atualizada
- `lib/app.dart` - Title do MaterialApp
- `lib/core/constants/app_constants.dart` - appName, appId
- `lib/core/constants/app_config.dart` - appName, description, companyName

#### **Páginas Legais e Promocionais**
- `lib/features/legal/presentation/pages/promotional_page.dart`
- `lib/features/legal/presentation/pages/privacy_policy_page.dart`
- `lib/features/legal/presentation/pages/terms_of_service_page.dart`
- `lib/features/legal/presentation/pages/cookies_policy_page.dart`
- `lib/features/legal/presentation/pages/account_deletion_page.dart`

#### **Widgets e Componentes**
- `lib/features/legal/presentation/widgets/web_legal_page_layout.dart`
  - Logo: "Cantinho" (bold) + "Verde" (emerald)
  - Copyright: "© 2025 CantinhoVerde"

- `lib/features/legal/presentation/widgets/promo_navigation_bar.dart`
  - Logo navigation bar

- `lib/features/legal/presentation/widgets/promo_header_section.dart`
- `lib/features/legal/presentation/widgets/promo_features_carousel.dart`
- `lib/features/legal/presentation/widgets/promo_call_to_action.dart`
- `lib/features/legal/presentation/builders/footer_section_builder.dart`

#### **Landing/Home**
- `lib/features/home/data/datasources/landing_content_datasource.dart`
- `lib/features/home/domain/entities/landing_content.dart`
- `lib/features/home/presentation/managers/landing_footer_builder.dart`

#### **Serviços**
- `lib/core/services/app_version_service.dart` - Fallback name
- `lib/core/services/plantis_notification_config.dart` - Descrições de notificações
- `lib/main.dart` - Analytics custom key

#### **Documentação**
- `README.md` - Todas as referências atualizadas

---

## ⚠️ O que NÃO foi alterado (Por Design)

### **Package Names e Identificadores** (Manter para compatibilidade)
- ✅ `name: app_plantis` (pubspec.yaml - package name)
- ✅ `br.com.agrimsolution.plantis` (Android package)
- ✅ Firebase Project ID: `plantis-72458`
- ✅ Nomes de classes técnicas: `PlantisDatabase`, `PlantisTheme`, etc.
- ✅ Nomes de arquivos: `plantis_*.dart`

**Por quê?** Alterar package names quebra:
- Updates existentes na loja
- Configurações Firebase
- Deep links
- Shared preferences
- Banco de dados local

---

## 🎨 Nova Identidade Visual

### **Logo Textual**
```
Cantinho (branco, bold) + Verde (emerald #10B981)
```

### **Cores Principais** (Mantidas)
- Primary: Emerald `#10B981`
- Secondary: Forest Green
- Background Dark: `#0A1F14`

### **Tagline**
"Seu jardim de apartamento sempre vivo"

### **Descrição Curta**
"Aplicativo para cuidado de plantas domésticas com lembretes inteligentes"

---

## 📊 Arquivos Modificados

### **Configuração** (2 arquivos)
- `pubspec.yaml`
- `README.md`

### **Core** (4 arquivos)
- `lib/app.dart`
- `lib/main.dart`
- `lib/core/constants/app_constants.dart`
- `lib/core/constants/app_config.dart`

### **Legal/Promo** (11 arquivos)
- `lib/features/legal/presentation/pages/*.dart` (4)
- `lib/features/legal/presentation/widgets/*.dart` (4)
- `lib/features/legal/presentation/builders/*.dart` (1)

### **Home** (3 arquivos)
- `lib/features/home/data/datasources/landing_content_datasource.dart`
- `lib/features/home/domain/entities/landing_content.dart`
- `lib/features/home/presentation/managers/landing_footer_builder.dart`

### **Services** (2 arquivos)
- `lib/core/services/app_version_service.dart`
- `lib/core/services/plantis_notification_config.dart`

**Total:** ~24 arquivos modificados

---

## ✅ Validação

```bash
cd apps/app-plantis
flutter analyze lib/ --no-preamble
# ✅ 0 errors, 0 warnings (apenas info lints)

flutter build web --release
# ✅ Build successful
```

---

## 🚀 Próximos Passos (Futuro)

### **Fase 2: Renomeação Técnica** (Opcional, Breaking Change)
Se decidir fazer major version (2.0.0):
- Renomear package: `app_plantis` → `app_cantinho_verde`
- Renomear classes: `PlantisDatabase` → `CantinhoVerdeDatabase`
- Renomear arquivos: `plantis_*.dart` → `cantinho_verde_*.dart`
- Atualizar imports em todo o monorepo

### **Fase 3: Novo Package Name** (Novo App)
Se quiser novo app nas lojas:
- Criar novo Firebase project
- Novo Android package: `br.com.agrimsolution.cantinhoverde`
- Novo iOS bundle: `br.com.agrimsolution.cantinhoverde`
- Submeter como novo app (perde reviews/downloads)

---

## 📱 Impacto para Usuários

### **Usuários Existentes**
- ✅ App continua funcionando normalmente
- ✅ Dados preservados
- ✅ Updates funcionam
- 🔄 Nome visível muda para "CantinhoVerde"

### **Novos Usuários**
- ✅ Veem "CantinhoVerde" em toda interface
- ✅ Identidade consistente
- ✅ Tagline clara e brasileira

---

## 🎯 Decisões de Design

### **Por que "CantinhoVerde"?**
- ✅ Identidade brasileira forte
- ✅ Afetivo e pessoal ("meu cantinho")
- ✅ Claro sobre contexto (apartamento)
- ✅ Memorável e único
- ✅ SEO-friendly

### **Por que manter package names?**
- ✅ Evita breaking changes
- ✅ Compatibilidade com updates
- ✅ Firebase já configurado
- ✅ Users não precisam reinstalar
- ✅ Foco na experiência do usuário

---

**Data:** 2025-12-21
**Status:** ✅ Completo e Validado
**Tipo de Mudança:** Non-Breaking (User-Facing Only)

