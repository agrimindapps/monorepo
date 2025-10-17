# Premium Features Guide - ReceituAgro

## 📊 Feature Matrix

| Feature | Free Tier | Premium | Implementação |
|---------|-----------|---------|---------------|
| **Comentários** | ❌ | ✅ Ilimitado | ✅ Completo |
| **Favoritos Diagnósticos** | ❌ | ✅ Ilimitado | ✅ Completo |
| **Favoritos Defensivos** | ❌ | ✅ Ilimitado | ✅ Completo |
| **Favoritos Pragas** | ❌ | ✅ Ilimitado | ✅ Completo |
| **Sync** | ❌ | ✅ | 🔄 Parcial |
| **Export PDF** | ❌ | ✅ | 🔄 Planejado |

---

## 🏗️ Como Implementar Nova Premium Feature

### **Passo 1: Adicionar ao PremiumFeature enum**

```dart
// lib/core/services/premium_service.dart
enum PremiumFeature {
  advancedDiagnostics,
  offlineMode,
  unlimitedSearches,
  exportReports,
  prioritySupport,
  additionalDevices,
  customBranding,
  myNewFeature, // ← Adicionar aqui
}
```

### **Passo 2: Verificar Premium no Widget**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/premium_notifier.dart';
import '../../core/constants/premium_design_tokens.dart';

class MyFeatureWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumNotifierProvider);
    final isPremium = premiumAsync.value?.isPremium ?? false;

    if (!isPremium) {
      return _buildPremiumRequiredCard(context);
    }

    // Feature premium aqui
    return _buildFeatureContent();
  }

  Widget _buildPremiumRequiredCard(BuildContext context) {
    return Center(
      child: Container(
        width: PremiumDesignTokens.premiumCardWidth,
        margin: EdgeInsets.all(PremiumDesignTokens.premiumCardMargin),
        padding: EdgeInsets.all(PremiumDesignTokens.premiumCardPadding),
        decoration: PremiumDesignTokens.getPremiumCardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumDesignTokens.getPremiumIcon(),
            SizedBox(height: PremiumDesignTokens.verticalSpacingMedium),
            Text(
              'Minha Feature Premium não disponível',
              style: PremiumDesignTokens.premiumTitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: PremiumDesignTokens.verticalSpacingSmall),
            Text(
              PremiumDesignTokens.featureRequiredMessage,
              style: PremiumDesignTokens.premiumDescriptionStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: PremiumDesignTokens.verticalSpacingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    PremiumDesignTokens.subscriptionRoute,
                  );
                },
                icon: PremiumDesignTokens.getUpgradeButtonIcon(),
                label: Text(
                  PremiumDesignTokens.upgradeButtonText,
                  style: PremiumDesignTokens.upgradeButtonStyle,
                ),
                style: PremiumDesignTokens.getUpgradeButtonStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **Passo 3: Setup Analytics**

```dart
import '../../features/analytics/analytics_service.dart';

final analytics = ref.read(analyticsServiceProvider);

// Quando usuário free tenta acessar
await analytics.logEvent(
  PremiumDesignTokens.premiumAttemptEvent,
  {
    'feature_name': 'my_new_feature',
    'user_type': 'free',
  },
);

// Quando clica em upgrade
await analytics.logEvent(
  PremiumDesignTokens.premiumUpgradeClickedEvent,
  {
    'feature_name': 'my_new_feature',
    'source': 'feature_lock_screen',
  },
);
```

### **Passo 4: Adicionar Feature Flag (Opcional)**

```dart
// lib/core/constants/receituagro_environment_config.dart
class ReceitaAgroFeatureFlag {
  static const String enableMyNewFeature = 'enable_my_new_feature';
}

// lib/core/providers/premium_notifier.dart
bool hasFeatureAccess(PremiumFeature feature) {
  // Verificar feature flag primeiro
  if (!_remoteConfig.isFeatureEnabled(
    ReceitaAgroFeatureFlag.enableMyNewFeature
  )) {
    return false;
  }

  // Depois verifica subscription
  return currentState.status.hasFeature(feature);
}
```

---

## 🧪 Testing Checklist

Quando implementar nova feature premium, validar:

- [ ] **Free user vê bloqueio claro** (UI de bloqueio premium)
- [ ] **Premium user acessa normalmente** (feature funciona sem restrições)
- [ ] **Analytics tracking funciona** (eventos sendo enviados)
- [ ] **Remote Config override testado** (feature flag desabilita corretamente)
- [ ] **Mensagens usam PremiumDesignTokens** (padronização)
- [ ] **Navegação para /subscription funciona** (CTA funcional)
- [ ] **Estado premium reactivo** (atualiza quando subscription muda)

---

## 🎨 Design Patterns

### **Padrão 1: Verificação Reativa (RECOMENDADO)**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumNotifierProvider);
    final isPremium = premiumAsync.value?.isPremium ?? false;

    return isPremium ? _buildPremiumContent() : _buildFreeContent();
  }
}
```

**Vantagens**:
- ✅ Reativo (auto-update quando status premium muda)
- ✅ Centralizado via Riverpod
- ✅ Cache gerenciado automaticamente

---

### **Padrão 2: Premium Status em State**

```dart
@riverpod
class MyFeatureNotifier extends _$MyFeatureNotifier {
  @override
  Future<MyFeatureState> build() async {
    // Setup listener para mudanças de premium
    ref.listen(premiumNotifierProvider, (previous, next) {
      final isPremium = next.value?.isPremium ?? false;
      state = AsyncValue.data(
        state.value!.copyWith(isPremium: isPremium),
      );
    });

    return MyFeatureState(
      isPremium: ref.read(premiumNotifierProvider).value?.isPremium ?? false,
    );
  }
}

