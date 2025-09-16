# Profile/Subscription Sync Melhorado - Plantis

## Visão Geral

Esta implementação substitui o sistema de sincronização simulado por uma implementação real e robusta baseada nos padrões estabelecidos nos outros apps do monorepo (app-receituagro e app-gasometer).

## Principais Melhorias Implementadas

### 1. **Integração Real com RevenueCat e Firebase**

- ✅ Substituição completa da simulação por implementação real
- ✅ Integração com o core package para serviços unificados
- ✅ Webhook processing para eventos premium em tempo real
- ✅ Cross-device sync com conflict resolution automático

### 2. **Arquitetura Stream-Based Reativa**

- ✅ Stream controllers para eventos em tempo real
- ✅ Real-time updates através do Firebase
- ✅ Estado reativo com notificação automática da UI
- ✅ Gerenciamento de recursos com dispose adequado

### 3. **Error Handling e Retry Logic Robustos**

- ✅ Retry exponencial para falhas de sincronização
- ✅ Limite de tentativas configurável (max 3 retries)
- ✅ Tratamento granular de diferentes tipos de erro
- ✅ Analytics detalhado para debug e monitoramento

### 4. **Features Específicas do Plantis**

- ✅ Limites de plantas dinâmicos baseados no status premium
- ✅ Notificações avançadas para usuários premium
- ✅ Backup em nuvem para dados das plantas
- ✅ Features premium específicas de plantas (identificação, diagnóstico)
- ✅ Configuração automática de funcionalidades baseada na assinatura

## Arquivos Implementados

### Core Service
- **`subscription_sync_service.dart`** - Serviço principal com sincronização cross-device

### Provider Melhorado
- **`premium_provider_improved.dart`** - Provider com funcionalidades avançadas

### Widgets de Demonstração
- **`sync_status_widget.dart`** - Widgets para monitorar sincronização em tempo real

## Como Usar

### 1. Integrar o Provider Melhorado

```dart
// No main.dart ou onde configura providers
MultiProvider(
  providers: [
    // ... outros providers
    ChangeNotifierProvider<PremiumProviderImproved>(
      create: (context) => PremiumProviderImproved(
        subscriptionRepository: GetIt.I<ISubscriptionRepository>(),
        authRepository: GetIt.I<IAuthRepository>(),
        analytics: GetIt.I<IAnalyticsRepository>(),
      ),
    ),
  ],
  child: MyApp(),
)
```

### 2. Usar nas Páginas

