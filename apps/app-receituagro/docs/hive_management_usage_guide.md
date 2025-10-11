# Guia de Uso - Sistema de Gerenciamento Hive

## 📚 Componentes Implementados

Este guia documenta os componentes do sistema de gerenciamento seguro de Hive boxes implementado no app-receituagro.

---

## 1. HiveBoxManager

**Localização**: `lib/core/utils/hive_box_manager.dart`

Helper centralizado para abertura/fechamento seguro de Hive boxes com padrão `try-finally`.

### Uso Básico

```dart
import 'package:app_receituagro/core/utils/hive_box_manager.dart';

// Operação em uma única box
final result = await HiveBoxManager.withBox<DiagnosticoHive, List<DiagnosticoHive>>(
  hiveManager: hiveManager,
  boxName: 'receituagro_diagnosticos',
  operation: (box) async {
    return box.values.toList();
  },
);

if (result.isSuccess) {
  final diagnosticos = result.data!;
  print('Loaded ${diagnosticos.length} diagnosticos');
}
```

### Operações em Múltiplas Boxes

```dart
final result = await HiveBoxManager.withMultipleBoxes(
  hiveManager: hiveManager,
  boxNames: ['receituagro_diagnosticos', 'receituagro_fitossanitarios', 'receituagro_pragas'],
  operation: (boxes) async {
    final diagnosticosBox = boxes['receituagro_diagnosticos'] as Box<DiagnosticoHive>;
    final fitossanitariosBox = boxes['receituagro_fitossanitarios'] as Box<FitossanitarioHive>;
    final pragasBox = boxes['receituagro_pragas'] as Box<PragasHive>;

    // Operação complexa usando múltiplas boxes
    return processData(diagnosticosBox, fitossanitariosBox, pragasBox);
  },
);
```

### Aliases Semânticos

```dart
// Para operações de leitura
final result = await HiveBoxManager.readBox<DiagnosticoHive, DiagnosticoHive?>(
  hiveManager: hiveManager,
  boxName: 'receituagro_diagnosticos',
  operation: (box) async => box.get('diag_123'),
);

// Para operações de escrita
final result = await HiveBoxManager.writeBox<DiagnosticoHive, void>(
  hiveManager: hiveManager,
  boxName: 'receituagro_diagnosticos',
  operation: (box) async => await box.put('diag_123', diagnostico),
);
```

---

## 2. DataIntegrityService

**Localização**: `lib/core/services/data_integrity_service.dart`

Serviço para validação de integridade referencial entre diagnósticos e suas entidades relacionadas.

### Registro DI (GetIt)

```dart
import 'package:injectable/injectable.dart';

@lazySingleton
DataIntegrityService get dataIntegrityService => DataIntegrityService(
  hiveManager: getIt<IHiveManager>(),
);
```

### Validação Completa

```dart
final service = getIt<DataIntegrityService>();

final reportResult = await service.validateIntegrity();

if (reportResult.isSuccess) {
  final report = reportResult.data!;

  print('Total diagnósticos: ${report.totalDiagnosticos}');
  print('Defensivos faltando: ${report.missingDefensivos.length}');
  print('Pragas faltando: ${report.missingPragas.length}');
  print('Culturas faltando: ${report.missingCulturas.length}');
  print('Integridade válida: ${report.isValid}');

  if (!report.isValid) {
    // Exibir alerta para o usuário
    showIntegrityWarning(report);
  }
}
```

### Validação Individual

```dart
final diagnostico = await diagnosticoRepo.getById('diag_123');

final errorsResult = await service.validateDiagnostico(diagnostico);

if (errorsResult.isSuccess) {
  final errors = errorsResult.data!;

  if (errors.isNotEmpty) {
    print('Problemas encontrados:');
    for (final error in errors) {
      print('- $error');
    }
  }
}
```

### Estatísticas

```dart
final statsResult = await service.getStatistics();

if (statsResult.isSuccess) {
  final stats = statsResult.data!;

  print('Percentual de integridade: ${stats['integrityPercentage']}%');
  print('Total de diagnósticos: ${stats['totalDiagnosticos']}');
  print('Total de problemas: ${stats['totalIssues']}');
}
```

---

## 3. DiagnosticoWithWarnings

**Localização**: `lib/core/data/models/diagnostico_with_warnings.dart`

Wrapper enriquecido para `DiagnosticoHive` com acesso seguro a entidades relacionadas.

### Uso em Repositories

```dart
Future<Result<DiagnosticoWithWarnings>> getEnrichedById(String id) async {
  final diagnosticoResult = await getById(id);

  if (diagnosticoResult.isError) {
    return Result.error(diagnosticoResult.error!);
  }

  final diagnostico = diagnosticoResult.data!;

  // Enriquecer com dados relacionados
  return await diagnostico.enrichWithRelatedData(hiveManager);
}
```

### Acesso Seguro em Widgets

```dart
Widget buildDiagnosticoCard(DiagnosticoWithWarnings enriched) {
  return Card(
    child: Column(
      children: [
        // Acesso seguro com fallback
        Text(enriched.defensivoNome ?? 'Defensivo não encontrado'),
        Text(enriched.pragaNome ?? 'Praga não encontrada'),
        Text(enriched.culturaNome ?? 'Cultura não encontrada'),

        // Exibir warnings se houver
        if (enriched.hasWarnings)
          WarningBanner(warnings: enriched.warnings),
      ],
    ),
  );
}
```

