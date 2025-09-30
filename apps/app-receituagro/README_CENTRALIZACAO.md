# Guia de Centralização - Core Package

**Data**: 30 de Setembro de 2025
**Objetivo**: Centralizar dependências dos apps no core package do monorepo

---

## Arquivos Gerados

1. **ANALISE_CENTRALIZACAO_CORE.md** (📄 Análise Completa)
   - Ranking de centralização por app
   - Comparação de imports diretos vs core
   - Services candidatos para mover ao core
   - Plano de ação detalhado (5 semanas)

2. **CENTRALIZACAO_SUMARIO_EXECUTIVO.md** (📊 Sumário Executivo)
   - Visão geral visual
   - Top oportunidades
   - ROI e impacto esperado
   - Próximos passos imediatos

3. **scripts_centralizacao.sh** (🛠️ Scripts de Automação)
   - Substituição automatizada de imports
   - Validação e rollback
   - Geração de relatórios

4. **README_CENTRALIZACAO.md** (Este arquivo)
   - Guia de uso rápido

---

## Quick Start (5 minutos)

### Passo 1: Revisar Análise

```bash
# Ler sumário executivo primeiro
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-receituagro
cat CENTRALIZACAO_SUMARIO_EXECUTIVO.md

# Para análise completa:
cat ANALISE_CENTRALIZACAO_CORE.md
```

### Passo 2: Executar Scripts de Migração

```bash
# Tornar script executável (já feito)
chmod +x scripts_centralizacao.sh

# Executar menu interativo
./scripts_centralizacao.sh
```

**Menu disponível:**
```
1. Fase 1.1 - Gasometer: Firestore (12 imports)
2. Fase 1.2 - Gasometer: Hive (11 imports)
3. Fase 1.3 - Gasometer: SharedPreferences (9 imports)
4. Fase 1.4 - Gasometer: Connectivity (6 imports)
5. Fase 1 - Gasometer: TODAS as substituições (38 imports)

6. Fase 2 - Plantis: Quick Fixes (10 imports)
7. Fase 3 - ReceitaAgro: Final Touches (6 imports)

8. EXECUTAR TUDO (Fases 1-3)

9. Validar mudanças (flutter analyze)
10. Gerar relatório
11. Rollback (restaurar backups)
12. Cleanup (remover backups)
```

### Passo 3: Validar Mudanças

```bash
# Opção 1: Via script (recomendado)
./scripts_centralizacao.sh
# Selecionar opção 9

# Opção 2: Manual
cd ../app-gasometer
flutter analyze
cd ../app-plantis
flutter analyze
cd ../app-receituagro
flutter analyze
```

---

## Workflow Recomendado

### Semana 1: Gasometer Quick Wins (Fase 1)

**Objetivo**: Eliminar 38 imports diretos (65% dos imports)

```bash
# 1. Executar migração
./scripts_centralizacao.sh
# Selecionar opção 5 (Fase 1 completa)

# 2. Validar
./scripts_centralizacao.sh
# Selecionar opção 9

# 3. Testar app
cd ../app-gasometer
flutter run

# 4. Se tudo OK, commit
git add .
git commit -m "refactor(gasometer): Centralizar 38 imports no core package

- Substitui cloud_firestore diretos por core (12x)
- Substitui hive/hive_flutter diretos por core (11x)
- Substitui shared_preferences diretos por core (9x)
- Substitui connectivity_plus diretos por core (6x)

Score de centralização: 6.0/10 → 8.0/10
Ref: ANALISE_CENTRALIZACAO_CORE.md"

# 5. Se algo deu errado, rollback
./scripts_centralizacao.sh
# Selecionar opção 11 (Rollback)
```

### Semana 2: Core Package Enhancement

**Objetivo**: Adicionar packages faltantes ao core

```bash
# 1. Editar core/pubspec.yaml
cd ../../../packages/core
code pubspec.yaml

# Adicionar:
# dependencies:
#   image_picker: ^1.0.0
#   device_info_plus: ^9.0.0
#   image: ^4.0.0
#   http: ^1.0.0
#   permission_handler: ^11.0.0
#   path_provider: ^2.0.0

# 2. Atualizar dependências
flutter pub get

# 3. Adicionar exports em core.dart
code lib/core.dart

# Adicionar no final:
# // Image Handling
# export 'package:image_picker/image_picker.dart';
# export 'package:image/image.dart' as img;
#
# // Device Info
# export 'package:device_info_plus/device_info_plus.dart';
#
# // HTTP Client
# export 'package:http/http.dart' show Client, Response, Request;
#
# // Permissions
# export 'package:permission_handler/permission_handler.dart';
#
# // File System
# export 'package:path_provider/path_provider.dart';

# 4. Validar core package
flutter analyze

# 5. Commit
git add .
git commit -m "feat(core): Adicionar packages para image handling e device info

- image_picker para profile images
- device_info_plus para device fingerprinting
- http para cloud functions calls
- permission_handler para camera/gallery access
- path_provider para cache management

Ref: CENTRALIZACAO_SUMARIO_EXECUTIVO.md - Fase 2"
```

