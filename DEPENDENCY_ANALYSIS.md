# 📊 Análise de Dependências - Monorepo Flutter

**Data da análise:** 2026-01-15  
**Objetivo:** Identificar dependências duplicadas entre apps e o package `core`

---

## 🎯 Sumário Executivo

- **Total de duplicações:** 204
- **Pacotes únicos duplicados:** 46
- **Apps analisados:** 13
- **Média de duplicações por app:** 15.7

---

## 📱 Dependências por App

### 1. **app-gasometer** (21 duplicações)
- cloud_firestore, dartz, drift, equatable, firebase_auth
- firebase_storage, flutter_riverpod, flutter_secure_storage
- flutter_staggered_grid_view, freezed_annotation, go_router
- image, image_picker, intl, path, path_provider
- permission_handler, riverpod_annotation, rxdart
- shared_preferences, uuid

### 2. **app-nutrituti** (26 duplicações)
- cloud_firestore, connectivity_plus, cupertino_icons, dartz
- drift, equatable, firebase_auth, firebase_core, fl_chart
- flutter_local_notifications, flutter_riverpod
- flutter_staggered_grid_view, freezed_annotation, go_router
- icons_plus, intl, logger, purchases_flutter
- riverpod_annotation, share_plus, shared_preferences
- skeletonizer, supabase_flutter, timezone, url_launcher, uuid

### 3. **web_receituagro** (19 duplicações)
- cloud_firestore, cupertino_icons, dartz, device_info_plus
- equatable, firebase_analytics, firebase_core, flutter_riverpod
- flutter_staggered_grid_view, go_router, icons_plus, intl
- package_info_plus, riverpod_annotation, shared_preferences
- skeletonizer, supabase_flutter, url_launcher, uuid

### 4. **app-petiveti** (18 duplicações)
- cloud_firestore, connectivity_plus, dartz, drift
- firebase_auth, firebase_core, flutter_local_notifications
- flutter_riverpod, freezed_annotation, go_router
- google_sign_in, intl, package_info_plus, permission_handler
- riverpod_annotation, shared_preferences, timezone, url_launcher

### 5. **app-receituagro** (17 duplicações)
- cloud_firestore, dartz, drift, equatable, firebase_auth
- firebase_messaging, firebase_remote_config
- flutter_local_notifications, flutter_riverpod, flutter_tts
- freezed_annotation, go_router, package_info_plus
- riverpod_annotation, share_plus, shared_preferences, url_launcher

### 6. **app-termostecnicos** (17 duplicações)
- cupertino_icons, dartz, drift, equatable, firebase_core
- flutter_riverpod, flutter_staggered_grid_view, flutter_tts
- go_router, google_mobile_ads, icons_plus, intl
- purchases_flutter, riverpod_annotation, share_plus
- shared_preferences, url_launcher

### 7. **app-minigames** (16 duplicações)
- cloud_firestore, crypto, dartz, equatable, firebase_analytics
- firebase_auth, firebase_core, flutter_riverpod
- flutter_staggered_grid_view, go_router, icons_plus, logger
- riverpod_annotation, shared_preferences, url_launcher, uuid

### 8. **app-plantis** (15 duplicações)
- cloud_firestore, dartz, drift, equatable, firebase_auth
- flutter_riverpod, flutter_staggered_grid_view
- freezed_annotation, go_router, image_picker, intl
- path_provider, riverpod_annotation, shared_preferences
- url_launcher

### 9. **app-taskolist** (14 duplicações)
- cloud_firestore, dartz, drift, equatable, flutter_riverpod
- image_picker, intl, json_annotation, mime, path_provider
- purchases_flutter, riverpod_annotation, shared_preferences, uuid

### 10. **app-calculei** (14 duplicações)
- crypto, cupertino_icons, equatable, firebase_core
- flutter_riverpod, go_router, icons_plus, intl, logger
- riverpod_annotation, share_plus, shared_preferences
- url_launcher, uuid

