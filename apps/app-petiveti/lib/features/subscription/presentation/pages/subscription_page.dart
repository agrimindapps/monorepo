import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../widgets/current_subscription_card.dart';
import '../widgets/subscription_empty_state.dart';
import '../widgets/subscription_feature_comparison.dart';
import '../widgets/subscription_loading_overlay.dart';
import '../widgets/subscription_page_coordinator.dart';
import '../widgets/subscription_page_header.dart';
import '../widgets/subscription_plan_card.dart';
import '../widgets/subscription_restore_button.dart';
import '../widgets/subscription_skeleton_loaders.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  final String userId;

  const SubscriptionPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    SubscriptionPageCoordinator.initializeData(ref, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return SubscriptionPageCoordinator(
      userId: widget.userId,
      bodyBuilder: (state) => _buildScaffold(state),
    );
  }

  Widget _buildScaffold(SubscriptionState state) {
    return Scaffold(
      appBar: _buildAppBar(state),
      body: Stack(
        children: [
          _buildBody(state),
          SubscriptionLoadingOverlay(state: state),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SubscriptionState state) {
    return AppBar(
      title: const Text('Assinaturas'),
      actions: [
        if (state.currentSubscription != null)
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => SubscriptionPageCoordinator.restorePurchases(
              ref, 
              context, 
              widget.userId,
            ),
            tooltip: 'Restaurar Compras',
          ),
      ],
    );
  }

  Widget _buildBody(SubscriptionState state) {
    return SingleChildScrollView(
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
          SubscriptionRestoreButton(
            userId: widget.userId,
            state: state,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCurrentSubscriptionSection(SubscriptionState state) {
    if (state.isLoadingCurrentSubscription) {
      return [
        SubscriptionSkeletonLoaders.buildCurrentSubscriptionSkeleton(),
        const SizedBox(height: 24),
      ];
    } else if (state.currentSubscription != null) {
      return [
        CurrentSubscriptionCard(
          subscription: state.currentSubscription!,
          userId: widget.userId,
          state: state,
        ),
        const SizedBox(height: 24),
      ];
    }
    return [];
  }

  List<Widget> _buildPlansSection(SubscriptionState state) {
    if (state.isLoadingPlans) {
      return [SubscriptionSkeletonLoaders.buildPlanCardsSkeleton()];
    } else if (state.availablePlans.isNotEmpty) {
      return state.availablePlans
          .where((p) => !p.isFree)
          .map((plan) => SubscriptionPlanCard(
                plan: plan,
                userId: widget.userId,
                state: state,
              ))
          .toList();
    } else if (!state.hasAnyLoading) {
      return [const SubscriptionEmptyState()];
    }
    return [];
  }
}