### Semana 3: Service Extraction (Tier 1)

**Objetivo**: Mover 4 services críticos para core

```bash
# 1. Enhanced Image Cache Manager (Plantis → Core)
cd ../../../apps/app-plantis/lib/core/services
cp enhanced_image_cache_manager.dart /tmp/

cd ../../../../../packages/core/lib/src/shared/services/
mv /tmp/enhanced_image_cache_manager.dart .

# Editar e tornar genérico (remover app-specific logic)
code enhanced_image_cache_manager.dart

# 2. Avatar Service (Gasometer → Core)
cd ../../../apps/app-gasometer/lib/core/services
cp avatar_service.dart /tmp/

cd ../../../../../packages/core/lib/src/shared/services/
mv /tmp/avatar_service.dart .
code avatar_service.dart

# 3. Cloud Functions Service (ReceitaAgro → Core)
cd ../../../apps/app-receituagro/lib/core/services
cp cloud_functions_service.dart /tmp/

cd ../../../../../packages/core/lib/src/infrastructure/services/
mv /tmp/cloud_functions_service.dart .
code cloud_functions_service.dart

# 4. Device Identity Service (ReceitaAgro → Core)
cd ../../../apps/app-receituagro/lib/core/services
cp device_identity_service.dart /tmp/

cd ../../../../../packages/core/lib/src/infrastructure/services/
mv /tmp/device_identity_service.dart .
code device_identity_service.dart

# 5. Adicionar exports no core.dart
cd ../../
code lib/core.dart

# Adicionar:
# // Shared Services (NEW)
# export 'src/shared/services/enhanced_image_cache_manager.dart';
# export 'src/shared/services/avatar_service.dart';
#
# // Infrastructure Services (NEW)
# export 'src/infrastructure/services/cloud_functions_service.dart';
# export 'src/infrastructure/services/device_identity_service.dart';

# 6. Atualizar apps para usar services do core
cd ../../../apps/app-gasometer
# Substituir imports locais por package:core/core.dart

cd ../app-plantis
# Substituir imports locais por package:core/core.dart

cd ../app-receituagro
# Substituir imports locais por package:core/core.dart

# 7. Validar
cd ../app-gasometer
flutter analyze && flutter test

cd ../app-plantis
flutter analyze && flutter test

cd ../app-receituagro
flutter analyze && flutter test

# 8. Commit
git add .
git commit -m "feat(core): Extrair 4 services reutilizáveis para core package

TIER 1 Services (Alto reuso - 3 apps):
- EnhancedImageCacheManager (Plantis → Core)
  * LRU cache + compute isolation
  * -30% memory usage
- AvatarService (Gasometer → Core)
  * Image picker + compression + permissions
  * Consistent profile images
- CloudFunctionsService (ReceitaAgro → Core)
  * Authenticated HTTP client wrapper
  * Firebase token injection
- DeviceIdentityService (ReceitaAgro → Core)
  * Device fingerprinting
  * Multi-device subscription enforcement

Impacto: ~1500 linhas de código reutilizável
Ref: ANALISE_CENTRALIZACAO_CORE.md - Fase 3"
```

---

## Troubleshooting

### Problema: Script não executa

```bash
# Solução: Verificar permissões
ls -la scripts_centralizacao.sh

# Se não for executável:
chmod +x scripts_centralizacao.sh
```

### Problema: "sed: command not found" ou erro de sintaxe

```bash
# Solução: Script usa sed do macOS
# Se estiver no Linux, ajustar script:
# Remover '' após -i em todas as linhas sed
# Exemplo: sed -i '' → sed -i
```

### Problema: Imports duplicados após migração

```bash
# Solução: Script já remove duplicatas com awk
# Se persistir, manualmente:
cd /path/to/file
awk '!seen[$0]++' file.dart > file.dart.tmp
mv file.dart.tmp file.dart
```

