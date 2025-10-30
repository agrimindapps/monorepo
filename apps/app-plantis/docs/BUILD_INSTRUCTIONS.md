# Build Instructions - Tasks Feature Improvements

## 🚨 IMPORTANTE: Executar Build Runner

As melhorias implementadas na feature de Tasks requerem a execução do build_runner para gerar os arquivos necessários.

## Arquivos que Precisam Ser Gerados

```
lib/features/tasks/presentation/providers/
├── tasks_providers.dart (✅ criado)
└── tasks_providers.g.dart (⚠️ precisa ser gerado)
```

## Como Executar

### Opção 1: Usando Melos (Recomendado para Monorepo)

```bash
# Na raiz do monorepo
cd /path/to/monorepo

# Gerar código apenas para app-plantis
melos run codegen --scope="app-plantis"

# OU gerar para todos os packages
melos run codegen
```

### Opção 2: Diretamente no App

```bash
# Navegar para o app
cd apps/app-plantis

# Executar build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# OU em modo watch (para desenvolvimento)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Opção 3: Usando FVM (se configurado)

```bash
cd apps/app-plantis

# Com FVM
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Verificação

Após executar, verifique se os seguintes arquivos foram criados:

```bash
# Verificar se o arquivo foi gerado
ls -la lib/features/tasks/presentation/providers/tasks_providers.g.dart

# Deve mostrar algo como:
# -rw-r--r-- 1 user user XXXX Oct 30 XX:XX tasks_providers.g.dart
```

## Resolução de Problemas

### Erro: "Conflicting outputs"
```bash
# Limpar e regenerar
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "Package not found"
```bash
# Instalar dependências primeiro
flutter pub get
# Depois executar build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "Part not found"
Verifique se o arquivo `tasks_providers.dart` tem a linha:
```dart
part 'tasks_providers.g.dart';
```

## Após a Geração

### 1. Verificar Compilação
```bash
cd apps/app-plantis
flutter analyze
```

### 2. Executar Testes (se disponíveis)
```bash
flutter test
```

### 3. Executar App
```bash
flutter run
```

## Estrutura Esperada Após Build

```
lib/features/tasks/
├── core/
├── data/
├── domain/
└── presentation/
    ├── notifiers/
    │   ├── tasks_notifier.dart
    │   └── tasks_notifier.g.dart (deve existir)
    ├── pages/
    ├── providers/
    │   ├── tasks_providers.dart (✅ criado)
    │   ├── tasks_providers.g.dart (⚠️ gerar)
    │   ├── tasks_state.dart
    │   └── tasks_state.freezed.dart (deve existir)
    └── widgets/
```

## Troubleshooting Adicional

### Se build_runner falhar:

1. **Verificar versões de dependências**
```bash
flutter pub outdated
```

2. **Limpar cache do Flutter**
```bash
flutter clean
flutter pub get
```

3. **Verificar análise estática**
```bash
flutter analyze
# Corrigir quaisquer erros antes de executar build_runner
```

4. **Versão do Dart/Flutter**
```bash
flutter --version
# Deve ser compatível com as especificações do pubspec.yaml
```

## Dependências Necessárias

Certifique-se de que o `pubspec.yaml` contém:

```yaml
dependencies:
  riverpod_annotation: any
  freezed_annotation: any

dev_dependencies:
  build_runner: ^2.4.6
  riverpod_generator: any
  freezed: any
```

## Próximos Passos Após Build

Após gerar os arquivos com sucesso:

1. ✅ Verificar compilação sem erros
2. ✅ Testar funcionalidades da feature Tasks
3. ✅ Commit dos arquivos modificados (exceto .g.dart)
4. 📋 Considerar implementar melhorias documentadas em `TASKS_IMPROVEMENTS_IMPLEMENTED.md`

## Mais Informações

- **Análise Completa**: `TASKS_FEATURE_ANALYSIS.md`
- **Melhorias Implementadas**: `TASKS_IMPROVEMENTS_IMPLEMENTED.md`
- **Riverpod Docs**: https://riverpod.dev/docs/concepts/about_code_generation
