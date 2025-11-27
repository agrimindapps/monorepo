import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/premium_notifier.dart';
import '../widgets/premium_feature_tabs.dart';
import '../widgets/premium_header.dart';
import '../widgets/premium_pricing_section.dart';
import '../widgets/premium_status_section.dart';

/// Premium subscription page with animated entry.
class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumProvider);
    final bool isPremium = premiumAsync.when(
      data: (premiumState) => premiumState.isPremium,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              PremiumHeader(isPremium: isPremium),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PremiumStatusSection(isPremium: isPremium),
                      const SizedBox(height: 24),
                      PremiumFeatureTabs(tabController: _tabController),
                      const SizedBox(height: 16),
                      PremiumFeatureTabView(
                        tabController: _tabController,
                        isPremium: isPremium,
                      ),
                      const SizedBox(height: 24),
                      if (!isPremium) const PremiumPricingSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
