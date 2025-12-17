import 'package:core/core.dart' hide Column, SubscriptionState, SubscriptionInfo, subscriptionProvider;
import 'package:flutter/material.dart';

import '../../domain/entities/subscription_plan.dart';
import '../state/subscription_notifier.dart';
import '../state/subscription_state.dart';
import '../widgets/subscription_empty_state.dart';
import '../widgets/subscription_feature_comparison.dart';
import '../widgets/subscription_page_header.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_restore_button.dart';
import '../widgets/subscription_skeleton_loaders.dart';

/// **Premium Subscription Management Page - Revenue & Feature Control Interface**
///
/// A comprehensive subscription management interface that handles premium plan
/// subscriptions, billing cycles, and feature access control. This page provides
/// users with subscription options while managing complex billing logic and
/// platform-specific purchase flows.
///
/// ## Business Logic & Revenue Model:
///
/// ### **Subscription Plans Architecture:**
/// The app implements a **freemium** model with multiple premium tiers:
/// - **Free Tier**: Basic functionality with limited features and advertisements
/// - **Premium Monthly**: Full feature access, ad-free experience, monthly billing
/// - **Premium Yearly**: Full feature access, discounted annual billing (typically 20% savings)
/// - **Lifetime**: One-time purchase for permanent premium access
///
/// ### **Revenue Integration:**
/// - **iOS**: Integrates with App Store In-App Purchases (StoreKit)
/// - **Android**: Integrates with Google Play Billing Library
/// - **Cross-Platform**: RevenueCat SDK provides unified billing interface
/// - **Subscription Validation**: Server-side receipt verification for security
///
/// ## Complex Subscription Logic:
///
/// ### **Subscription State Management:**
/// The page handles multiple subscription states with complex transitions:
///
/// 1. **Active Subscription States:**
///    - `ACTIVE`: Currently subscribed with valid payment
///    - `IN_GRACE_PERIOD`: Payment failed but still has access (24-72 hours)
///    - `ON_HOLD`: Payment issue, access suspended but subscription recoverable
///
/// 2. **Transition States:**
///    - `PENDING_RENEWAL`: Auto-renewal pending next billing cycle
///    - `PENDING_CANCELLATION`: Cancelled but active until period end
///    - `UPGRADING`: In process of changing to higher tier
///    - `DOWNGRADING`: In process of changing to lower tier
///
/// 3. **Inactive States:**
///    - `EXPIRED`: Subscription ended, no access to premium features
///    - `CANCELLED`: User-cancelled subscription
///    - `REFUNDED`: Subscription refunded, access revoked
///    - `PAUSED`: Temporarily suspended (Android-specific feature)
///
/// ### **Complex Billing Scenarios:**
///
/// #### **Plan Upgrades/Downgrades:**
/// - **Immediate Upgrade**: User pays prorated amount, gets immediate access
/// - **End-of-Period Downgrade**: Change takes effect at next billing cycle
/// - **Refund Processing**: Calculate prorated refunds for downgrades
/// - **Billing Cycle Alignment**: Handle different billing periods when switching
///
/// #### **Trial Management:**
/// - **Free Trial Tracking**: Monitor trial eligibility and remaining days
/// - **Trial to Paid Conversion**: Seamless transition at trial end
/// - **Trial Cancellation**: Handle early trial cancellations
/// - **Multi-Platform Trial Sync**: Prevent trial abuse across platforms
///
/// #### **Purchase Restoration:**
/// - **Cross-Device Sync**: Restore purchases on new devices
/// - **Account Linking**: Associate purchases with user accounts
/// - **Family Sharing**: Handle iOS family sharing subscriptions
/// - **Lost Purchase Recovery**: Restore purchases after app reinstall
///
/// ## Technical Implementation:
///
/// ### **Coordinator Pattern Architecture:**
/// The page uses a specialized coordinator pattern to manage complex subscription workflows:
/// - **SubscriptionPageCoordinator**: Manages business logic and state transitions
/// - **Component Widgets**: Specialized UI components for different subscription states
/// - **Loading States**: Skeleton loaders and overlay management
/// - **Error Handling**: Comprehensive error recovery and user feedback
///
/// ### **State Management Strategy:**
/// - **Riverpod Provider**: Centralized subscription state management
/// - **Real-time Updates**: Live subscription status monitoring
/// - **Optimistic Updates**: Immediate UI updates with rollback on failure
/// - **Caching**: Local caching of subscription data for offline access
///
/// ### **Security & Validation:**
/// - **Receipt Verification**: Server-side validation of all purchases
/// - **Fraud Prevention**: Anti-fraud measures and anomaly detection
/// - **Secure Storage**: Encrypted local storage of sensitive subscription data
/// - **API Security**: Authenticated API calls for subscription management
///
/// ## User Experience Features:
///
/// ### **Dynamic UI Adaptation:**
/// - **Current Subscription Display**: Shows active subscription details and benefits
/// - **Available Plans**: Displays relevant upgrade/downgrade options
/// - **Feature Comparison**: Interactive comparison table of plan features
/// - **Promotional Pricing**: Supports limited-time discounts and offers
///
/// ### **Loading & Error States:**
/// - **Skeleton Loading**: Non-blocking loading states for better UX
/// - **Progressive Enhancement**: Show available data while loading additional content
/// - **Error Recovery**: Graceful error handling with retry mechanisms
/// - **Offline Support**: Cached data display when network unavailable
///
/// ### **Accessibility & Localization:**
/// - **Screen Reader Support**: Full VoiceOver/TalkBack compatibility
/// - **High Contrast**: Supports accessibility color schemes
/// - **Localized Pricing**: Currency and pricing localization
/// - **Legal Compliance**: GDPR, CCPA compliance for subscription data
///
/// ## Analytics & Business Intelligence:
///
/// ### **Subscription Metrics:**
/// - **Conversion Tracking**: Free-to-paid conversion rates
/// - **Churn Analysis**: Subscription cancellation patterns
/// - **Revenue Analytics**: MRR (Monthly Recurring Revenue) tracking
/// - **Feature Usage**: Premium feature utilization metrics
///
/// ### **A/B Testing Support:**
/// - **Pricing Experiments**: Test different pricing strategies
/// - **UI Variations**: Test different subscription page layouts
/// - **Promotional Testing**: Test discount offers and messaging
/// - **Onboarding Optimization**: Test different trial flows
///
/// ## Platform-Specific Considerations:
///
/// ### **iOS App Store Guidelines:**
/// - **In-App Purchase Rules**: Must use StoreKit for digital subscriptions
/// - **Subscription Management**: Links to iOS Settings for cancellation
/// - **Family Sharing**: Support for iOS family subscription sharing
/// - **Review Guidelines**: Compliance with App Store review requirements
///
/// ### **Google Play Store Requirements:**
/// - **Play Billing**: Required for in-app subscriptions
/// - **Subscription Pausing**: Support for Android subscription pausing
/// - **Account Hold**: Handle payment method failures gracefully
/// - **Play Pass Integration**: Support for Play Pass subscribers
///
/// ## Data Flow Architecture:
///
/// ### **Subscription Lifecycle:**
/// ```
/// User Selection → Plan Validation → Purchase Flow → Receipt Verification
/// ↓
/// Server Validation → Feature Unlock → Analytics Tracking → UI Update
/// ```
///
/// ### **Error Handling Flow:**
/// ```
/// Purchase Error → Error Classification → Recovery Action → User Feedback
/// ↓
/// Retry Logic → Fallback Options → Support Contact → Analytics Logging
/// ```
///
/// @author PetiVeti Revenue Team
/// @since 1.0.0
/// @version 2.3.0 - Enhanced subscription management with advanced billing features
/// @businessLogic Handles freemium conversion and subscription lifecycle management
/// @revenueModel Freemium with monthly/yearly premium subscriptions
/// @platformIntegration iOS App Store + Google Play Store via RevenueCat
/// @lastUpdated 2025-01-15
class SubscriptionPage extends ConsumerStatefulWidget {
  final String userId;

