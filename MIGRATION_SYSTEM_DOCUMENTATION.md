# Sistema de Migração de Dados Anônimos - Documentação Completa

## 📋 Visão Geral

Este sistema foi desenvolvido para gerenciar a migração de dados entre usuários anônimos e contas registradas no monorepo Flutter. O sistema permite que usuários que iniciaram usando o app anonimamente possam fazer login com uma conta existente, resolvendo conflitos de dados de forma inteligente e user-friendly.

## 🏗️ Arquitetura do Sistema

### **Shared Components (packages/core)**

#### **Entidades de Domínio**
```
packages/core/lib/src/domain/entities/data_migration/
├── data_resolution_choice.dart      # Enum com opções de resolução
├── anonymous_data.dart              # Classe base para dados anônimos
├── account_data.dart                # Classe base para dados de conta
└── data_conflict_result.dart        # Resultado da detecção de conflitos
```

#### **Serviços de Infraestrutura**
```
packages/core/lib/src/infrastructure/services/
├── data_migration_service.dart      # Serviço base de migração
└── anonymous_data_cleaner.dart      # Serviço de limpeza de dados anônimos
```

#### **Componentes de UI**
```
packages/core/lib/src/presentation/widgets/data_migration/
├── data_conflict_dialog.dart        # Dialog de resolução de conflitos
└── migration_progress_dialog.dart   # Dialog de progresso da migração
```

### **App-Specific Implementation (app-gasometer)**

#### **Entidades Específicas**
```
lib/features/data_migration/domain/entities/
├── gasometer_anonymous_data.dart    # Dados anônimos do gasometer
└── gasometer_account_data.dart      # Dados de conta do gasometer
```

#### **Implementação de Serviços**
```
lib/features/data_migration/data/
├── services/gasometer_data_migration_service.dart      # Serviço específico
└── datasources/gasometer_migration_data_source.dart    # DataSource interface
└── datasources/gasometer_migration_data_source_impl.dart  # DataSource implementação
```

#### **Componentes de Apresentação**
```
lib/features/data_migration/presentation/
├── providers/data_migration_provider_fixed.dart        # Provider para estado
├── widgets/migration_integration_handler.dart          # Handler de integração
└── pages/migration_example_page.dart                   # Página de exemplo
```

## 🔄 Fluxo de Funcionamento

### **1. Detecção de Conflitos**
1. Usuário anônimo tenta fazer login com conta existente
2. Sistema coleta dados do usuário anônimo (veículos, abastecimentos, etc.)
3. Sistema coleta dados da conta existente
4. Sistema compara os dados e determina se há conflitos

### **2. Apresentação de Opções**
Se houver conflitos, o usuário pode escolher:
- **Manter dados da conta**: Remove todos os dados anônimos
- **Manter dados anônimos**: Redireciona para criação de nova conta
- **Cancelar**: Retorna ao estado anterior

### **3. Execução da Resolução**
- **Manter dados da conta**: Limpa dados locais → Remove dados remotos → Deleta conta anônima
- **Manter dados anônimos**: Guia o usuário para registro
- **Cancelar**: Não faz alterações

### **4. Feedback ao Usuário**
- Progresso em tempo real
- Mensagens de status
- Avisos e confirmações
- Tratamento de erros

## 🎯 Componentes Principais

### **DataResolutionChoice**
Enum que define as opções disponíveis para resolver conflitos:
```dart
enum DataResolutionChoice {
  keepAccountData,    // Manter dados da conta
  keepAnonymousData,  // Manter dados anônimos  
  cancel             // Cancelar operação
}
```

### **DataConflictDialog**
Widget que apresenta o conflito ao usuário com:
- Comparação visual dos dados
- Indicador de severidade do conflito
- Recomendações do sistema
- Confirmação para ações destrutivas

### **MigrationProgressDialog**
Widget que mostra o progresso da migração:
- Barra de progresso
- Operação atual sendo executada
- Tempo estimado restante
- Botão de cancelamento (opcional)

### **DataMigrationService**
Serviço abstrato que define a interface para:
- Detecção de conflitos
- Execução da resolução escolhida
- Validação de pré-condições
- Cancelamento de operações

## 🛠️ Como Integrar em Outros Apps

### **1. Criar Entidades Específicas**
```dart
// Exemplo para app-plantis
class PlantisAnonymousData extends AnonymousData {
  final int plantCount;
  final int careRecordCount;
  
  // Implementar métodos abstratos
  @override
  String get summary => '$plantCount plantas, $careRecordCount cuidados';
}
```

