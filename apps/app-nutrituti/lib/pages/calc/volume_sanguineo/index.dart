// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'controller/volume_sanguineo_controller.dart';
import 'handlers/message_handler.dart';
import 'services/message_service.dart';
import 'widgets/info_dialog.dart';
import 'widgets/input_form.dart';
import 'widgets/result_card.dart';

class VolumeSanguineoCalcPage extends StatelessWidget {
  const VolumeSanguineoCalcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        // Configura MessageService com SnackBarMessageHandler
        final messageHandler = SnackBarMessageHandler(context);
        final messageService = VolumeSanguineoMessageService(messageHandler);

        return VolumeSanguineoController(
          messageService: messageService,
        );
      },
      child: const _VolumeSanguineoView(),
    );
  }
}

class _VolumeSanguineoView extends StatelessWidget {
  const _VolumeSanguineoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Voltar',
      ),
      title: Row(
        children: [
          Icon(
            Icons.opacity_outlined,
            size: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.red.shade300
                : Colors.red,
          ),
          const SizedBox(width: 10),
          const Text('Volume Sanguíneo'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => VolumeSanguineoInfoDialog.show(context),
          tooltip: 'Informações sobre o Volume Sanguíneo',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: VolumeSanguineoInputForm(),
                ),
                SizedBox(height: 10),
                VolumeSanguineoResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
