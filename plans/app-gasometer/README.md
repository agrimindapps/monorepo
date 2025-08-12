# 🚗 App GasOMeter

## 📋 Visão Geral

O **GasOMeter** é um módulo Flutter para gerenciamento completo de veículos, focado no controle de combustível, manutenções e despesas automotivas. Oferece uma solução robusta para rastreamento de abastecimentos, cálculo de consumo, histórico de odômetro e gestão financeira veicular.

## 🎯 Propósito

Sistema modular para controle automotivo com:
- Gerenciamento de múltiplos veículos
- Rastreamento detalhado de abastecimentos
- Cálculo preciso de consumo médio
- Histórico de manutenções e despesas
- Notificações inteligentes para manutenções
- Sincronização online/offline com Firebase
- Exportação de dados e relatórios

## 🏗️ Arquitetura

### Padrões de Projeto Utilizados

#### 1. **Clean Architecture com Camadas**
```
📁 app-gasometer/
├── 📁 pages/          # Presentation Layer (UI)
├── 📁 controllers/    # Application Layer (GetX)
├── 📁 services/       # Domain Layer (Business Logic)
├── 📁 repository/     # Data Layer (Storage)
├── 📁 database/       # Entity Models (Hive)
└── 📁 di/            # Dependency Injection
```

#### 2. **GetX Pattern (State Management)**
- **Controllers**: Gerenciamento de estado reativo
- **Bindings**: Injeção de dependências por página
- **Routes**: Sistema de navegação declarativo
- **Workers**: Reactive programming com debounce/throttle

#### 3. **Repository Pattern**
- Abstração da fonte de dados (Hive/Firebase)
- CRUD operations padronizadas
- Sync mechanisms para offline-first

#### 4. **Dependency Injection Modular**
- **Core Module**: Repositories permanentes
- **Feature Modules**: Dependencies por funcionalidade
- **Modern Bindings**: Controllers com lifecycle adequado
- Elimina memory leaks e duplicações

#### 5. **Result Pattern (Error Handling)**
```dart
typedef GasometerResult<T> = Result<T, GasometerException>;
// Success ou Failure explícitos
// Context preservado em exceptions
// Recovery mechanisms automáticos
```

#### 6. **Service Layer Pattern**
- **Business Services**: Lógica de negócio isolada
- **Calculation Services**: Cálculos complexos
- **Validation Services**: Regras de validação
- **Export Services**: Geração de relatórios

#### 7. **Observer Pattern**
- RxDart para reactive streams
- Event Bus para comunicação entre componentes
- ValueNotifiers para UI updates

#### 8. **Singleton Pattern**
- BoxManager para gerenciamento de Hive
- DependencyManager para DI thread-safe
- ErrorHandler centralizado

## 📂 Estrutura de Pastas

### Camada de Apresentação (`pages/`)
```
pages/
├── cadastros/         # CRUD screens
│   ├── veiculos_page/
│   ├── abastecimento_page/
│   ├── manutencoes_page/
│   ├── despesas_page/
│   └── odometro_page/
├── resultados/        # Reports & Analytics
├── settings/          # Configuration
└── subscription/      # Premium features
```

### Camada de Controle (`controllers/`)
- `realtime_abastecimentos_controller.dart` - Sync em tempo real
- `auth_controller.dart` - Autenticação
- Controllers específicos por página com state management

### Camada de Serviços (`services/`)
```
services/
├── business_logic/    # Domain logic
│   ├── consumption_calculator_service.dart
│   ├── abastecimento_business_validator.dart
│   └── abastecimento_business_service.dart
├── error_handler.dart       # Error management
├── error_recovery.dart      # Recovery patterns
├── logging_service.dart     # Structured logging
└── dependency_manager.dart  # Thread-safe DI
```

### Camada de Dados (`repository/`)
- Repositories com BoxManager centralizado
- Híbrido online/offline com Firebase
- Adapters para serialização Hive

### Modelos (`database/`)
- Models com Hive annotations
- Generated adapters (`.g.dart`)
- Enums para tipos

### Injeção de Dependências (`di/`)
- Sistema modular hierárquico
- Core module com repositories permanentes
- Feature modules por funcionalidade
- Modern bindings sem memory leaks

### Tipos e Utilitários
- `types/result.dart` - Result pattern
- `errors/gasometer_exceptions.dart` - Exception hierarchy
- `translations/` - i18n support
- `widgets/` - Componentes reutilizáveis

## 🔧 Padrões Técnicos

### State Management
- **GetX** para reactive state
- **RxDart** para streams complexos
- **ValueNotifier** para UI simples
- **Computed properties** para derived state

### Error Handling
```dart
// Result Pattern
GasometerResult<Veiculo> result = await repository.getById(id);
result.when(
  onSuccess: (veiculo) => // handle success,
  onError: (error) => // handle error with context
);

// Exception Hierarchy
GasometerException
├── VeiculoException
├── AbastecimentoException
├── StorageException
└── NetworkException
```

### Dependency Injection
```dart
// Modular registration
GasometerCoreModule.registerDependencies();
VeiculosFeatureModule.registerDependencies();

// Page binding
class VeiculosPageBinding extends Bindings {
  void dependencies() {
    Get.lazyPut(() => VeiculosPageController());
  }
}
```

