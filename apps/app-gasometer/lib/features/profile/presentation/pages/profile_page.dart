import 'package:core/core.dart' show GetIt, ConsumerStatefulWidget, ConsumerState;
import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../../data_export/presentation/widgets/export_data_section.dart';
import '../../domain/services/account_service.dart';
import '../../domain/services/profile_image_service.dart';
import '../controllers/profile_controller.dart';
import '../widgets/devices_section_widget.dart';
import '../widgets/profile_account_info_section.dart';
import '../widgets/profile_actions_section.dart';
import '../widgets/profile_data_management_section.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_personal_info_section.dart';
import '../widgets/profile_settings_section.dart';
import '../widgets/profile_sync_section.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _scrollController = ScrollController();
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController(
      GetIt.instance<AccountService>(),
      GetIt.instance<GasometerProfileImageService>(),
    );
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
        ProfilePersonalInfoSection(
          user: user,
          isAnonymous: isAnonymous,
          isPremium: isPremium,
          profileController: _profileController,
        ),
        if (!isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const DevicesSectionWidget(),
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          ProfileAccountInfoSection(user: user, isPremium: isPremium),
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
