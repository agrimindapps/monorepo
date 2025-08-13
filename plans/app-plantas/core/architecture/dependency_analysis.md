# Análise de Dependências - Sistema de Plantas

## 🔄 Mapeamento de Dependências Atuais

### Dependências Identificadas

#### 1. **PlantaRepository**
```
PlantaRepository -> ITaskService (interface ✅)
PlantaRepository -> ServiceLocator (DI container ✅)
PlantaRepository -> SyncFirebaseService
PlantaRepository -> Optimization Services (MemoizationManager, etc.)
```

#### 2. **SimpleTaskService**
```
SimpleTaskService -> TarefaRepository (DEPENDÊNCIA DIRETA ⚠️)
SimpleTaskService -> PlantaConfigRepository (DEPENDÊNCIA DIRETA ⚠️)
SimpleTaskService -> CareTypeService
```

#### 3. **TarefaRepository**
```
TarefaRepository -> SyncFirebaseService
TarefaRepository -> Cache/Optimization Services
```

#### 4. **PlantaConfigRepository**
```
PlantaConfigRepository -> SyncFirebaseService
PlantaConfigRepository -> Cache/Optimization Services
```

#### 5. **EspacoRepository**
```
EspacoRepository -> SyncFirebaseService
EspacoRepository -> Cache/Optimization Services
```

## 🚨 Potenciais Dependências Circulares Identificadas

### Ciclo Crítico 1: PlantaRepository ↔ SimpleTaskService
```
PlantaRepository -> ITaskService (SimpleTaskService)
SimpleTaskService -> TarefaRepository
SimpleTaskService -> PlantaConfigRepository

RISCO: Se PlantaConfigRepository ou TarefaRepository dependerem de PlantaRepository
no futuro, teremos um ciclo.
```

### Ciclo Crítico 2: Services Interdependentes
```
Muitos Domain Services dependem diretamente de múltiplos repositories:
- PlantaCareOperationsService -> PlantaRepository + TarefaRepository
- PlantaStatisticsService -> PlantaRepository + TarefaRepository
- BusinessRulesService -> EspacoRepository + PlantaRepository
```

## ✅ Implementações Corretas Já Existentes

1. **ServiceLocator**: Sistema de DI básico já implementado
2. **Interface ITaskService**: PlantaRepository usa abstração correta
3. **InitializationManager**: Controla ordem de inicialização

## ❌ Problemas a Resolver

1. **Dependências Hardcoded**: Services ainda dependem diretamente de repositories
2. **Falta de Event Bus**: Comunicação direta entre componentes
3. **Service Dependencies**: Services não usam abstração de repositories
4. **Circular Reference Risk**: Alto risco de ciclos conforme sistema cresce

## 🎯 Estratégia de Solução

### Fase 1: Abstrair Dependências de Repositories
- Criar interfaces para todos repositories
- Atualizar ServiceLocator para gerenciar repositories
- Refatorar services para usar interfaces

### Fase 2: Implementar Event Bus
- Sistema de eventos desacoplado
- Publishers/Subscribers pattern
- Event-driven communication

### Fase 3: Domain Events
- Eventos de domínio específicos
- Eliminar dependências diretas através de eventos
- Implementar sagas para operações complexas

## 📊 Prioridade de Implementação

1. **CRÍTICA**: Abstrair repositories em interfaces
2. **ALTA**: Event bus para comunicação desacoplada
3. **MÉDIA**: Domain events e sagas
4. **BAIXA**: Advanced DI features