class MyFeatureState {
  final bool isPremium;
  // ... outros campos

  MyFeatureState({required this.isPremium});

  MyFeatureState copyWith({bool? isPremium}) {
    return MyFeatureState(
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
```

**Vantagens**:
- ✅ State imutável e testável
- ✅ Lifecycle gerenciado pelo notifier
- ✅ Performance otimizada (não rebuild desnecessário)

---

## 🔧 Utilities

### **PremiumDesignTokens**

Todas as constantes premium estão centralizadas em:
`lib/core/constants/premium_design_tokens.dart`

```dart
// Exemplo de uso
import 'package:app_receituagro/core/constants/premium_design_tokens.dart';

// Mensagens
final title = PremiumDesignTokens.featureTitles['comentarios'];
final message = PremiumDesignTokens.featureRequiredMessage;
final buttonText = PremiumDesignTokens.upgradeButtonText;

// Cores
final bgColor = PremiumDesignTokens.premiumCardBackground;
final iconColor = PremiumDesignTokens.premiumIconColor;

// Helpers
final decoration = PremiumDesignTokens.getPremiumCardDecoration();
final buttonStyle = PremiumDesignTokens.getUpgradeButtonStyle();
final icon = PremiumDesignTokens.getPremiumIcon();
```

---

## 📈 Analytics Events

Eventos premium padronizados:

| Evento | Quando Disparar | Parâmetros |
|--------|-----------------|------------|
| `premium_feature_attempted` | User free tenta acessar feature | `feature_name`, `user_type` |
| `premium_upgrade_clicked` | Clica em "Desbloquear Agora" | `feature_name`, `source` |
| `premium_preview_clicked` | Clica em preview de feature | `feature_name` |

---

## 🚨 Troubleshooting

### **Feature não desbloqueando após compra**

1. Verificar se `PremiumNotifier` está escutando stream:
   ```dart
   // premium_notifier.dart:108
   _subscriptionStreamSubscription = _subscriptionRepository.subscriptionStatus.listen(...)
   ```

2. Checar logs do PremiumNotifier:
   ```bash
   flutter logs | grep "PremiumNotifier"
   ```

3. Verificar RemoteConfig:
   ```dart
   final isEnabled = _remoteConfig.isFeatureEnabled(ReceitaAgroFeatureFlag.enablePremiumFeatures);
   ```

### **Analytics não trackando**

1. Importar analytics service:
   ```dart
   import '../../features/analytics/analytics_service.dart';
   ```

2. Usar provider correto:
   ```dart
   final analytics = ref.read(analyticsServiceProvider);
   ```

---

## 🔮 Future Improvements

### **Planejado**
- [ ] Limites configuráveis via RemoteConfig (max comments, max favorites)
- [ ] Previews de features premium (blur + teaser)
- [ ] Refatorar PremiumGuards para usar PremiumNotifier
- [ ] Widget PremiumFeatureWidget usado em todas features
- [ ] Sistema de trials (7 dias free)

### **Considerando**
- [ ] Planos multi-tier (Basic, Pro, Enterprise)
- [ ] Features premium por região
- [ ] A/B testing de pricing

---

## 📚 Referências

- **PremiumNotifier**: `lib/core/providers/premium_notifier.dart`
- **PremiumDesignTokens**: `lib/core/constants/premium_design_tokens.dart`
- **Comentários (Exemplo Completo)**: `lib/features/comentarios/comentarios_page.dart`
- **Favoritos (Exemplo Completo)**: `lib/features/favoritos/presentation/widgets/`

---

## 📞 Support

Dúvidas sobre implementação premium?
- Consulte exemplos em Comentários e Favoritos
- Revise PremiumDesignTokens para padrões visuais
- Use PremiumNotifier como fonte única de verdade para status premium

**Última Atualização**: 2025-10-17
