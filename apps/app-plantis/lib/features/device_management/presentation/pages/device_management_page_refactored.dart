import 'package:core/core.dart' hide Column, DeviceManagementState;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/managers/device_dialog_manager.dart';
import '../../presentation/managers/device_feedback_builder.dart';
import '../../presentation/managers/device_menu_action_handler.dart';
import '../../presentation/managers/device_status_builder.dart';
import '../../presentation/providers/device_management_notifier.dart';
import '../widgets/device_list_widget.dart';
import '../widgets/device_statistics_widget.dart';

/// Página principal de gerenciamento de dispositivos
/// Interface principal para visualizar e gerenciar dispositivos no app-plantis
class DeviceManagementPage extends ConsumerStatefulWidget {
  const DeviceManagementPage({super.key});

  @override
  ConsumerState<DeviceManagementPage> createState() =>
      _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceManagementAsync = ref.watch(deviceManagementNotifierProvider);
    final dialogManager = DeviceDialogManager();
    final menuActionHandler = DeviceMenuActionHandler(
      ref: ref,
      dialogManager: dialogManager,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Dispositivos'),
        elevation: 0,
        actions: [
          if (deviceManagementAsync.hasValue)
            PopupMenuButton<String>(
              onSelected: (value) async =>
                  await menuActionHandler.handleMenuAction(
                    context,
                    value,
                    deviceManagementAsync.value!.activeDeviceCount,
                  ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Atualizar'),
                    dense: true,
                  ),
                ),
                if (deviceManagementAsync.value!.hasDevices == true &&
                    deviceManagementAsync.value!.activeDeviceCount > 1)
                  const PopupMenuItem(
                    value: 'revoke_all',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Revogar Outros Dispositivos'),
                      dense: true,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Ajuda'),
                    dense: true,
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Estatísticas'),
          ],
        ),
      ),
      body: deviceManagementAsync.when(
        data: (DeviceManagementState deviceState) => Column(
          children: [
            DeviceFeedbackBuilder.buildFeedbackMessages(deviceState, ref),
            DeviceStatusBuilder.buildGeneralStatus(deviceState, context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDevicesTab(deviceState),
                  _buildStatisticsTab(deviceState),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) =>
            Center(child: Text('Erro ao carregar: $error')),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildDevicesTab(DeviceManagementState deviceState) {
    return const DeviceListWidget();
  }

  Widget _buildStatisticsTab(DeviceManagementState deviceState) {
    return const DeviceStatisticsWidget();
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Add new device logic
      },
      tooltip: 'Adicionar Dispositivo',
      child: const Icon(Icons.add),
    );
  }
}
