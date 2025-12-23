# ❌ Erros de Build - app-minigames

## 📊 Resumo

**Total de Erros:** 37  
**Status Build Web:** ❌ FALHOU  
**Última Sincronização:** 2025-12-22 (PACKAGES_SYNC.md)

---

## 🔴 Categorias de Erros

### 1. **Type Not Found** (14 erros)
```
Error: Type 'PhysicsService' not found
Error: Type 'PipeGeneratorService' not found
Error: Type 'CollisionService' not found
Error: Type 'PowerUpService' not found
Error: Type 'StartGameUseCase' not found
Error: Type 'FlapBirdUseCase' not found
```

**Causa:** Services/UseCases não gerados pelo Riverpod code generation.

**Arquivos afetados:**
- FlappyBird game services
- UseCases do domínio

---

### 2. **Nullable Receiver** (10 erros)
```
error • The property 'definition' can't be unconditionally accessed because the receiver can be 'null'
```

**Arquivo:** `lib/features/flappbird/presentation/widgets/achievements_dialog_adapter.dart`

**Linhas:** 54-66

**Causa:** `achievement.definition` pode ser null mas está sendo acessado sem null check.

---

### 3. **Type Argument Issues** (2 erros)
```
error • The name 'FlappyAchievementWithDefinition' isn't a type
error • The name 'SnakeAchievementWithDefinition' isn't a type
```

**Causa:** Tipos compostos não definidos.

---

### 4. **Undefined Identifiers** (3 erros)
```
error • Undefined name 'game2048NotifierProvider'
error • Undefined name 'snakeAchievementsProvider'
error • Undefined name 'snakeAchievementStatsProvider'
```

**Causa:** Providers não gerados ou imports faltando.

---

### 5. **Ambiguous Import** (1 erro)
```
error • The name 'AchievementStats' is defined in 2 libraries
  - package:app_minigames/features/snake/presentation/providers/achievement_provider.dart
  - package:app_minigames/widgets/shared/game_achievements_dialog.dart
```

**Causa:** Mesmo nome em 2 arquivos diferentes.

---

## 🔧 Soluções Necessárias

### **Prioridade ALTA**

#### 1. **Rodar Code Generation**
```bash
cd apps/app-minigames
flutter pub run build_runner build --delete-conflicting-outputs
```

Isso deve gerar:
- `*.g.dart` files com providers
- Riverpod providers anotados com `@riverpod`

---

#### 2. **Corrigir Null Safety**

**Arquivo:** `achievements_dialog_adapter.dart`

```dart
// ANTES (erro)
achievement.definition.id

// DEPOIS (correto)
achievement.definition?.id ?? ''
// ou
achievement.definition!.id  // se garantir que não é null
```

---

#### 3. **Definir Tipos Faltantes**

Criar `typedef` ou `class` para:
- `FlappyAchievementWithDefinition`
- `SnakeAchievementWithDefinition`

Exemplo:
```dart
class FlappyAchievementWithDefinition {
  final AchievementDefinition definition;
  final Achievement achievement;
  
  FlappyAchievementWithDefinition({
    required this.definition,
    required this.achievement,
  });
}
```

---

#### 4. **Resolver Ambiguous Imports**

**Opção A:** Renomear uma das classes

**Opção B:** Usar imports com alias
```dart
import 'package:.../achievement_provider.dart' as provider;
import 'package:.../game_achievements_dialog.dart' as dialog;

// Uso
provider.AchievementStats(...)
dialog.AchievementStats(...)
```

---

## 📝 Checklist de Resolução

- [ ] Rodar `build_runner` para gerar providers
- [ ] Corrigir null safety no achievements_dialog_adapter.dart
- [ ] Definir tipos `*AchievementWithDefinition`
- [ ] Resolver ambiguous imports
- [ ] Verificar se providers estão anotados com `@riverpod`
- [ ] Re-testar `flutter analyze`
- [ ] Re-testar `flutter build web`

---

## 🚀 Comandos Rápidos

```bash
# 1. Limpar builds anteriores
cd apps/app-minigames
flutter clean

# 2. Reinstalar dependências
flutter pub get

# 3. Gerar código Riverpod
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Analisar erros restantes
flutter analyze

# 5. Build web
flutter build web --release
```

---

## ⚠️ Notas

- Os erros parecem ter sido introduzidos após a sync com core package
- Possivelmente faltou rodar `build_runner` após a sync
- Alguns tipos podem ter sido removidos/renomeados

---

**Data:** 2025-12-22  
**Próximo Passo:** Rodar build_runner e corrigir null safety