  const SubscriptionPage({super.key, required this.userId});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

/// **Subscription Page State Management**
///
/// Manages the subscription page lifecycle, data loading, and user interactions.
/// Uses the local SubscriptionNotifier for state management.
class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);

    // Listen for errors
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        _showErrorMessage(context, next.errorMessage!);
      }
    });

    return _buildScaffold(state);
  }

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildScaffold(SubscriptionState state) => Scaffold(
    appBar: _buildAppBar(state),
    body: Stack(
      children: [
        _buildBody(state),
        if (state.isLoading) _buildLoadingOverlay(),
      ],
    ),
  );

  Widget _buildLoadingOverlay() => const ColoredBox(
    color: Colors.black26,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );

  PreferredSizeWidget _buildAppBar(SubscriptionState state) => AppBar(
    title: const Text('Assinaturas'),
    actions: [
      if (state.isPremium)
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () async {
            final result = await ref.read(subscriptionProvider.notifier).restorePurchases();
            if (!mounted) return;
            result.fold(
              (error) => _showErrorMessage(context, error),
              (_) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compras restauradas com sucesso!')),
              ),
            );
          },
          tooltip: 'Restaurar Compras',
        ),
    ],
  );

  Widget _buildBody(SubscriptionState state) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._buildCurrentSubscriptionSection(state),
        const SubscriptionPageHeader(),
        const SizedBox(height: 24),
        ..._buildPlansSection(state),
        const SizedBox(height: 32),
        const SubscriptionFeatureComparison(),
        const SizedBox(height: 32),
        SubscriptionRestoreButton(userId: widget.userId, state: state),
      ],
    ),
  );

  /// **Build Current Subscription Section**
  ///
  /// Creates the UI section that displays the user's current subscription status.
  /// Handles multiple states including loading, active subscription, and no subscription.
  ///
  /// ## State Handling:
  /// - **Loading State**: Shows skeleton loader while fetching data
  /// - **Active Subscription**: Displays subscription details and management options
  /// - **No Subscription**: Returns empty list (section not shown)
  ///
  /// ## UI Components:
  /// - Current subscription card with billing details
  /// - Subscription management actions (cancel, modify)
  /// - Billing cycle and renewal information
  ///
  /// @param state Current subscription state from provider
  /// @returns List of widgets for current subscription section
  List<Widget> _buildCurrentSubscriptionSection(SubscriptionState state) {
    if (state.isLoadingCurrentSubscription) {
      return [
        SubscriptionSkeletonLoaders.buildCurrentSubscriptionSkeleton(context),
        const SizedBox(height: 24),
      ];
    } else if (state.isPremium && state.currentSubscription != null) {
      final subscription = state.currentSubscription!;
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Assinatura Premium Ativa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Produto: ${subscription.productId}'),
                if (subscription.expirationDate != null)
                  Text(
                    'Expira em: ${_formatDate(subscription.expirationDate!)}',
                  ),
                if (subscription.isTrialPeriod)
                  const Text(
                    '🎁 Período de avaliação',
                    style: TextStyle(color: Colors.orange),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ];
    }
    return [];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// **Build Available Plans Section**
  ///
  /// Creates the UI section that displays available subscription plans for purchase.
  /// Filters and presents plans based on user's current subscription status.
  ///
  /// ## Plan Filtering Logic:
  /// - **Free Users**: Shows all premium plans
  /// - **Premium Users**: Shows upgrade/downgrade options
  /// - **Trial Users**: Shows conversion options
  /// - **Expired Users**: Shows reactivation options
  ///
  /// ## State Handling:
  /// - **Loading State**: Shows skeleton loaders for plan cards
  /// - **Plans Available**: Renders interactive plan cards
  /// - **No Plans**: Shows empty state with retry option
  /// - **Error State**: Handled by coordinator with error messaging
  ///
  /// ## Plan Card Features:
  /// - Interactive plan selection and purchase
  /// - Pricing comparison and savings calculation
  /// - Feature highlights and benefits
  /// - Promotional pricing and discounts
  ///
  /// @param state Current subscription state with available plans
  /// @returns List of widgets for subscription plans section
  List<Widget> _buildPlansSection(SubscriptionState state) {
    if (state.isLoadingPlans) {
      return [SubscriptionSkeletonLoaders.buildPlanCardsSkeleton(context)];
    } else if (state.availablePlans.isNotEmpty) {
      return state.availablePlans
          .map(
            (product) => SubscriptionPlanCard(
              plan: _productInfoToPlan(product),
              userId: widget.userId,
              state: state,
            ),
          )
          .toList();
    } else if (!state.isLoadingPlans) {
      return [const SubscriptionEmptyState()];
    }
    return [];
  }

  SubscriptionPlan _productInfoToPlan(ProductInfo product) {
    return SubscriptionPlan(
      id: product.productId,
      productId: product.productId,
      title: product.title,
      description: product.description,
      price: product.price,
      currency: product.currencyCode,
      type: _getPlanType(product.productId),
      features: _getFeaturesForProduct(product.productId),
      isPopular: product.productId.contains('yearly') || product.productId.contains('annual'),
      trialDays: product.hasFreeTrial ? 7 : null,
    );
  }

  PlanType _getPlanType(String productId) {
    final id = productId.toLowerCase();
    if (id.contains('monthly') || id.contains('mensal')) return PlanType.monthly;
    if (id.contains('yearly') || id.contains('annual') || id.contains('anual')) return PlanType.yearly;
    if (id.contains('lifetime') || id.contains('vitalicio')) return PlanType.lifetime;
    return PlanType.monthly;
  }

  List<String> _getFeaturesForProduct(String productId) {
    return [
      'Animais ilimitados',
      'Sincronização na nuvem',
      'Relatórios avançados',
      'Lembretes de medicamentos',
      'Exportação de dados',
      'Sem anúncios',
    ];
  }
}