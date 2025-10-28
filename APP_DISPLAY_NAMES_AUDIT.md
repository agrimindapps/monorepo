# 📱 Auditoria de Nomes de Aplicativos - Android e iOS

**Data**: 28 de outubro de 2025  
**Status**: ⚠️ **INCONSISTÊNCIAS DETECTADAS**

---

## 🎯 Resumo Executivo

Foram identificadas **sérias inconsistências** nos nomes de exibição dos aplicativos entre as plataformas Android e iOS, bem como entre o nome técnico e o nome de marketing.

**Total de Apps Auditados**: 11  
**Apps com Inconsistências**: 9  
**Apps Corretos**: 2

---

## 📊 Tabela de Inconsistências

| App | Android Label | iOS Display Name | iOS Bundle Name | Status |
|-----|---|---|---|---|
| **app-calculei** | `app_calculei` ❌ | `App Calculei` ✅ | `app_calculei` | ⚠️ MISMATCH |
| **app-minigames** | `app_minigames` ❌ | `App Minigames` ✅ | `app_minigames` | ⚠️ MISMATCH |
| **app-gasometer** | `GasOMeter` ✅ | `GasOMeter` ✅ | `GasOMeter` | ✅ CONSISTENTE |
| **app-plantis** | `Plantis` ✅ | `App Plantis` ⚠️ | `app_plantis` | ⚠️ MISMATCH |
| **app-receituagro** | `ReceitaAgro` ✅ | `ReceitaAgro` ✅ | `ReceitaAgro` | ✅ CONSISTENTE |
| **app-taskolist** | `app_task_manager` ⚠️ | `App Task Manager` ✅ | `app_task_manager` | ⚠️ MISMATCH |
| **app-nebulalist** | `app_nebulalist` ❌ | `App Nebulalist` ✅ | `app_nebulalist` | ⚠️ MISMATCH |
| **app-agrihurbi** | `app_agrihurbi` ❌ | `App Agrihurbi` ✅ | `app_agrihurbi` | ⚠️ MISMATCH |
| **app-nutrituti** | `app_nutrituti` ❌ | `App Nutrituti` ✅ | `app_nutrituti` | ⚠️ MISMATCH |
| **app-petiveti** | `app_petiveti` ❌ | `App Petiveti` ✅ | `app_petiveti` | ⚠️ MISMATCH |
| **app-termostecnicos** | `termostecnicos` ✅ | `termostecnicos` ✅ | `termostecnicos` | ✅ CONSISTENTE |

---

## 🔴 Problemas Identificados

### 1. **Android Labels com Snake Case ou Genéricos**
Muitos apps usam nomes técnicos em Android em vez de nomes amigáveis:
- `app_calculei` → Deveria ser "Calculei" ou "App Calculei"
- `app_minigames` → Deveria ser "MiniGames" ou "App MiniGames"
- `app_nebulalist` → Deveria ser "Nebulalist" ou "App Nebulalist"
- `app_agrihurbi` → Deveria ser "Agrihurbi" ou "App Agrihurbi"
- `app_nutrituti` → Deveria ser "Nutrituti" ou "App Nutrituti"
- `app_petiveti` → Deveria ser "Petiveti" ou "App Petiveti"

### 2. **Inconsistência entre Plataformas**
iOS exibe nomes mais amigáveis (ex: "App Calculei") enquanto Android exibe nomes técnicos (ex: "app_calculei").

### 3. **Falta de Padronização**
Diferentes padrões de nomenclatura:
- Alguns em CamelCase: `GasOMeter`, `ReceitaAgro`
- Alguns em snake_case: `app_calculei`, `app_minigames`
- Alguns em lowercase: `termostecnicos`

---

## ✅ Recomendações

### **Estratégia de Normalização**

**Opção 1: Nomes Amigáveis em Ambas as Plataformas** (RECOMENDADO)
```
Android Label        iOS DisplayName      iOS BundleName
Calculei            Calculei             app_calculei
MiniGames           MiniGames            app_minigames
GasOMeter           GasOMeter            GasOMeter
Plantis             Plantis              app_plantis
ReceitaAgro         ReceitaAgro          ReceitaAgro
Task Manager        Task Manager         app_task_manager
Nebulalist          Nebulalist           app_nebulalist
Agrihurbi           Agrihurbi            app_agrihurbi
Nutrituti           Nutrituti            app_nutrituti
Petiveti            Petiveti             app_petiveti
TermosTecnicos      TermosTecnicos       termostecnicos
```

**Opção 2: Prefixo "App" Consistente em Ambas**
```
Todos com "App " no início para melhor identificação na loja
Ex: "App Calculei", "App MiniGames", "App Plantis", etc.
```

---

## 📋 Arquivos a Modificar por App

### **app-calculei** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_calculei` → `Calculei`

### **app-minigames** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_minigames` → `MiniGames`

### **app-plantis** ⚠️
- [ ] `ios/Runner/Info.plist`: `App Plantis` → `Plantis` (para consistência com Android)

### **app-taskolist** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_task_manager` → `Task Manager`
- [ ] `ios/Runner/Info.plist`: `App Task Manager` → `Task Manager`

### **app-nebulalist** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_nebulalist` → `Nebulalist`

### **app-agrihurbi** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_agrihurbi` → `Agrihurbi`

### **app-nutrituti** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_nutrituti` → `Nutrituti`

### **app-petiveti** ⚠️
- [ ] `android/app/src/main/AndroidManifest.xml`: `app_petiveti` → `Petiveti`

---

## 🎯 Impacto

### ❌ **Problema Atual**
- Usuários veem nomes diferentes na App Store (iOS) vs Google Play (Android)
- Experiência inconsistente entre plataformas
- Nomes técnicos menos profissionais em Android

### ✅ **Após Correção**
- Branding consistente em ambas as plataformas
- Melhor reconhecimento do produto
- Experiência unificada para o usuário

---

## 🔗 Próximos Passos

1. **Definir padrão de nomenclatura** (com stakeholders)
2. **Aplicar correções** em todos os apps
3. **Testar builds** para validar as mudanças
4. **Documentar padrão** para futuros apps