### Problema: Flutter analyze falha após migração

```bash
# Solução 1: Verificar se core package está atualizado
cd packages/core
flutter pub get

# Solução 2: Limpar cache dos apps
cd apps/app-gasometer
flutter clean
flutter pub get

# Solução 3: Rollback e investigar
./scripts_centralizacao.sh
# Opção 11 (Rollback)
```

### Problema: App quebra em runtime

```bash
# Solução: Verificar se services do core foram inicializados
# Ex: GetIt registration, Firebase initialization

# Gasometer: lib/core/di/injection_container.dart
# Plantis: lib/core/di/injection.dart
# ReceitaAgro: lib/core/di/injection.dart

# Verificar se services movidos para core estão registrados
```

---

## Métricas de Sucesso

### Antes da Migração

| App | Score | Core Imports | Direct Imports | Ratio |
|-----|-------|--------------|----------------|-------|
| ReceitaAgro | 9.5/10 | 217 | 6 | 36:1 |
| Plantis | 8.5/10 | 177 | 10 | 18:1 |
| Gasometer | 6.0/10 | 156 | 58+ | 3:1 |

### Após Fase 1 (Esperado)

| App | Score | Core Imports | Direct Imports | Ratio |
|-----|-------|--------------|----------------|-------|
| ReceitaAgro | 9.5/10 | 217 | 6 | 36:1 ✅ |
| Plantis | 8.5/10 | 177 | 10 | 18:1 ✅ |
| Gasometer | 8.0/10 | 194+ | 20 | 9.7:1 📈 |

### Meta Final (Após Fase 1-3)

| App | Score | Core Imports | Direct Imports | Ratio |
|-----|-------|--------------|----------------|-------|
| ReceitaAgro | 10/10 | 225+ | 0 | ∞:1 🎯 |
| Plantis | 9.5/10 | 195+ | 2 | 97:1 🎯 |
| Gasometer | 9.5/10 | 220+ | 5 | 44:1 🎯 |

---

## Comandos Úteis

### Contar imports do core em um app

```bash
grep -r "^import 'package:core" --include="*.dart" lib/ | wc -l
```

### Contar imports diretos de Firebase

```bash
grep -r "^import 'package:firebase_" --include="*.dart" lib/ | wc -l
```

### Contar imports diretos de Hive

```bash
grep -r "^import 'package:hive" --include="*.dart" lib/ | wc -l
```

### Listar todos os imports diretos (exceto core)

```bash
grep -r "^import 'package:" --include="*.dart" lib/ | \
  grep -v "package:core" | \
  grep -v "package:flutter" | \
  sort | uniq -c | sort -rn
```

### Gerar relatório de imports por app

```bash
for app in app-gasometer app-plantis app-receituagro; do
  echo "=== $app ==="
  cd apps/$app

  echo "Core imports: $(grep -r "^import 'package:core" --include="*.dart" lib/ | wc -l)"
  echo "Firebase imports: $(grep -r "^import 'package:firebase_" --include="*.dart" lib/ | wc -l)"
  echo "Hive imports: $(grep -r "^import 'package:hive" --include="*.dart" lib/ | wc -l)"
  echo "SharedPreferences imports: $(grep -r "^import 'package:shared_preferences" --include="*.dart" lib/ | wc -l)"
  echo ""

  cd ../..
done
```

---

## Próximos Passos

### Esta Semana:
- [ ] Revisar análise completa com tech lead
- [ ] Aprovar packages a adicionar no core
- [ ] Executar Fase 1 (Gasometer quick wins)
- [ ] Validar e commitar

### Semana Seguinte:
- [ ] Adicionar packages faltantes ao core (Fase 2)
- [ ] Iniciar extração de services Tier 1 (Fase 3)
- [ ] Testar services extraídos cross-app
- [ ] Documentar novos services do core

### Próximo Mês:
- [ ] Extrair services Tier 2
- [ ] Criar widget library no core
- [ ] Atualizar todos os apps para usar widgets compartilhados
- [ ] Celebrar 95%+ de centralização! 🎉

---

## Contato

Para dúvidas sobre este guia ou análise de centralização:

- **Análise Completa**: `ANALISE_CENTRALIZACAO_CORE.md`
- **Sumário Executivo**: `CENTRALIZACAO_SUMARIO_EXECUTIVO.md`
- **Scripts**: `scripts_centralizacao.sh`

**Gerado por**: Claude Sonnet 4.5 (Flutter Architect)
**Data**: 30 de Setembro de 2025
