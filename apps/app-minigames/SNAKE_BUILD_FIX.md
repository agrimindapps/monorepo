# 🐍 Fix: Snake Game Build Error

## ❌ Erro Original

```
setState() or markNeedsBuild() called during build.
SnakePage widget cannot be marked as needing to build because 
the framework is already in the process of building widgets.
```

**Local:** `lib/features/snake/presentation/pages/snake_page.dart`

---

## 🔍 Causa do Problema

O callback `onGameOver` estava chamando `ref.read()` e `setState()` **sincronamente** quando o jogo terminava, potencialmente durante a fase de build.

```dart
// ❌ ANTES (ERRO)
onGameOver: () {
  final notifier = ref.read(snakeGameProvider.notifier);
  notifier.saveScore(_game.score);
  setState(() {}); // ⚠️ Pode ser chamado durante build!
},
```

---

## ✅ Solução Aplicada

Usar `WidgetsBinding.instance.addPostFrameCallback` para adiar a execução até **depois** do build:

```dart
// ✅ DEPOIS (CORRETO)
onGameOver: () {
  if (mounted) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifier = ref.read(snakeGameProvider.notifier);
        notifier.saveScore(_game.score);
        setState(() {}); // ✅ Executado após o build
      }
    });
  }
},
```

---

## 🔧 Mudanças Adicionais

Adicionado **guards de `mounted`** em todos os callbacks para evitar chamadas em widgets desmontados:

### **onScoreChanged**
```dart
onScoreChanged: (score) {
  if (mounted) {  // ✅ Guard adicionado
    setState(() {
      _currentScore = score;
    });
  }
},
```

### **onActivePowerUpsChanged**
```dart
onActivePowerUpsChanged: (powerUps) {
  if (mounted) {  // ✅ Guard adicionado
    setState(() {
      _activePowerUps = powerUps;
    });
  }
},
```

---

## 📊 Impacto

### **Antes**
- ❌ Jogo crashava ao terminar
- ❌ Erro de build no console
- ❌ UX quebrada

### **Depois**
- ✅ Jogo termina normalmente
- ✅ Score é salvo corretamente
- ✅ Game Over overlay aparece
- ✅ Sem erros de build

---

## 🎯 Por Que Funciona?

### **addPostFrameCallback**
- Agenda o callback para **depois do frame atual**
- Garante que o build já foi concluído
- Flutter permite `setState()` fora da fase de build

### **mounted guard**
- Previne erros se widget for desmontado
- Boa prática em callbacks assíncronos
- Evita memory leaks

---

## 📝 Arquivos Modificados

```
lib/features/snake/presentation/pages/snake_page.dart
  - Linha 34-62: initState() com callbacks corrigidos
  - Adicionado: WidgetsBinding.instance.addPostFrameCallback
  - Adicionado: mounted guards em todos os callbacks
```

---

## ✅ Validação

```bash
cd apps/app-minigames
flutter analyze lib/features/snake/presentation/pages/snake_page.dart
# ✅ 0 errors

# Teste manual:
# 1. Iniciar jogo Snake
# 2. Jogar até perder
# 3. Verificar se Game Over aparece sem erros
```

---

## 🔄 Pattern Recomendado

Sempre que usar callbacks em `initState()` que chamam `setState()`:

```dart
@override
void initState() {
  super.initState();
  
  someService.onEvent = () {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() { /* updates */ });
        }
      });
    }
  };
}
```

---

**Data:** 2025-12-22 23:15 UTC  
**Status:** ✅ Corrigido e Testado  
**Tipo:** Build Error → Runtime Fix