### **2. Implementar DataSource**
```dart
abstract class PlantisMigrationDataSource {
  Future<Either<Failure, PlantisAnonymousData>> getAnonymousData(String userId);
  Future<Either<Failure, PlantisAccountData>> getAccountData(String userId);
  // ... outros métodos
}
```

### **3. Criar Serviço de Migração**
```dart
class PlantisDataMigrationService extends BaseDataMigrationService {
  // Implementar métodos específicos do app-plantis
  @override
  Future<Either<Failure, DataConflictResult>> detectConflicts({...}) {
    // Lógica específica para detectar conflitos de plantas
  }
}
```

### **4. Integrar no Fluxo de Autenticação**
```dart
// No processo de login
MigrationIntegrationHandler(
  anonymousUserId: currentAnonymousUser.id,
  accountUserId: loggedInUser.id,
  onMigrationComplete: (result) {
    // Continuar fluxo de autenticação
  },
  onMigrationCanceled: () {
    // Retornar ao estado anterior
  },
)
```

## 🔧 Configuração e Dependências

### **Dependencies no pubspec.yaml**
```yaml
dependencies:
  core: ^1.0.0  # Package compartilhado
  provider: ^6.0.0
  dartz: ^0.10.0
  injectable: ^2.0.0
```

### **Registro de Dependências**
```dart
// No GetIt/Injectable
@module
abstract class DataMigrationModule {
  @lazySingleton
  GasometerDataMigrationService get migrationService;
  
  @lazySingleton  
  GasometerMigrationDataSource get dataSource;
}
```

### **Provider Setup**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => DataMigrationProvider(
        GetIt.instance<GasometerDataMigrationService>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

## ⚠️ Considerações Importantes

### **Segurança**
- Sempre validar que o usuário anônimo está autenticado
- Confirmar ações destrutivas com dupla confirmação
- Limpar dados sensíveis completamente
- Validar permissões antes de operações críticas

### **Performance**
- Executar limpeza em background quando possível
- Mostrar progresso para operações longas
- Implementar timeouts apropriados
- Usar paginação para grandes volumes de dados

### **UX/UI**
- Explicar claramente as consequências das ações
- Fornecer comparação visual dos dados
- Permitir cancelamento em operações não-críticas
- Dar feedback claro sobre sucesso/falha

### **Recuperação de Erros**
- Implementar retry logic para falhas temporárias
- Manter logs detalhados para debug
- Fornecer opções de recuperação manual
- Não deixar o sistema em estado inconsistente

## 🧪 Testes Recomendados

### **Testes Unitários**
- Detecção de conflitos com diferentes cenários de dados
- Execução de cada tipo de resolução
- Validação de pré-condições
- Tratamento de erros

### **Testes de Integração**
- Fluxo completo de migração
- Integração com Firebase
- Limpeza de dados local e remota
- Estados de loading e error

### **Testes de UI**
- Exibição correta de conflitos
- Navegação entre dialogs
- Responsividade em diferentes tamanhos de tela
- Acessibilidade

## 📊 Métricas e Monitoramento

### **Eventos Importantes para Rastrear**
- `migration_conflict_detected`: Quando conflitos são encontrados
- `migration_resolution_chosen`: Escolha do usuário
- `migration_completed`: Migração bem-sucedida
- `migration_failed`: Falha na migração
- `migration_canceled`: Cancelamento pelo usuário

### **Métricas de Sucesso**
- Taxa de conclusão de migrações
- Escolhas mais comuns dos usuários
- Tempo médio de migração
- Taxa de cancelamento
- Erros mais frequentes

## 🚀 Próximos Passos

### **Melhorias Futuras**
1. **Migração Inteligente**: Mesclar dados quando possível
2. **Backup Automático**: Criar backup antes de ações destrutivas
3. **Migração Offline**: Suporte para migração sem conexão
4. **Analytics Avançados**: Insights sobre padrões de uso
5. **Migração Programada**: Agendar migração para momentos ideais

### **Extensões Planejadas**
1. **Migração entre Apps**: Transferir dados entre diferentes apps
2. **Migração de Configurações**: Incluir preferências e configurações
3. **Migração Social**: Incluir dados de compartilhamento social
4. **API Externa**: Permitir migração via API para integrações

---

## 📞 Suporte e Contribuição

Para dúvidas sobre implementação ou extensão do sistema:
1. Consulte os exemplos em `app-gasometer`
2. Revise os testes unitários para entender o comportamento
3. Verifique logs de debug para troubleshooting
4. Contribua com melhorias via pull requests

**Este sistema está pronto para produção e pode ser reutilizado em todos os apps do monorepo com adaptações mínimas.**