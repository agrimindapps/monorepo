# Auditoria de Compra In‑App do Gasometer — 07/10/2025

## Escopo
- Avaliar a implementação atual de compra in‑app (IAP) dentro de `apps/app-gasometer`.
- Rastrear como a funcionalidade consome serviços compartilhados de `packages/core`.
- Destacar pontos fortes, riscos e oportunidades concretas de melhoria para agentes subsequentes.

## Visão Geral da Arquitetura
- **Apresentação**: `PremiumNotifier` orquestra o estado, chamando casos de uso como `PurchasePremium` e `GetAvailableProducts`.
- **Domínio/Dados**: `PremiumRepositoryImpl` delega operações remotas para `PremiumRemoteDataSourceImpl`, cache local para `PremiumLocalDataSourceImpl` e sincronização entre dispositivos para `PremiumSyncService`.
- **Integração Core**: `PremiumRemoteDataSourceImpl` encapsula `core.ISubscriptionRepository` (atualmente vinculado a `core.RevenueCatService`) para operações do RevenueCat (`purchaseProduct`, `restorePurchases`, `subscriptionStatus`, etc.).
- **DI**: `CoreModule` registra `core.RevenueCatService` como a implementação compartilhada de `ISubscriptionRepository`, expondo‑a à camada de app via GetIt/Injectable.

## Pontos Fortes Observados
- A separação em camadas está consistente: apresentação → domínio → repositório → fontes de dados → serviço core.
- `PremiumSyncService` já agrega RevenueCat, cache Firebase e atualizações via webhook, fornecendo um único stream para a UI.
- Hierarquia de falhas abrangente em `packages/core` permite tratamento de erro refinado, quando corretamente propagado.
- A fonte de dados remota expõe `setUser`, `restorePurchases` e `getManagementUrl`, mantendo o app pronto para fluxos de conta mais ricos.

## Problemas e Oportunidades

## Análise Técnica Detalhada

### Arquitetura de Camadas e Fluxo de Dados
- **Camada de Apresentação** (`PremiumNotifier`):
  - Responsável por expor `Stream<PremiumState>` para a UI.
  - Utiliza casos de uso (`PurchasePremium`, `GetAvailableProducts`) que são injetados via **GetIt**.
  - **Exemplo**:
    ```dart
    class PremiumNotifier extends ChangeNotifier {
      final PurchasePremium purchasePremium;
      final GetAvailableProducts getAvailableProducts;

      PremiumNotifier({required this.purchasePremium, required this.getAvailableProducts});

      Future<void> loadProducts() async {
        final products = await getAvailableProducts();
        _availableProducts = products;
        notifyListeners();
      }
    }
    ```
- **Camada de Domínio** (`PremiumRepositoryImpl`):
  - Orquestra chamadas ao `RemoteDataSource` e ao `LocalDataSource`.
  - Converte falhas do core (`core.Failure`) em falhas de domínio (`PremiumFailure`).
- **Camada de Dados** (`PremiumRemoteDataSourceImpl`):
  - Wrapper thin sobre `core.ISubscriptionRepository`.
  - **Ponto crítico**: a maioria das regras de negócio (e.g., elegibilidade de trial) está aqui, mas ainda depende de convenções de nomes de produto.
- **Integração Core** (`RevenueCatService`):
  - Implementa `ISubscriptionRepository` usando o SDK do RevenueCat.
  - Expondo métodos como `configure`, `purchaseProduct`, `getCustomerInfo`.

### Fluxo de Inicialização Atual
1. `CoreModule` registra `RevenueCatService`.
2. `AppInitializer` (ou similar) chama `RevenueCatService.configure()`.
3. `PremiumSyncService` escuta `onAuthStateChanged` e tenta sincronizar.
4. `PremiumNotifier` solicita `GetAvailableProducts` que delega ao `RemoteDataSource`.

**Problema**: o **snapshot inicial** da assinatura não é emitido após `configure()`, resultando em estado `free` temporário.

---