```dart
class PremiumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Premium')),
      body: Column(
        children: [
          // Status de sincronização em tempo real
          SyncStatusWidget(),

          // Features premium disponíveis
          PremiumFeaturesWidget(),

          // Debug info (apenas desenvolvimento)
          if (kDebugMode) SyncDebugWidget(),

          // Botões de ação
          Consumer<PremiumProviderImproved>(
            builder: (context, provider, child) {
              if (provider.isPremium) {
                return Text('Você tem acesso premium!');
              }

              return ElevatedButton(
                onPressed: provider.isLoading ? null : () {
                  // Comprar premium
                  provider.purchaseProduct('plantis_premium_monthly');
                },
                child: provider.isLoading
                  ? CircularProgressIndicator()
                  : Text('Assinar Premium'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 3. Verificar Features Premium

```dart
Consumer<PremiumProviderImproved>(
  builder: (context, provider, child) {
    return Column(
      children: [
        // Verificar limite de plantas
        if (provider.canCreateMorePlants(currentPlantCount))
          FloatingActionButton(
            onPressed: () => addNewPlant(),
            child: Icon(Icons.add),
          )
        else if (!provider.isPremium)
          UpgradePromptWidget(),

        // Features específicas
        if (provider.canIdentifyPlants())
          PlantIdentificationWidget(),

        if (provider.canDiagnoseDiseases())
          PlantDiagnosisWidget(),

        if (provider.canBackupToCloud())
          CloudBackupWidget(),
      ],
    );
  },
)
```

### 4. Monitorar Sincronização

```dart
Consumer<PremiumProviderImproved>(
  builder: (context, provider, child) {
    final syncStatus = provider.getSyncStatus();

    return Card(
      child: ListTile(
        leading: Icon(
          provider.isSyncing ? Icons.sync : Icons.check_circle,
          color: provider.hasSyncErrors ? Colors.red : Colors.green,
        ),
        title: Text('Sincronização'),
        subtitle: Text(
          provider.hasSyncErrors
            ? provider.syncErrorMessage ?? 'Erro desconhecido'
            : 'Última sync: ${syncStatus['lastSyncAt'] ?? 'Nunca'}',
        ),
        trailing: provider.isSyncing
          ? CircularProgressIndicator()
          : IconButton(
              icon: Icon(Icons.refresh),
              onPressed: provider.forceSyncSubscription,
            ),
      ),
    );
  },
)
```

## Features Premium Específicas do Plantis

### Limites e Recursos
- **Plantas**: Gratuito (5) / Premium (ilimitado)
- **Lembretes customizados**: Gratuito (3) / Premium (ilimitado)
- **Backup de fotos**: Gratuito (10MB) / Premium (1GB)

### Funcionalidades Premium
1. **🌱 Identificação de Plantas** - Reconhecimento por foto
2. **🩺 Diagnóstico de Doenças** - Análise de problemas nas plantas
3. **📊 Analytics Detalhados** - Estatísticas de crescimento
4. **🌤️ Notificações Meteorológicas** - Alertas baseados no clima
5. **📅 Calendário de Cuidados** - Planejamento avançado
6. **☁️ Backup na Nuvem** - Sincronização de dados
7. **🎨 Temas Personalizados** - Customização visual
8. **📤 Exportar Dados** - Relatórios e backups

## Eventos de Sincronização

O sistema emite eventos em tempo real que podem ser monitorados:

```dart
provider.syncService.syncEventsStream.listen((event) {
  switch (event.type) {
    case PlantisSubscriptionSyncEventType.success:
      showSnackBar('Sincronização concluída!');
      break;
    case PlantisSubscriptionSyncEventType.purchased:
      showSnackBar('Nova compra detectada!');
      break;
    case PlantisSubscriptionSyncEventType.failed:
      showErrorDialog(event.error);
      break;
  }
});
```

## Configuração de Analytics

Todos os eventos são logados automaticamente:

```dart
// Eventos automaticamente logados:
- plantis_subscription_sync_started
- plantis_subscription_sync_completed
- plantis_purchase_completed
- plantis_features_processed
- plantis_conflict_resolved
- plantis_sync_error
```

## Conflict Resolution

O sistema detecta e resolve automaticamente conflitos entre dispositivos:

1. **Premium Status Mismatch** - Quando um device mostra premium e outro não
2. **Product Mismatch** - Diferentes produtos ativos em diferentes devices
3. **Timestamp Conflicts** - Dados desatualizados entre devices

Estratégia: **Server Wins** - O RevenueCat é sempre a fonte da verdade.

## Testing e Debug

### Debug Info
```dart
// Obtém informações completas para debug
final debugInfo = provider.getDebugInfo();
print('Subscription: ${debugInfo['subscription']}');
print('Sync Status: ${debugInfo['sync']}');
print('Features: ${debugInfo['features']}');
```

### Logs de Debug
```dart
// Habilitar logs detalhados
debugPrint('[PlantisSync] Sincronização iniciada');
debugPrint('[PlantisSync] ${premiumFeaturesEnabled.length} features habilitadas');
```

## Migração da Implementação Antiga

1. **Substituir Provider**: Trocar `PremiumProvider` por `PremiumProviderImproved`
2. **Atualizar Injeção**: Adicionar `IAnalyticsRepository` nas dependências
3. **Adaptar UI**: Usar novos getters e métodos disponíveis
4. **Configurar Widgets**: Adicionar widgets de monitoramento se desejado

## Considerações de Performance

- ✅ Sincronização automática a cada 15 minutos (configurável)
- ✅ Debounce em mudanças para evitar sync excessivo
- ✅ Cache local para reduzir chamadas ao Firebase
- ✅ Cleanup automático de recursos não utilizados
- ✅ Retry exponencial para reduzir carga em caso de falhas

## Segurança

- ✅ Validação de dados de webhook do RevenueCat
- ✅ Sanitização de parâmetros de analytics
- ✅ Verificação de autenticação antes de cada operação
- ✅ Logs não incluem informações sensíveis

---

## Próximos Passos Sugeridos

1. **Testes de Integração** - Testar fluxo completo com RevenueCat/Firebase
2. **A/B Testing** - Comparar performance com implementação anterior
3. **Monitoring** - Configurar alertas para falhas de sincronização
4. **Documentation** - Atualizar docs da API para webhooks
5. **Performance Testing** - Validar behavior sob carga

Esta implementação estabelece uma base sólida e escalável para o sistema premium do Plantis, seguindo os padrões de qualidade estabelecidos no monorepo.