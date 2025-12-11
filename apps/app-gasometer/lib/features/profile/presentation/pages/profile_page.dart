import 'package:core/core.dart'
    show
        ConsumerStatefulWidget,
        ConsumerState,
        EnhancedAnalyticsService,
        GoRouterHelper;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../../data_export/presentation/widgets/export_data_section.dart';
import '../../domain/services/account_service.dart';
import '../../domain/services/profile_image_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/devices_section_widget.dart';
import '../widgets/profile_actions_section.dart';
import '../widgets/profile_combined_info_section.dart';
import '../widgets/profile_data_management_section.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_premium_section.dart';
import '../widgets/profile_settings_section.dart';
import '../widgets/profile_sync_section.dart';

// Providers for ProfileController dependencies
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountServiceImpl();
});

final profileImageServiceProvider = Provider<GasometerProfileImageService>((
  ref,
) {
  final analytics = ref.watch(analyticsRepositoryProvider);
  final crashlytics = ref.watch(crashlyticsRepositoryProvider);

  return GasometerProfileImageService(
    GasometerAnalyticsService(
      EnhancedAnalyticsService(analytics: analytics, crashlytics: crashlytics),
    ),
  );
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _scrollController = ScrollController();
  ProfileController? _profileController;

  ProfileController get profileController {
    return _profileController ??= ProfileController(
      ref.read(accountServiceProvider),
      ref.read(profileImageServiceProvider),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAnonymous = ref.watch(isAnonymousProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(isAnonymous: isAnonymous),
            Expanded(
              child: Semantics(
                label: 'Página de perfil do usuário',
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Padding(
                        padding: EdgeInsets.all(
                          GasometerDesignTokens.responsiveSpacing(context),
                        ),
                        child: _buildContent(
                          context,
                          user,
                          isAnonymous,
                          isPremium,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic user,
    bool isAnonymous,
    bool isPremium,
  ) {
    return Column(
      children: [
        ProfileCombinedInfoSection(
          user: user,
          isAnonymous: isAnonymous,
          profileController: profileController,
          onLoginTap: isAnonymous
              ? () {
                  context.go('/login');
                }
              : null,
        ),
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        const ProfilePremiumSection(),
        if (!isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const DevicesSectionWidget(),
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ProfileSyncSection(),
        ],
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        const ProfileSettingsSection(),
        if (!isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ExportDataSection(),
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ProfileDataManagementSection(),
        ],
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        ProfileActionsSection(isAnonymous: isAnonymous),
      ],
    );
  }
}