### 1. Incompatibilidade de catálogo RevenueCat (bloqueador)
- **Evidência**: `GasometerEnvironmentConfig.monthlyProductId`/`yearlyProductId` referenciam `gasometer_premium_*`, enquanto `RevenueCatService.getGasometerProducts()` solicita `gasometer_monthly`/`gasometer_yearly` (`packages/core/lib/src/infrastructure/services/revenue_cat_service.dart`).
- **Impacto**: `getAvailableProducts()` devolve lista vazia, quebrando a exibição de produtos e as compras.
- **Análise Profunda**:
  - O desacoplamento entre **configuração de ambiente** e **código de serviço** viola o princípio *Single Source of Truth*.
  - Qualquer mudança no console do RevenueCat exige duas atualizações manuais, aumentando risco de regressão.
- **Exemplo de Código Problemático**:
    ```dart
    // packages/core/lib/src/infrastructure/services/revenue_cat_service.dart
    static const _monthlyId = 'gasometer_monthly';
    static const _yearlyId = 'gasometer_yearly';
    
    List<String> getGasometerProducts() => [_monthlyId, _yearlyId];
    ```
  - Enquanto no app:
    ```dart
    class GasometerEnvironmentConfig {
      static const monthlyProductId = 'gasometer_premium_monthly';
      static const yearlyProductId = 'gasometer_premium_yearly';
    }
    ```
- **Tarefas Detalhadas**:
  1. Criar enum `ProductId` em `packages/core/lib/src/domain/models/product_id.dart` contendo os IDs canônicos.
  2. Atualizar `GasometerEnvironmentConfig` para ler os valores de `ProductId` via `String.fromEnvironment` ou `.env`.
  3. Refatorar `RevenueCatService.getGasometerProducts()` para usar o mesmo enum.
  4. Adicionar teste unitário `RevenueCatService_productIds_match_test.dart` que verifica a equivalência entre os IDs expostos e os configurados.
  5. Documentar o processo de atualização de IDs no `README.md` do core.

---

### 2. Usuário RevenueCat nunca identificado (crítico)
- **Evidência**: Nenhum chamador invoca `PremiumRepository.setUser`; `_onAuthStateChanged` em `PremiumSyncService` nunca chega ao `logIn` do RevenueCat.
- **Impacto**: As compras podem ficar vinculadas a usuários anônimos do RevenueCat, causando perda de direitos após logout ou em outros dispositivos.
- **Análise Profunda**:
  - O fluxo de autenticação está desacoplado da camada de subscrição; o `PremiumSyncService` deveria observar o `AuthNotifier` (ou similar) e propagar o `userId`.
  - Falta de chamada a `Purchases.logOut()` impede a limpeza correta de sessões.
