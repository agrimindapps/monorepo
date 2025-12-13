import 'package:core/core.dart' hide Column, AuthStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
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

class _AccountProfilePageState extends ConsumerState<AccountProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAnonymous = authState.user?.provider.name == 'anonymous';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(isAnonymous: isAnonymous),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: authState.status == AuthStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
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
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
