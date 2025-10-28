# Relatório de Identificadores de Pacote (Bundle IDs)

**Data**: 27 de outubro de 2025  
**Monorepo**: agrimindapps/monorepo

---

## Resumo Executivo

| Status | Quantidade | Apps |
|--------|-----------|------|
| ✅ Sincronizados | 6 | app-agrihurbi, app-gasometer, app-petiveti, app-plantis, app-receituagro, app-taskolist |
| ⚠️ Parcialmente Sincronizados | 3 | app-calculei, app-minigames, app_nebulalist |
| ❌ Não Sincronizados | 1 | app-nutrituti |

---

## Detalhamento por App

### ✅ app-agrihurbi
- **Android**: `br.com.agrimind.calculadoraagronomica`
- **iOS**: `br.com.agrimind.calculadoraagronomica`
- **Status**: ✅ Sincronizados

### ⚠️ app-calculei
- **Android**: `com.example.app_calculei`
- **iOS**: `com.example.appCalculei`
- **Status**: ⚠️ DIFERENTES
- **Problema**: Android usa snake_case, iOS usa camelCase
- **Recomendação**: Padronizar para `com.example.app_calculei` (Android) ou `com.agrimind.calculei` (produção)

### ✅ app-gasometer
- **Android**: `br.com.agrimind.gasometer`
- **iOS**: `br.com.agrimind.gasometer`
- **Status**: ✅ Sincronizados

### ⚠️ app-minigames
- **Android**: `com.example.app_minigames`
- **iOS**: `com.example.appMinigames`
- **Status**: ⚠️ DIFERENTES
- **Problema**: Android usa snake_case, iOS usa camelCase
- **Recomendação**: Padronizar para `com.example.app_minigames` (Android) ou `com.agrimind.minigames` (produção)

### ❌ app-nutrituti
- **Android**: `br.com.agrimind.nutrituti`
- **iOS**: `com.example.appNutrittuti`
- **Status**: ❌ CRÍTICO - Domínios completamente diferentes!
- **Problema**: Android usa domínio Agrimind oficial, iOS usa exemplo genérico
- **Recomendação**: Atualizar iOS para `br.com.agrimind.nutrituti` imediatamente

### ✅ app-petiveti
- **Android**: `br.com.agrimind.racasdecachorros`
- **iOS**: `br.com.agrimind.racasdecachorros`
- **Status**: ✅ Sincronizados

### ✅ app-plantis
- **Android**: `br.com.agrimind.especiesorquideas`
- **iOS**: `br.com.agrimind.especiesorquideas`
- **Status**: ✅ Sincronizados

### ✅ app-receituagro
- **Android**: `br.com.agrimind.pragassoja`
- **iOS**: `br.com.agrimind.pragassoja`
- **Status**: ✅ Sincronizados

### ✅ app-taskolist
- **Android**: `br.com.agrimind.winfinancas`
- **iOS**: `br.com.agrimind.winfinancas`
- **Status**: ✅ Sincronizados

### ⚠️ app_nebulalist
- **Android**: `br.com.agrimind.nebulalist.app_nebulalist`
- **iOS**: `br.com.agrimind.nebulalist.appNebulalist`
- **Status**: ⚠️ DIFERENTES
- **Problema**: Android usa snake_case, iOS usa camelCase
- **Recomendação**: Padronizar para `br.com.agrimind.nebulalist` (remover sufixo redundante)

---

## Padrões Identificados

### Nomenclatura Android
- **Padrão Agrimind**: `br.com.agrimind.[nome-app]` (ex: br.com.agrimind.pragassoja)
- **Padrão Exemplo**: `com.example.[app_name]` (ex: com.example.app_calculei)

### Nomenclatura iOS
- **Padrão Agrimind**: `br.com.agrimind.[nome-app]` (ex: br.com.agrimind.pragassoja)
- **Padrão Exemplo**: `com.example.app[NomeApp]` (camelCase)

---

## Recomendações de Ação

### 🔴 CRÍTICO (Deve ser feito imediatamente)
1. **app-nutrituti**: Atualizar iOS para `br.com.agrimind.nutrituti`
   - Localização: `ios/Runner.xcodeproj/project.pbxproj`
   - Localização: `ios/Runner/Info.plist`

### 🟡 IMPORTANTE (Deve ser padronizado)
2. **app-calculei**: Definir padrão (production bundle id)
   - Opção A: Atualizar iOS para `com.example.app_calculei`
   - Opção B: Atualizar ambos para `com.agrimind.calculei`

3. **app-minigames**: Definir padrão (production bundle id)
   - Opção A: Atualizar iOS para `com.example.app_minigames`
   - Opção B: Atualizar ambos para `com.agrimind.minigames`

4. **app_nebulalist**: Simplificar bundle id
   - Remover sufixo `app_nebulalist`/`appNebulalist`
   - Padronizar para: `br.com.agrimind.nebulalist`

---

## Impacto de Mudanças

⚠️ **AVISO**: Alterar Bundle IDs pode impactar:
- App Store Connect / Google Play Console (requer reconexão)
- Deep Links e URL schemes
- Firebase configuration
- Sign in providers (Google, Apple, Facebook)
- Push notifications
- Analytics

**Recomendação**: Fazer mudanças em ambiente de desenvolvimento primeiro e testar completamente.