- **Exemplo de Código Atual**:
    ```dart
    class PremiumSyncService {
      void _onAuthStateChanged(User? user) {
        // TODO: chamar setUser no repositório
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Injetar `AuthNotifier` (ou `FirebaseAuth`) no `PremiumSyncService`.
  2. Implementar método `_handleAuthChange(User? user)` que:
     - Se `user != null` → `await premiumRepository.setUser(user.id, attributes)`;
     - Se `user == null` → `await subscriptionRepository.logOut();`.
  3. Atualizar `PremiumRepository.setUser` para delegar ao `ISubscriptionRepository.setUser`.
  4. Criar teste de integração `premium_sync_auth_flow_test.dart` simulando login/logout e verificando chamadas ao SDK RevenueCat.
  5. Garantir que o `AppInitializer` registre o listener de auth antes de iniciar o `PremiumSyncService`.

---

### 3. Stream de assinatura sem snapshot inicial
- **Evidência**: `RevenueCatService` só emite atualizações quando `CustomerInfo` muda; não há emissão inicial após `configure()`.
- **Impacto**: `PremiumSyncService` inicia com `PremiumStatus.free` mesmo quando há compras, até que a primeira atualização externa ocorra.
- **Análise Profunda**:
  - O SDK do RevenueCat oferece `Purchases.getCustomerInfo()` que retorna o estado atual; não utilizá‑lo resulta em *race condition* entre UI e backend.
  - A ausência de um *seed* impede que a camada de domínio tenha consistência imediata.
- **Código Proposto**:
    ```dart
    class RevenueCatService implements ISubscriptionRepository {
      final _controller = StreamController<SubscriptionEntity>.broadcast();

      Future<void> configure() async {
        await Purchases.configure(...);
        // Emitir snapshot inicial
        final info = await Purchases.getCustomerInfo();
        _controller.add(_mapCustomerInfo(info));
        // Escutar mudanças
        Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Implementar método `Future<SubscriptionEntity?> seed()` que chama `Purchases.getCustomerInfo()`.
  2. Modificar `PremiumSyncService` para aguardar `seed()` antes de expor o stream.
  3. Adicionar teste unitário `revenue_cat_service_initial_snapshot_test.dart` que verifica a primeira emissão.
  4. Atualizar documentação do serviço em `README_CORE.md`.

---

### 4. Mensagens de falha degradadas na camada de app
- **Evidência**: `PremiumRemoteDataSourceImpl` converte `core.Failure` em `ServerFailure(coreFailure.toString())`, perdendo a `message` original.
- **Impacto**: UI mostra `Instance of 'SubscriptionPaymentFailure'` ao invés de strings localizadas.
- **Análise Profunda**:
  - A perda de contexto das falhas dificulta o diagnóstico e a experiência do usuário.
  - A conversão genérica para `ServerFailure` oculta detalhes importantes.
- **Exemplo de Código Problemático**:
    ```dart
    class PremiumRemoteDataSourceImpl {
      Future<void> purchaseProduct(...) async {
        try {
          // chamada ao core
        } on core.Failure catch (coreFailure) {
          throw ServerFailure(coreFailure.toString());
        }
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Propagar `coreFailure.message` e `code` ao envolver falhas.
  2. Expandir `_mapFailure` em `PremiumRepositoryImpl` com `switch` explícito nos tipos de falha concretos, ao invés de comparar `runtimeType` como string.
  3. Criar teste unitário `premium_repository_failure_mapping_test.dart` que valida a conversão correta de falhas.
  4. Atualizar documentação em `README.md` sobre a nova estratégia de mapeamento de falhas.

---

### 5. Elegibilidade para trial contornada
- **Evidência**: `PremiumRemoteDataSourceImpl.isEligibleForTrial()` simplesmente nega `hasActiveSubscription()`.
- **Impacto**: Ignora a elegibilidade do RevenueCat (ex.: usuário já consumiu oferta introdutória em outra plataforma).
- **Análise Profunda**:
  - A lógica atual não considera o histórico do usuário em outras plataformas ou ofertas.
  - A dependência de um único método para determinar elegibilidade pode levar a erros.
- **Exemplo de Código Problemático**:
    ```dart
    class PremiumRemoteDataSourceImpl {
      bool isEligibleForTrial(String productId) {
        return !hasActiveSubscription();
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Invocar `subscriptionRepository.isEligibleForTrial(productId: …)` com os IDs de catálogo do Gasometer.
  2. Expor status de trial ao `PremiumNotifier` para mensagens UI precisas.
  3. Criar teste de unidade `premium_remote_data_source_eligibility_test.dart` que valida a lógica de elegibilidade.
  4. Atualizar documentação em `README.md` sobre a nova lógica de elegibilidade.

---

### 6. Mapeamento incorreto de userId dentro de RevenueCatService
- **Evidência**: `_mapEntitlementToSubscription` define `userId` como `entitlement.originalPurchaseDate.toString()`.
- **Impacto**: `SubscriptionEntity.userId` armazenado torna‑se sem sentido, impedindo análises ou resolução de conflitos por usuário.
- **Análise Profunda**:
  - O `userId` deve ser único e imutável, ligado à identidade do usuário, não a um atributo volátil como a data de compra.
  - A correlação incorreta pode causar problemas em relatórios e na lógica de negócios que depende da identidade do usuário.
- **Exemplo de Código Problemático**:
    ```dart
    class RevenueCatService {
      SubscriptionEntity _mapEntitlementToSubscription(Entitlement entitlement) {
        return SubscriptionEntity(
          userId: entitlement.originalPurchaseDate.toString(),
          // outros mapeamentos
        );
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Passar `CustomerInfo.originalAppUserId` para o mapper e persistir como `userId`.
  2. Retroalimentar documentos Firebase (`user_subscriptions`/`premium_cache`) durante a próxima sincronização para reparar registros existentes.
  3. Criar teste de unidade `revenue_cat_service_userId_mapping_test.dart` que valida o mapeamento correto do userId.
  4. Atualizar documentação em `README.md` sobre a estratégia de mapeamento de userId.

---

### 7. Carregador de chaves de ambiente é um stub
- **Evidência**: `EnvironmentConfig.getApiKey` ignora `keyName` e devolve valores fallback/dummy.
- **Impacto**: Builds de produção correm risco de usar chaves placeholder do RevenueCat, a menos que sobrescritas manualmente.
- **Análise Profunda**:
  - O uso de valores dummy em produção pode levar a falhas silenciosas, onde funcionalidades críticas não operam como esperado.
  - A ausência de validação para chaves ausentes pode causar comportamentos inesperados em tempo de execução.
- **Exemplo de Código Problemático**:
    ```dart
    class EnvironmentConfig {
      static String getApiKey(String keyName) {
        return 'DUMMY_API_KEY';
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Implementar recuperação segura (ex.: `const String.fromEnvironment`, canais de plataforma, ou `.env` injetado) e validar quando chaves estiverem ausentes.
  2. Atualizar `GasometerEnvironmentConfig.revenueCatApiKey` para alimentar a chave resolvida na inicialização do RevenueCat ao invés de um fallback hard‑coded.
  3. Criar teste de unidade `environment_config_api_key_loading_test.dart` que valida o carregamento correto da chave da API.
  4. Atualizar documentação em `README.md` sobre a estratégia de carregamento de chaves de ambiente.

---

### 8. Perda de metadados do produto
- **Evidência**: `_mapStoreProductToProductInfo` descarta `introPrice`, `freeTrialPeriod` e `discounts`, embora `ProductInfo` os modele.
- **Impacto**: Paywall não consegue comunicar promoções ou trials de forma correta.
- **Análise Profunda**:
  - A falta de metadados pode resultar em perda de receita, pois usuários não são expostos a ofertas promocionais.
  - A UI do paywall fica incompleta, afetando a conversão de usuários gratuitos para pagos.
- **Exemplo de Código Problemático**:
    ```dart
    class ProductMapper {
      ProductInfo _mapStoreProductToProductInfo(StoreProduct product) {
        return ProductInfo(
          // campos obrigatórios
        );
      }
    }
    ```
- **Tarefas Detalhadas**:
  1. Popular `introPrice`, `freeTrialPeriod` e `subscriptionPeriod` usando os dados de `Package.storeProduct`.
  2. Atualizar widgets UI (`premium_products_list.dart`) para exibir os campos adicionais assim que disponíveis.
  3. Criar teste de unidade `product_mapper_metadata_test.dart` que valida o mapeamento correto dos metadados do produto.
  4. Atualizar documentação em `README.md` sobre a estratégia de mapeamento de produtos.

---

### 9. Fallback para Web / plataformas não suportadas
- **Evidência**: No web, `_ensureInitialized()` lança `NOT_AVAILABLE`, mas os chamadores não protegem as operações.
- **Impacto**: Builds de web travam ao invés de desabilitar compras de forma graciosa.
- **Ações**:
  - [ ] Guardar fluxos premium atrás de `Platform.isIOS/Android` (ou injetar capacidade via `EnvironmentConfig`).
  - [ ] Expor um stub `ISubscriptionRepository` para web/testes retornando flags de recurso sem lançar exceções.

### 9.1. UI alternativa para Web (sem assinatura)
- **Contexto**: Na versão web o modelo de assinatura não está disponível; portanto a tela tradicional de *In‑App Purchase* não deve ser exibida.
- **Comportamento desejado**: Na página de **Configurações** exibir um *card* informativo contendo:
  1. **Data de início** do plano (ou data de criação da conta, caso não haja plano ativo).
  2. **Tipo de plano** (ex.: Free, Premium Monthly, Premium Yearly).
  3. **Data de término** (se aplicável) ou indicação de plano vitalício.
  4. **Dias restantes** até o término do plano.
- **Exemplo de implementação Flutter** (Web compatible):
    ```dart
    class WebPlanInfoCard extends StatelessWidget {
      final DateTime startDate;
      final DateTime? endDate; // null = vitalício
      final String planName;

      const WebPlanInfoCard({
        Key? key,
        required this.startDate,
        required this.planName,
        this.endDate,
      }) : super(key: key);

      @override
      Widget build(BuildContext context) {
        final now = DateTime.now();
        final daysRemaining = endDate != null ? endDate!.difference(now).inDays : null;
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plano: $planName', style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 8),
                Text('Início: ${DateFormat.yMMMd().format(startDate)}'),
                if (endDate != null) ...[
                  Text('Fim: ${DateFormat.yMMMd().format(endDate!)}'),
                  Text('Dias restantes: $daysRemaining'),
                ] else
                  const Text('Plano vitalício'),
              ],
            ),
          ),
        );
      }
    }
    ```
- **Tarefas detalhadas**:
  1. Criar o widget `WebPlanInfoCard` em `apps/app-gasometer/lib/widgets/web_plan_info_card.dart`.
  2. Atualizar a tela de **Configurações** (`settings_page.dart`) para detectar a plataforma (`kIsWeb`) e, ao invés de navegar para a tela de IAP, inserir o `WebPlanInfoCard`.
  3. Implementar um método `SubscriptionRepository.getCurrentPlanInfo()` que, no web, retorna um objeto estático ou mockado contendo as informações acima.
  4. Adicionar teste unitário `web_plan_info_card_test.dart` verificando renderização correta dos campos e cálculo de dias restantes.
  5. Documentar o comportamento na seção "Fallback para Web" do README do core.

## Cobertura de Testes Sugerida
- Teste unitário para `PremiumRemoteDataSource.purchaseProduct` simulando `ISubscriptionRepository` para garantir que mensagens de falha sejam propagadas.
- Teste de integração (widget ou nível de serviço) simulando atualizações de `CustomerInfo` para validar snapshot inicial e emissões de stream.
- Teste de contrato para alinhamento entre `EnvironmentConfig.getProductId` e `RevenueCatService.getGasometerProducts`.

## Próximos Passos para Agentes Subsequentes
| Prioridade | Tarefa | Dica de Responsável | Dependências |
| --- | --- | --- | --- |
| 🔴 | Alinhar IDs de produto e adicionar teste de regressão para ofertas | Core + equipe do app Gasometer | Confirmar nomenclatura do catálogo RevenueCat |
| 🔴 | Chamar `PremiumRepository.setUser` no login/logout, garantir `Purchases.logOut()` no logout | Equipe de autenticação do app | Ganchos do notifier de auth |
| 🟠 | Emitir snapshot de assinatura inicial após configuração | Time de subscriptions core | Acesso à API `Purchases` |
| 🟠 | Preservar `Failure.message` através das camadas de repositório/dados | Time premium do app | Refatorar adaptadores de erro |
| 🟡 | Implementar carregador real de chaves de ambiente e validar chaves ausentes | Infraestrutura de plataforma | Estratégia de segredos de deployment |
| 🟡 | Preencher `ProductInfo` com metadados de intro/trial e atualizar UI do paywall | Time premium do app | Depende do #1 |
| 🟡 | Fornecer stub de repositório de assinatura seguro para web | Time de subscriptions core | Utilitário de detecção de plataforma |

> ✅ **Entregável**: Compartilhar este relatório com o squad, alinhar responsabilidades e, em seguida, criar tickets dedicados referenciando as seções acima.