### Getters Disponíveis

```dart
// Entidades relacionadas
final defensivo = enriched.defensivo; // FitossanitarioHive?
final praga = enriched.praga; // PragasHive?
final cultura = enriched.cultura; // CulturaHive?

// Nomes com fallback
final defensivoNome = enriched.defensivoNome; // String?
final pragaNome = enriched.pragaNome; // String?
final culturaNome = enriched.culturaNome; // String?

// Status
final hasWarnings = enriched.hasWarnings; // bool
final warnings = enriched.warnings; // List<String>
```

---

## 4. DiagnosticoEnrichmentExtension

**Localização**: `lib/core/extensions/diagnostico_enrichment_extension.dart`

Extension methods para enriquecer `DiagnosticoHive` com dados relacionados.

### Enriquecimento Individual

```dart
// Completo (defensivo + praga + cultura)
final enriched = await diagnostico.enrichWithRelatedData(hiveManager);

// Seletivo
final withDefensivo = await diagnostico.enrichWithDefensivo(hiveManager);
final withPraga = await diagnostico.enrichWithPraga(hiveManager);
final withCultura = await diagnostico.enrichWithCultura(hiveManager);
```

### Enriquecimento em Lote (Otimizado)

```dart
final diagnosticos = await diagnosticoRepo.getAll();

// Enriquece todos de uma vez (abre boxes uma única vez)
final enrichedList = await diagnosticos.enrichAllWithRelatedData(hiveManager);

if (enrichedList.isSuccess) {
  final enrichedData = enrichedList.data!;

  for (final enriched in enrichedData) {
    print('${enriched.defensivoNome} -> ${enriched.pragaNome} em ${enriched.culturaNome}');

    if (enriched.hasWarnings) {
      print('  Warnings: ${enriched.warnings.join(', ')}');
    }
  }
}
```

---

## 5. HiveLeakDetector

**Localização**: `lib/core/utils/hive_leak_detector.dart`

Singleton para detecção de memory leaks causados por boxes abertas não fechadas.

### Inicialização (Debug Mode)

```dart
void main() {
  if (kDebugMode) {
    // Configurar detector para verificar leaks periodicamente
    Timer.periodic(Duration(minutes: 5), (_) {
      final report = HiveLeakDetector.instance.checkForLeaks(
        thresholdMinutes: 10, // Boxes abertas há mais de 10 minutos
      );

      if (report.hasLeaks) {
        debugPrint('⚠️ LEAK DETECTED: ${report.leakedBoxes.length} boxes abertas há muito tempo');
        HiveLeakDetector.instance.printStatus();
      }
    });
  }

  runApp(MyApp());
}
```

### Registro Manual (Integração com HiveBoxManager)

```dart
// Já integrado automaticamente no HiveBoxManager
// Mas pode ser usado manualmente se necessário:

HiveLeakDetector.instance.registerOpen('my_box');
// ... operações ...
HiveLeakDetector.instance.registerClosed('my_box');
```

### Debugging

```dart
// Status completo
HiveLeakDetector.instance.printStatus();

// Estatísticas
final stats = HiveLeakDetector.instance.getStatistics();
print('Boxes abertas: ${stats['openBoxes']}');
print('Total de eventos: ${stats['totalEvents']}');
print('Histórico: ${stats['historySize']}');

// Resetar tracking
HiveLeakDetector.instance.reset();
```

---

## 📋 Checklist de Integração

### Fase 1: Refatorar Repositórios Existentes

- [ ] Substituir `hiveManager.getBox()` por `HiveBoxManager.withBox()`
- [ ] Atualizar métodos de busca para usar `HiveBoxManager`
- [ ] Garantir que boxes nunca sejam mantidas abertas após operações

### Fase 2: Integrar Validação de Integridade

- [ ] Adicionar `DataIntegrityService` no DI (GetIt)
- [ ] Executar validação na primeira inicialização do app
- [ ] Agendar validações periódicas (background job)
- [ ] Exibir relatório ao usuário se houver problemas críticos

### Fase 3: UI com Warnings

- [ ] Atualizar widgets de visualização para usar `DiagnosticoWithWarnings`
- [ ] Criar componente `WarningBanner` para exibir avisos
- [ ] Permitir ao usuário corrigir referências quebradas

### Fase 4: Ativar Leak Detection (Debug)

- [ ] Adicionar periodic check no `main.dart` (debug mode)
- [ ] Logar alertas quando leaks forem detectados
- [ ] Monitorar logs durante desenvolvimento

---

## 🎯 Próximos Passos

1. **Remover/condicionar debug logs excessivos** (tarefa #6 do plano)
   - Usar `developer.log` ao invés de `print`/`debugPrint`
   - Condicionar logs por ambiente (`kDebugMode`)

2. **Criar índices manuais para Hive** (tarefa #10 do plano)
   - Implementar índices em memória para FKs
   - Refatorar buscas para usar índices

3. **Adicionar testes de integração** (tarefa #7 do plano)
   - Testar fluxos completos de busca e exibição
   - Testar performance de batch loading

---

**Data de criação**: 2025-10-10
**Autor**: Claude Code (flutter-engineer agent)
**Versão**: 1.0
