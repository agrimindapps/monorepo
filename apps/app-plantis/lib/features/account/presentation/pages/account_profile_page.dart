import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as local;
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../widgets/account_actions_section.dart';
import '../widgets/account_details_section.dart';
import '../widgets/account_info_section.dart';
import '../widgets/data_sync_section.dart';
import '../widgets/device_management_section.dart';

class AccountProfilePage extends ConsumerStatefulWidget {
  const AccountProfilePage({super.key});

  @override
  ConsumerState<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends ConsumerState<AccountProfilePage>
    with LoadingPageMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BasePageScaffold(
      body: ResponsiveLayout(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: PlantisHeader(
                title: 'Perfil do Visitante',
                subtitle: 'Entre em sua conta para recursos completos',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
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
                            if (isAnonymous) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Conta Anônima',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Seus dados estão armazenados apenas neste dispositivo. Para maior segurança e sincronização entre dispositivos, recomendamos criar uma conta.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          context.push('/login');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.person_add,
                                          size: 18,
                                        ),
                                        label: const Text('Criar Conta'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (!isAnonymous) ...[
                              const AccountDetailsSection(),
                              const SizedBox(height: 24),
                            ],
                            if (!isAnonymous) ...[
                              const DeviceManagementSection(),
                              const SizedBox(height: 24),
                            ],
                            if (!isAnonymous) ...[
                              const DataSyncSection(),
                              const SizedBox(height: 24),
                            ],
                            const AccountActionsSection(),

                            const SizedBox(height: 40),
                          ],
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) => Center(
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
