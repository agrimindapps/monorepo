# Refatoração Arquitetural - Separação de Responsabilidades

Este documento descreve a refatoração realizada para resolver a **Issue #11 - Mistura de Concerns em Repository**, implementando separação clara entre Data Access e Lógica de Negócio.

## 🎯 Problema Resolvido

Os repositories continham lógica de negócio (estatísticas, validações, transformações) que violava o princípio da arquitetura em camadas. A implementação misturava:

- **Data Access**: Operações CRUD, queries básicas
- **Business Logic**: Regras de negócio, validações complexas
- **Statistics**: Cálculos, métricas e relatórios

## 📋 Services Criados

### 1. BusinessRulesService
**Responsabilidade**: Implementar lógica de negócio pura

**Métodos principais**:
- `existeEspacoComNome()` - Validação de unicidade de espaços
- `existePlantaComNome()` - Validação de unicidade de plantas por espaço
- `podeExcluirEspaco()` / `podeExcluirPlanta()` - Regras de exclusão
- `podeDesativarEspaco()` - Regras de desativação
- `calcularProximoCuidado()` - Lógica de agendamento
- `plantaPrecisaCuidadoHoje()` - Detecção de necessidade de cuidados
- `devecriarTarefaAutomatica()` - Regras de criação automática
- `calcularPrioridadeTarefa()` - Algoritmo de priorização

### 2. ValidationService
**Responsabilidade**: Centralizar todas as validações (dados + negócio)

**Métodos principais**:
- `validateEspacoComplete()` - Validação completa de espaços
- `validatePlantaComplete()` - Validação completa de plantas
- `validatePlantaConfigComplete()` - Validação de configurações
- `validateTarefaComplete()` - Validação completa de tarefas
- `validateEspacoDeletion()` - Validação de operações de exclusão
- `validateAutomaticTaskCreation()` - Validação de criação automática
- `validateBatch()` - Validação em lote
- `validateBeforeSync()` - Validação antes de sincronização

### 3. StatisticsService
**Responsabilidade**: Centralizar e coordenar todas as estatísticas

**Métodos principais**:
- `getEspacoStatistics()` - Estatísticas básicas de espaços
- `getPlantaStatistics()` - Estatísticas básicas de plantas
- `getTarefaStatistics()` - Estatísticas básicas de tarefas
- `getCompleteStatistics()` - Estatísticas completas para dashboard
- `getSummaryStatistics()` - Resumo para widgets
- `getProductivityStats()` - Estatísticas de produtividade
- `getPerformanceStats()` - Métricas de performance

## 🔧 Refatoração dos Repositories

### Métodos Deprecados
Os seguintes métodos foram marcados como `@Deprecated` com orientações:

#### EspacoRepository
```dart
@Deprecated('Use BusinessRulesService.existeEspacoComNome() - será removido na v2.0')
Future<bool> existeComNome(String nome, {String? excluirId})

@Deprecated('Use StatisticsService.getEspacoStatistics() - será removido na v2.0')
Future<Map<String, int>> getEstatisticas()
```

#### PlantaRepository
```dart
@Deprecated('Use StatisticsService.getPlantaStatistics() - será removido na v2.0')
Future<Map<String, int>> getEstatisticas()
```

#### TarefaRepository
```dart
@Deprecated('Use StatisticsService.getTarefaStatistics() - será removido na v2.0')
Future<Map<String, int>> getEstatisticas()
```

### Documentação Atualizada
Todos os repositories agora incluem documentação clara sobre:
- Foco exclusivo em Data Access
- Services especializados para lógica de negócio
- Mapeamento de responsabilidades

## 📊 Arquitetura Final

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Controllers   │───▶│    Services      │───▶│   Repositories  │
│                 │    │                  │    │                 │
│ - PlantaController  │ - BusinessRules   │    │ - EspacoRepo    │
│ - TarefaController  │ - Validation      │    │ - PlantaRepo    │
│ - EspacoController  │ - Statistics      │    │ - TarefaRepo    │
└─────────────────┘    │ - Domain Services │    │                 │
                       └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Data Layer     │
                       │                  │
                       │ - Hive/Firebase  │
                       │ - Sync Services  │
                       └──────────────────┘
```

## 🎯 Benefícios Alcançados

### ✅ Single Responsibility Principle
- **Repositories**: Apenas data access e queries básicas
- **Business Services**: Lógica de negócio pura
- **Statistics Services**: Cálculos e métricas
- **Validation Service**: Validações centralizadas

### ✅ Separation of Concerns
- Lógica de negócio isolada dos repositories
- Validações centralizadas e reutilizáveis
- Estatísticas coordenadas entre domínios

### ✅ Testability
- Services podem ser mockados independentemente
- Testes unitários mais focados
- Validações isoladas para testes específicos

### ✅ Maintainability
- Mudanças em regras de negócio localizadas
- Código mais legível e organizado
- Responsabilidades claras

## 🚀 Como Usar

### Regras de Negócio
```dart
// ANTES (deprecated)
final existe = await espacoRepository.existeComNome('Jardim');

// DEPOIS (recomendado)
final existe = await BusinessRulesService.instance
    .existeEspacoComNome('Jardim');
```

### Estatísticas
```dart
// ANTES (deprecated)  
final stats = await plantaRepository.getEstatisticas();

// DEPOIS (recomendado)
final stats = await StatisticsService.instance
    .getPlantaStatistics();
```

### Validações Completas
```dart
// NOVO - Validação completa com regras de negócio
final result = await ValidationService.instance
    .validateEspacoComplete(novoEspaco);
    
if (result.isSuccess) {
  // Proceder com criação
} else {
  // Tratar erro específico
}
```

## 🛠️ Migração Gradual

1. **Fase 1** (Atual): Métodos deprecated mantidos para compatibilidade
2. **Fase 2**: Migração gradual do código cliente para usar services
3. **Fase 3**: Remoção dos métodos deprecated (v2.0)

## 📝 Validação da Implementação

### ✅ Critérios Atendidos:
- [x] `getEstatisticas()` movido para StatisticsService
- [x] Validações centralizadas em ValidationService  
- [x] `existeComNome()` movido para BusinessRulesService
- [x] Repositories focam apenas em data access
- [x] Métodos legacy marcados como deprecated
- [x] Documentação atualizada com orientações
- [x] Compatibilidade mantida durante transição

### 🎉 Resultado:
Os repositories agora seguem o padrão de arquitetura limpa, com responsabilidades bem definidas e separação clara entre data access e lógica de negócio.