### 11. **app-agrihurbi** (13 duplicações)
- connectivity_plus, dartz, dio, drift, fl_chart
- flutter_riverpod, flutter_secure_storage, freezed_annotation
- go_router, intl, json_annotation, path_provider
- riverpod_annotation

### 12. **app-nebulalist** (13 duplicações)
- cloud_firestore, connectivity_plus, dartz, drift, equatable
- firebase_auth, firebase_core, flutter_riverpod
- freezed_annotation, go_router, riverpod_annotation
- shared_preferences, uuid

### 13. **web_agrimind_site** (1 duplicação)
- url_launcher

---

## 🔝 Top 15 Dependências Mais Duplicadas

| # | Pacote | Apps usando |
|---|--------|-------------|
| 1 | riverpod_annotation | 12 apps |
| 2 | flutter_riverpod | 12 apps |
| 3 | go_router | 11 apps |
| 4 | shared_preferences | 11 apps |
| 5 | dartz | 11 apps |
| 6 | equatable | 10 apps |
| 7 | drift | 9 apps |
| 8 | cloud_firestore | 9 apps |
| 9 | intl | 9 apps |
| 10 | url_launcher | 9 apps |
| 11 | freezed_annotation | 7 apps |
| 12 | uuid | 7 apps |
| 13 | firebase_auth | 7 apps |
| 14 | firebase_core | 7 apps |
| 15 | flutter_staggered_grid_view | 6 apps |

---

## ✅ Recomendações

### 🎯 Prioridade ALTA (devem ser removidos dos apps)

Estes pacotes estão em **core** e **NÃO devem** estar nos apps individuais:

1. **riverpod_annotation** (12 apps) ⚠️
2. **flutter_riverpod** (12 apps) ⚠️
3. **go_router** (11 apps) ⚠️
4. **shared_preferences** (11 apps) ⚠️
5. **dartz** (11 apps) ⚠️
6. **equatable** (10 apps) ⚠️
7. **drift** (9 apps) ⚠️
8. **cloud_firestore** (9 apps) ⚠️
9. **intl** (9 apps) ⚠️
10. **url_launcher** (9 apps) ⚠️

### 📋 Prioridade MÉDIA

11. **freezed_annotation** (7 apps)
12. **uuid** (7 apps)
13. **firebase_auth** (7 apps)
14. **firebase_core** (7 apps)
15. **flutter_staggered_grid_view** (6 apps)

### 🔄 Processo de Migração

Para cada app:

1. **Remover** a dependência duplicada do `pubspec.yaml` do app
2. **Verificar** se o app já tem `core` como dependência
3. **Adicionar** `core` se ainda não estiver presente:
   ```yaml
   dependencies:
     core:
       path: ../../packages/core
   ```
4. **Atualizar imports** no código (se necessário):
   - De: `import 'package:riverpod_annotation/riverpod_annotation.dart';`
   - Para: *não muda* (o Flutter resolve automaticamente via `core`)
5. **Testar** com `flutter pub get` e `flutter analyze`

### 🚫 Exceções

Pacotes que **PODEM** permanecer nos apps individuais:
- `flame` e derivados (engine de jogos específica)
- Pacotes UI específicos do app
- Plugins específicos de funcionalidade única do app

---

## 🎬 Próximos Passos

1. ✅ **Análise concluída**
2. ⏳ **Remover dependências duplicadas** (app por app)
3. ⏳ **Validar builds** após cada migração
4. ⏳ **Atualizar documentação** do monorepo

---

## 📝 Notas Técnicas

- Todos os apps já deveriam estar usando `core` package como dependência única
- A presença de duplicações indica que os `pubspec.yaml` não foram atualizados após a criação do `core`
- Remover duplicações reduzirá:
  - ⚡ Tempo de build
  - 💾 Tamanho de downloads
  - 🔧 Complexidade de manutenção
  - 🐛 Risco de conflitos de versão

---

**Gerado automaticamente em:** 2026-01-15 13:23 UTC
