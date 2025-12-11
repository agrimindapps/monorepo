import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as local;
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../widgets/account_actions_section.dart';
import '../widgets/account_info_section.dart';
import '../widgets/data_sync_section.dart';
import '../widgets/device_management_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_subscription_section.dart';

class AccountProfilePage extends ConsumerStatefulWidget {
  const AccountProfilePage({super.key});

  @override
  ConsumerState<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends ConsumerState<AccountProfilePage>
    with LoadingPageMixin {
  @override
  Widget build(BuildContext context) {
    return BasePageScaffold(
      applyDefaultPadding: false,
      body: ResponsiveLayout(
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(local.authProvider);
                final isAnonymous = authState.value?.isAnonymous ?? true;
                return ProfileHeader(isAnonymous: isAnonymous);
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: ref
                    .watch(local.authProvider)
                    .when(
                      data: (authState) {
                        final isAnonymous = authState.isAnonymous;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AccountInfoSection(),

                            const SizedBox(height: 24),
                            
                            if (!isAnonymous) ...[
                              const ProfileSubscriptionSection(),
                              const SizedBox(height: 24),
                              const DeviceManagementSection(),
                              const SizedBox(height: 32),
                            ],
                            if (!isAnonymous) ...[
                              const DataSyncSection(),
                              const SizedBox(height: 32),
                            ],
                            const AccountActionsSection(),

                            const SizedBox(height: 100),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Erro ao carregar perfil: $error'),
                      ),
                    ),
              ), // SingleChildScrollView
            ), // Expanded
          ],
        ), // Column
      ), // ResponsiveLayout
    ); // Scaffold
  }
}
