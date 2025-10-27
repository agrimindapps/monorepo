# 🔧 CORREÇÃO FREEZED CODE GENERATION - app-nutrituti e app-agrihurbi

## 📋 Problema Identificado

Ambos os apps (app-nutrituti e app-agrihurbi) apresentam erros durante a compilação do Flutter relacionados a modelos Freezed:

```
Error: Required named parameter 'id' must be provided.
Error: Required named parameter 'date' must be provided.
Error: Required named parameter 'category' must be provided.
```

---

## 🎯 Causa Raiz

Os arquivos `.g.dart` gerados pelo Freezed estão retornando instâncias sem passar os parâmetros obrigatórios.

**Exemplo:**
```dart
// ❌ ERRADO (gerado)
return BeberAgua();  // Falta 'id'

// ✅ CORRETO (esperado)
return BeberAgua(id: /* valor */);
```

---

## ✅ Solução

### Passo 1: Limpar Arquivos Gerados
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-nutrituti
flutter clean
rm -rf .dart_tool
rm -rf pubspec.lock
```

### Passo 2: Atualizar Dependências
```bash
flutter pub get
```

### Passo 3: Regenerar Código Freezed
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Passo 4: Limpar Cache de Build
```bash
flutter clean
```

### Passo 5: Testar Build
```bash
flutter build apk --debug
```

---

## 📝 Comandos Completos

### Para app-nutrituti:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-nutrituti
flutter clean && rm -rf .dart_tool pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean
flutter build apk --debug
```

### Para app-agrihurbi:
```bash
cd /Users/lucineiloch/Documents/deveopment/monorepo/apps/app-agrihurbi
flutter clean && rm -rf .dart_tool pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean
flutter build apk --debug
```

---

## 🔍 Modelos Afetados

### app-nutrituti
- `BeberAgua` (falta parâmetro `id`)
- `PesoModel` (falta parâmetro `id`)

### app-agrihurbi
- Múltiplos modelos com parâmetros `id`, `date`, `category` faltando

---

## 📌 Notas Importantes

1. **Build Runner Versão:** Verificar se está atualizado no pubspec.yaml
   ```yaml
   build_runner: ^2.4.12
   ```

2. **Freezed Versão:** Certificar que é compatível
   ```yaml
   freezed: any  # (via core package)
   freezed_annotation: ^2.4.1
   ```

3. **Conflitos de Geração:** Se persisti os erros, tentar:
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

---

## ⚠️ Possíveis Causas Adicionais

1. **Versões Incompatíveis de Freezed**
   - Solução: Atualizar `pubspec.yaml` via `core` package

2. **Cache Corrompido de Build**
   - Solução: `flutter clean` seguido de `flutter pub get`

3. **Modelos com Herança Não Suportada**
   - Solução: Revisar anotações `@freezed` nos arquivos `.dart`

4. **Parâmetros Renomeados Recentemente**
   - Solução: Verificar se nomes em `.dart` match com geração esperada

---

## 🧪 Verificação Final

Depois de executar os passos acima, verificar:

```bash
# 1. Verificar se arquivos .g.dart foram gerados corretamente
ls -la lib/**/*_model.g.dart

# 2. Verificar conteúdo do arquivo gerado
cat lib/pages/agua/models/beber_agua_model.g.dart | grep "return BeberAgua"

# 3. Rodar build novamente
flutter build apk --debug
```

---

## 📞 Próximas Ações

- [ ] Executar regeneração de código em app-nutrituti
- [ ] Executar regeneração de código em app-agrihurbi
- [ ] Testar builds em ambos os apps
- [ ] Confirmar APKs gerados com sucesso
- [ ] Fazer commit das mudanças

---

**Status:** ⏳ **AGUARDANDO EXECUÇÃO DOS PASSOS ACIMA**