### Data Persistence
- **Hive** para storage local
- **Firebase Firestore** para cloud sync
- **SharedPreferences** para configurações
- **BoxManager** para lifecycle management

## 🚀 Funcionalidades Principais

### Gestão de Veículos
- Cadastro completo com fotos
- Múltiplos veículos por usuário
- Histórico detalhado
- Estatísticas individuais

### Controle de Abastecimentos
- Registro com odômetro, litros, valor
- Cálculo automático de consumo médio
- Detecção de anomalias
- Histórico com gráficos

### Manutenções Programadas
- Notificações inteligentes
- Histórico de serviços
- Controle de custos
- Lembretes por km ou tempo

### Análises e Relatórios
- Consumo médio por período
- Gastos totais e por categoria
- Exportação CSV/PDF
- Gráficos interativos

## 🔐 Segurança e Confiabilidade

### Thread Safety
- DependencyManager com Completer pattern
- Inicialização única garantida
- Race conditions eliminadas

### Memory Management
- Controllers com dispose adequado
- BoxManager com connection pooling
- Eliminação de fenix pattern problemático

### Data Validation
- Business rules robustas
- Validação em múltiplas camadas
- Sanitização de inputs
- Integridade referencial

## 📈 Melhorias Implementadas

### Sistema de DI Modular ✅
- Elimina duplicação de registros
- Remove memory leaks
- Organização hierárquica
- Test utilities integradas

### Error Handling Robusto ✅
- Exception hierarchy completa
- Result pattern implementation
- Recovery mechanisms
- Logging estruturado

### Business Logic Corrigida ✅
- Cálculo matemático preciso de consumo
- Validações de business rules
- Detecção de anomalias
- Testes unitários abrangentes

### Resource Management ✅
- BoxManager centralizado
- Lifecycle adequado
- Thread-safe operations
- Connection pooling

## 🎯 Próximos Passos

### Alta Prioridade
1. Separar responsabilidades dos controllers complexos
2. Implementar cache e otimização de queries
3. Adicionar controle de acesso por usuário
4. Melhorar performance da UI com lazy loading

### Média Prioridade
1. Sistema de retry para operações falhas
2. Padronizar nomenclatura (PT → EN)
3. Implementar Use Cases pattern
4. Batch operations para sync

### Baixa Prioridade
1. Configurar valores hardcoded como constantes
2. Melhorar feedback visual de loading
3. Documentar APIs públicas
4. Adicionar cobertura de testes

## 🛠️ Configuração para Desenvolvimento

### Dependências Necessárias
```yaml
dependencies:
  get: ^4.6.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  firebase_core: ^2.15.0
  cloud_firestore: ^4.8.0
```

### Inicialização
```dart
// No main.dart ou módulo principal
await GasometerHiveService.initialize();
await GasometerDIManager.instance.initializeAll();
```

### Rotas
```dart
// Adicionar ao GetMaterialApp
getPages: [
  ...GasometerPages.routes,
]
```

## 📚 Documentação Adicional

- [Sistema de DI](./di/README_DI_SYSTEM.md) - Arquitetura de injeção de dependências
- [Issues e Melhorias](./issues.md) - Backlog técnico detalhado
- [Database Inspector](../core/services/README_database_inspector.md) - Ferramenta de debug

## 🤝 Contribuição

Para manter a qualidade e consistência do código:

1. **Siga os padrões estabelecidos** - Clean Architecture, GetX pattern
2. **Use o sistema de DI modular** - Evite registros duplicados
3. **Implemente error handling adequado** - Result pattern com exceptions tipadas
4. **Adicione testes** - Unitários para business logic
5. **Documente mudanças** - Atualize este README e issues.md

## ⚠️ Avisos Importantes

### Para IA/Desenvolvimento Assistido

1. **SEMPRE use BoxManager** para Hive operations - NUNCA abra/feche boxes manualmente
2. **EVITE fenix pattern** em GetX bindings - Causa memory leaks
3. **USE Result pattern** para operações que podem falhar
4. **MANTENHA backward compatibility** ao refatorar
5. **TESTE edge cases** - Primeiro abastecimento, reset odômetro, etc.
6. **PRESERVE contexto em exceptions** - Facilita debugging
7. **USE services especializados** - Não misture business logic em controllers

### Armadilhas Comuns

❌ **NÃO FAÇA:**
```dart
// Manual box management
final box = await Hive.openBox('veiculos');
// ... uso
await box.close();

// Fenix pattern
Get.lazyPut(() => Controller(), fenix: true);

// Business logic em controllers
class Controller {
  double calcularConsumo() { /* lógica */ }
}
```

✅ **FAÇA:**
```dart
// BoxManager centralizado
final box = await BoxManager.instance.getBox<Veiculo>('veiculos');

// Modern binding sem fenix
Get.lazyPut(() => Controller());

// Business logic em services
class ConsumptionService {
  double calculate() { /* lógica */ }
}
```

## 📊 Métricas de Qualidade

- **Cobertura de Testes**: Meta 80%+ para business logic
- **Análise Estática**: Zero errors críticos
- **Performance**: <16ms frame time
- **Memory**: Stable usage sem leaks
- **Crashes**: <0.1% crash rate

## 📝 Licença

Proprietário - Todos os direitos reservados

---

*Última atualização: 2025.08*
*Versão do documento: 1.0.0*