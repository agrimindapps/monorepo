// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/services/subscription_config_service.dart';
import '../controllers/subscription_controller.dart';
import '../utils/subscription_constants.dart';
import '../utils/subscription_helpers.dart';
import 'widgets/subscription_benefits_widget.dart';
import 'widgets/subscription_header_widget.dart';
import 'widgets/subscription_pricing_widget.dart';
import 'widgets/subscription_restore_widget.dart';
import 'widgets/subscription_terms_widget.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late final SubscriptionController _controller;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionConfig();
    _controller = SubscriptionController();
    _controller.initialize();
  }

  void _initializeSubscriptionConfig() {
    try {
      // Inicializar configuração para o petiveti
      SubscriptionConfigService.initializeForApp('petiveti');
    } catch (e) {
      debugPrint('Erro ao inicializar configuração: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: _buildBody(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(SubscriptionConstants.appTitle),
      backgroundColor: SubscriptionConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    if (!_controller.isInitialized && _controller.isLoading) {
      return SubscriptionHelpers.buildLoadingIndicator(
        message: SubscriptionConstants.loadingMessage,
      );
    }

    if (_controller.hasError) {
      return SubscriptionHelpers.buildErrorWidget(
        _controller.errorMessage!,
        _controller.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: SubscriptionHelpers.getResponsivePadding(context),
        child: Center(
          child: SizedBox(
            width: SubscriptionHelpers.getResponsiveWidth(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubscriptionHeaderWidget(controller: _controller),
                const SizedBox(height: SubscriptionConstants.spacing),
                SubscriptionBenefitsWidget(controller: _controller),
                const SizedBox(height: SubscriptionConstants.spacing),
                SubscriptionPricingWidget(controller: _controller),
                const SizedBox(height: SubscriptionConstants.spacing),
                SubscriptionRestoreWidget(controller: _controller),
                const SizedBox(height: SubscriptionConstants.spacing),
                SubscriptionTermsWidget(controller: _controller),
                const SizedBox(height: SubscriptionConstants.largeSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
